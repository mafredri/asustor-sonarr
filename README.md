# sonarr-apkg

![Sonarr](https://raw.githubusercontent.com/mafredri/sonarr-apkg/master/source/CONTROL/icon.png)

Sonarr develop branch for ASUSTOR ADM. To be used in conjunction with newer
[Mono version](https://github.com/mafredri/mono-apkg) (3.10.0, at the time of writing).

## Features

* Latest Sonarr develop branch (Bittorrent support!)
* Built-in automatic updates
* Does not interfere with NzbDrone package (runs on port 8990)
* Can migrate existing configuration from NzbDrone
* Self-contained configuration (stored in /usr/local/AppCentral/sonarr/config)
* Lightweight, only the required libs present.

## Word of caution

If your configuration from NzbDrone is migrated to Sonarr and NzbDrone was running master branch, the migrated
configuration files will be incompatible with the master branch. This means that the configuration will only work with
the develop branch until it is made stable and merged into master.

**Note:** this does not mean your NzbDrone configuration will be lost, it just means that any configuration done in Sonarr
will not be backwards compatible with NzbDrone!

## Links

* ASUSTOR [App Central](http://www.asustor.com/apps?lan=en)
* ASUSTOR [Developer Corner](http://developer.asustor.com/)
* Sonarr [homepage](https://sonarr.tv/)
