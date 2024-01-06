{ stdenv, pkgs, lib, buildPythonPackage, fetchFromGitHub, setuptools}:

 pkgs.python311Packages.buildPythonPackage rec {
  pname = "frigate-hass-integration";
  version = "v4.0.1";
  format="other";

  src = fetchFromGitHub {
    owner = "blakeblackshear";
    repo = "frigate-hass-integration";
    rev = version;
    sha256 = "sha256-2ci8ClxZJC2Vrewu6mKYm4oiOjUGoxEywwRKEW5NjXE=";
  };

 
  propagatedBuildInputs = [
    pkgs.python311Packages.pytz
  ];

  postPatch = ''
    substituteInPlace custom_components/frigate/manifest.json \
      --replace 'pytz==2022.7' 'pytz>=2022.7'
  '';


  doCheck = false;
  dontBuild = true;
  pythonImportsCheck = [ "frigate-hass-integration" ];

  # TODO: default installPhase uses $src, so patches don't take effect
  installPhase = ''
    runHook preInstall
    mkdir $out
    cp -r custom_components/ $out/
    runHook postInstall
  '';

  
  meta = with lib; {
    description = "Frigate Home Assistant Integration";
    homepage = "https://github.com/blakeblackshear/frigate-hass-integration";
    license = licenses.asl20;
    maintainers = with maintainers; [ nathan-gs ];
  };
}
