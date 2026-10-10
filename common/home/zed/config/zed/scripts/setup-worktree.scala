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

  def printBuildTool(tool: String): Unit < Sync = Sync.defer(println(s"$cyan→ Build tool: $tool$reset"))
  def printEnvFiles(files: Chunk[String]): Unit < Sync = Sync.defer {
    if files.isEmpty then println(s"$dim○ Env files: none$reset")
    else println(s"$green+ Env files: ${files.mkString(", ")}$reset")
  }
  def printInstall(command: String): Unit < Sync = Sync.defer(println(s"$cyan→ Install: $command$reset"))
  def printDone(): Unit < Sync = Sync.defer(println(s"$green✔ Done$reset"))
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

  def pullWithFastForwardOnly(root: Path): Unit < (Async & Abort[CommandException | ExitCode] & Sync) =
    Command("git", "pull", "--ff-only").cwd(root).textWithExitCode.map((_, _) => ())

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
    def _extractWorktreeBranchName(worktreeRoot: Path): Maybe[String] =
      worktreeRoot.name match
        case Present(leaf) if leaf == "nix-config" =>
          worktreeRoot.parent.flatMap(_.name) match
            case Present(parentName) if parentName.nonEmpty => Present(parentName)
            case _                                           => Present(leaf)
        case other => other

    def _isBranchNameValid(branchName: String): Boolean < (Async & Abort[CommandException]) =
      Command("git", "check-ref-format", "--branch", branchName).cwd(repositoryRoot).textWithExitCode.map(_._2.isSuccess)

    def _fetchCurrentBranchName: String < (Async & Abort[CommandException]) =
      Command("git", "branch", "--show-current").cwd(repositoryRoot).textWithExitCode.map(_._1.trim)

    def _fetchOriginRemote: Unit < (Async & Abort[CommandException] & Sync) =
      Command("git", "fetch", "origin").cwd(repositoryRoot).textWithExitCode.map((_, _) => ())

    def _hasUpstreamBranch: Boolean < (Async & Abort[CommandException]) =
      Command("git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}").cwd(repositoryRoot).textWithExitCode.map(_._2.isSuccess)

    def _pullWhenUpstreamExists: Unit < (Async & Abort[CommandException | ExitCode] & Sync) =
      _hasUpstreamBranch.flatMap: hasUpstream =>
        Kyo.when(hasUpstream)(pullWithFastForwardOnly(repositoryRoot))

    def _checkoutInferredBranch(branchName: String): Unit < (Async & Abort[CommandException | ExitCode] & Sync) =
      for
        isValid <- _isBranchNameValid(branchName)
        _ <- Kyo.when(isValid) {
          for
            _                 <- _fetchOriginRemote
            localBranchExists <- isGitReferencePresent(repositoryRoot, s"refs/heads/$branchName")
            remoteBranchExists <-
              if localBranchExists then Sync.defer(false)
              else isGitReferencePresent(repositoryRoot, s"refs/remotes/origin/$branchName")
            _ <-
              if localBranchExists then
                Command("git", "checkout", branchName).cwd(repositoryRoot).inheritIO.waitForSuccess
                  .andThen(_pullWhenUpstreamExists)
              else if remoteBranchExists then
                Command("git", "checkout", "--track", s"origin/$branchName").cwd(repositoryRoot).inheritIO.waitForSuccess
                  .andThen(_pullWhenUpstreamExists)
              else Command("git", "checkout", "-b", branchName).cwd(repositoryRoot).inheritIO.waitForSuccess
          yield ()
        }
      yield ()

    // Trust git over the directory name: Zed already checks out the right
    // branch, and the worktree dir is often just the project name (e.g.
    // .../Macaws). Only fall back to inferring from the path on detached HEAD.
    // Note: the two steps are separate generators (not if/else) so neither
    // RHS is a `Unit | Unit < ...` union, which has no flatMap.
    for
      currentBranchName <- _fetchCurrentBranchName
      isAttached = currentBranchName.nonEmpty && currentBranchName != "HEAD"
      _ <- Kyo.when(isAttached) {
        for
          _ <- _fetchOriginRemote
          _ <- _pullWhenUpstreamExists
        yield ()
      }
      _ <- Kyo.unless(isAttached) {
        _extractWorktreeBranchName(repositoryRoot) match
          case Absent                                    => ()
          case Present(branchName) if branchName.isEmpty => ()
          case Present(branchName)                       => _checkoutInferredBranch(branchName)
      }
    yield ()
end Git

object Dependencies:
  def installAllProjectDependenciesIfPresent(repositoryRoot: Path): Unit < (Async & Abort[CommandException | ExitCode] & PathRead & Sync) =
    for
      hasPackageJsonFile <- (repositoryRoot / "package.json").exists
      hasMillBuildFile   <- (repositoryRoot / "build.sc").exists
      hasSbtBuildFile    <- (repositoryRoot / "build.sbt").exists
      hasPackageJson     = hasPackageJsonFile
      _ <- Kyo.when(hasPackageJson)(installJavaScriptDependencies(repositoryRoot)).unit
      _ <- Kyo.when(hasMillBuildFile)(resolveMillDependencies(repositoryRoot)).unit
      _ <- Kyo.when(hasSbtBuildFile)(resolveSbtDependencies(repositoryRoot)).unit
      _ <- Kyo.when(!hasPackageJson && !hasMillBuildFile && !hasSbtBuildFile)(Console.printBuildTool("none")).unit
    yield ()

  def installJavaScriptDependencies(repositoryRoot: Path): Unit < (Async & Abort[CommandException | ExitCode] & PathRead & Sync) =
    for
      hasBunBinaryLockFile <- (repositoryRoot / "bun.lockb").exists
      hasBunTextLockFile   <- (repositoryRoot / "bun.lock").exists
      hasPnpmLockFile      <- (repositoryRoot / "pnpm-lock.yaml").exists
      hasYarnLockFile      <- (repositoryRoot / "yarn.lock").exists
      hasPackageLockFile   <- (repositoryRoot / "package-lock.json").exists
      _ <-
        if hasBunBinaryLockFile || hasBunTextLockFile then
          Console.printBuildTool("bun")
            .andThen(Console.printInstall("bun install --frozen-lockfile"))
            .andThen(Command("bun", "install", "--frozen-lockfile").cwd(repositoryRoot).inheritIO.waitForSuccess)
        else if hasPnpmLockFile then
          Console.printBuildTool("pnpm")
            .andThen(Console.printInstall("pnpm install --frozen-lockfile"))
            .andThen(Command("pnpm", "install", "--frozen-lockfile").cwd(repositoryRoot).inheritIO.waitForSuccess)
        else if hasYarnLockFile then
          Console.printBuildTool("yarn")
            .andThen(Console.printInstall("yarn install --frozen-lockfile"))
            .andThen(Command("yarn", "install", "--frozen-lockfile").cwd(repositoryRoot).inheritIO.waitForSuccess)
        else
          val installCommand =
            if hasPackageLockFile then "npm ci"
            else "npm install"
          val installEffect =
            if hasPackageLockFile then Command("npm", "ci")
            else Command("npm", "install")
          Console.printBuildTool("npm")
            .andThen(Console.printInstall(installCommand))
            .andThen(installEffect.cwd(repositoryRoot).inheritIO.waitForSuccess)
    yield ()

  def resolveMillDependencies(repositoryRoot: Path): Unit < (Async & Abort[CommandException | ExitCode] & Sync) =
    Console.printBuildTool("mill")
      .andThen(Console.printInstall("mill resolve _"))
      .andThen(Command("mill", "resolve", "_").cwd(repositoryRoot).inheritIO.waitForSuccess)

  def resolveSbtDependencies(repositoryRoot: Path): Unit < (Async & Abort[CommandException | ExitCode] & Sync) =
    Console.printBuildTool("sbt")
      .andThen(Console.printInstall("sbt update"))
      .andThen(Command("sbt", "update").cwd(repositoryRoot).inheritIO.waitForSuccess)
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
          Git.findIgnoredFiles(candidateWorktree, repositoryRoot).flatMap: relativePaths =>
            if _hasShareableEnvironmentFiles(relativePaths) then Present(candidateWorktree)
            else _searchRemainingWorktrees(otherWorktrees)
      _listAllWorktrees.flatMap(_searchRemainingWorktrees)

    _findSiblingWorktreeContainingEnvironmentFiles.flatMap:
      case Absent =>
        Console.printEnvFiles(Chunk.empty)
      case Present(siblingWorktree) =>
        Git.findIgnoredFiles(siblingWorktree, repositoryRoot).flatMap: relativePaths =>
          val wanted = relativePaths.filter(rp => !FilePaths.isSkippedTemplateFile(rp) && _isEnvironmentFileCopyable(rp))
          Console.printEnvFiles(wanted).andThen(
            Kyo.foreachDiscard(relativePaths): relativePath =>
              val isWantedEnvironmentFile = !FilePaths.isSkippedTemplateFile(relativePath) && _isEnvironmentFileCopyable(relativePath)
              if !isWantedEnvironmentFile then ()
              else
                val destinationPath = repositoryRoot / Path(relativePath)
                Kyo.unless(destinationPath.exists)(
                  (siblingWorktree / Path(relativePath)).copy(destinationPath)
                ).unit
          )
end EnvironmentFiles

object SetupWorktree extends KyoApp:
  run {
    Path.run {
      for
        repositoryRoot <- Command("git", "rev-parse", "--show-toplevel").text.map(repositoryTopLevel => Path(repositoryTopLevel.trim))
        _              <- EnvironmentFiles.copyEnvironmentFilesFromSiblingWorktree(repositoryRoot)
        _              <- Git.ensureBranchExistsForWorktree(repositoryRoot)
        _              <- Dependencies.installAllProjectDependenciesIfPresent(repositoryRoot)
        _              <- Console.printDone()
      yield ()
    }
  }
end SetupWorktree
