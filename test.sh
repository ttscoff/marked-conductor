#!/bin/bash

# ./test.sh PATH [pr[eo]]

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
output_file=""
verbose=0

show_help() {
	echo "$(basename $0): Shortcut for testing conductor with a given file"
	echo "Options:"
	echo "  -p [pre|pro] (run as preprocessor(*) or processor)"
	echo "  -o [err|out] (output stderr, stdout, both(*))"
	echo "  -d (debug, only show stderr)"
	echo "Usage:"
	echo "  $0 [-p PHASE] [-o OUTPUT] FILE_PATH"
}

if [[ -d bin ]]; then
	CMD="./bin/conductor"
else
	CMD="$(which conductor)"
fi

PHASE="PREPROCESS"
STD="BOTH"

while getopts "h?p:o:d" opt; do
  case "$opt" in
    h|\?)
      show_help
      exit 0
      ;;
    p)  PHASE=$OPTARG
      ;;
    o)  STD=$OPTARG
      ;;
    d)
 		STD="ERR"
 	  ;;
  esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

if [[ -z $1 ]]; then
	show_help
	exit 1
fi

FILE=$(realpath $1)
FILENAME=$(basename -- "$FILE")
EXTENSION="${FILENAME##*.}"
PHASE=$(echo $PHASE | tr [a-z] [A-Z])
STD=$(echo $STD | tr [a-z] [A-Z])

if [[ $PHASE =~ ^PRE ]]; then
	PHASE="PREPROCESS"
else
	PHASE="PROCESS"
fi

export OUTLINE="NONE"
export MARKED_ORIGIN="$FILE"
export MARKED_EXT="$EXTENSION"
export MARKED_CSS_PATH="/Applications/Marked 2.app/Contents/Resources/swiss.css"
export PATH="$PATH:$(dirname "$FILE")"
export MARKED_PATH="$FILE"
export MARKED_INCLUDES=""
export MARKED_PHASE="$PHASE"

if [[ $STD =~ ^(STD)?E ]]; then
	command cat "$FILE" | $CMD 1>/dev/null
elif [[ $STD =~ ^(STD)?O ]]; then
	command cat "$FILE" | $CMD 2>/dev/null
else
	command cat "$FILE" | $CMD
fi

