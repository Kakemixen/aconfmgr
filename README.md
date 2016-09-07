# aconfmgr: A configuration manager for Arch Linux

`aconfmgr` is a package to track, manage, and restore the configuration of an Arch Linux system.
Its goals are:

- Quickly configure a new system, or restore an existing system according to a saved configuration
- Track temporary/undesired changes to the system's configuration
- Identify obsolete packages and maintain a lean system

`aconfmgr` tracks the list of installed packages (both native and external), as well as changes to configuration files (`/etc/`).
Since the system configuration is described as shell scripts, it is trivially extensible.

![screenshot](https://dump.thecybershadow.net/8172adadc91ceb38588eb22581f485d9/composed.png)

## Usage

### First run

Run `aconfmgr save` to transcribe the system's configuration to the `config` directory.

This will create the file `config/99-unsorted.sh`, as well as other files describing the system configuration. You should review the contents of `99-unsorted.sh`, and sort it into one or more new files (e.g.: `10-base.sh`, `20-drivers.sh`, `30-gui.sh`, `50-misc.sh` ...). The files should have a `.sh` extension, and use `bash` syntax. I suggest adding a comment for each package describing why installing the package was needed, so it is clear when the package is no longer needed and can be removed.

During this process, you may identify packages or system changes which are no longer needed. Do not sort them into your configuration files - instead, delete the file `99-unsorted.sh`, and run `aconfmgr apply`. This will synchronize the system state against your configuration, thus removing the omitted packages. (You will be given a chance to confirm all changes before they are applied.)

Note: you don't need to run `aconfmgr` via `sudo`. It will elevate as necessary by invoking `sudo` itself.

### Maintenance

The `config` directory should be versioned using a version control system (e.g. Git). Ideally, the file `99-unsorted.sh` should not be versioned - it will only be created when the current configuration does not reflect the current system state, therefore indicating that there are system changes that have not been accounted for.

Periodic maintenance consists of running `aconfmgr save`; if this results in uncommitted changes to the `config` directory, then there are unaccounted system changes. The changes should be reviewed, sorted, documented, committed and pushed.

### Restoring

To restore a system to its earlier state, or to set up a new system, simply make sure the correct configuration is in the `config` directory and run `aconfmgr apply`. You will be able to preview and confirm any actual system changes.

## Modus operandi

The `aconfmgr` script has two subcommands:

- `aconfmgr save` saves the difference between current system's configuration and the configuration described by the `config` directory back to the `config` directory.
- `aconfmgr apply` applies the difference between the configuration described by the `config` directory and the current system's configuration, installing/removing packages and creating/editing configuration files.

The `config` directory contains shell scripts, initially generated by the `save` subcommand, and then usually edited by the user. Evaluating these scripts will *compile* a system configuration description in the `output` directory. The difference between that directory's contents, and the actual current system configuration, dictates the actions ultimately taken by `aconfmgr`.

`aconfmgr save` will write the difference to the file `config/99-unsorted.sh` as a series of shell commands which attempt to bring the configuration up to date with the current system. When starting with an empty configuration, this difference will consist of the entire system description. Since the script only appends to that file, it may end up undoing configuration changes done earlier in the scripts (e.g. removing packages from the package list). It is up to the user to refactor the configuration to remove redundancies, document changes, and improve maintainability.

`aconfmgr apply` will apply the differences to the actual system.

The contracts of both commands are that they are mutually idempotent: after a successful invocation of either, invoking either command immediately after will be a no-op.

### Packages

Background: On Arch Linux, every installed package is installed either explicitly, or as a dependency for another package. Packages can also have mandatory (hard) or optional dependencies. You can view this information using `pacman -Qi <package>` ("Install Reason", "Depends On", "Optional Deps").

`aconfmgr` only tracks explicitly-installed packages, ignoring their hard dependencies. Therefore:

- `aconfmgr save` will only save installed packages that are marked as explicitly installed.
- Installed packages that are neither explicitly installed, nor are hard dependencies of other installed packages, are considered prunable orphans and will be removed.
- Packages that are only optional dependencies of other packages must be listed explicitly, otherwise they will be pruned.
- `aconfmgr apply` removes unlisted packages by unpinning them (setting their install reason as "installed as a dependency"), after which it prunes all orphan packages. If the package is still required by another package, it will remain on the system (until it is no longer required); otherwise, it is removed.
- Packages that are installed and explicitly listed in the configuration will have their install reason set to "explicitly installed".

## Advanced Usage

### Ignoring some changes

#### Ignoring files

Some files will inevitably neither belong to or match any installed packages, nor can be considered part of the system configuration. This can include:

* Temporary / cache / auto-generated / lock / pipe / pid / timestamp / database / backup / log files
* Files managed by third-party package managers, esp. programming languages' package managers (pip, gem, npm)
* Virtual machine disk images

Other files may not be desirable to include in the managed system configuration because they are security-sensitive (e.g. sshd private keys).

To declare a group of files to be ignored by `aconfmgr`, add the path mask to the `ignore_paths` array, e.g.:

```bash
ignore_paths+=('/var/lib/pacman/local/*') # package metadata
ignore_paths+=('/var/lib/pacman/sync/*.db') # repos
ignore_paths+=('/var/lib/pacman/sync/*.db.sig') # repo sigs
```

#### Ignoring packages

To ignore the presence of some packages on the system, add the package names to the `ignore_packages` array:

```bash
ignore_packages+=(linux-git)
```

`aconfmgr save` will not update the configuration based on ignored packages' presence or absence, and `aconfmgr apply` will not install or uninstall them. The packages should also not be present in the configuration's package list, of course. To ignore a foreign package (e.g. a non-AUR foreign package), add its name to the `ignore_foreign_packages` array.

### Managing multiple systems

You can use the same `config` repository to manage multiple sufficiently-similar systems. One way of doing so is e.g. Git branches (having one main branch plus one branch per machine, and periodically merge in changes from the main branch into the machine-specific branches); however, it is simpler to use shell scripting:

```bash
packages+=(coreutils)
# ... more common packages ...

if [[ "$HOST" == "home.example.com" ]]
then
	packages+=(nvidia)
	packages+=(nvidia-utils)
	# ... more packages only for the home system ...
fi
```
