#!/usr/bin/env python3

from ninja import ninja_syntax


writer = ninja_syntax.Writer(open("build.ninja", "w"))

writer.rule("cleancurrent", command="rm -rf tmpcurrent; mkdir -p tmpcurrent")
writer.rule('prereqbuild', command='sh testprereq.sh')
writer.rule('toolbuild', command='sh testtool.sh $toolname')

writer.build('FORCE', 'phony')

writer.build('clean-current-dir', rule='cleancurrent', inputs=['FORCE'])

def tool(writer, toolname, dependencies):
    inputs = ['tmpcurrent/000-meta-prereq']
    for dep in dependencies:
        inputs.append(f'tmpcurrent/{dep}')
    writer.build(
        f'tmpcurrent/{toolname}',
        rule='toolbuild',
        inputs=inputs,
        variables={'toolname': toolname}
    )

def tool_using_automake(writer, toolname, dependencies):
    tool(writer, toolname, dependencies + ['m4', 'ninja', 'expat'])

writer.build(
    'tmpcurrent/000-meta-prereq',
    rule='prereqbuild',
    inputs=['clean-current-dir']
)

tool(writer, 'libdeflate', dependencies=[])
tool(writer, 'tar', dependencies=['libdeflate'])
tool(writer, 'patch', dependencies=['libdeflate'])
tool(writer, 'zstd', dependencies=['libdeflate', 'patch', 'tar'])

# sh testprereq.sh

# sh testtool.sh libdeflate
# sh testtool.sh patch
# sh testtool.sh tar
# sh testtool.sh zstd
# sh testtool.sh m4
# sh testtool.sh ninja
# sh testtool.sh expat