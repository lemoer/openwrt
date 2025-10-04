#!/usr/bin/env python3

from ninja import ninja_syntax


writer = ninja_syntax.Writer(open("build.ninja", "w"))

writer.rule("cleancurrent", command="rm -rf tmpcurrent; mkdir -p tmpcurrent")
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

tool(writer, 'pkgconf', depends_on=basic_deps + ['meson', 'ninja'])
tool(writer, 'missing-macros', depends_on=basic_deps + ['autoconf'])

tool(writer, 'automake', depends_on=basic_deps + ['sed', 'm4', 'autoconf', 'pkgconf', 'xz'])

tool(writer, 'libtool', depends_on=automake + basic_deps + ['gnulib', 'missing-macros'])

tool(writer, 'flex', depends_on=automake + basic_deps + ['libtool'])
tool(writer, 'gmp', depends_on=basic_deps + ['libtool'])
tool(writer, 'fakeroot', depends_on=basic_deps + ['libtool'])
tool(writer, 'genext2fs', depends_on=automake + basic_deps + ['libtool'])
tool(writer, 'gengetopt', depends_on=automake + basic_deps + ['libtool'])
tool(writer, 'patchelf', depends_on=automake + basic_deps + ['libtool'])

tool(writer, 'bison', depends_on=automake + basic_deps + ['flex', 'missing-macros'])

tool(writer, 'findutils', depends_on=automake + basic_deps + ['bison'])

tool(writer, 'lzma-old', depends_on=basic_deps + ['zlib'])

tool(writer, 'dosfstools', depends_on=automake + ['libdeflate'])
tool(writer, 'coreutils', depends_on=automake + basic_deps + ['missing-macros', 'bison', 'gnulib'])
tool(writer, 'padjffs2', depends_on=basic_deps + ['findutils'])
tool(writer, 'squashfs4', depends_on=basic_deps + ['xz', 'zlib'])
tool(writer, 'squashfs3-lzma', depends_on=basic_deps + ['lzma-old'])
tool(writer, 'util-linux', depends_on=meson + basic_deps + ['sed', 'bison'])

tool(writer, 'autoconf-archive', depends_on=automake + basic_deps + ['missing-macros'])
tool(writer, 'lz4', depends_on=meson + basic_deps + ['sed'])

tool(writer, 'make-ext4fs', depends_on=basic_deps + ['zlib'])

tool(writer, 'mtd-utils', depends_on=automake + basic_deps + ['libtool', 'zlib', 'util-linux', 'pkgconf'])
tool(writer, 'cbootimage', depends_on=automake + ['libdeflate'])

tool(writer, 'mklibs', depends_on=automake + basic_deps + ['libtool'])

tool(writer, 'bc', depends_on=basic_deps + ['bison', 'libtool'])
tool(writer, 'b43-tools', depends_on=automake + basic_deps + ['bison'])

tool(writer, 'quilt', depends_on=automake + basic_deps + ['findutils'])

tool(writer, 'libressl', depends_on=automake + basic_deps + ['pkgconf'])
tool(writer, 'mkimage', depends_on=automake + basic_deps + ['bison', 'libressl'])

tool(writer, 'mpfr', depends_on=automake + basic_deps + ['gmp'])
tool(writer, 'mpc', depends_on=basic_deps + ['mpfr', 'gmp'])

tool(writer, 'isl', depends_on=automake + basic_deps + ['gmp'])

tool(writer, 'cmake', depends_on=basic_deps + ['libressl', 'ninja', 'expat', 'zstd'])

tool(writer, 'bzip2', depends_on=cmake + basic_deps + ['zlib'])
tool(writer, 'firmware-utils', depends_on=cmake + basic_deps + ['zlib', 'libressl'])
tool(writer, 'liblzo', depends_on=cmake + ['libdeflate'])
tool(writer, 'lzop', depends_on=cmake + basic_deps + ['liblzo'])
tool(writer, 'mold', depends_on=cmake + basic_deps + ['zlib', 'zstd'])
tool(writer, 'yafut', depends_on=cmake + ['libdeflate'])

tool(writer, 'elfutils', depends_on=automake + basic_deps + ['libtool', 'bison', 'gnulib', 'zlib', 'zstd'])
tool(writer, 'e2fsprogs', depends_on=automake + basic_deps + ['gnulib', 'libtool', 'util-linux', 'pkgconf'])
tool(writer, 'erofs-utils', depends_on=basic_deps + ['libtool', 'xz', 'lz4', 'util-linux'])
