# dotfiles

I don't know how any of this works, I just use Nix to look smart.

The basic framework was originally based off of [nmasur's
dotfiles](https://github.com/nmasur/dotfiles/tree/master). I would recommend
looking there for examples and documentation, as their configuration is
probably more applicaple and tweakable than this, but there might be something
helpful here. :)

## Goals

- Have each host declared as a single file, containing a single bare attribute set (not a function returning one).
- Have a single, generic "make configuration" function that works to merge the host file for every host type (NixOS, Home-Manager, Nix-Darwin).
- Heavily opinionate while maintaining modularity.
- Use filesystem paths as data.
- Maximalism is next to Godlinism.
- More lines of code more gooder.
- Use as few external flakes as possible.
- Complexity is beauty.
- No LLMs (gross) allowed.
- Wunkify everything.
- Document nothing.
- Learn something new every day.

## TODO

- Rework module sets to be more clear: difference between presets, profiles, etc. has been muddied.
- Keep overridden packages up to date and remove when obsolete. They should always be marked with TODO in code.
- Figure out a solution for no-framework zsh that works with plugins that generate runtime files.
