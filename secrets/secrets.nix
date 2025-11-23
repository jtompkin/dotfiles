let
  josh_franken = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINbmsUpHamS9g+sfhNhsBZ0DU5dO+7XpYMg+oPrMgeot";
  deck_steamdeck = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILt5cxf21yGBEsSpqHIY/uzZwliBx4itTh9tqbBzXa1c";
  users = [
    josh_franken
    deck_steamdeck
  ];
  franken = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNHi5giEnLrSrWzuqg9G+lGaUfUq/1TbA1TOzC8Nzs+";
  systems = [
    franken
  ];
in
{
  "pypi-token.age" = {
    publicKeys = [
      josh_franken
      deck_steamdeck
    ];
    armor = true;
  };
  # "spotify-client-id-01.age".publicKeys = [ josh_ixodes ];
  # "spotify-secret-01.age".publicKeys = [ josh_ixodes ];
}
