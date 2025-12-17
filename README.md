# dotfiles

I don't know how any of this works, I just use Nix to look smart.

The basic framework was originally based off of [nmasur's
dotfiles](https://github.com/nmasur/dotfiles/tree/master). I would recommend
looking there for examples and documentation, as their configuration is
probably more applicable and tweakable than this, but there might be something
helpful here. :)

## Goals

- Have each host declared as a single file, containing a single bare attribute set (not a function returning one).
- Have a single, generic "make configuration" function that works to merge the host file for every host type (NixOS, Home-Manager, Nix-Darwin).
- Heavily opinionate while maintaining modularity.
- Use filesystem paths as data.
- Maximalism is next to godliness.
- More lines of code more gooder.
- Use as few external flakes as possible.
- Complexity is beauty.
- No stochastic hallucination machines allowed.
- Wunkify everything.
- Document nothing.
- Learn something new every day.

## Layout

All paths are relative from the root of this repository.

### Setup stuff

| File / directory        | Purpose |
| ----------------------- | ------- |
| `flake.nix`             | Define Nix system configurations |
| `lib/default.nix`       | Define Nix functions and constants used in the flake. Also available to all modules through `config.lib.dotfiles`. |

### Modules

Module files must end in `-module.nix` to be automatically imported into system configurations.

| File / directory                        | Purpose |
| --------------------------------------  | ------- |
| `modules/`                              | Store modules by configuration type (e.g. NixOS, Home-Manager). |
| `modules/*/`                            | Store modules by namespace (e.g. "wunkus", the primary namespace for all custom modules). |
| `modules/*/*/settings-module.nix`       | Define settings potentially used by all other modules in the namespace. This should not be enableable or change any config. |
| `modules/home-manager/wunkus/presets/`  | Store modules defining preset configurations for individual programs or services. |
| `modules/home-manager/wunkus/profiles/` | Store modules defining overarching configurations that enable and apply broad swaths of good stuff. |
| `modules/**/data/`                      | Store non-Nix code and arbitrary data files. Should have subdirectories that specify which module the data is used for. |
| `modules/**/${module_name}/`            | Store extra Nix code to be used by the matching module but not to be imported by the top-level system configs. |

### Hosts

| File / directory                | Purpose |
| ------------------------------- | ------- |
| `hosts/`                        | **In progress** |

## TODO

- Rework module sets to be more clear: difference between presets, profiles, etc. has been muddied.
- Keep overridden packages up to date and remove when obsolete. They should always be marked with TODO in code.
- Figure out a solution for no-framework zsh that works with plugins that generate runtime files.
