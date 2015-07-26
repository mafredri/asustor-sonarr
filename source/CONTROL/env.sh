#!/bin/sh

NAME=Sonarr
PACKAGE=sonarr
PKG_PID=nzbdrone.pid
USER=admin
GROUP=administrators

PKG_PATH=/usr/local/AppCentral/${PACKAGE}
DAEMON_USER="${USER}:${GROUP}"

export PKG_BIN_PATH=${PKG_PATH}/bin
export PKG_LD_LIBRARY_PATH=$PKG_PATH/lib
export PKG_CONF_ROOT=${PKG_PATH}/config
export PKG_CONF=${PKG_CONF_ROOT}

export LD_LIBRARY_PATH=${PKG_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}
