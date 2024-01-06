{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
, pytz
, dateutil
, numpy
, pillow
, hass-nabucasa
, pynacl
}:

buildHomeAssistantComponent rec {
  owner = "blakeblackshear";
  domain = "frigate-hass-integration";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "blakeblackshear";
    repo = "frigate-hass-integration";
    rev = "v${version}";
    sha256 = "sha256-2ci8ClxZJC2Vrewu6mKYm4oiOjUGoxEywwRKEW5NjXE=";
  };

  doCheck = false;
  postPatch = ''
    substituteInPlace custom_components/frigate/manifest.json \
      --replace 'pytz==2022.7' 'pytz>=2022.7'
  '';

  propagatedBuildInputs = [
    pytz
    dateutil
    numpy
    pillow
    hass-nabucasa
    pynacl
  ];

  # TODO: default installPhase uses $src, so patches don't take effect
  installPhase = ''
    runHook preInstall
    mkdir $out
    cp -r custom_components/ $out/
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/blakeblackshear/frigate-hass-integration";
    license = licenses.mit;
    description = "Frigate Home Assistant integration";
    maintainers = with maintainers; [ graham33 ];
  };
}
