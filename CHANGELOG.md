# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- 1.5x scale (36px) cursors for HiDPI setups
- Standard CSS/freedesktop cursor aliases (`grab`, `grabbing`, `ns-resize`,
  `ew-resize`, `nesw-resize`, `nwse-resize`, `nw-resize`, `ne-resize`,
  `se-resize`, `sw-resize`, `dnd-ask`, `dnd-link`, `bd_double_arrow`,
  `fd_double_arrow`, `top_left_arrow`, `up_arrow`)
- Containerized build via `make build/docker` for hosts without inkscape or
  xcursorgen
- bats test suite (`make test`) covering build outputs, index.theme and
  install/uninstall staging

### Changed
- Build scripts rewritten in strictly POSIX sh (`build.sh` replaces both the
  old bash script and `build.py`)
- `make install` honors `PREFIX` and `DESTDIR` and defaults to
  `/usr/local/share/icons` instead of `~/.icons`

### Fixed
- `make clean` (the target was previously missing its rule) and repeated
  `make install` nesting the theme directory
- `size-bdiag`, `size-fdiag`, `size-hor` and `size-ver` aliases now point at
  their real counterparts instead of `default`
- Recoloring no longer overwrites the X logo color with the Wayland logo
  color when `--logo-color` is not passed

## [2.0.1] - 2018-02-24
### Added
- Makefile
### Changed
- Improved documentation

## [2.0.0] - 2016-05-08
### Changed
- col-resize
- row-resize
- e-resize
- w-resize
- n-resize
- s-resize
- left-arrow
- right-arrow
- up-arrow
- down-arrow
- ne-resize
- se-resize
- sw-resize
- nw-resize

## [2.0.0] - 2015-03-20
### Added
- Initial release
