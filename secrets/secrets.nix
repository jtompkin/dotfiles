let
  systems = {
    steamdeck = {
      system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhIQQ2UsFhweDONaAGeiLDeymYsxBnO5Uut3KSPhcBn";
      deck = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILt5cxf21yGBEsSpqHIY/uzZwliBx4itTh9tqbBzXa1c";
    };
    franken = {
      system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNHi5giEnLrSrWzuqg9G+lGaUfUq/1TbA1TOzC8Nzs+";
      josh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINbmsUpHamS9g+sfhNhsBZ0DU5dO+7XpYMg+oPrMgeot";
    };
  };
  allSystems = map (builtins.getAttr "system") (
    builtins.filter (builtins.hasAttr "system") (builtins.attrValues systems)
  );
  allUsers = builtins.concatLists (
    map builtins.attrValues (
      map (system: builtins.removeAttrs system [ "system" ]) (builtins.attrValues systems)
    )
  );
in
{
  "pypi-token.age" = {
    publicKeys = allUsers;
    armor = true;
  };
}
