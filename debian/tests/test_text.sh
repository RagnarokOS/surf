#!/bin/sh

HTML=/usr/share/doc/autopkgtest/README.package-tests.html
RST=/usr/share/doc/autopkgtest/README.package-tests.rst.gz

cd "$AUTOPKGTEST_ARTIFACTS"

# start surf and wait a bit
surf "$HTML" &
PID=$!
sleep 3
xdotool search --onlyvisible --class Surf windowfocus

# take screenshot and OCR it
scrot --focused surf.png
kill "$PID"
tesseract surf.png surf

# compare texts
cat surf.txt | tr -c -d "[A-Za-z0-9]" > txt1
CHARS=$(wc -c < txt1)
zcat "$RST"  | tr -c -d "[A-Za-z0-9]" | head -c "$CHARS" > txt2
# convert to lines to make it better diffable
sed 's/\(.\)/\1\n/g' -i txt1 txt2
DIFFERENCES=$(diff -u txt1 txt2 | grep -c ^[+-])

if [ $CHARS -lt 500 ]; then
	echo "Too few characters detected ($CHARS)"
	exit 1
fi

# allow 1% "error", as OCR does not detect some characters correctly
LIMIT=$((CHARS / 100))
if [ $DIFFERENCES -gt $LIMIT ]; then
	echo "Too many differences in the text ($DIFFERENCES/$CHARS)"
	exit 1
fi

echo "Text has $CHARS characters and $DIFFERENCES detected errors"

exit 0
