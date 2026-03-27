function fish_prompt
  set -l last_exit $status
  set -l cyan (set_color 7aa2f7)
  set -l gray (set_color 565f89)
  set -l purple (set_color bb9af7)
  set -l red (set_color f7768e)
  set -l reset (set_color normal)

  # path with ~ substitution
  set -l pwd (string replace -r "^$HOME" "~" $PWD)

  # git info
  set -l git_info ""
  set -l branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if test -n "$branch"
    set -l dirty ""
    if test -n "$(git status --porcelain 2>/dev/null)"
      set dirty "*"
    end
    set git_info " $gray$branch$dirty$reset"
  end

  # prompt symbol
  set -l sym_color $purple
  if test $last_exit -ne 0
    set sym_color $red
  end

  echo -e "\n$cyan$pwd$reset$git_info\n$sym_color❯$reset "
end
