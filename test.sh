#!/bin/bash

# ./test.sh PATH [pr[eo]]

if [[ $# == 0 ]] || [[ $1 =~ ^- ]]; then
	echo "$(basename $0): Shortcut for testing conductor with a given file"
	echo "Usage: $0 PATH [pr[eo]]"
else
	FILE=$(realpath $1)
	PHASE=${2-PREPROCESS}
	PHASE=$(echo $PHASE | tr [a-z] [A-Z])

	if [[ $PHASE =~ ^PRE ]]; then
		PHASE="PREPROCESS"
	else
		PHASE="PROCESS"
	fi

	command cat "$FILE" | OUTLINE="NONE" MARKED_ORIGIN="$FILE" HOME="/Users/ttscoff" MARKED_EXT="mktransient" MARKED_CSS_PATH="/Users/ttscoff/Sync/Synology/Marked/Paddle/Debug/Marked 2.app/Contents/Resources/swiss.css" PATH="/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:$(dirname "$FILE")" MARKED_PATH="$FILE" MARKED_INCLUDES="" US="LANGUAGE" MARKED_PHASE="$PHASE" bin/conductor
fi
