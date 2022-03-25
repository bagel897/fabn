#FABN
Find A Better Name 
## Goals
1. provide a format for configuring and installing plugins and their dependencies. 
1. focus primarily on Neovim and Lua.
1. be easier to configure than existing plugins
1. work for any plugin manager and plugin that is willing to implement the spec
1. add features such as plugin groups
1. make lazy loading easier
1. allow the plugin to specify native dependencies such as clangd
1. learn lua for myself
## Plugin Side
A plugin will have a file called $pkgname-plugin.lua with the following format.
### Location
For now, plugin files will be located in a registry (aka one of my github repositories). However, the goal is for package maintainers to maintain their own configs in their own repositories.
### Configuration format
| Item | Description | function input | function output | required/defaults to |
|--------------|-----------|------------|------------|------------|
| version | specifies the version of the plugin format | none, not a function | string with version "0.0.1" | yes |
| default_opts | specifies the default options | none, not a function | dictionary of default options | yes |
| setup | specifies the plugin at runtime | opts | nothing | yes | 
| dependencies | specifies the plugin's dependencies | opts | list of dependencies | yes |
| source| specifies the plugin code repository, useful if the plugin file is in a registry | not a function | string with github user/repo | defaults to repository of plugin file | 
| keymaps | specifies any GLOBAL keymaps | opts | table of keymap entries | defaults tto no keymaps |
### Options
The opts will be a metatable created from user supplied by the user combined with default opts. Initially it'll be only the first level, but the goal is for it to be recursive.
### Example

```lua
local M={}
M.version = "0.0.1"
M.dependencies = function(opts) if(opts.i_like_candy == true) then return {"totally-real/candy"} end  return {} end
M.default_opts = {
	i_like_candy=false
}
M.setup = function(opts) ... end
return M
```
## User Side
Any package manager which can read the default opts, metatable them with the user options and call the appropriate functions and use them will work.
## Notes
I am pretty new to both neovim and lua and if you have any suggestions on approach or features or want to contribute, I'm open to suggestions.
## TODO
- [x] Create README.md
- [] Create package manager using packer
- [] Move my configs to package manager
- [] Implement lazy loading
- [] Add native dependencies (Ideally using nix)

