#!/bin/bash

#if [ "$OS" = "Windows_NT" ]; then
#    ./mingw64.sh
#    exit 0
#fi

# Linux build

make distclean || echo clean

rm -f config.status
./autogen.sh || echo done

# Ubuntu 10.04 (gcc 4.4)
# extracflags="-O3 -march=native -Wall -D_REENTRANT -funroll-loops -fvariable-expansion-in-unroller -fmerge-all-constants -fbranch-target-load-optimize2 -fsched2-use-superblocks -falign-loops=16 -falign-functions=16 -falign-jumps=16 -falign-labels=16"

# Debian 7.7 / Ubuntu 14.04 (gcc 4.7+)
#extracflags="$extracflags -Ofast -flto -fuse-linker-plugin -ftree-loop-if-convert-stores"

#CFLAGS="-O3 -march=native -Wall" ./configure --with-curl --with-crypto=$HOME/usr
#CFLAGS="-O3 -march=native -Wall" CXXFLAGS="$CFLAGS -std=gnu++11" ./configure --with-curl

#CFLAGS="-O3 -march=native -Wall" ./configure --with-curl
extracflags="$extracflags -Wall"

# Crude Arm detection/optimization
processor=$(uname -p)
: ${CC:="gcc"}

# Old / Badly configured gcc don't have march=native and usually ALSO don't have mfpu=neon available in this case, we filter them out
LANG=C
if ${CC} -march=native -Q --help=target 2>&1 |grep -q "unknown architecture"; then
	echo "${CC} does not support -march=native - you should manually optimize your build"
else
	case "${processor}" in
		"aarch64" )
		echo "AArch64 CPU detected"
		extracflags="$extracflags -march=native"
		;;
	
		"armv7l" )
		echo "Armv7 CPU detected"
		extracflags="$extracflags -march=armv7-a -mfpu=neon"
		;;

		* )
	    extracflags="$extracflags -march=native"
		;;
	esac
fi

./configure --with-curl CFLAGS="-O3 $extracflags"

make -j 4

strip -s cpuminer
