# sonarr-apkg

![Sonarr](https://raw.githubusercontent.com/mafredri/sonarr-apkg/master/source/CONTROL/icon.png)

Sonarr for ASUSTOR ADM.

## Features

* Built-in automatic updates
* Can migrate existing configuration from NzbDrone
* Self-contained configuration (stored in /usr/local/AppCentral/sonarr/config)

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
