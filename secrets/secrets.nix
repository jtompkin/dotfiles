let
  josh_ixodes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDjOc7br/xaws2hbaPgG2ilza/cUoZxmkF4H+sSnBzS";
  josh_franken = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDDtiipNZgcDN8pE+w8vnOyfzQusJzl+bSjEjczY/wZO";
  users = [
    josh_ixodes
    josh_franken
  ];
  ixodes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBp852Rd5uF1dbsXAV3YlkJp5nNy4K+RlAG7QWAM0VgY";
  franken = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIn77mqeyR6BiL/gRxmlr+oajDMoabz7XEhwL/pdlQ74";
  systems = [
    ixodes
    franken
  ];
in
{
  "password1.age".publicKeys = [
    josh_ixodes
    ixodes
  ];
  "spotify-client-id-01.age".publicKeys = [ josh_ixodes ];
  "spotify-secret-01.age".publicKeys = [ josh_ixodes ];
}
