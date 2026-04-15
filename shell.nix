{ pkgs ? import <nixpkgs> {}, run ? "bash" }:

let
  python = pkgs.python3.withPackages (p: [
    p.setuptools
  ]);

  hostCompilerWrapper = pkgs.runCommand "openwrt-host-compiler-wrapper" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin
    makeWrapper ${pkgs.gcc}/bin/gcc $out/bin/gcc \
      --add-flags "-idirafter /usr/include -L/usr/lib64"
    ln -s gcc $out/bin/cc

    makeWrapper ${pkgs.gcc}/bin/cpp $out/bin/cpp \
      --add-flags "-idirafter /usr/include"

    for i in ${pkgs.gcc.cc}/bin/*-gnu-gcc*; do
      ln -s $out/bin/gcc $out/bin/$(basename "$i")
    done
  '';
in
(pkgs.buildFHSEnv {
  name = "openwrt-build-env";
  targetPkgs = pkgs: with pkgs; [
    argp-standalone
    bash
    binutils
    bison
    bzip2
    coreutils-full
    curl
    diffutils
    file
    findutils
    flex
    gawk
    gcc
    gcc-unwrapped
    getopt
    gettext
    git
    glibc
    glibc.dev
    gnumake
    gnugrep
    gnutar
    gnused
    gzip
    musl-fts
    musl-obstack
    ncurses
    ncurses.dev
    openssl
    patch
    perl
    pkg-config
    python
    rsync
    stdenv.cc.cc
    stdenv.cc.cc.lib
    subversion
    swig
    unzip
    util-linux
    wget
    which
    xz
    zlib

    hostCompilerWrapper

    zlib.static
    glibc.static
  ];
  runScript = run;
  profile = ''
    export hardeningDisable=all
    export NIX_HARDENING_ENABLE=
    export NIX_HARDENING_DISABLE=all
    export PATH=${hostCompilerWrapper}/bin:$PATH
    export CXX=${pkgs.gcc.cc}/bin/g++
    export CXXCPP='${pkgs.gcc.cc}/bin/g++ -E'
    export LIBRARY_PATH=/usr/lib64:/usr/lib''${LIBRARY_PATH:+:$LIBRARY_PATH}
    export NIX_LDFLAGS="$NIX_LDFLAGS -L/usr/lib64"
  '';
  multiPkgs = null;
  extraOutputsToInstall = [ "dev" ];
}).env
