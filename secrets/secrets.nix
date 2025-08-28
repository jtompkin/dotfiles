let
  josh_ixodes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDjOc7br/xaws2hbaPgG2ilza/cUoZxmkF4H+sSnBzS";
  users = [ josh_ixodes ];
  ixodes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBp852Rd5uF1dbsXAV3YlkJp5nNy4K+RlAG7QWAM0VgY";
  systems = [ ixodes ];
in
{
  "password1.age".publicKeys = [
    josh_ixodes
    ixodes
  ];
  "spotify-client-id-01.age".publicKeys = [ josh_ixodes ];
}
