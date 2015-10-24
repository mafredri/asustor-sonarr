#!/bin/sh

if [ -z "$APKG_PKG_DIR" ]; then
    PKG_DIR=/usr/local/AppCentral/sonarr
else
    PKG_DIR=$APKG_PKG_DIR
fi

# Source env variables
. "${PKG_DIR}/CONTROL/env.sh"

install_sonarr() {
    tar xzf "$PKG_DIR"/.release/NzbDrone.*.tar.gz -C "$PKG_DIR/"
    mv "$PKG_DIR/NzbDrone" "$PKG_DIR/Sonarr"
}

case "${APKG_PKG_STATUS}" in
    install)
        if [ ! -f "$PKG_CONF/config.xml" ]; then
            cp "$PKG_CONF/config_base.xml" "$PKG_CONF/config.xml"
        fi

        # If NzbDrone configuration exists, copy it
        if [ -d /volume1/home/admin/.config/NzbDrone ]; then
            rsync -ra --exclude "config.xml" /volume1/home/admin/.config/NzbDrone/ "$PKG_CONF/"
        fi

        chown -R "$DAEMON_USER" "$PKG_CONF"

        install_sonarr
        ;;
    upgrade)
        rsync -ra "$APKG_TEMP_DIR/config/" "$PKG_CONF/"

        # Restore application or extract included version
        if [ -d "$APKG_TEMP_DIR/Sonarr" ]; then
            cp -af "$APKG_TEMP_DIR/Sonarr" "$PKG_DIR/"
        else
            install_sonarr
        fi
        ;;
    *)
        ;;
esac

chown -R "$DAEMON_USER" "$PKG_DIR/Sonarr"

# Set the NAS ARCH variable
arch=$(uname -m)
if [ "$arch" = "x86_64" ]; then
    AS_NAS_ARCH="x86-64"
elif [ "$arch" = "armv7l" ]; then
    AS_NAS_ARCH="arm"
else
    AS_NAS_ARCH="i386"
fi

# Create appropriate symlinks
(cd "$PKG_DIR";
    for i in $AS_NAS_ARCH/*; do
        name=$(basename "$i")
        if [ -d "$name" ]; then
            for j in $i/*; do
                ln -sf "$j" "./$name/"
            done
        else
            ln -sf "$i" "./"
        fi
    done)

exit 0
