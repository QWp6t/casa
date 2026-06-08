codex() {
  local sentry_token_file="${CODEX_SENTRY_AUTH_TOKEN_FILE:-$HOME/.local/share/agenix/codex-sentry-auth-token}"

  if [ -r "$sentry_token_file" ]; then
    SENTRY_AUTH_TOKEN="$(< "$sentry_token_file")" command codex "$@"
  else
    command codex "$@"
  fi
}
