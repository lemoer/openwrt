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

## Shortcomings

- So far, I do not respect the `CONFIG_*` variables from .config.
    - However, this currently only affects which tools are build, e.g. by `CONFIG_BUILD_ALL_HOST_TOOLS`, `BUILD_BZIP2_TOOLS`, ...
    - The tools themselves do not depend on these variables.
- Single-threaded build:
    - Since I am currently using just a shell script, everything is single-threaded.
    - However, this is just a proof-of-concept and the concept is not tied to using shell scripts.

# Next-Steps/Ideas

- Compare if the result is equivalent to building with the standard OpenWrt build process.
- Maybe make the inputs more specific?
    - Import only certain files from `scripts` or `include` into the `tmpenv`.
- Build something that checks if a tool has a proper cleanup.

## TODOs

- Use a common download dir.
- Recreate basic hash in python-style based approach.
