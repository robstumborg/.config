# no greeting
set -g fish_greeting ""

# full paths, no shortening
set -g fish_prompt_pwd_dir_length 0

# env
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx LESS -R
set -gx GPG_TTY (tty)

# path
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path $HOME/.local/bin $HOME/.opencode/bin $BUN_INSTALL/bin /opt/nvim-linux-x86_64/bin

# aliases
alias ls 'ls --color=auto'
alias g git
alias c clear

# fzf
fzf --fish | source

# vi mode
fish_vi_key_bindings

# syntax highlighting
set -g fish_color_command 9ece6a  # tokyo night green — valid command
set -g fish_color_param normal    # arguments — plain
set -g fish_color_option normal   # flags — plain
set -g fish_color_error f7768e    # tokyo night red — invalid command

# cursor shapes
set -g fish_cursor_default block
set -g fish_cursor_insert line
set -g fish_cursor_replace_one underscore
set -g fish_cursor_external line  # beam while command is running
