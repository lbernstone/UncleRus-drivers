#! /bin/bash
# Copyright (c) 2021 Larry Bernstone
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

srcdir="$HOME/esp32/3rdparty/UncleRus"
compdir="$srcdir/components"

if [ 0 -ne $(find "$compdir" -name '*.c' -o -name '*.h' |sed 's|.*/||' | sort | uniq -d | wc -c) ]; then
   echo "Duplicate file found.  Will not proceed"
   exit 1
fi
rm -rf src
mkdir src
find "$compdir" -name "*.c" -exec cp {} src/ \;
find "$compdir" -name "*.h" -exec cp {} src/ \;
rm -rf LICENSE
mkdir LICENSE
find "$compdir" -name LICENSE > /dev/shm/RusLicense.txt
for x in $(cat /dev/shm/RusLicense.txt); do
   cp "$x" LICENSE/$(dirname $x | sed 's|.*/||')
done
rm -rf examples
cp -a "$srcdir/examples" examples
rm -rf src-md
mkdir src-md
find "$srcdir" -maxdepth 1 -name "*.md" -exec cp {} src-md \;
mv src-md/README.md src-md/src-README.md
mv src-md/* .
echo "library flattened.  Make sure to increment library.properties before pushing"
