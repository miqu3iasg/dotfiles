-- lua/language/servers/jdtls.lua

-- Java through the Eclipse JDT language server, used for code navigation and
-- completion. Diagnostics and formatting are disabled to keep startup fast and
-- memory usage low; formatting stays with conform.
--
-- This module does not follow the `UserLspServerModule` contract of the other
-- files in `servers/`: jdtls is started per buffer by nvim-jdtls through
-- `start_or_attach`, not by `vim.lsp.enable`, because the server command
-- depends on the workspace of each project root. Mason still installs it
-- through the `install_only` list of `lua/language/init.lua`, and the editor
-- options and buffer-local keymaps live in `after/ftplugin/java.lua`.
--
-- nvim-jdtls must be declared in `pack.lua` and installed through the plugin
-- manager. The jdtls server itself is installed through Mason, which must
-- already be set up:
--
-- :MasonInstall jdtls
--
-- The package also ships `lombok.jar`, which is loaded as a Java agent when
-- present so that generated members such as getters and builders resolve. The
-- launcher is a Python script, so Python 3 must be available on PATH.
--
-- The server requires JDK 21 or newer. On Arch Linux:
--
-- $ sudo pacman -S jdk21-openjdk
--
-- Every JDK found in `/usr/lib/jvm` named `java-<version>-openjdk` is
-- registered as a runtime, so projects can compile against other versions,
-- for example with `jdk17-openjdk`. The system default JDK does not need to
-- match the server JDK, because jdtls is pointed to the highest installed
-- JDK 21+ through `JAVA_HOME`. Installed JDKs can be checked with:
--
-- $ archlinux-java status
--
-- Maven projects are imported through the m2e integration bundled with the
-- server. The `mvn` command is only needed by the project tasks when a
-- project has no `mvnw` wrapper:
--
-- $ sudo pacman -S maven
--
-- Gradle projects are supported as well, but Maven takes precedence when a
-- project root contains both.
--
-- File watching is disabled to save resources, so jdtls does not notice
-- changes to build files on its own. Saving `pom.xml` or `build.gradle`
-- reloads the project configuration automatically.
--
-- Each project gets an isolated workspace under
-- `~/.cache/nvim/jdtls-workspace/`. It only holds the index and can be deleted
-- safely when jdtls fails to start, for example because of corruption.
--
-- See: after/ftplugin/java.lua
-- See: https://github.com/mfussenegger/nvim-jdtls
-- See: https://github.com/eclipse-jdtls/eclipse.jdt.ls
-- See: :help lsp

local M = {}

---@alias JavaTask "run"|"test"|"build"

---@class JavaJdk
---@field name string Java execution environment identifier advertised to jdtls.
---@field path string Filesystem path to the JDK installation.

local mason = vim.fn.stdpath("data") .. "/mason"
local pkg = mason .. "/packages"

---Resolve the project root of a Java buffer: the nearest directory with build
---files or `.git`, reusing the running server for decompiled `jdt://` buffers,
---which have no path, and falling back to the working directory.
---@param bufnr? integer Defaults to the current buffer.
---@return string
function M.root(bufnr)
	return vim.fs.root(bufnr or 0, {
		{ "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts" },
		".git",
		{ "pom.xml", "build.gradle", "build.gradle.kts" },
	}) or (vim.lsp.get_clients({ name = "jdtls" })[1] or {}).root_dir or vim.fn.getcwd()
end

---Isolated jdtls workspace of a project root, holding only the index.
---@param root string
---@return string
local function workspace_of(root)
	return vim.fn.stdpath("cache")
		.. "/jdtls-workspace/"
		.. vim.fn.sha256(root):sub(1, 8)
		.. "-"
		.. vim.fs.basename(root)
end

---Run a project task in a terminal split from the project root. The build
---tool is selected from the project files found at `root`.
---@param action JavaTask
function M.build(action)
	local root = M.root(0)

	local function has(f)
		return vim.uv.fs_stat(root .. "/" .. f) ~= nil
	end

	local maven = has("pom.xml") or has("mvnw")
	local gradle = not maven and (has("gradlew") or has("build.gradle") or has("build.gradle.kts"))
	local tool = maven and (has("mvnw") and "./mvnw" or "mvn") or (has("gradlew") and "./gradlew" or "gradle")

	local tasks = {
		run = gradle and "bootRun" or "spring-boot:run",
		test = "test",
		build = gradle and "build -x test" or "clean install -DskipTests",
	}

	vim.cmd(("botright vnew | lcd %s | terminal %s %s"):format(vim.fn.fnameescape(root), tool, tasks[action]))
end

---Ask the jdtls client that owns the current buffer to reload the Maven or
---Gradle configuration.
function M.update_project()
	local path = vim.api.nvim_buf_get_name(0)
	for _, c in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
		if c.root_dir and vim.startswith(path, c.root_dir) then
			c:exec_cmd({
				title = "Update project configuration",
				command = "java.projectConfiguration.update",
				arguments = { vim.uri_from_bufnr(0) },
			})
			return
		end
	end
end

---Stop every running jdtls client.
function M.stop()
	for _, c in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
		c:stop()
	end
end

---Stop jdtls, delete the workspace of the current project and reload the
---buffer so the server restarts from a clean index.
function M.wipe_workspace()
	local workspace = workspace_of(M.root(0))
	M.stop()
	vim.wait(2000, function()
		return #vim.lsp.get_clients({ name = "jdtls" }) == 0
	end)
	vim.fn.delete(workspace, "rf")
	vim.notify("Wiped " .. workspace)
	if vim.bo.modified then
		vim.notify("Save the buffer and run :edit to restart jdtls", vim.log.levels.WARN)
	else
		vim.cmd.edit()
	end
end

---Start jdtls for the buffer, or reuse the client of its project root.
---Notifies instead of raising when the server or a JDK 21+ is missing, so the
---editor options and keymaps of the ftplugin keep working without them.
---@param bufnr? integer Defaults to the current buffer.
function M.start(bufnr)
	if vim.fn.isdirectory(pkg .. "/jdtls") == 0 then
		vim.notify("Run :MasonInstall jdtls", vim.log.levels.WARN)
		return
	end

	local jvm_dir = "/usr/lib/jvm"

	---Installed JDK paths indexed by major version.
	---@type table<integer, string>
	local installed = {}

	if vim.fn.isdirectory(jvm_dir) == 1 then
		for name in vim.fs.dir(jvm_dir) do
			local version = tonumber(name:match("^java%-(%d+)%-openjdk"))
			if version and version >= 8 and version <= 25 then
				installed[version] = jvm_dir .. "/" .. name
			end
		end
	end

	---@type JavaJdk[]
	local runtimes = {}

	---JDK used to run the server itself, which is the highest installed version
	---that is 21 or newer.
	---@type string?
	local server_jdk
	local server_version = 0

	for version, path in pairs(installed) do
		table.insert(runtimes, { name = version == 8 and "JavaSE-1.8" or ("JavaSE-" .. version), path = path })
		if version >= 21 and version > server_version then
			server_jdk, server_version = path, version
		end
	end

	if not server_jdk then
		vim.notify("jdtls requires a JDK 21+ in " .. jvm_dir, vim.log.levels.ERROR)
		return
	end

	local root = M.root(bufnr)
	local workspace = workspace_of(root)

	---@param client vim.lsp.Client
	local function on_attach(client)
		-- Disable every provider that is not needed, so Neovim never requests
		-- them from the server. Completion is deliberately kept.
		for _, provider in ipairs({
			"semanticTokensProvider",
			"signatureHelpProvider",
			"codeLensProvider",
			"inlayHintProvider",
			"documentHighlightProvider",
		}) do
			client.server_capabilities[provider] = nil
		end
	end

	local cmd = {
		mason .. "/bin/jdtls",
		"--jvm-arg=-Xmx1g",
		"--jvm-arg=-XX:+UseSerialGC",
		"-data",
		workspace,
	}

	local lombok = pkg .. "/jdtls/lombok.jar"
	if vim.uv.fs_stat(lombok) then
		table.insert(cmd, 2, "--jvm-arg=-javaagent:" .. lombok)
	end

	-- Dynamic file watching is expensive on large repositories.
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

	local config = {
		cmd = cmd,
		cmd_env = { JAVA_HOME = server_jdk },
		root_dir = root,
		capabilities = capabilities,
		on_attach = on_attach,
		flags = { debounce_text_changes = 800 },
		-- Diagnostics are ignored since the server is used for navigation only.
		handlers = { ["textDocument/publishDiagnostics"] = function() end },
		settings = {
			java = {
				autobuild = { enabled = false },
				completion = {
					enabled = true,
					guessMethodArguments = true,
					favoriteStaticMembers = {
						"org.junit.jupiter.api.Assertions.*",
						"org.mockito.Mockito.*",
					},
				},
				format = { enabled = false },
				signatureHelp = { enabled = false },
				referencesCodeLens = { enabled = false },
				implementationsCodeLens = { enabled = false },
				maxConcurrentBuilds = 1,
				compile = { nullAnalysis = { mode = "disabled" } },
				configuration = {
					runtimes = runtimes,
					updateBuildConfiguration = "automatic",
				},
				maven = { downloadSources = true },
				project = {
					resourceFilters = {
						"node_modules",
						".git",
						".gradle",
						"target",
						"build",
						"out",
					},
				},
			},
		},
		-- Required for go-to-definition into library classes (jdt:// URIs).
		init_options = {
			extendedClientCapabilities = require("jdtls").extendedClientCapabilities,
		},
	}

	require("jdtls").start_or_attach(config)

	-- Reload the project configuration when a build file is saved.
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = vim.api.nvim_create_augroup("JavaBuildFile", { clear = true }),
		pattern = { "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts" },
		callback = M.update_project,
		desc = "Java: reload project configuration when a build file is saved",
	})
end

return M
