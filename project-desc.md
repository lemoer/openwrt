# Experimental Tools Build Project

- The main idea behind this project is, that we could improve the OpenWrt build system by relying on isolated builds of all the small pieces of the build system (like tools, toolchain, kernel, packages) and could compose them together as needed to build other pieces.
- This repository is a small proof-of-concept/experiment, which has the focus to build all `tools` using this approach.
- The build inputs are be hashed such that each tool is stored in a path with it's hash, similar known from the nix-store.

## Overview of Scripts

- `test.sh` - Build all tools.
- `testprereq.sh` - Builds a meta tool called `000-meta-prereq`, which contains the prerequisite tools (symlinks of host system).
- `testtool.sh $toolname` - Build the tool with name `$toolname`.
- `testtool_deps.sh` - Contains the specification of dependencies.
- `tmpcmpnoniso.sh $toolname` - A script that can be used to compare which files the standard OpenWrt build process adds for a tool to staging_dir vs. what we did.

## How it Works

The following folders and variables are used during the build:
1. `tmpenv/`:
    - For every tool build, this folder is newly created.
    - The build script copies (just) the necessary files (mostly `include`, `scripts`, `Makefile`, `tools/$toolname`) to this folder.
    - Furthermore, if a tool has dependencies, their output is also copied to `tempenv/staging_dir/host/...`.
    - This folder is used as `$TOPDIR` for the OpenWrt build later.
2. `$inputhash`:
    - The contents of the `tempenv/` folder are hashed to create an input hash variable.
3. `tmpbuild/$toolname/$inputhash/`:
    - This folder is used as destination/output dir to install things to.
    - This is done via setting `HOST_BUILD_PREFIX=$(pwd)/tmpbuild/$toolname/$inputhash/` for the OpenWrt build.
4. Now, the build of the tool is triggered.
5. `tmpfinished/$toolname/$inputhash/`:
    - This is a symlink to `tmpbuild/$toolname/$inputhash/`, which is created after the build is finished.
    - If this exists, we know that the build of a tool has finished.
6. `tmpcurrent/$toolname`:
    - This is a symlink to `tmpfinished/$toolname/$inputhash/`, which enables to reference a tool without specifying it's input hash.

### Skipping Package Builds

- Now, actually, before the tool is built in step 4, the build process checks if `tmpfinished/$toolname/$inputhash/` already exists.
- If so, it skips steps 4. and 5 and just creates the symlink in `tmpcurrent/$toolname`.
- Since the path `tmpfinished/$toolname/$inputhash/` contains the hash of all inputs `$inputhash`, this accelerating path is only taken if the inputs are unchanged and therefore the output would not change either.

## Advantages of the Proposed Method

1. It should reduce build time, when nothing is to be done.
    - (Assuming we can be faster than `make` in detecting this.)
2. Changes to the source do not necessarily cause rebuilding all tools that depend on it:
    - Let's say, we have three tools `A`, `B` and `C`.
    - The dependency chain looks like this: `A -> B -> C`.
    - `A` has to be rebuilt since the inputs of `A` changed.
    - With the current standard OpenWrt build system, this would mean that both `B` and `C` would have to be rebuilt.
    - However, if the changes to `A` were in a way that the output of tool `B` is not changed, then with the proposed system, the input hash of `C` does not change and therefore `C` doesn't have to be rebuilt.
3. Isolation helps to find bugs early:
    - Since every tool only gets to see its input files, missing dependencies between tools are caught early.
    - To some degree, we watch that a tool build does not have side-effects.
4. Working with different versions of OpenWrt becomes more reliable.
    - Since staging_dir/host is reassembled (fast) from the hash addressed store in `tmpfinished/`, switching back-and-forth between mutliple revisions of the repo should be no problem, while still keeping all build artifacts.
    - When a build is triggered, the `tmpcurrent/` dir is assembled as quickly as possible.
    - (Of course this only makes the builds really stable if we apply the proposed method also to toolchain, kernel, package and image builds)
5. Cache servers could be used in the future.
    - Since the inputhashes and outhashes are stored for every tool, it would be also possible in the future to store them as artifacts on a server and pull them from there if appropriate.
    - Instead of building a package locally, it could be downloaded from a cache server if available with the `$inputhash` we are looking for.
6. Easier to understand:
    - The Makefiles of OpenWrt are somewhat hard to digest, since it consists of a lot of GLOBAL variables.
    - The proposed approach tries to reduce the number of passed envionment variables to a minimum.
    - Furthermore, since I did not use Makefiles, I hope that it enhances the complexity.

## Speedup Of A Chached Build

In this section, we compare the build times when actually nothing has to be rebuilt between standard OpenWrt makefile and our approach.
This comparison is not 100% fair so far, since (I think) OpenWrt makefiles do some additional steps before.

### Single-Threaded 

**Standard OpenWrt-Build Process:**
```
lemoer@luna ~/g/f/openwrt (experimental-tools-build)> time make tools/compile
[...]
________________________________________________________
Executed in   14.74 secs    fish           external
   usr time    9.85 secs    0.43 millis    9.85 secs
   sys time    5.95 secs    1.16 millis    5.95 secs
```

**Our Approach:**
```
lemoer@luna ~/g/f/openwrt (experimental-tools-build)> time bash -c 'python testninja.py; ninja -j 1'
[...]
________________________________________________________
Executed in    1.69 secs    fish           external
   usr time    0.80 secs    0.54 millis    0.80 secs
   sys time    1.14 secs    1.11 millis    1.13 secs
```

### Multi-Threaded

**Standard OpenWrt-Build Process:**
```
lemoer@luna ~/g/f/openwrt (experimental-tools-build)> time make tools/compile -j 12
________________________________________________________
Executed in   10.38 secs    fish           external
   usr time    9.31 secs    0.00 millis    9.31 secs
   sys time    5.04 secs    1.04 millis    5.04 secs
```

**Our Approach:**
```
lemoer@luna ~/g/f/openwrt (experimental-tools-build)> time bash -c 'python testninja.py; ninja -j 12'
________________________________________________________
Executed in  380.71 millis    fish           external
   usr time  733.18 millis    0.00 millis  733.18 millis
   sys time  594.56 millis    1.02 millis  593.54 millis
```

## Comparison of Results with OpenWrt Makefile

``` shell
# Build with OpenWrt
make dirclean tools/compile

# Build with our approach
sh test.sh
python3 testninja.py
ninja -j 12

# Genrate comparison outputs
sh tmpcmpstagingdir.sh -c

# Diff which filenames were created
vim tmpcmpfilelist.diff

# Diff hashes of files
vim tmpcmp.diff

# Use diffoscope to inspect diff in specific files
sh tmpdiffoscope.sh host/bin/tune2fs
```

# Next-Steps/Ideas

- Compare if the result is equivalent to building with the standard OpenWrt build process.
- Maybe make the inputs more specific?
    - Import only certain files from `scripts` or `include` into the `tmpenv`.
- Build something that checks if a tool has a proper cleanup.

## TODOs

- Use a common download dir.
- Recreate basic hash in python-style based approach.
    - After this, delete test.sh.
- Store tool dependencies only in one place.
- Update project-desc.md:
    - Mention python based approach.
    - New build dependency ninja.
    - Mention how-to-setup.
- scripts/config changes input hash on dirclean.
- Include generation of tmpmetabasic to ninja file.
- Use other hashing mechanism than md5.
