# Package

version       = "1.0.0"
author        = "Nick Shobe"
description   = "Fetch various remote files in a small way"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
bin           = @["fetch"]


# Dependencies

requires "nim >= 1.6.0"
requires "argparse >= 2.0.1"

# Tasks

task muslbuild, "Builds the project":
    exec "nimble --accept install argparse@2.0.1"
    exec "/bin/bash build.sh linux-x86_64"

task muslbuildmips, "Builds the project for mips":
    exec "nimble --accept install argparse@2.0.1"
    exec "/bin/bash build.sh mipssf"
