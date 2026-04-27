export CLAUDE_CODE_EFFORT_LEVEL=max
export CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1

claude() {
  CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}" command claude --allow-dangerously-skip-permissions "$@"
}
