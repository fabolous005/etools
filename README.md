# etools

bash library for gentoo utils

## How to use

```bash
source etools
```

## Configuration

etools searches for a configuration file at the following locations:
```shell
/etc/etools/etools.conf
$HOME/.config/etools.conf
$HOME/.config/etools/etools.conf
```

## What it does

provided function are the following:
```bash
einfo <info>
ewarn <warning>
eerror <error>
etools_configure
etools_unset
etools_smart_find <package name> [repo]
```

