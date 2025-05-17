{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "goclacker";
  version = "1.4.2";
  src = fetchFromGitHub {
    owner = "jtompkin";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-3jELTnPFDpB5vJ+mCTV6drYIvhiPIhmQmsn2MlvaNz0=";
  };
  vendorHash = "sha256-rELkSYwqfMFX++w6e7/7suzPaB91GhbqFsLaYCeeIm4=";

  meta = with lib; {
    description = "Command line reverse Polish notation (RPN) calculator";
    homepage = "https://github.com/jtompkin/goclacker";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "goclacker";
  };
}
