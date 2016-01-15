# vim.zsh
# Setting up all vim mode mapping and special keys
#
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# special key setup
if [[ -n "${key[Home]}" ]]; then
  bindkey -M viins "${key[Home]}" beginning-of-line
  bindkey -M vicmd "${key[Home]}" beginning-of-line
fi
if [[ -n "${key[End]}" ]]; then
  bindkey -M viins "${key[End]}" end-of-line
  bindkey -M vicmd "${key[End]}" end-of-line
fi
if [[ -n "${key[Delete]}" ]]; then
  bindkey -M viins "${key[Delete]}" delete-char
  bindkey -M vicmd "${key[Delete]}" delete-char
fi
if [[ -n "${key[PageUp]}" ]]; then
  bindkey -M viins "${key[PageUp]}" beginning-of-buffer-or-history
  bindkey -M vicmd "${key[PageUp]}" beginning-of-buffer-or-history
fi
if [[ -n "${key[PageDown]}" ]]; then
  bindkey -M viins "${key[PageDown]}" end-of-buffer-or-history
  bindkey -M vicmd "${key[PageDown]}" end-of-buffer-or-history
fi
if [[ -n "${key[Insert]}" ]]; then
  bindkey -M viins "${key[Insert]}" vi-replace
  bindkey -M vicmd "${key[Insert]}" vi-insert
fi

# insert mode
dir-backward-delete-word() {
  local WORDCHARS="${WORDCHARS:s#/#}"
  zle backward-delete-word
}
zle -N dir-backward-delete-word
bindkey -M viins "^W" dir-backward-delete-word
bindkey -M viins "^H" backward-delete-char
bindkey -M viins "^U" backward-kill-line 
bindkey -M viins "^?" backward-delete-char

bindkey -N vivis vicmd
bindkey -N virep viins

visual-mode() {
  zle -K vivis
  zle .visual-mode
}
visual-line-mode() {
  zle -K vivis
  zle .visual-line-mode
}
vi-replace() {
  zle -K virep
  zle .vi-replace
}

zle -N visual-mode
zle -N visual-line-mode
zle -N vi-replace

# normal mode
vi-put-before(){
  zle .vi-put-before
  MARK=
}
zle -N vi-put-before

vi-put-after(){
  zle .vi-put-after
  MARK=
}
zle -N vi-put-after

# visual mode
vi-visual-delete(){
  zle .vi-delete
  zle .vi-cmd-mode
}
zle -N vi-visual-delete
[[ -n "${key[Delete]}" ]] && bindkey -M vivis "${key[Delete]}" vi-visual-delete
bindkey -M vivis "x" vi-visual-delete
bindkey -M vivis "d" vi-visual-delete
bindkey -M vivis "o" exchange-point-and-mark
bindkey -M vivis "p" put-replace-selection

# replace mode
[[ -n "${key[Insert]}" ]] && bindkey -M virep "${key[Insert]}" vi-insert

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  zle-keybinds-init() {
    echoti smkx
  }
  zle-keybinds-finish() {
    echoti rmkx
  }
  add-zle-hook zle-line-init zle-keybinds-init
  add-zle-hook zle-line-finish zle-keybinds-finish
fi

bindkey -v
