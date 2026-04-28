{
  writeShellApplication,
  coreutils,
  curl,
  gawk,
  git,
  openssh,
}:

# Stopgap packaging of the ssh-agent-op script. The script itself
# is vendored verbatim from ~/Projects/me/ssh-agent-op so that, once
# that project ships its own flake, the migration here is just a
# delete-and-add-input.
writeShellApplication {
  name = "ssh-agent-op";

  runtimeInputs = [
    coreutils
    curl
    gawk
    git
    openssh
  ];

  # SC2089/SC2090: `apply` builds a literal `core.sshCommand` value
  # that embeds quoted `-i "<path>"` fragments for git to re-tokenize;
  # the literal-quote behavior is the whole point.
  # SC2155: the script uses `local foo=$(...)` deliberately for
  # readability; failure modes of the inner commands aren't load-bearing
  # because each pipeline starts under `set -e`.
  excludeShellChecks = [
    "SC2089"
    "SC2090"
    "SC2155"
  ];

  text = builtins.readFile ./ssh-agent-op;
}
