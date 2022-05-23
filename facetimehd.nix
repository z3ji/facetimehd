{
  fetchFromGitHub, # Function to fetch source code from GitHub releases
  stdenv,
  linuxPackages,
  cmake,
  dkms, # DKMS (Dynamic Kernel Module Support) package
}:
stdenv.mkDerivation rec {
  pname = "facetimehd";
  version = "0.5.7";

  # Fetch the source code from GitHub
  src = fetchFromGitHub {
    owner = "patjak";
    repo = pname;
    rev = "v${version}";
    sha256 = "5361032278e09fe4d096d421189d8438f7cfabab923a3aa1739ad515a4047ae5"; # SHA256 hash of the release archive
  };

  # Dependencies required for building
  buildInputs = [cmake linuxPackages.dkms];

  # Additional build-time dependencies
  nativeBuildInputs = [cmake];

  # Build the module
  buildPhase = ''
    mkdir build
    cd build
    cmake ${src}
    make
  '';

  # Install the module
  installPhase = ''
    mkdir -p $out/lib/modules/${version}/extra/facetimehd
    cp -r build/*.ko $out/lib/modules/${version}/extra/facetimehd
  '';

  # DKMS configuration
  postInstall = ''
    mkdir -p $out/etc/dkms/facetimehd/${version}
    cp -r ${src}/dkms.conf $out/etc/dkms/facetimehd/${version}
  '';

  meta = with stdenv.lib; {
    description = "Reverse engineered Linux driver for the FacetimeHD (Broadcom 1570) PCIe webcam";
    homepage = https://github.com/patjak/facetimehd;
    license = licenses.gpl2;
    maintainers = [maintainers.z3ji];
  };
}
