#!/bin/bash
DEST=../../ironmon_tracker/extensions/
if [ ! -d $DEST/ironbot ]; then
    mkdir $DEST/ironbot
fi
for FILE in $(ls | grep '\.lua$' | xargs); do
    echo "Copying ${FILE} to ${DEST}..."
    cp $FILE $DEST
done
echo "Copying ironbot folder to ${DEST}..."
cp -r ironbot $DEST
