#!/usr/bin/env python3

from ninja import ninja_syntax

host_os = 'Linux'
print("WARNING: This script is Linux-specific, fix this.") # FIXME, TODO

def parse_openwrt_config(path):
    config = {}
    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") and "not set" not in line:
                continue

            # Example: CONFIG_FOO=y
            if line.startswith("CONFIG_"):
                key, value = line.split("=", 1)
                config[key] = value
            # Example: # CONFIG_BAR is not set
            elif line.startswith("# CONFIG_") and line.endswith("is not set"):
                key = line.split()[1]
                config[key] = False  # oder False

    return config

writer = ninja_syntax.Writer(open("build.ninja", "w"))

writer.rule("cleancurrent", command="rm -rf tmpcurrent; mkdir -p tmpcurrent")
writer.rule('preparebuild', command='sh testprepare.sh')
writer.rule('prereqbuild', command='sh testprereq.sh')
writer.rule('toolbuild', command='sh testtool.sh $toolname')

writer.build('FORCE', 'phony')

writer.build('clean-current-dir', rule='cleancurrent', inputs=['FORCE'])

def tool(writer, toolname, depends_on):
    inputs = ['tmpcurrent/000-meta-prereq']
    for dep in depends_on:
        inputs.append(f'tmpcurrent/{dep}')
    writer.build(
        f'tmpcurrent/{toolname}',
        rule='toolbuild',
        inputs=inputs,
        variables={'toolname': toolname}
    )

writer.build(
    'tmpcurrent/000-meta-prereq',
    rule='prereqbuild',
    inputs=['clean-current-dir']
)

writer.build(
    'tmpcurrent/000-meta-prepare',
    rule='preparebuild',
    inputs=['clean-current-dir']
)

basic_deps = ['libdeflate']
automake = ['sed', 'm4', 'autoconf', 'automake']
cmake = ['cmake', 'ninja']
meson = ['meson', 'ninja', 'sed']

tool(writer, 'libdeflate', depends_on=[])
tool(writer, 'patch', depends_on=basic_deps)
tool(writer, 'tar', depends_on=basic_deps)
tool(writer, 'zstd', depends_on=basic_deps)
tool(writer, 'm4', depends_on=basic_deps)
tool(writer, 'ninja', depends_on=basic_deps)
tool(writer, 'expat', depends_on=basic_deps)
tool(writer, 'xz', depends_on=basic_deps)
tool(writer, 'zlib', depends_on=basic_deps)
tool(writer, 'gnulib', depends_on=basic_deps)
tool(writer, 'sed', depends_on=basic_deps)

tool(writer, 'meson', depends_on=basic_deps + ['ninja'])
tool(writer, 'autoconf', depends_on=basic_deps + ['m4'])

tool(writer, 'pkgconf', depends_on=basic_deps + meson)
tool(writer, 'missing-macros', depends_on=basic_deps + ['autoconf'])

tool(writer, 'automake', depends_on=basic_deps + ['sed', 'm4', 'autoconf', 'pkgconf', 'xz'])

tool(writer, 'libtool', depends_on=automake + basic_deps + ['gnulib', 'missing-macros'])

tool(writer, 'flex', depends_on=automake + basic_deps + ['libtool'])
tool(writer, 'fakeroot', depends_on=basic_deps + ['libtool'])
tool(writer, 'gengetopt', depends_on=automake + basic_deps + ['libtool'])
tool(writer, 'patchelf', depends_on=automake + basic_deps + ['libtool'])

tool(writer, 'bison', depends_on=automake + basic_deps + ['flex', 'missing-macros'])

tool(writer, 'findutils', depends_on=automake + basic_deps + ['bison'])

tool(writer, 'dosfstools', depends_on=automake + ['libdeflate'])
tool(writer, 'padjffs2', depends_on=basic_deps + ['findutils'])
tool(writer, 'squashfs4', depends_on=basic_deps + ['xz', 'zlib'])
tool(writer, 'util-linux', depends_on=meson + basic_deps + ['sed', 'bison'])

tool(writer, 'autoconf-archive', depends_on=automake + basic_deps + ['missing-macros'])
tool(writer, 'lz4', depends_on=meson + basic_deps + ['sed'])

tool(writer, 'make-ext4fs', depends_on=basic_deps + ['zlib'])

tool(writer, 'mtd-utils', depends_on=automake + basic_deps + ['libtool', 'zlib', 'util-linux', 'pkgconf'])

tool(writer, 'mklibs', depends_on=automake + basic_deps + ['libtool'])

tool(writer, 'bc', depends_on=basic_deps + ['bison', 'libtool'])

tool(writer, 'quilt', depends_on=automake + basic_deps + ['findutils'])

tool(writer, 'libressl', depends_on=automake + basic_deps + ['pkgconf'])
tool(writer, 'mkimage', depends_on=automake + basic_deps + ['bison', 'libressl'])

tool(writer, 'cmake', depends_on=basic_deps + ['libressl', 'ninja', 'expat', 'zstd', 'zlib'])
tool(writer, 'firmware-utils', depends_on=cmake + basic_deps + ['zlib', 'libressl'])

tool(writer, 'elfutils', depends_on=automake + basic_deps + ['libtool', 'bison', 'gnulib', 'zlib', 'zstd'])
tool(writer, 'e2fsprogs', depends_on=automake + basic_deps + ['gnulib', 'libtool', 'util-linux', 'pkgconf'])
tool(writer, 'erofs-utils', depends_on=basic_deps + ['libtool', 'xz', 'lz4', 'util-linux'])

tool(writer, 'cpio', depends_on=basic_deps)
tool(writer, 'flock', depends_on=basic_deps)
tool(writer, 'lzma', depends_on=basic_deps)
tool(writer, 'patch-image', depends_on=basic_deps)
tool(writer, 'zip', depends_on=basic_deps)
tool(writer, 'mtools', depends_on=basic_deps)
tool(writer, 'sstrip', depends_on=basic_deps)

config = parse_openwrt_config(".config")

is_y = lambda config_part: config.get("CONFIG_" + config_part) == 'y'
is_n = lambda config_part: config.get("CONFIG_" + config_part, False) == False
build_all_host_tools = is_y('BUILD_ALL_HOST_TOOLS')
is_target = lambda targetname: is_y(f'TARGET_{targetname}')

build_b43_tools = is_y('SDK') or is_y('PACKAGE_kmod-b43') or is_y('BRCMSMAC_USE_FW_FROM_WL')
build_bzip2_tools = is_y('SDK') or is_y('TARGET_INITRAMFS_COMPRESSION_BZIP2')
build_lz4_tools = is_y('SDK') or is_y('TARGET_INITRAMFS_COMPRESSION_LZ4')
build_lzo_tools = is_y('SDK') or is_y('TARGET_INITRAMFS_COMPRESSION_LZO')
build_toolchain = is_n('EXTERNAL_TOOLCHAIN')
build_isl = is_n('EXTERNAL_TOOLCHAIN') and is_y('GCC_USE_GRAPHITE')
build_gmp = build_isl or build_toolchain
build_coreutils = host_os != 'Linux' or is_y('SDK')

if build_all_host_tools or build_b43_tools:
    tool(writer, 'b43-tools', depends_on=automake + basic_deps + ['bison'])

if build_all_host_tools or build_bzip2_tools:
    tool(writer, 'bzip2', depends_on=cmake + basic_deps + ['zlib'])

if build_all_host_tools or build_gmp:
    tool(writer, 'gmp', depends_on=basic_deps + ['libtool'])

if build_all_host_tools or build_isl:
    tool(writer, 'isl', depends_on=automake + basic_deps + ['gmp'])

if build_all_host_tools or build_lz4_tools:
    tool(writer, 'lz4', depends_on=meson + basic_deps + ['sed'])

if build_all_host_tools or build_lzo_tools:
    tool(writer, 'liblzo', depends_on=cmake + ['libdeflate'])
    tool(writer, 'lzop', depends_on=cmake + basic_deps + ['liblzo'])

if build_all_host_tools or build_toolchain:
    tool(writer, 'mpfr', depends_on=automake + basic_deps + ['libtool', 'gmp'])
    tool(writer, 'mpc', depends_on=basic_deps + ['libtool', 'gmp', 'mpfr'])

if build_all_host_tools or build_coreutils:
    tool(writer, 'coreutils', depends_on=automake + basic_deps + ['missing-macros', 'bison', 'gnulib'])

# TODO, FIXME: in the OpenWrt makefile, we have some weird additional
# dependency to coreutils added to elfutils, findutils, squashfs4 and
# util-linux, but only if coreutils is built. No idea why this is.

# TODO, FIXME: CONFIG_CCACHE is ignored here and xxhash and ccache are not built.

if build_all_host_tools or is_target('apm821xx') or is_target('gemini'):
    tool(writer, 'genext2fs', depends_on=automake + basic_deps + ['libtool'])
else:
    print("Skipping genext2fs as CONFIG_BUILD_ALL_HOST_TOOLS is not set and target is not apm821xx or gemini.")

if build_all_host_tools or is_target('ath79'):
    # lzma-old and squashfs3-lzma
    tool(writer, 'lzma-old', depends_on=basic_deps + ['zlib'])
    tool(writer, 'squashfs3-lzma', depends_on=basic_deps + ['lzma-old'])
else:
    print("Skipping lzma-old and squashfs3-lzma as CONFIG_BUILD_ALL_HOST_TOOLS is not set and target is not ath79.")

if build_all_host_tools or is_target('mxsl'):
    # elftosb and sdimage
    tool(writer, 'elftosb', depends_on=automake + basic_deps + ['libtool', 'bison', 'flex'])
    tool(writer, 'sdimage', depends_on=automake + basic_deps + ['libtool', 'bison', 'flex', 'elftosb'])
else:
    print("Skipping elftosb and sdimage as CONFIG_BUILD_ALL_HOST_TOOLS is not set and target is not mxsl.")

if build_all_host_tools or is_target('realtek'):
    # 7z
    tool(writer, '7z', depends_on=basic_deps + ['bzip2', 'lzma-old', 'zstd', 'zlib'])
else:
    print("Skipping 7z as CONFIG_BUILD_ALL_HOST_TOOLS is not set and target is not realtek.")

if build_all_host_tools or is_target('tegra'):
    # cbootimage cbootimage-configs
    tool(writer, 'cbootimage-configs', depends_on=automake + ['libdeflate'])
    tool(writer, 'cbootimage', depends_on=automake + basic_deps + ['libtool', 'cbootimage-configs'])
else:
    print("Skipping cbootimage and cbootimage-configs as CONFIG_BUILD_ALL_HOST_TOOLS is not set and target is not tegra.")

if is_y('USES_MIRROR'):
    # yafut
    tool(writer, 'yafut', depends_on=cmake + basic_deps + ['libdeflate'])
else:
    print("Skipping yafut as CONFIG_USES_MIRROR is not set.")

if is_y('USE_SPARSE'):
    tool(writer, 'sparse', depends_on=automake + basic_deps + ['libtool'])
else:
    print("Skipping sparse as CONFIG_USE_SPARSE is not set.")

if is_y('USE_LLVM_BUILD'):
    # llvm-bpf
    tool(writer, 'llvm-bpf', depends_on=cmake + basic_deps + ['libressl', 'zlib'])
else:
    print("Skipping llvm-bpf as CONFIG_USE_LLVM_BUILD is not set.")

if is_y('USE_MOLD'):
    # mold
    tool(writer, 'mold', depends_on=cmake + basic_deps + ['zlib', 'zstd'])
else:
    print("Skipping mold as CONFIG_USE_MOLD is not set.")