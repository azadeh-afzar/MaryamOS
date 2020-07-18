#!/usr/bin/env bash

# generate pixmaps from svg source
SRC="$PWD/src"
THEME="MaryamOS Cursors"

function inkscape() {
  command flatpak run org.inkscape.Inkscape "$@"
}

function create {
	cd "$SRC"
	mkdir -p x1 x1_25 x1_5 x2

	cd "$SRC"/$1
	echo "Generating png files fron svg source, it may take a while ..."
	for f in *.svg;
	do
		inkscape -o "../x1/${f%.svg}.png" -w 32 -h 32 $f > /dev/null 2>&1
		inkscape -o "../x1_25/${f%.svg}.png" -w 40 -h 40 $f > /dev/null 2>&1
		inkscape -o "../x1_5/${f%.svg}.png" -w 48 -h 48 $f > /dev/null 2>&1
		inkscape -o "../x2/${f%.svg}.png" -w 64 -h 64 $f > /dev/null 2>&1
	done
	echo "Generating png files... DONE"
	cd "$SRC"
	

	# generate cursors
	BUILD="$SRC"/../dist
	OUTPUT="$BUILD"/cursors
	ALIASES="$SRC"/cursorList

	if [ ! -d "$BUILD" ]; then
		mkdir "$BUILD"
	fi
	if [ ! -d "$OUTPUT" ]; then
		mkdir "$OUTPUT"
	fi

	echo -ne "Generating cursor theme...\\r"
	for CUR in config/*.cursor; do
		BASENAME="$CUR"
		BASENAME="${BASENAME##*/}"
		BASENAME="${BASENAME%.*}"
		
		xcursorgen "$CUR" "$OUTPUT/$BASENAME"
	done
	echo -e "Generating cursor theme... DONE"

	cd "$OUTPUT"	

	#generate aliases
	echo -ne "Generating shortcuts...\\r"
	while read ALIAS; do
		FROM="${ALIAS#* }"
		TO="${ALIAS% *}"

		if [ -e $TO ]; then
			continue
		fi
		ln -sr "$FROM" "$TO"
	done < "$ALIASES"
	echo -e "Generating shortcuts... DONE"

	cd "$PWD"

	echo -ne "Generating Theme Index...\\r"
	INDEX="$OUTPUT/../index.theme"
	if [ ! -e "$OUTPUT/../$INDEX" ]; then
		touch "$INDEX"
		echo -e "[Icon Theme]\nName=$THEME\n" > "$INDEX"
	fi
	echo -e "Generating Theme Index... DONE"

	# clean up
	cd "$SRC"
	rm -rf x1 x1_25 x1_5 x2
}

create svg

