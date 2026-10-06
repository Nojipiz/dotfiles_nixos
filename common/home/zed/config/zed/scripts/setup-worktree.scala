#!/usr/bin/env -S scala-cli shebang
//> using scala 3.9.0
//> using jvm system
//> using dep io.getkyo::kyo-core:1.0.0-RC7
//> using dep io.getkyo::kyo-system:1.0.0-RC7

import kyo.*

object Console:
  private val cyan  = "\u001b[36m"
  private val green = "\u001b[32m"
  private val dim   = "\u001b[2m"
  private val reset = "\u001b[0m"

  def printStep(message: String): Unit < Sync = Sync.defer(println(s"$cyan→ $message$reset"))
  def printDone(message: String): Unit < Sync = Sync.defer(println(s"$green✔ $message$reset"))
  def printSkip(message: String): Unit < Sync = Sync.defer(println(s"$dim○ $message$reset"))
  def printAddedFile(relativePath: String): Unit < Sync = Sync.defer(println(s"  $green+ $relativePath$reset"))
  def printAlreadyUpToDate: Unit < Sync = Sync.defer(println(s"$green✔ Already up to date with remote$reset"))
  def printPullSkipped(detail: String): Unit < Sync =
    if detail.nonEmpty then Sync.defer(println(s"$dim○ Pull skipped (no upstream or diverged): $detail$reset"))
    else Sync.defer(println(s"$dim○ Pull skipped (no upstream or diverged)$reset"))
  def printFetchWarning(detail: String): Unit < Sync =
    Sync.defer(println(s"$dim○ Fetch warning: $detail$reset"))
end Console

object FilePaths:
  def extractFileNameFromRelativePath(relativePath: String): String =
    val separatorIndex = relativePath.lastIndexOf('/')
    if separatorIndex < 0 then relativePath else relativePath.substring(separatorIndex + 1)

  def isSkippedTemplateFile(relativePath: String): Boolean =
    val skippedTemplateSuffixes = Seq(".example", ".sample", ".template", ".dist")
    skippedTemplateSuffixes.exists(relativePath.endsWith)
end FilePaths

object Git:
  def isGitReferencePresent(root: Path, reference: String): Boolean < (Async & Abort[CommandException]) =
    Command("git", "show-ref", "--verify", "--quiet", reference).cwd(root).textWithExitCode.map(_._2.isSuccess)

  def pullWithFastForwardOnly(root: Path): Unit < (Async & Abort[CommandException] & Sync) =
    Command("git", "pull", "--ff-only").cwd(root).textWithExitCode.map: (output, code) =>
      if code.isSuccess then Console.printAlreadyUpToDate
      else Console.printPullSkipped(output.trim)

  def findIgnoredFiles(candidateWorktree: Path, repositoryRoot: Path): Chunk[String] < Async =
    Abort.recover[CommandException](_ => "")(
      Command(
        "git",
        "-C",
        candidateWorktree.toString,
        "ls-files",
        "--others",
        "--ignored",
        "--exclude-standard"
      ).cwd(repositoryRoot).textWithExitCode.map(_._1)
    ).map(output => Chunk.from(output.linesIterator.filter(_.nonEmpty)))

  def ensureBranchExistsForWorktree(repositoryRoot: Path): Unit < (Async & Abort[CommandException | ExitCode] & Sync) =
    def _isBranchNameValid(branchName: String): Boolean < (Async & Abort[CommandException]) =
      Command("git", "check-ref-format", "--branch", branchName).cwd(repositoryRoot).textWithExitCode.map(_._2.isSuccess)

    def _fetchCurrentBranchName: String < (Async & Abort[CommandException]) =
      Command("git", "branch", "--show-current").cwd(repositoryRoot).textWithExitCode.map(_._1.trim)

    def _fetchOriginRemote: Unit < (Async & Abort[CommandException] & Sync) =
      Command("git", "fetch", "origin").cwd(repositoryRoot).textWithExitCode.map: (output, code) =>
        if !code.isSuccess && output.trim.nonEmpty then Console.printFetchWarning(output.trim)

    repositoryRoot.name match
      case Absent =>
        Console.printSkip("Could not derive branch name from worktree path, skipping branch setup")
      case Present(branchName) if branchName.isEmpty =>
        Console.printSkip("Empty worktree name, skipping branch setup")
      case Present(branchName) =>
        for
          isValid <- _isBranchNameValid(branchName)
          _ <-
            if !isValid then Console.printSkip(s"Worktree name '$branchName' is not a valid branch name, skipping branch setup")
            else
              for
                currentBranchName <- _fetchCurrentBranchName
                _                 <- Console.printStep(s"Ensuring branch '$branchName' for worktree")
                _                 <- _fetchOriginRemote
                localBranchExists <- isGitReferencePresent(repositoryRoot, s"refs/heads/$branchName")
                remoteBranchExists <-
                  if localBranchExists then Sync.defer(false)
                  else isGitReferencePresent(repositoryRoot, s"refs/remotes/origin/$branchName")
                _ <-
                  if currentBranchName == branchName then
                    Console.printStep(s"Already on branch '$branchName', pulling latest").andThen(pullWithFastForwardOnly(repositoryRoot))
                  else if localBranchExists then
                    Console.printStep(s"Checking out existing local branch '$branchName'").andThen(
                      Command("git", "checkout", branchName).cwd(repositoryRoot).inheritIO.waitForSuccess
                    ).andThen(pullWithFastForwardOnly(repositoryRoot)).andThen(Console.printDone(s"Branch '$branchName' ready"))
                  else if remoteBranchExists then
                    Console.printStep(s"Checking out remote branch 'origin/$branchName'").andThen(
                      Command("git", "checkout", "--track", s"origin/$branchName").cwd(repositoryRoot).inheritIO.waitForSuccess
                    ).andThen(pullWithFastForwardOnly(repositoryRoot)).andThen(Console.printDone(s"Branch '$branchName' ready"))
                  else
                    Console.printStep(s"Creating new local branch '$branchName'").andThen(
                      Command("git", "checkout", "-b", branchName).cwd(repositoryRoot).inheritIO.waitForSuccess
                    ).andThen(Console.printDone(s"Branch '$branchName' created"))
              yield ()
        yield ()
end Git

object Dependencies:
  def installJavaScriptDependencies(repositoryRoot: Path): Unit < (Async & Abort[CommandException | ExitCode] & PathRead & Sync) =
    for
      hasBunBinaryLockFile <- (repositoryRoot / "bun.lockb").exists
      hasBunTextLockFile   <- (repositoryRoot / "bun.lock").exists
      hasPnpmLockFile      <- (repositoryRoot / "pnpm-lock.yaml").exists
      hasYarnLockFile      <- (repositoryRoot / "yarn.lock").exists
      _ <-
        if hasBunBinaryLockFile || hasBunTextLockFile then
          Console.printStep("Bun project").andThen(
            Command("bun", "install", "--frozen-lockfile").cwd(repositoryRoot).inheritIO.waitForSuccess
          ).andThen(Console.printDone("Bun install complete"))
        else if hasPnpmLockFile then
          Console.printStep("pnpm project").andThen(
            Command("pnpm", "install", "--frozen-lockfile").cwd(repositoryRoot).inheritIO.waitForSuccess
          ).andThen(Console.printDone("pnpm install complete"))
        else if hasYarnLockFile then
          Console.printStep("Yarn project").andThen(
            Command("yarn", "install", "--frozen-lockfile").cwd(repositoryRoot).inheritIO.waitForSuccess
          ).andThen(Console.printDone("Yarn install complete"))
        else
          (repositoryRoot / "package-lock.json").exists.map: hasPackageLockFile =>
            val installCommand =
              if hasPackageLockFile then Command("npm", "ci")
              else Command("npm", "install")
            val projectLabel =
              if hasPackageLockFile then "npm project"
              else "Node project (no lockfile)"
            val completionLabel =
              if hasPackageLockFile then "npm ci complete"
              else "npm install complete"
            Console.printStep(projectLabel).andThen(
              installCommand.cwd(repositoryRoot).inheritIO.waitForSuccess
            ).andThen(Console.printDone(completionLabel))
    yield ()

  def resolveMillDependencies(repositoryRoot: Path): Unit < (Async & Abort[CommandException | ExitCode] & Sync) =
    Console.printStep("Mill project").andThen(
      Command("mill", "resolve", "_").cwd(repositoryRoot).inheritIO.waitForSuccess
    ).andThen(Console.printDone("Mill resolve complete"))
end Dependencies

object EnvironmentFiles:
  def copyEnvironmentFilesFromSiblingWorktree(
      repositoryRoot: Path
  ): Unit < (Async & PathRead & PathWrite & Sync & Abort[CommandException | FileSystemException]) =
    def _isEnvironmentFileCopyable(relativePath: String): Boolean =
      val fileName = FilePaths.extractFileNameFromRelativePath(relativePath)
      fileName == ".env" || fileName.startsWith(".env.")

    def _hasShareableEnvironmentFiles(relativePaths: Chunk[String]): Boolean =
      def _isEnvironmentFile(relativePath: String): Boolean =
        FilePaths.extractFileNameFromRelativePath(relativePath).startsWith(".env")
      relativePaths.exists(relativePath => !FilePaths.isSkippedTemplateFile(relativePath) && _isEnvironmentFile(relativePath))

    def _listAllWorktrees: Chunk[Path] < (Async & Abort[CommandException]) =
      Command("git", "worktree", "list", "--porcelain").cwd(repositoryRoot).text.map: output =>
        Chunk.from(
          output.linesIterator.collect:
            case line if line.startsWith("worktree ") =>
              Path(line.stripPrefix("worktree ").trim)
        )

    def _findSiblingWorktreeContainingEnvironmentFiles: Maybe[Path] < (Async & Abort[CommandException]) =
      def _searchRemainingWorktrees(remainingWorktrees: Chunk[Path]): Maybe[Path] < (Async & Abort[CommandException]) =
        if remainingWorktrees.isEmpty then Absent
        else if remainingWorktrees.head == repositoryRoot then _searchRemainingWorktrees(remainingWorktrees.tail)
        else
          val candidateWorktree = remainingWorktrees.head
          val otherWorktrees    = remainingWorktrees.tail
          Git.findIgnoredFiles(candidateWorktree, repositoryRoot).map: relativePaths =>
            if _hasShareableEnvironmentFiles(relativePaths) then Present(candidateWorktree)
            else _searchRemainingWorktrees(otherWorktrees)
      _listAllWorktrees.flatMap(_searchRemainingWorktrees)

    _findSiblingWorktreeContainingEnvironmentFiles.flatMap:
      case Absent =>
        Console.printSkip("No .env files found in sibling worktrees, skipping")
      case Present(siblingWorktree) =>
        Console.printStep(s"Copying .env files from $siblingWorktree").andThen(
          Git.findIgnoredFiles(siblingWorktree, repositoryRoot).flatMap: relativePaths =>
            Kyo.foreachDiscard(relativePaths): relativePath =>
              val isWantedEnvironmentFile = !FilePaths.isSkippedTemplateFile(relativePath) && _isEnvironmentFileCopyable(relativePath)
              if !isWantedEnvironmentFile then ()
              else
                val destinationPath = repositoryRoot / Path(relativePath)
                Kyo.unless(destinationPath.exists)(
                  (siblingWorktree / Path(relativePath)).copy(destinationPath).andThen(
                    Console.printAddedFile(relativePath)
                  )
                ).unit
        ).andThen(Console.printDone("Env files copied"))
end EnvironmentFiles

object SetupWorktree extends KyoApp:
  run {
    Path.run {
      for
        repositoryTopLevel <- Command("git", "rev-parse", "--show-toplevel").text
        repositoryRoot      = Path(repositoryTopLevel.trim)
        _                  <- Console.printStep(s"Setting up dependencies for: $repositoryRoot")
        _                  <- Git.ensureBranchExistsForWorktree(repositoryRoot).andThen(Console.printDone("Branch setup complete"))
        hasPackageJsonFile <- (repositoryRoot / "package.json").exists
        _                  <- Kyo.when(hasPackageJsonFile)(Dependencies.installJavaScriptDependencies(repositoryRoot)).unit
        hasMillBuildFile   <- (repositoryRoot / "build.sc").exists
        _                  <- Kyo.when(hasMillBuildFile)(Dependencies.resolveMillDependencies(repositoryRoot)).unit
        _                  <- EnvironmentFiles.copyEnvironmentFilesFromSiblingWorktree(repositoryRoot)
        _                  <- Console.printDone("Done.")
      yield ()
    }
  }
end SetupWorktree
