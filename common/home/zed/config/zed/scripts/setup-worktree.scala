#!/usr/bin/env -S scala-cli shebang
//> using scala 3.9.0
//> using jvm system
//> using dep io.getkyo::kyo-core:1.0.0-RC7
//> using dep io.getkyo::kyo-system:1.0.0-RC7

import kyo.*

def baseName(relativePath: String): String =
  val separatorIndex = relativePath.lastIndexOf('/')
  if separatorIndex < 0 then relativePath else relativePath.substring(separatorIndex + 1)

def isEnvFile(relativePath: String): Boolean =
  // Mirrors: grep -qE '(^|/)\.env([^/]*)$'
  baseName(relativePath).startsWith(".env")

val skippedSuffixes = Seq(".example", ".sample", ".template", ".dist")

def isSkippedTemplate(relativePath: String): Boolean =
  // Mirrors: *.example | *.sample | *.template | *.dist
  skippedSuffixes.exists(relativePath.endsWith)

def isCopyableEnvFile(relativePath: String): Boolean =
  // Mirrors: .env | */.env | .env.* | */.env.*
  val fileName = baseName(relativePath)
  fileName == ".env" || fileName.startsWith(".env.")

def hasShareableEnvFiles(relativePaths: Chunk[String]): Boolean =
  relativePaths.exists(relativePath => !isSkippedTemplate(relativePath) && isEnvFile(relativePath))

def resolve(root: Path, relativePath: String): Path =
  root / Path(relativePath)

def runWithInheritedIO(cmd: Command): Unit < (Async & Abort[CommandException | ExitCode]) =
  cmd.inheritIO.waitForSuccess

def installJavaScriptDependencies(root: Path): Unit < (Async & Abort[CommandException | ExitCode] & PathRead & Sync) =
  for
    hasBunBinaryLock <- (root / "bun.lockb").exists
    hasBunTextLock   <- (root / "bun.lock").exists
    hasPnpmLock      <- (root / "pnpm-lock.yaml").exists
    hasYarnLock      <- (root / "yarn.lock").exists
    _ <-
      if hasBunBinaryLock || hasBunTextLock then
        Sync.defer(println("→ Bun project")).andThen(
          runWithInheritedIO(Command("bun", "install", "--frozen-lockfile").cwd(root))
        )
      else if hasPnpmLock then
        Sync.defer(println("→ pnpm project")).andThen(
          runWithInheritedIO(Command("pnpm", "install", "--frozen-lockfile").cwd(root))
        )
      else if hasYarnLock then
        Sync.defer(println("→ Yarn project")).andThen(
          runWithInheritedIO(Command("yarn", "install", "--frozen-lockfile").cwd(root))
        )
      else
        (root / "package-lock.json").exists.map: hasPackageLock =>
          val installCommand =
            if hasPackageLock then Command("npm", "ci")
            else Command("npm", "install")
          val projectLabel =
            if hasPackageLock then "→ npm project"
            else "→ Node project (no lockfile)"
          Sync.defer(println(projectLabel)).andThen(
            runWithInheritedIO(installCommand.cwd(root))
          )
  yield ()

def resolveMillDependencies(root: Path): Unit < (Async & Abort[CommandException | ExitCode] & Sync) =
  Sync.defer(println("→ Mill project")).andThen(
    runWithInheritedIO(Command("mill", "resolve", "_").cwd(root))
  )

def listWorktrees(root: Path): Chunk[Path] < (Async & Abort[CommandException]) =
  Command("git", "worktree", "list", "--porcelain").cwd(root).text.map: output =>
    Chunk.from(
      output.linesIterator.collect:
        case line if line.startsWith("worktree ") =>
          Path(line.stripPrefix("worktree ").trim)
    )

def worktreeBranchName(root: Path): Maybe[String] =
  root.name

def gitRefExists(root: Path, ref: String): Boolean < (Async & Abort[CommandException]) =
  Command("git", "show-ref", "--verify", "--quiet", ref).cwd(root).textWithExitCode.map(_._2.isSuccess)

def isValidBranchName(root: Path, branch: String): Boolean < (Async & Abort[CommandException]) =
  Command("git", "check-ref-format", "--branch", branch).cwd(root).textWithExitCode.map(_._2.isSuccess)

def currentBranch(root: Path): String < (Async & Abort[CommandException]) =
  Command("git", "branch", "--show-current").cwd(root).textWithExitCode.map(_._1.trim)

def pullFastForward(root: Path): Unit < (Async & Abort[CommandException] & Sync) =
  Command("git", "pull", "--ff-only").cwd(root).textWithExitCode.map: (output, code) =>
    if code.isSuccess then println("→ Already up to date with remote")
    else
      val detail = output.trim
      if detail.nonEmpty then println(s"→ Pull skipped (no upstream or diverged): $detail")
      else println("→ Pull skipped (no upstream or diverged)")

def fetchOrigin(root: Path): Unit < (Async & Abort[CommandException] & Sync) =
  Command("git", "fetch", "origin").cwd(root).textWithExitCode.map: (output, code) =>
    if !code.isSuccess && output.trim.nonEmpty then println(s"→ Fetch warning: ${output.trim}")

def ensureBranchForWorktree(root: Path): Unit < (Async & Abort[CommandException | ExitCode] & Sync) =
  worktreeBranchName(root) match
    case Absent =>
      Sync.defer(println("→ Could not derive branch name from worktree path, skipping branch setup"))
    case Present(branch) if branch.isEmpty =>
      Sync.defer(println("→ Empty worktree name, skipping branch setup"))
    case Present(branch) =>
      for
        valid <- isValidBranchName(root, branch)
        _ <-
          if !valid then Sync.defer(println(s"→ Worktree name '$branch' is not a valid branch name, skipping branch setup"))
          else
            for
              current     <- currentBranch(root)
              _           <- Sync.defer(println(s"→ Ensuring branch '$branch' for worktree"))
              _           <- fetchOrigin(root)
              localExists <- gitRefExists(root, s"refs/heads/$branch")
              remoteExists <-
                if localExists then Sync.defer(false)
                else gitRefExists(root, s"refs/remotes/origin/$branch")
              _ <-
                if current == branch then
                  Sync.defer(println(s"→ Already on branch '$branch', pulling latest")).andThen(pullFastForward(root))
                else if localExists then
                  Sync.defer(println(s"→ Checking out existing local branch '$branch'")).andThen(
                    runWithInheritedIO(Command("git", "checkout", branch).cwd(root))
                  ).andThen(pullFastForward(root))
                else if remoteExists then
                  Sync.defer(println(s"→ Checking out remote branch 'origin/$branch'")).andThen(
                    runWithInheritedIO(Command("git", "checkout", "--track", s"origin/$branch").cwd(root))
                  ).andThen(pullFastForward(root))
                else
                  Sync.defer(println(s"→ Creating new local branch '$branch'")).andThen(
                    runWithInheritedIO(Command("git", "checkout", "-b", branch).cwd(root))
                  )
            yield ()
      yield ()

def ignoredFiles(candidate: Path, root: Path): Chunk[String] < Async =
  // `2>/dev/null` equivalent: never fail, treat launch errors as empty.
  // textWithExitCode never aborts on ExitCode, only on CommandException.
  Abort.recover[CommandException](_ => "")(
    Command(
      "git",
      "-C",
      candidate.toString,
      "ls-files",
      "--others",
      "--ignored",
      "--exclude-standard"
    ).cwd(root).textWithExitCode.map(_._1)
  ).map(output => Chunk.from(output.linesIterator.filter(_.nonEmpty)))

def findSiblingWorktreeHoldingEnvFiles(
    root: Path
): Maybe[Path] < (Async & Abort[CommandException]) =
  def loop(remaining: Chunk[Path]): Maybe[Path] < (Async & Abort[CommandException]) =
    if remaining.isEmpty then Absent
    else if remaining.head == root then loop(remaining.tail)
    else
      val candidate = remaining.head
      val others    = remaining.tail
      ignoredFiles(candidate, root).map: relativePaths =>
        if hasShareableEnvFiles(relativePaths) then Present(candidate)
        else loop(others)
  listWorktrees(root).flatMap(loop)

def copyEnvFilesFromSiblingWorktree(
    root: Path
): Unit < (Async & PathRead & PathWrite & Sync & Abort[CommandException | FileSystemException]) =
  findSiblingWorktreeHoldingEnvFiles(root).flatMap:
    case Absent =>
      Sync.defer(println("→ No .env files found in sibling worktrees, skipping"))
    case Present(sibling) =>
      Sync.defer(println(s"→ Copying .env files from $sibling")).andThen(
        ignoredFiles(sibling, root).flatMap: relativePaths =>
          Kyo.foreachDiscard(relativePaths): relativePath =>
            val isWantedEnvFile = !isSkippedTemplate(relativePath) && isCopyableEnvFile(relativePath)
            if !isWantedEnvFile then ()
            else
              val destination = resolve(root, relativePath)
              // copy creates parent directories by default (createFolders = true)
              Kyo.unless(destination.exists)(
                resolve(sibling, relativePath).copy(destination).andThen(
                  Sync.defer(println(s"  + $relativePath"))
                )
              ).unit
      )

object SetupWorktree extends KyoApp:
  run {
    Path.run {
      for
        topLevelOutput <- Command("git", "rev-parse", "--show-toplevel").text
        root            = Path(topLevelOutput.trim)
        _              <- Sync.defer(println(s"Setting up dependencies for: $root"))
        _              <- ensureBranchForWorktree(root)
        hasPackageJson <- (root / "package.json").exists
        _              <- Kyo.when(hasPackageJson)(installJavaScriptDependencies(root)).unit
        hasMillBuild   <- (root / "build.sc").exists
        _              <- Kyo.when(hasMillBuild)(resolveMillDependencies(root)).unit
        _              <- copyEnvFilesFromSiblingWorktree(root)
        _              <- Sync.defer(println("Done."))
      yield ()
    }
  }
end SetupWorktree
