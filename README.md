# The crave command line tool

Crave is a command line interface for running commands against [Crave](https://www.crave.io/) platform clusters.

Crave looks for a `crave.conf` configuration file in the current working directory or any of it's parent directories. If it does not find the file there, it will search the user's `${HOME}` directory for the configuration file. You can specify the crave.conf to be used by setting it in the command line using the `-c` (or `--configFile`) parameter.

## Installation

The latest stable version of `crave` can be download from the [crave GitHub](https://github.com/accupara/crave/releases) page. Pick the binary for your platform. For Windows users, download and unzip the contents into a folder.

When running crave, you might be asked to give permissions to a program called `chisel`. Please allow this program to run and accept connections.

## Syntax

Crave follows the following syntax that users can use when running commands from a terminal window:

```text
crave [crave options] [command] [command options]
```

where:

- `crave options` are options for crave itself. For example, `--quiet` or the `-c` flags.
- `command` are the crave actions. Examples are `run`, `ssh`, `list`, `pull`, etc.
- `command options` are the options for the crave command being run.

## Usage

The following is a list of the top-level crave options.

```text
  -h, --help            show this help message and exit
  -c CONFIGFILE, --configFile CONFIGFILE
                        Config file to use for the command. If not provided,
                        this file is searched in the parent directories and at
                        $HOME
  -q, --quiet           Silence HTTPS warnings. Also do not show progress bar
                        when downloading artifcts.
  -v, --verbose         print out verbose messages
```

## Crave commands

Crave supports the following commands.

```text

  {version,list,set,stop,run,ssh,pull,fullbuild,localrun}
                        sub-command help
    version             Crave version
    list                List my projects, running builds and ssh sessions
    set                 Set config options
    stop                Stop a build or interactive session.
    run                 Run command
    ssh                 Start an SSH session on the remote workspace
    pull                Pull job artifacts
    fullbuild           Start a new sandbox build
    localrun            Run commands locally

```

### crave version

Prints the version of crave you are using.

```text
$ crave version
crave 0.2-5484 darwin/x86_64
```

### crave list

Lists all projects that you are a part of. It also lists running jobs (if any).

```text
$ crave list

Configured Projects:

  Id  Name               Source Url
----  -----------------  ------------------------------------------------------------------
   4  Linux kernel       https://github.com/torvalds/linux.git
  16  docker-images      https://github.com/accupara/docker-images.git
  11  kubernetes         git@github.com:kubernetes/kubernetes.git
  12  linkerd            git@github.com:linkerd/linkerd.git
   2  postgreSQL         https://github.com/postgres/postgres.git
  15  protocolbuffers    https://github.com/protocolbuffers/protobuf.git


Your jobs:

  Job Id  Project Name    Job Status    Local Workspace                           Job Url
--------  --------------  ------------  ----------------------------------------  --------------------------------------------------
    5102  Linux kernel    running       /Volumes/case-sensitive/github.com-linux  https://www.crave.io/app/#/build/info/5102?team=1
```

### crave run

When executed without any further options, crave will run the default configured set of commands from the project configuration. If any commands are specified on the command-line, then crave will override the configured commands with these.

Crave will run this command on the workspace and stream back the stdout/stderr to the terminal until the command completes. The command can be terminated by hitting `ctrl-c`. This will kill the command on the terminal as well as on the server.

```text
$ crave run make clean
$ crave run -- make -j64
Picking up local changes (if any)...
Waiting for build to start...
using branch "master"
using base commit "67b9b3ca328392f9afc4e66fe03564f5fc87feff"

checking build system type... x86_64-pc-linux-gnu
checking host system type... x86_64-pc-linux-gnu
checking which template to use... linux
checking whether NLS is wanted... no
checking for default port number... 5432
checking for block size... 8kB
checking for segment size... 1GB
checking for WAL block size... 8kB
checking for gcc... gcc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables...
checking whether we are cross compiling... no
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes
...
...
------------------------------------------------------------------------
Build Successful

Total time: 4m4.853300055s
------------------------------------------------------------------------
Build logs saved at: https://dev-server.crave.io/app/#/build/info/5757?team=1
```

#### Crave run arguments

```text
$ crave run --help
usage: crave run [-h] [--projectID PROJECTID] [--no-artifacts] [--detached]
                 [--clean] [--no-patch] [--artifacts ARTIFACTS_LIST]
                 [--message MESSAGE] [--full-patch-stat]
                 [--disable-build-cache]
                 [cmd [cmd ...]]

positional arguments:
  cmd                   Command to run

optional arguments:
  -h, --help            show this help message and exit
  --projectID PROJECTID
                        Id of the project to build
  --no-artifacts        Do not download build artifacts when build completes
  --detached            Start build in background (do not stream
                        stdout/stderr)
  --clean               Start build on a clean workspace (causing a full
                        build)
  --no-patch            Run with remote commit id and branch without
                        generating a patch
  --artifacts ARTIFACTS_LIST
                        Override the default artifacts downloaded with this
  --message MESSAGE     Set the given message as the message attribute for
                        this job
  --full-patch-stat     Show full patch stats when generating patches
  --disable-build-cache
                        Disable using cache during build
```

- `--projectID`

In normal cases, Crave tries to automatically guess the project configuration that should be used to run the command based on the Git URL of the project. However, when more than one project points to the same Git URL, crave cannot guess which project configuration should be used. In that case, it is required to provide a `--projectID` option to crave. A default projectID option can be set using the `crave set` command.

- `--clean`

This option tells `crave` to create a new clean workspace for running the build commands. This workspace is created from the snapshot of the sources.

- `--no-patch`

This option tells crave to not generate a patch for the run. This will preserve the sources on the server as-is and will not modify any contents. Any patches that have already been uploaded and applied previously will stay applied.

- `--detached`

This option forces crave to disconnect from the stream after starting the job. Crave will print the job URL where the job progress (stdout) can be viewed in the browser.

- `--no-artifacts`

This option tells crave to not download any artifacts after the build completes.

- `--disable-build-cache`

This option tells crave to not use the build cache during the build process. All commands will be run through the compiler and no acceleration is enabled.

- `--artifacts`

This option tells crave to automatically download the specified artifact after the build is complete. The artifact is downloaded to the same location in the current sources as is present in the built workspace.

### crave ssh

This command provides an easy way for developers to log into the workspace console and inspect the contents of the workspace. By default, this command will drop the user into an ephemeral SSH session at the mount location of the sources.

Normally, this is a new SSH instance. If there already is a job running on this workspace, then the `--current-job` parameter can be used to get access to the running instance of the job. This can be used to debug the running processes inside the build container.

### crave pull

This command tells crave to pull artifacts from the remote workspace. The changes are incrementally downloaded so that repeated downloads of the same file do not cause any additional downloads.

```text
crave pull build/kernel/fs
```

### crave stop

Stops any running jobs on the current workspace.

```text
crave stop
```

When a job ID is provided as a parameter, crave will stop that job id only. To stop more than one jobs, the job IDs could be provided as a list. There is no output to this command.

```text
crave stop 5102
```

## crave.yaml
Crave supports yaml file `crave.yaml` which allows users to 
-- override certain project settings (such as docker image used for build and artifacts to be downloaded after build)
-- add user-specific files which are not a part of source repository

`crave.yaml` needs to be added to source repository for crave to use it.
```text
$git add crave.yaml
``` 

Following are the fields for `crave.yaml`
- `image`
This is used to override the `Build Image` specified in `Project Configuration`
```text
$cat crave.yaml
Linux kernel:
  image: "accupara/lkbuild@sha256:c31ec38936e30bce9ed7355bb428ab8173900c0c4e7b3f5ff626d195b0484d73"
```

- `artifacts`
  This can be used to override the `Build Artifacts` specified in `Project Configuration`
```text
$cat crave.yaml
rsync:
  artifacts: ["compat.o" ,"io.o"]
```

- `include_files`
This is used to create patch for custom files in a user's workspace.
```text
$cat crave.yaml
protocolbuffers:
  include_files:
   - testFile
```

- `no_branch_per_workspace`
This is set to `True` to ensure that same workspace is used across different branches.
If it is not set, unique workspaces are used for different branches.
```text
$cat crave.yaml
linkerd:
  no_branch_per_workspace: True
```

crave supports configuring multiple projects using the same `crave.yaml` file
```text
$cat crave.yaml
Linux kernel:
  image: "accupara/lkbuild@sha256:c31ec38936e30bce9ed7355bb428ab8173900c0c4e7b3f5ff626d195b0484d73"
rsync:
  include_files:
   - testfile1
   - testfile2
```
