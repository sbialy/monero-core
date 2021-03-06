#!/bin/bash

BUILD_TYPE=$1
if [ -z $BUILD_TYPE ]; then
    BUILD_TYPE=Release
fi


source ./utils.sh
pushd $(pwd)
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MONERO_DIR=monero
MONEROD_EXEC=monerod

# Build libwallet if monero folder doesnt exist
if [ ! -d $MONERO_DIR ]; then 
    $SHELL get_libwallet_api.sh $BUILD_TYPE
fi
 
if [ ! -d build ]; then mkdir build; fi

if [ "$BUILD_TYPE" == "Release" ]; then
	CONFIG="CONFIG+=release";
  BIN_PATH=release/bin
else
	CONFIG="CONFIG+=debug"
  BIN_PATH=debug/bin
fi


# Platform indepenent settings
platform=$(get_platform)
if [ "$platform" == "linux32" ] || [ "$platform" == "linux64" ]; then
    distro=$(lsb_release -is)
    if [ "$distro" == "Ubuntu" ]; then
        CONFIG="$CONFIG libunwind_off"
    fi
fi

if [ "$platform" == "darwin" ]; then
    BIN_PATH=$BIN_PATH/monero-core.app/Contents/MacOS/
elif [ "$platform" == "mingw64" ] || [ "$platform" == "mingw32" ]; then
    MONEROD_EXEC=monerod.exe
fi

cd build
qmake ../monero-core.pro "$CONFIG"
make 

# Copy monerod to bin folder
if [ "$platform" != "mingw32" ]; then
cp ../$MONERO_DIR/bin/$MONEROD_EXEC $BIN_PATH
fi

# make deploy
popd

