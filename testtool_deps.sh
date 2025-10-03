
add_dependency 000-meta-prereq

if [ $toolname != "libdeflate" ]; then
    add_dependency libdeflate
fi

uses_automake() {
    add_dependency m4
    add_dependency autoconf
    add_dependency automake
    add_dependency sed
}

# The following are the dependencies between tools, as far as I could
# figure out.
# For each dependency, call add_dependency with the dependency name.

case "$toolname" in
    autoconf)
        add_dependency m4
        ;;
    autoconf-archive)
        uses_automake
        add_dependency missing-macros
        ;;
    automake)
        add_dependency sed
        add_dependency m4
        add_dependency autoconf
        add_dependency pkgconf
        add_dependency xz
        ;;
    b43-tools)
        add_dependency bison
        ;;
    bc)
        add_dependency bison
        add_dependency libtool
        ;;
    bison)
        add_dependency flex
        add_dependency missing-macros
        uses_automake
        ;;
    bzip2)
        add_dependency cmake
        ;;
    cbootimage)
        add_dependency automake
        ;;
    cmake)
        add_dependency libressl
        add_dependency ninja
        add_dependency expat
        add_dependency xz
        add_dependency zlib
        add_dependency zstd
        ;;
    coreutils)
        uses_automake
        add_dependency missing-macros
        add_dependency bison
        add_dependency gnulib
        ;;
    dosfstools)
        uses_automake
        ;;
    e2fsprogs)
        uses_automake
        add_dependency gnulib
        add_dependency libtool
        add_dependency util-linux
        add_dependency pkgconf
        add_dependency sed
        ;;
    elfutils)
        uses_automake
        add_dependency libtool
        add_dependency bison
        add_dependency gnulib
        add_dependency zlib
        add_dependency zstd
        ;;
    erofs-utils)
        add_dependency libtool
        add_dependency xz
        add_dependency lz4
        add_dependency util-linux
        ;;
    fakeroot)
        add_dependency libtool
        ;;
    findutils)
        add_dependency bison
        uses_automake
        ;;
    firmware-utils)
        add_dependency cmake
        ;;
    flex)
        add_dependency libtool
        uses_automake
        ;;
    genext2fs)
        add_dependency libtool
        uses_automake
        ;;
    gengetopt)
        add_dependency libtool
        uses_automake
        ;;
    gmp)
        add_dependency libtool
        ;;
    isl)
        uses_automake
        add_dependency gmp
        ;;
    liblzo)
        add_dependency cmake
        ;;
    libressl)
        add_dependency pkgconf
        uses_automake
        ;;
    libtool)
        uses_automake
        add_dependency gnulib
        add_dependency missing-macros
        ;;
    lz4)
        add_dependency meson
        add_dependency sed
        add_dependency ninja
        ;;
    lzma-old)
        add_dependency zlib
        ;;
    lzop)
        add_dependency cmake
        add_dependency liblzo
        ;;
    llvm-bpf)
        add_dependency cmake
        ;;
    make-ext4fs)
        add_dependency zlib
        ;;
    meson)
        add_dependency ninja
        ;;
    missing-macros)
        add_dependency autoconf
        ;;
    mkimage)
        add_dependency bison
        add_dependency libressl
        ;;
    mklibs)
        add_dependency libtool
        ;;
    mold)
        add_dependency cmake
        add_dependency zlib
        add_dependency zstd
        ;;
    mpc)
        add_dependency mpfr
        add_dependency gmp
        ;;
    mpfr)
        uses_automake
        add_dependency gmp
        ;;
    mtd-utils)
        uses_automake
        add_dependency libtool
        add_dependency zlib
        add_dependency util-linux
        add_dependency pkgconf
        ;;
    padjffs2)
        add_dependency findutils
        ;;
    patchelf)
        add_dependency libtool
        uses_automake
        ;;
    pkgconf)
        add_dependency ninja
        add_dependency meson
        add_dependency sed
        ;;
    quilt)
        uses_automake
        add_dependency findutils
        ;;
    squashfs3-lzma)
        add_dependency lzma-old
        ;;
    squashfs4)
        add_dependency xz
        add_dependency zlib
        ;;
    util-linux)
        add_dependency meson
        add_dependency ninja
        add_dependency sed
        add_dependency bison
        ;;
    yafut)
        add_dependency cmake
        ;;
esac