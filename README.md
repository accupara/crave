# The crave command line tool

Crave is a command line interface for running commands against [Crave](https://www.crave.io/) platform clusters.

Crave looks for a `crave.conf` configuration file in the current working directory or any of its parent directories. If it does not find the file there, it will search the user's `${HOME}` directory for the configuration file. You can specify the crave.conf to be used by setting it in the command line using the `-c` (or `--configFile`) parameter.

## Installation

The latest stable version of `crave` can be download from the [crave GitHub](https://github.com/accupara/crave/releases) page. Pick the binary for your platform. For Windows users, download and unzip the contents into a folder.

Alternatively, your administrator approved version of crave can be downloaded from the "Downloads" page in the Crave UI.

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

$ crave --help
usage: crave-0.2-6591 [-h] [-c CONFIGFILE] [-q] [-v] [-n] {version,list,set,stop,run,exec,ssh,pull,push,fullbuild,localrun,discard,lookbusy,getlog,fetchdiagnostics,devspace,clone} ...

Crave Build invoker

positional arguments:
  {version,list,set,stop,run,exec,ssh,pull,push,fullbuild,localrun,discard,lookbusy,getlog,fetchdiagnostics,devspace,clone}
                        sub-command help
    version             Prints crave client version
    list                List my projects, running builds and ssh sessions
    set                 Set config options
    stop                Stop a build or interactive session.
    run                 Run build command on crave servers
    exec                Runs additional commands in current job
    ssh                 Start an SSH session on the remote workspace
    pull                Pull job artifacts from build workspace to local disk
    push                push job artifacts to build workspace from local disk
    fullbuild           Start a new sandbox build. For use with CI (e.g., Jenkins)
    localrun            Run build commands on local machine
    discard             discard a user workspace
    getlog              Show logs of current (or previous) build
    fetchdiagnostics    Show system logs for build
    devspace            Start an SSH session on the remote devspace
    clone               Clone or destroy a project source into a devspace location

optional arguments:
  -h, --help            show this help message and exit
  -c CONFIGFILE, --configFile CONFIGFILE
                        Config file to use for the command. If not provided, this file is searched in the parent directories and at $HOME/crave.conf
  -q, --quiet           Silence HTTPS warnings. Also do not show progress bar when downloading artifacts.
  -v, --verbose         print out verbose messages
  -n, --noUpdate        Do not check for crave updates

```

### crave version

Prints the version of crave you are using.

```text
$ crave version
crave 0.2-6591 darwin/x86_64
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

This mode runs the build commands provided on the command-line
and preserves the workspace at the end of the build which enables
users to pull the artifacts back to local disk after the build
is complete. It also allows users to run incremental builds.

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
$ crave stop --help
usage: crave stop [-h] [--projectID PROJECTID] [--force] [--ssh] [--all]
                  [ids [ids ...]]

positional arguments:
  ids                   one or more job ids of the jobs to stop

optional arguments:
  -h, --help            show this help message and exit
  --projectID PROJECTID
                        ID of the project for which jobs should be stopped
  --force               Force-stop all jobs queued or running on this
                        workspace
  --ssh                 Stop all ssh sessions on this workspace
  --all                 Stop all ssh sessions and jobs running on this
                        workspace
```

When a job ID is provided as a parameter, crave will only stop that job. To stop more than one jobs, the job IDs could be provided as a list. If a job ID is not specified, crave will stop any jobs running on the current workspace (for the current directory).

```text
crave stop 5102
```

By default, `crave stop` will only stop the running build jobs on this workspace. To stop SSH sessions, use the `--ssh` option
```text
crave stop --ssh
```

To stop all jobs and SSH sessions, use the `--all` flag.

### crave discard

Crave allows you to proactively delete your workspace without waiting for the default workspace GC cycle to clean it up.

```text
$ crave discard --help
usage: crave discard [-h] --current-workspace [--projectID PROJECTID] [-y]

optional arguments:
  -h, --help            show this help message and exit
  --current-workspace, --current-ws
                        delete the current workspace
  --projectID PROJECTID
                        Id of the project to build
  -y, --yes             Silence the confirmation question
```

`crave discard` shows a confirmation question and success message.
```text
$ crave discard --current-ws
This action will discard the current workspace. Continue? [Y/n] y
workspace deleted successfully
```

If the workspace does not exist, then `crave discard` would show the following message
```text
$ crave discard --current-ws
This action will discard the current workspace. Continue? [Y/n]
workspace has already been deleted
```

## Customizing build configuration with `crave.yml`
Crave supports yaml file `crave.yaml` which allows users to
-- override certain project settings (such as docker image used for build and artifacts to be downloaded after build)
-- add user-specific files which are not a part of source repository

`crave.yaml` does not need to be added to source repository for crave to use it.

Following are the fields for `crave.yaml`
- `image`
This is used to override the `Build Image` specified in `Project Configuration`
```text
$ cat crave.yaml
Linux kernel:
  image: "accupara/lkbuild@sha256:c31ec38936e30bce9ed7355bb428ab8173900c0c4e7b3f5ff626d195b0484d73"
```

- `artifacts`
  This can be used to override the `Build Artifacts` specified in `Project Configuration`
```text
$ cat crave.yaml
rsync:
  artifacts: ["compat.o" ,"io.o"]
```

- `include_files`
This is used to create patch for custom files in a user's workspace.
```text
$ cat crave.yaml
protocolbuffers:
  include_files:
   - testFile
   - Makefile.custom
```

- `workspace_per_branch`
This is set to `True` to ensure that same workspace is used across different branches.
If it is not set, unique workspaces are used for different branches.
```text
$ cat crave.yaml
linkerd:
  workspace_per_branch: True
```

- `env`
This tag can be used to add custom environment variables to `crave run` or to the SSH sessions.
```text
$ cat crave.yaml
MyProject:
  env:
    key1: value1
    key2: value2
```


Crave supports configuring multiple projects using the same `crave.yaml` file
```text
$ cat crave.yaml
Linux kernel:
  image: "accupara/lkbuild@sha256:c31ec38936e30bce9ed7355bb428ab8173900c0c4e7b3f5ff626d195b0484d73"
rsync:
  include_files:
   - testfile1
   - testfile2
```
