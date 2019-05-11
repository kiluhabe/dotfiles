self: super:
{
  spotifyd = with super; rustPlatform.buildRustPackage rec {
    name = "spotifyd-${version}";
    version = "0.2.5";

    src = fetchFromGitHub {
      owner = "Spotifyd";
      repo = "spotifyd";
      rev = "v${version}";
      sha256 = "0pgm7ldkz79dpszq4nlx55rgxpb1hm2nlss2czjfhbwvlik8b0kj";
    };

    cargoSha256 = "08icw78grx9qr007h1b8j4iwqmz66fls2chb4h2mb2v8c2myblc8";

    nativeBuildInputs = [ pulseaudio ];

    cargoBuildFlags = [
      "--features"
      "pulseaudio_backend"
    ];
  };
}
