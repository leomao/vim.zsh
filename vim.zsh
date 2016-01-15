#===============================================================================
# LICENCE: GNU GPL version 3
#
# vim.zsh is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This project is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#===============================================================================
# Setting up all vim mode mapping and special keys
#
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo

get-x-clipboard() {
  if which xclip >/dev/null 2>&1; then
    clippaste='xclip -selection clipboard -out'
  elif which pbpaste >/dev/null 2>&1; then
    clippaste='pbpaste'
  elif which xsel >/dev/null 2>&1; then
    clippaste='xsel --clipboard --output'
  else
    return 1
  fi

  (( $+DISPLAY )) || return 1
  local r
  r=$(eval "$clippaste")
  if [[ -n $r && $r != $CUTBUFFER ]]; then
    killring=("$CUTBUFFER" "${(@)killring[1,-2]}")
    CUTBUFFER=$r
  fi
}

set-x-clipboard() {
  if which xclip >/dev/null 2>&1; then
    clipcopy='xclip -selection clipboard -in'
  elif which pbcopy >/dev/null 2>&1; then
    clipcopy='pbcopy'
  elif which xsel >/dev/null 2>&1; then
    clipcopy='xsel --clipboard --input'
  else
    return 1
  fi

  (( ! $+DISPLAY )) ||
    print -rn -- "$1" | eval "$clipcopy"
}

# redefine the copying widgets so that they update the clipboard.
for w in copy-region-as-kill vi-delete vi-yank vi-change vi-change-whole-line vi-change-eol; do
  eval $w'() {
    #if [[ $_clipcopy == "+" ]];then
    zle .'$w'
    set-x-clipboard $CUTBUFFER
    unset _clipcopy
    #else
    #    zle .'$w'
    #fi
  }
  zle -N '$w
done

vi-set-buffer() {
  read -k keys
  if [[ $keys == '+' ]];then
    _clipcopy='+'
  else
    zle -U $keys
    zle .vi-set-buffer
  fi
}
zle -N vi-set-buffer

vi-put-after() {
  if [[ $_clipcopy == '+' ]];then
    local cbuf
    cbuf=$CUTBUFFER
    get-x-clipboard
    zle .vi-put-after
    unset _clipcopy
    CUTBUFFER=$cbuf
  else
    zle .vi-put-after
  fi
  REGION_ACTIVE=0
}
zle -N vi-put-after

vi-put-before() {
  if [[ $_clipcopy == '+' ]];then
    local cbuf
    cbuf=$CUTBUFFER
    get-x-clipboard
    zle .vi-put-before
    unset _clipcopy
    CUTBUFFER=$cbuf
  else
    zle .vi-put-before
  fi
  REGION_ACTIVE=0
}
zle -N vi-put-before

visual-mode() {
  zle .visual-mode
  zle zle-keymap-select
}
zle -N visual-mode

visual-line-mode() {
  zle .visual-line-mode
  zle zle-keymap-select
}
zle -N visual-line-mode

overwrite-mode() {
  zle -K virep
  zle .overwrite-mode
}
zle -N overwrite-mode

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
  bindkey -M viins "${key[Insert]}" overwrite-mode
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

bindkey -N virep viins

# normal mode
bindkey -M vicmd "R" overwrite-mode

# visual mode
[[ -n "${key[Delete]}" ]] && bindkey -M visual "${key[Delete]}" kill-region

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
