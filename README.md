# FABN
Find A Better Name 
## Goals
1. Provide a format for configuring and installing plugins and their dependencies. 
1. Focus primarily on Neovim and Lua.
1. Be easier to configure than existing plugins
1. Work for any plugin manager and plugin that is willing to implement the spec
1. Add features such as plugin groups
1. Make lazy loading easier
1. Allow the plugin to specify native dependencies such as LSPs (IE: clangd)  or utilities (IE: fd) probably using Nix 
1. Learn lua for myself
## Plugin Side
A plugin will have a file called fabn/$pkgname.lua with the following format.
### Location
For now, plugin files will be located in a registry (aka one of my github repositories). However, the goal is for package maintainers to maintain their own configs in their own repositories.
### Configuration format
| Item | Description | function input | function output | required | defaults to |
|--------------|-----------|------------|------------|------------|------------|
| fabn_version | specifies the version of the plugin format. This way we can make breaking changes to the spec without breaking existing plugins | none, not a function | string with version "0.0.1" | yes | - |
| default_opts | specifies the default options. Every configurable option must be in the default_opts. | none, not a function | dictionary of default options. Preferably, the options are strings, ints, or bools (or lists of the above), so users can write configurations in languages like TOML or vim| yes | - |
| setup | sets up the function. Must be idempotent - it can be called repeatedly and work fine. The package manager will have all the dependencies installed  | opts | nothing | yes | - ||
| dependencies | specifies the plugin's dependencies, installed via FABN with config files | opts | list of dependencies, each a dictionary with a name and config | no | no dependencies |
| vanilla_deps | specifies the plugin's vanilla dependencies, installed via plugin manager (Will be replaced when all packages have FABN format) | opts | list of dependencies | no | no dependencies |
| natie_deps | specifies the plugin's nix dependencies. Not implemented yet | opts | list of dependencies | no | no native dependencies |
| source| specifies the plugin code repository, useful if the plugin file is in a registry | not a function | string with github user/repo | no | repository of plugin file | 
| keymaps | specifies any GLOBAL keymaps | opts | table of keymap entries in the which key format | no | no keymaps | 
### Options
The opts will be a table using the default options with user overrides. 
The package manager will first get the dependencies, set them up, THEN call the setup function on installation and any time the plugin configuration changes. A package manager does not need to implement package reloading.
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
### Split Packages
A package with many (optional) subpackages should default to including all the stable sub-packages in the main function with the option to start with a minimal configuration.
## User Side
Any package manager which can read the default opts, metatable them with the user options and call the appropriate functions and use them will work.
## Notes
I am pretty new to both neovim and lua and if you have any suggestions on approach or features or want to contribute, I'm open to suggestions.
## TODO
- [x] Create README.md
- [x] Create prototype package manager wrapping packer
- [ ] Document bootstrap installation
- [ ] Implement package reloading
- [ ] Move my configs to package manager
- [ ] Implement lazy loading
- [ ] Add native dependencies (Ideally using nix)

