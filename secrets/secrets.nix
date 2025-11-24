let
  keys = {
    steamdeck = {
      system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhIQQ2UsFhweDONaAGeiLDeymYsxBnO5Uut3KSPhcBn";
      users.deck = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILt5cxf21yGBEsSpqHIY/uzZwliBx4itTh9tqbBzXa1c";
    };
    franken = {
      system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNHi5giEnLrSrWzuqg9G+lGaUfUq/1TbA1TOzC8Nzs+";
      users.josh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINbmsUpHamS9g+sfhNhsBZ0DU5dO+7XpYMg+oPrMgeot";
    };
  };
  groups = {
    systems = builtins.catAttrs "system" (builtins.attrValues keys);
    users = builtins.concatMap (sys: builtins.attrValues sys.users) (builtins.attrValues keys);
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
  pypi-token = groups.users;
}
