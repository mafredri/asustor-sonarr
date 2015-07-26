#!/bin/bash

EIX="eix -*neI --format '<installedversions:NAMEVERSION>' -A"

ROOT=$(cd "$(dirname "${0}")" && pwd)
VERSION=$(<version.txt)
# Merge i386 and x86-64?
MERGE=1

# This defines the arches available and from where to fetch the files
# ARCH:PREFIX
ADM_ARCH=(
    "x86-64:/cross/x86_64-asustor-linux-gnu"
    "i386:/cross/i686-asustor-linux-gnu"
)

# Set hostname (ssh) from where to fetch the files
HOST=asustorx

cd "$ROOT"

if [[ ! -d dist ]]; then
    mkdir dist
fi

for arch in "${ADM_ARCH[@]}"; do
    cross=${arch#*:}
    arch=${arch%:*}

    echo "Building ${arch} from ${HOST}:${cross}"

    # Check package versions
    packages=$(<packages.txt)
    echo "# This file is auto-generated." > "pkgversions_$arch.txt"
    for package in $packages; do
        version=$(ssh ${HOST} "EIX_PREFIX=${cross} ${EIX} ${package}")
        echo "$version" >> "pkgversions_$arch.txt"
    done

    WORK_DIR=build/$arch
    if [ ! -d "$WORK_DIR" ]; then
        mkdir -p "$WORK_DIR"
    fi
    echo "Cleaning out ${WORK_DIR}..."
    rm -rf "$WORK_DIR"
    mkdir "$WORK_DIR"
    chmod 0755 "$WORK_DIR"

    if [ ${MERGE} -eq 0 ]; then
        echo "Copying apkg skeleton..."
        rsync -ra source/ "$WORK_DIR/"
    fi

    echo "Rsyncing files..."
    for file in $(<files.txt); do
        FILEDIR=$(dirname "$file")
        FILEPATH=${FILEDIR#/usr}
        if [ ! -d "${WORK_DIR}${FILEPATH}" ]; then
            mkdir -p "${WORK_DIR}${FILEPATH}"
        fi
        rsync -ra ${HOST}:"${cross}${file}*" "${WORK_DIR}${FILEPATH}/"
    done

    if [ ${MERGE} -eq 0 ]; then
        echo "Finalizing..."
        echo "Setting version to ${VERSION}"
        sed -i '' -e "s^ADM_ARCH^${arch}^" -e "s^APKG_VERSION^${VERSION}^" "$WORK_DIR/CONTROL/config.json"

        echo "Building APK..."
        # Clean up...
        find "$WORK_DIR" -name ".DS_Store" -exec rm {} \;
        # APKs require root privileges, make sure priviliges are correct
        sudo chown -R 0:0 "$WORK_DIR"
        sudo scripts/apkg-tools.py create "$WORK_DIR" --destination dist/
        sudo chown -R "$(whoami)" dist

        # Reset permissions on working directory
        sudo chown -R "$(whoami)" "$WORK_DIR"

        echo "Done!"
    fi

done

if [ ! ${MERGE} -eq 0 ]; then
    WORK_DIR=build

    echo "Copying apkg skeleton..."
    rsync -ra source/ $WORK_DIR/

    echo "Finalizing..."
    echo "Setting version to ${VERSION}"
    sed -i '' -e "s^ADM_ARCH^any^" -e "s^APKG_VERSION^${VERSION}^" $WORK_DIR/CONTROL/config.json

    echo "Building APK..."
    # Clean up...
    find $WORK_DIR -name ".DS_Store" -exec rm {} \;
    # APKs require root privileges, make sure priviliges are correct
    sudo chown -R 0:0 $WORK_DIR
    sudo scripts/apkg-tools.py create $WORK_DIR --destination dist/
    sudo chown -R "$(whoami)" dist

    # Reset permissions on working directory
    sudo chown -R "$(whoami)" $WORK_DIR

    echo "Done!"
fi


# #!/bin/bash

# FETCH_PACKAGES=0

# show_help() {
#     echo "Options:
#   -f    Fetch packages instead of using local ones
#   -h    This help"
#     exit 0
# }

# while getopts :fgh opts; do
#    case $opts in
#         f)
#             FETCH_PACKAGES=1
#             ;;
#         h)
#             show_help
#             ;;
#    esac
# done


# ROOT=$(cd $(dirname "${0}") && pwd)
# PACKAGE=$(basename "${ROOT}")
# NAME=$(<name.txt)
# VERSION=$(<version.txt)

# # This defines the arches available and from where to fetch the files
# # ARCH:PREFIX
# ADM_ARCH=(
#     "x86-64:/cross/x86_64-asustor-linux-gnu"
#     #"i386:/cross/i686-asustor-linux-gnu"
# )

# # Set hostname (ssh) from where to fetch the files
# HOST=asustorx

# cd $ROOT

# if [[ ! -d dist ]]; then
#     mkdir dist
# fi

# for arch in ${ADM_ARCH[@]}; do
#     cross=${arch#*:}
#     arch=${arch%:*}

#     echo "Building ${arch} from ${HOST}:${cross}"

#     # Create temp directory and copy the APKG template
#     PKG_DIR=build/packages/$arch
#     if [ ! -d $PKG_DIR ]; then
#         mkdir -p $PKG_DIR
#     fi
#     if [ $FETCH_PACKAGES -eq 1 ]; then
#         echo "Rsyncing packages..."
#         rsync -ram --delete --include-from=packages.txt --exclude="*/*" --exclude="Packages" $HOST:$cross/packages/* $PKG_DIR
#         PKG_INSTALLED=$(cd $PKG_DIR; ls -1 */*.tbz2 | sort)
#         echo -e "# This file is auto-generated.\n${PKG_INSTALLED//.tbz2/}" > pkgversions_$arch.txt
#     else
#         echo "Using cached packages..."
#     fi

#     WORK_DIR=build/$arch
#     if [ -d $WORK_DIR ]; then
#         echo "Cleaning out ${WORK_DIR}..."
#         rm -rf $WORK_DIR
#         rm -rf $WORK_DIR
#     fi

#     mkdir -p $WORK_DIR

#     chmod 0755 $WORK_DIR

#     echo "Copying apkg skeleton..."
#     cp -af source/* $WORK_DIR

#     echo "Unpacking files..."
#     TMP_DIR=$(mktemp -d /tmp/$PACKAGE.XXXXXX)
#     (cd $TMP_DIR; for pkg in $ROOT/$PKG_DIR/*/*.tbz2; do tar xjf $pkg; done)

#     (cd $TMP_DIR;
#         rsync -ra usr/local/AppCentral/${NAME}/ .;
#         rm -rf usr/local/AppCentral/${NAME};
#         # Cleanup
#         rmdir usr/local/AppCentral;
#         rmdir usr/local
#         # Ultraflat
#         rsync -rav usr/ .
#         rsync -rav lib64/ lib/
#         rm -rf lib64
#         rm -rf usr bin include share)

#     rsync -ra $TMP_DIR/ $WORK_DIR/
#     rm -rf $TMP_DIR/

#     echo "Finalizing..."
#     echo "Setting version to ${VERSION}"
#     sed -i '' -e "s^ADM_ARCH^${arch}^" -e "s^APKG_VERSION^${VERSION}^" $WORK_DIR/CONTROL/config.json

#     echo "Building APK..."
#     # APKs require root privileges, make sure priviliges are correct
#     sudo chown -R 0:0 $WORK_DIR
#     sudo scripts/apkg-tools.py create $WORK_DIR --destination dist/
#     sudo chown -R $(whoami) dist

#     # Reset permissions on working directory
#     sudo chown -R $(whoami) $WORK_DIR

#     echo "Done!"
# done
