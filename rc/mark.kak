# Mark
# Public commands: ["mark", "show-marks", "hide-marks"]
# Public faces: ["MarkedPrimarySelection", "MarkedSecondarySelection", "MarkedPrimaryCursor", "MarkedSecondaryCursor"]

# Modes ────────────────────────────────────────────────────────────────────────

try %[ declare-user-mode mark ]

define-command -override mark -docstring 'mark' %{
  enter-user-mode mark
}

# Options ──────────────────────────────────────────────────────────────────────

# Internal variables
declare-option -hidden str register_name
declare-option -hidden range-specs mark_ranges

# Faces
set-face global MarkedPrimarySelection 'black,bright-magenta'
set-face global MarkedSecondarySelection 'black,bright-blue'
set-face global MarkedPrimaryCursor 'black,magenta'
set-face global MarkedSecondaryCursor 'black,blue'

# Mappings ─────────────────────────────────────────────────────────────────────

map -docstring 'enter insert mode with main selection' global mark 'i' ':enter-insert-mode-with-main-selection %val{register}<ret>'
map -docstring 'consume main selection' global mark 'c' ':consume-main-selection %val{register}<ret>'
map -docstring 'consume selections' global mark 'C' ':consume-selections %val{register}<ret>'
map -docstring 'iterate next selection' global mark 'n' ':iterate-next-selection %val{register}<ret>'
map -docstring 'iterate previous selection' global mark 'p' ':iterate-previous-selection %val{register}<ret>'
map -docstring 'add selections to register' global mark 'a' ':add-selections-to-register %val{register}<ret>'
map -docstring 'clear register' global mark 'd' ':clear-register %val{register}<ret>'
map -docstring 'lock' global mark 'l' ':enter-user-mode -lock mark<ret>'

# Commands ─────────────────────────────────────────────────────────────────────

# Reference:
# https://github.com/mawww/kakoune/blob/master/src/normal.cc#:~:text=enter_insert_mode
define-command -override enter-insert-mode-with-main-selection -params 1 -docstring 'enter insert mode with main selection and iterate selections with Alt+N and Alt+P (default: ^)' %{
  execute-keys -save-regs '' "<a-:><a-;>""%arg{1}Z<space>i"

  # Internal mappings
  map -docstring 'iterate next selection' window insert <a-n> "<a-;>""%arg{1}z<a-;>)<a-;>""%arg{1}Z<a-;><space>"
  map -docstring 'iterate previous selection' window insert <a-p> "<a-;>""%arg{1}z<a-;>(<a-;>""%arg{1}Z<a-;><space>"

  hook -always -once window ModeChange 'pop:insert:normal' "
    execute-keys '""%arg{1}z'
    unmap window insert
  "
}

define-command -override consume-selections -params 1..2 -docstring 'consume selections (default: ^)' %{
  restore-selections-from-register %arg{1}
  evaluate-commands %arg{2}
  save-selections-to-register %arg{1}
  execute-keys '<space>'
}

define-command -override consume-main-selection -params 1 -docstring 'consume main selection (default: ^)' %{
  consume-selections %arg{1} %{
    execute-keys '<a-space>'
  }
}

define-command -override iterate-next-selection -params 1 -docstring 'iterate next selection (default: ^)' %{
  consume-selections %arg{1} %{
    execute-keys ')'
  }
}

define-command -override iterate-previous-selection -params 1 -docstring 'iterate previous selection (default: ^)' %{
  consume-selections %arg{1} %{
    execute-keys '('
  }
}

define-command -override save-selections-to-register -params 1 -docstring 'save selections to register (default: ^)' %{
  execute-keys -save-regs '' """%arg{1}Z"
}

define-command -override restore-selections-from-register -params 1 -docstring 'restore selections from register (default: ^)' %{
  try %[ execute-keys """%arg{1}<a-z>a" ]
}

define-command -override add-selections-to-register -params 1 -docstring 'add selections to register (default: ^)' %{
  evaluate-commands -draft %{
    restore-selections-from-register %arg{1}
    save-selections-to-register %arg{1}
  }
  # Display message:
  execute-keys """%arg{1}Z"
}

define-command -override clear-register -params 1 -docstring 'clear register (default: ^)' %{
  set-option global register_name %sh{printf '%s' "${kak_register:-^}"}
  set-register %opt{register_name}
  echo -markup "{Information}cleared register '%opt{register_name}'{Default}"
}

# Highlighters ─────────────────────────────────────────────────────────────────

define-command -override -hidden update-mark-ranges -docstring 'update mark ranges' %{
  # Reset ranges
  evaluate-commands -buffer '*' unset-option buffer mark_ranges
  try %{
    evaluate-commands -draft %{
      # Jump to the buffer
      execute-keys 'z'
      # Initialize ranges
      set-option buffer mark_ranges %val{timestamp}
      # Mark the main selection
      evaluate-commands -draft %{
        execute-keys '<space>'
        set-option -add buffer mark_ranges "%val{selection_desc}|MarkedPrimarySelection"
        execute-keys ';'
        set-option -add buffer mark_ranges "%val{selection_desc}|MarkedPrimaryCursor"
      }
      # Mark other selections
      execute-keys '<a-space>'
      evaluate-commands -draft -itersel %{
        set-option -add buffer mark_ranges "%val{selection_desc}|MarkedSecondarySelection"
        execute-keys ';'
        set-option -add buffer mark_ranges "%val{selection_desc}|MarkedSecondaryCursor"
      }
    }
  }
}

define-command -override show-marks -docstring 'show marks' %{
  remove-hooks global show-marks
  add-highlighter -override global/marks ranges mark_ranges
  hook -group show-marks -always global RegisterModified '\^' update-mark-ranges
}

define-command -override hide-marks -docstring 'hide marks' %{
  remove-hooks global show-marks
  remove-highlighter global/marks
}
