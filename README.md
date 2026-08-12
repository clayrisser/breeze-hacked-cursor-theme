# breeze-hacked-cursor-theme

> Official cursor theme for Jam OS

![](assets/breeze-hacked-cursor-theme.png)

Please &#9733; this repo if you found it useful &#9733; &#9733; &#9733;


## Features

* Compatible with most Linux window managers
* Animated cursors
* HiDPI support (1x, 1.5x and 2x scales)
* [Supports custom color schemes](#recoloring)


## Installation

```sh
# system-wide (installs to /usr/local/share/icons)
sudo make install

# current user only (installs to ~/.local/share/icons)
make install PREFIX=~/.local
```

`install` honors `PREFIX` and `DESTDIR`, so packagers can stage the theme
with `make install DESTDIR=/tmp/pkgroot PREFIX=/usr`. `make uninstall`
removes it again.


## Building

Building renders `src/cursors.svg` with [Inkscape](https://inkscape.org) and
assembles the cursors with
[xcursorgen](https://www.x.org/archive/X11R7.7/doc/man/man1/xcursorgen.1.xhtml),
so both must be installed:

```sh
make
```

On hosts without the render tools (e.g. macOS, where xcursorgen is not
available), build inside a container instead:

```sh
make build/docker
```


## Recoloring

Before building and installing, run the following:

```sh
# Replace values with hex codes of desired colors
./recolor-cursor.sh --accent-color "#012345" --base-color "#6789ab" --border-color "#cdef10" --logo-color "#111213"
```

For more information, run the following:

```sh
./recolor-cursor.sh --help
```


## Development

```sh
make prepare  # install the pinned dev toolchain (shfmt, bats) via asdf
make test     # run the bats test suite against the built theme
make format   # format shell scripts
make lint     # check shell script formatting
```


## Support

Submit an [issue](https://gitlab.com/bitspur/misc/breeze-hacked-cursor-theme/-/issues/new)


## Screenshots

![breeze-hacked-cursor-theme](https://user-images.githubusercontent.com/6234038/36633597-7dcf9e4e-1990-11e8-8d28-e0495db37c0e.png)


## Contributing

Review the [guidelines for contributing](CONTRIBUTING.md)


## License

[GPL 2.0 License](LICENSE)


## Changelog

Review the [changelog](CHANGELOG.md)


## Credits

* Ken Vermette <vermette@gmail.com> - Cursor Author
* Hugo Pereira Da Costa <hugo.pereira@free.fr> - Kstyle Developer
* Andrew Lake <jamboarder@gmail.com> - Kstyle Designer
* Uri Herrera <kaisergreymon99@gmail.com> - Breeze Icon Theme
* [Clay Risser](https://clayrisser.com) - Contributor
