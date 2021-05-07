swift.nvim WIP
===================

Neovim Swift development environment. Why?, I'm too dump to learn xcode and
start using the mouse while coding.

The project is currently under development, so please use and report issues.

Install
---------------------

```vim
Plug 'keith/swift.vim' " syntax highlighting
Plug 'nvim-lua/plenary.nvim'
Plug 'tami5/swift.nvim'
```

### Requirements:

- swiftformat
- macOS
- Xcode

Options
--------------------

```lua

require'swift_env'.setup {
  --- Normal/Visual Mode leader key
  leader = "<leader>",
  --- Format Configuration
  format = {
    -- path to the swiftformat binary.
    cmd = "swiftformat",
    -- command to run formater manually
    ex = "Sfmt",
    -- mapping to run formater manually
    mapping = "eF",
    -- whether to format on write.
    auto = true,
    -- options to be passed when calling swiftformat from the command line
    options = {},
    -- path to config file from root directory
    config_file = ".swiftformat",
    -- create config format config file when it doesn't exists?
    config_create_if_unreadable = true,
    -- the file content to be generated.
    config_default_content = [[]],
}

-- somewhere in your nvim-lsp attach function call .attach
if vim.bo.filetype == "swift" then
  require'swift_env'.attach()
end

-- if you don't use nvim-lsp, then append the function to ftplugin/swift.vim
lua require'swift_env'.attach()

```

Features
--------------------

### Done: Format

Format current file using swiftformat. If .swiftformat or config_file doesn't
exists at the root of cwd, create it.


### PAUSE: Lint

**May not be built-in**

Lint current file, in case of errors, show virtual text to errors or open
quickfix

### TODO: Build

Build the project, show quickfix with all the errors, if any errors found,
otherwise print success message.

### TODO: Run

Run through mappings and ex-command. It would be cool if a popup open to choose
avaliable methods to run the app.

### TODO: Test

- [ ] run current test file
  - [ ] Open a popup in case of errors
  - [ ] message that the test function has been ran successfully
- [ ] run tests for a file with associated test file
- [ ] Manually run test function
- [ ] Create test file for current file, with a template
