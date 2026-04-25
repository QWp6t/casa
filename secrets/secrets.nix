let
  me = "age1rrqcc5g0zueg4vf3c0m5j3ghmsf03tf3n30elsc09v75et4s9yfq2cxje9";

  everyone = [ me ];
in
{
  "work-shell.age".publicKeys = everyone;
  "git-local-include.age".publicKeys = everyone;
  "claude-routing.age".publicKeys = everyone;
  "me-password.age".publicKeys = everyone;
}
