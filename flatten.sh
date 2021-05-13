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
mkdir src/lib8tion
mv src/math8.h src/random8.h src/scale8.h src/trig8.h src/lib8tion/
rm -rf LICENSE
mkdir LICENSE
find "$compdir" -name LICENSE > /dev/shm/RusLicense.txt
for x in $(cat /dev/shm/RusLicense.txt); do
   cp "$x" LICENSE/$(dirname "$x" | sed 's|.*/||')
done
rm -rf examples
cp -a "$srcdir/examples" examples
rm -rf src-md
mkdir src-md
find "$srcdir" -maxdepth 1 -name "*.md" -exec cp {} src-md \;
mv src-md/README.md src-md/src-README.md
mv src-md/* .
find "$compdir" -name Kconfig -exec grep -e config -e default {} > /dev/shm/helper \;
echo -e "\n// Arduino helpers for CONFIG_ entries" >> src/esp_idf_lib_helpers.h
awk '/config/ {config=toupper($1) "_" $2}; /default/ {print "#ifndef " config "\n#define " config " " $2 "\n#endif\n"}' /dev/shm/helper >> src/esp_idf_lib_helpers.h
vi src/esp_idf_lib_helpers.h
echo "library flattened.  Make sure to increment library.properties before pushing"
