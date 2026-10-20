#!/usr/bin/env -S scala-cli shebang
//> using scala 3.9.0
//> using jvm system
//> using dep com.lihaoyi::os-lib:0.11.9-M8

object Console:
  private val cyan  = "\u001b[36m"
  private val green = "\u001b[32m"
  private val dim   = "\u001b[2m"
  private val reset = "\u001b[0m"

  def printBuildTool(tool: String): Unit = println(s"$cyan→ Build tool: $tool$reset")
  def printEnvFiles(files: Seq[String]): Unit =
    if files.isEmpty then println(s"$dim○ Env files: none$reset")
    else println(s"$green+ Env files: ${files.mkString(", ")}$reset")
  def printInstall(command: String): Unit = println(s"$cyan→ Install: $command$reset")
  def printDone(): Unit = println(s"$green✔ Done$reset")
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
  def runGit(root: os.Path, args: String*): os.CommandResult =
    os.call(cmd = Seq("git") ++ args, cwd = root, check = false)

  def checkGitSuccess(result: os.CommandResult, action: String): Unit =
    if result.exitCode != 0 then sys.error(s"$action failed: ${result.err.text().trim}")

  def runInherited(root: os.Path, args: String*): Unit =
    val result = os.call(cmd = args.toSeq, cwd = root, stdout = os.Inherit, stderr = os.Inherit, check = false)
    if result.exitCode != 0 then sys.error(s"${args.mkString(" ")} failed with exit ${result.exitCode}")

  def isGitReferencePresent(root: os.Path, reference: String): Boolean =
    runGit(root, "show-ref", "--verify", "--quiet", reference).exitCode == 0

  def pullWithFastForwardOnly(root: os.Path): Unit =
    val result = runGit(root, "pull", "--ff-only")
    checkGitSuccess(result, "git pull --ff-only")

  def findIgnoredFiles(candidateWorktree: os.Path, repositoryRoot: os.Path): List[String] =
    val result = os.call(
      cmd = Seq("git", "-C", candidateWorktree.toString, "ls-files", "--others", "--ignored", "--exclude-standard"),
      cwd = repositoryRoot,
      check = false
    )
    checkGitSuccess(result, "git ls-files")
    result.out.text().linesIterator.filter(_.nonEmpty).toList

  def ensureBranchExistsForWorktree(repositoryRoot: os.Path): Unit =
    def _extractWorktreeBranchName(worktreeRoot: os.Path): Option[String] =
      val leaf = worktreeRoot.last
      if leaf != "nix-config" then Some(leaf)
      else
        val parentName = (worktreeRoot / os.up).last
        if parentName.nonEmpty then Some(parentName) else Some(leaf)

    def _isBranchNameValid(branchName: String): Boolean =
      runGit(repositoryRoot, "check-ref-format", "--branch", branchName).exitCode == 0

    def _fetchCurrentBranchName: String =
      val result = runGit(repositoryRoot, "branch", "--show-current")
      checkGitSuccess(result, "git branch --show-current")
      result.out.text().trim

    def _fetchOriginRemote: Unit =
      val result = runGit(repositoryRoot, "fetch", "origin")
      checkGitSuccess(result, "git fetch origin")

    def _hasUpstreamBranch: Boolean =
      runGit(repositoryRoot, "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}").exitCode == 0

    def _pullWhenUpstreamExists: Unit =
      if _hasUpstreamBranch then pullWithFastForwardOnly(repositoryRoot)

    def _checkoutInferredBranch(branchName: String): Unit =
      if !_isBranchNameValid(branchName) then return
      _fetchOriginRemote
      val localBranchExists = isGitReferencePresent(repositoryRoot, s"refs/heads/$branchName")
      val remoteBranchExists =
        if localBranchExists then false
        else isGitReferencePresent(repositoryRoot, s"refs/remotes/origin/$branchName")
      if localBranchExists then
        runInherited(repositoryRoot, "git", "checkout", branchName)
        _pullWhenUpstreamExists
      else if remoteBranchExists then
        runInherited(repositoryRoot, "git", "checkout", "--track", s"origin/$branchName")
        _pullWhenUpstreamExists
      else runInherited(repositoryRoot, "git", "checkout", "-b", branchName)

    val currentBranchName = _fetchCurrentBranchName
    val isAttached = currentBranchName.nonEmpty && currentBranchName != "HEAD"
    if isAttached then
      _fetchOriginRemote
      _pullWhenUpstreamExists
    else
      _extractWorktreeBranchName(repositoryRoot) match
        case None => ()
        case Some(branchName) if branchName.isEmpty => ()
        case Some(branchName) => _checkoutInferredBranch(branchName)
end Git

object Dependencies:
  def installAllProjectDependenciesIfPresent(repositoryRoot: os.Path): Unit =
    val hasPackageJson = os.exists(repositoryRoot / "package.json")
    val hasMillBuildFile = os.exists(repositoryRoot / "build.sc")
    val hasSbtBuildFile = os.exists(repositoryRoot / "build.sbt")
    if hasPackageJson then installJavaScriptDependencies(repositoryRoot)
    if hasMillBuildFile then resolveMillDependencies(repositoryRoot)
    if hasSbtBuildFile then resolveSbtDependencies(repositoryRoot)
    if !hasPackageJson && !hasMillBuildFile && !hasSbtBuildFile then Console.printBuildTool("none")

  def installJavaScriptDependencies(repositoryRoot: os.Path): Unit =
    val hasBunBinaryLockFile = os.exists(repositoryRoot / "bun.lockb")
    val hasBunTextLockFile = os.exists(repositoryRoot / "bun.lock")
    val hasPnpmLockFile = os.exists(repositoryRoot / "pnpm-lock.yaml")
    val hasYarnLockFile = os.exists(repositoryRoot / "yarn.lock")
    val hasPackageLockFile = os.exists(repositoryRoot / "package-lock.json")
    if hasBunBinaryLockFile || hasBunTextLockFile then
      Console.printBuildTool("bun")
      Console.printInstall("bun install --frozen-lockfile")
      Git.runInherited(repositoryRoot, "bun", "install", "--frozen-lockfile")
    else if hasPnpmLockFile then
      Console.printBuildTool("pnpm")
      Console.printInstall("pnpm install --frozen-lockfile")
      Git.runInherited(repositoryRoot, "pnpm", "install", "--frozen-lockfile")
    else if hasYarnLockFile then
      Console.printBuildTool("yarn")
      Console.printInstall("yarn install --frozen-lockfile")
      Git.runInherited(repositoryRoot, "yarn", "install", "--frozen-lockfile")
    else
      val installCommand = if hasPackageLockFile then "npm ci" else "npm install"
      Console.printBuildTool("npm")
      Console.printInstall(installCommand)
      if hasPackageLockFile then Git.runInherited(repositoryRoot, "npm", "ci")
      else Git.runInherited(repositoryRoot, "npm", "install")

  def resolveMillDependencies(repositoryRoot: os.Path): Unit =
    Console.printBuildTool("mill")
    Console.printInstall("mill resolve _")
    Git.runInherited(repositoryRoot, "mill", "resolve", "_")

  def resolveSbtDependencies(repositoryRoot: os.Path): Unit =
    Console.printBuildTool("sbt")
    Console.printInstall("sbt update")
    Git.runInherited(repositoryRoot, "sbt", "update")
end Dependencies

object EnvironmentFiles:
  def copyEnvironmentFilesFromSiblingWorktree(repositoryRoot: os.Path): Unit =
    def _isEnvironmentFileCopyable(relativePath: String): Boolean =
      val fileName = FilePaths.extractFileNameFromRelativePath(relativePath)
      fileName == ".env" || fileName.startsWith(".env.")

    def _isConfigurationFileCopyable(relativePath: String): Boolean =
      FilePaths.extractFileNameFromRelativePath(relativePath).endsWith(".conf")

    def _isShareableFileCopyable(relativePath: String): Boolean =
      _isEnvironmentFileCopyable(relativePath) || _isConfigurationFileCopyable(relativePath)

    def _hasShareableEnvironmentFiles(relativePaths: Seq[String]): Boolean =
      relativePaths.exists(relativePath => !FilePaths.isSkippedTemplateFile(relativePath) && _isShareableFileCopyable(relativePath))

    def _listAllWorktrees: List[os.Path] =
      val result = Git.runGit(repositoryRoot, "worktree", "list", "--porcelain")
      Git.checkGitSuccess(result, "git worktree list")
      result.out.text().linesIterator.collect:
        case line if line.startsWith("worktree ") =>
          os.Path(line.stripPrefix("worktree ").trim)
      .toList

    def _findSiblingWorktreeContainingEnvironmentFiles: Option[os.Path] =
      def _searchRemainingWorktrees(remainingWorktrees: List[os.Path]): Option[os.Path] =
        remainingWorktrees match
          case Nil => None
          case head :: tail if head == repositoryRoot => _searchRemainingWorktrees(tail)
          case head :: tail =>
            val relativePaths = Git.findIgnoredFiles(head, repositoryRoot)
            if _hasShareableEnvironmentFiles(relativePaths) then Some(head)
            else _searchRemainingWorktrees(tail)
      _searchRemainingWorktrees(_listAllWorktrees)

    _findSiblingWorktreeContainingEnvironmentFiles match
      case None => Console.printEnvFiles(Nil)
      case Some(siblingWorktree) =>
        val relativePaths = Git.findIgnoredFiles(siblingWorktree, repositoryRoot)
        val wanted = relativePaths.filter(relativePath => !FilePaths.isSkippedTemplateFile(relativePath) && _isShareableFileCopyable(relativePath))
        Console.printEnvFiles(wanted)
        wanted.foreach: relativePath =>
          val destinationPath = repositoryRoot / os.RelPath(relativePath)
          if !os.exists(destinationPath) then
            os.makeDir.all(destinationPath / os.up)
            os.copy(siblingWorktree / os.RelPath(relativePath), destinationPath, createFolders = true)
end EnvironmentFiles

@main def setupWorktree(): Unit =
  val toplevel = os.call(cmd = Seq("git", "rev-parse", "--show-toplevel"), check = false)
  if toplevel.exitCode != 0 then sys.error(s"git rev-parse failed: ${toplevel.err.text().trim}")
  val repositoryRoot = os.Path(toplevel.out.text().trim)
  EnvironmentFiles.copyEnvironmentFilesFromSiblingWorktree(repositoryRoot)
  Git.ensureBranchExistsForWorktree(repositoryRoot)
  Dependencies.installAllProjectDependenciesIfPresent(repositoryRoot)
  Console.printDone()
