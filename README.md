# compnav-eshell

[compnav](https://github.com/mrcnski/compnav) for eshell. Instead of relying on an external `fzf` binary, this package aims to instead leverage whatever completion framework the user has configured.

## TODO

- [ ] Use a custom completion sort function that makes sense for paths (prioritize matches higher up in the dir hierarchy).
- [ ] Implement `--select-1` and `--exit-0` using the number of matches based on the initial input, before invoking `completing-read`.
