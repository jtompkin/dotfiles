let
  # Top level attrs should be machine names
  # System (root) key should be in 2nd level attr "system"
  # User keys should be in 3rd level attrs under 2nd level "user" attr
  # Keys not belonging to any machine should be under attrpath ["other" "users"]
  keys = {
    steamdeck = {
      system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhIQQ2UsFhweDONaAGeiLDeymYsxBnO5Uut3KSPhcBn";
      users.deck = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILt5cxf21yGBEsSpqHIY/uzZwliBx4itTh9tqbBzXa1c";
    };
    franken = {
      system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNHi5giEnLrSrWzuqg9G+lGaUfUq/1TbA1TOzC8Nzs+";
      users.josh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINbmsUpHamS9g+sfhNhsBZ0DU5dO+7XpYMg+oPrMgeot";
    };
    other.users = { };
  };
  groups = {
    systems = builtins.catAttrs "system" (builtins.attrValues keys);
    users = builtins.concatMap (sys: builtins.attrValues sys.users) (builtins.attrValues keys);
    python = with keys; [
      steamdeck.users.deck
      franken.users.josh
    ];
  };
  makeEntries =
    entries:
    builtins.listToAttrs (
      builtins.attrValues (
        builtins.mapAttrs (name: specOrKeys: {
          name = "${name}.age";
          value = {
            armor = true;
          }
          // (if builtins.isAttrs specOrKeys then specOrKeys else { publicKeys = specOrKeys; });
        }) entries
      )
    );
in
makeEntries {
  pypi-token = groups.python;
  spotify-client-id-01 = [ keys.franken.users.josh ];
  spotify-secret-01 = [ keys.franken.users.josh ];
  password-01 = [
    keys.franken.users.josh
    keys.franken.system
  ];
}
