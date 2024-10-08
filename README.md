# etools

bash library for gentoo utils

## How to use

Just source it!

```bash
source etools
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
# repo can be a path relative to /var/db/repos/ or a full path
# default will be /var/db/repos/ so all repos will be searched
eools_get_version <package name> [offset]
# offset will output the <offset> latest version
# eg.: when 1.2.3 is latest offset 1 will result in a version 1 beneath 1.2.2-r2 for example
etools_current_version <package> [index]
# get currently installed version of a package
# it'll show all version, by specifying the index the n'th version starting at 0 will be displayed
# btw feel free to time all of them ;)
```

## Configuration

etools searches for a configuration file at the following locations:

```shell
/etc/etools/etools.conf
$HOME/.config/etools.conf
$HOME/.config/etools/etools.conf
```

Look at [the exmaple configuration file](etools.conf) for an example with all configuration options.

For the default values take a look at [config.sh](config.sh).

> **_NOTE:_** Letting already set options fallback to defaults will not work, as defaults only get set when the relative variables are undefined. To force reload:

```bash
etools_unset
source etools
```

## Motivation

They say "A picture is worth a thousand words", so here ya go:

![](https://github.com/fabolous005/etools/blob/main/assets/motivation.png?raw=true)

## Test it

This script reads all packages in your world file and runs etools_smart_find with the name of the package

```bash
while IFS= read -r line; do
    if [[ ${line%% *} == ${line##* }  ]]; then
        echo -e "${line%% *} \e[32mpassed\e[0m";
    else
        echo -e "${line%% *} \e[31mFAILED\e[0m";
    fi;
done <<< $(
    for pkg in $(cat /var/lib/portage/world); do
        echo -n "$pkg ";
        etools_smart_find $(echo $pkg | awk -F'/' '{print $2}');
    done
);
```
