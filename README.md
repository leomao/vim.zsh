# vim.zsh

This plugin needs zsh 5.2+ to work properly.
To use the X clipboard feature, you will need `xsel`, `xclip` or `pbpaste, pbcopy`.

This plugin depends on [zsh-hooks][zsh-hooks] and provide a function
`add-vi-mode-hook`. Any hooks registered will be called with two arguments:
*mode* and *type* when the *vim mode* is changed.
- Possible modes are: `i`, `n`, `v`, `r` (insert, normal, visual, replace)
- Possible types are: `line-init`, `line-finish`, `keymap-select`

[zsh-hooks]: https://github.com/leomao/zsh-hooks
