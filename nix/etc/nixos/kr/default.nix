# Original: https://github.com/bogsen/nixos-public/blob/a0dc497eab5de528ce3006d36c52bc601422cf87/pkgs/krypton/default.nix

{ config, lib, pkgs, ... }: with lib; let
  cfg = config.services.krypton;

  cargoWeb = with pkgs; rustPlatform.buildRustPackage rec {
    name = "cargo-web-${version}";
    version = "0.6.10";
    src = fetchFromGitHub {
      owner = "koute";
      repo = "cargo-web";
      rev = "${version}";
      sha256 = "0jwpq9a2l14j6vbd7lfy1pl4ak2p3a4ymh4yayksf8arh3qc8rn0";
    };
    cargoSha256 = "183d5pyn0zkaadadw4pqarsjh9lb7gj6y854z07hrwlf6qn4w46d";
    nativeBuildInputs = [ openssl perl pkgconfig ];
    buildInputs = stdenv.lib.optionals stdenv.isDarwin [ CoreServices Security ];
    meta = with stdenv.lib; {
      description = "A Cargo subcommand for the client-side Web";
      homepage = https://github.com/koute/cargo-web;
      license = with licenses; [asl20 /* or */ mit];
      maintainers = [ maintainers.kevincox ];
      broken = stdenv.isDarwin;  # test with CoreFoundation 10.11
      platforms = platforms.all;
    };
  };

  dependencies = with pkgs; [
    cargo
    emscripten
    go
    makeWrapper
    perl
  ];

  kr = pkgs.stdenv.mkDerivation {
    name = "kr";

    srcs = map pkgs.fetchFromGitHub [
      {
        owner = "kryptco";
        repo = "kr";
        rev = "2.4.10";
        sha256 = "1xxhlkcw2d52q1y4h40iyvq25804w7hzv0lflqnib68aps491xnj";
	fetchSubmodules = true;	
      }
    ];

    nativeBuildInputs = [pkgs.breakpointHook];
    buildInputs = dependencies ++ [cargoWeb];

    dontBuild = true;

    postUnpack = ''
      export RUST_BACKTRACE=1
      mkdir .cargo
      export CARGO_HOME=./.cargo
      # https://github.com/kryptco/kr/issues/254#issuecomment-464890476
      sed -i.bak -e '8,11d' source/sigchain/Cargo.toml
      
      export GOPATH=$(pwd)
      export GOCACHE=$GOPATH/.cache/go-build
      mkdir -p src/github.com/kryptco
      mv source src/github.com/kryptco/kr
      ln -s src/github.com/kryptco/kr source
    '';

    postPatch = ''
      substituteInPlace Makefile --replace sudo ""
    '';

    installPhase = ''      
      cd ../src/github.com/kryptco/kr && make V=1
    '';

    makeFlags = [ "PREFIX=$(out)" ];
  };  
in {
  options = {
    services.krypton.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Krypton";
    };
  };

  config = {
    nixpkgs.config.packageOverrides = pkgs: { kr = kr; };
  };
}