#!/usr/bin/env bash

function usage () {
	echo "usage: $0 connect server port nick"
	echo "       $0 join %channel"
	echo "       $0 part %channel"
	echo "       $0 quit"
	exit 1
}

IRCDIR="$(dirname $0)/io"

INFILE="$IRCDIR/main.in"
OUTFILE="$IRCDIR/main.out"

case "$1" in
	connect )
		HOST=$2
		PORT=$3
		NICK=$4

		mkdir -p "$IRCDIR"

		rm -f "$INFILE"
		mkfifo "$INFILE"

		nc $HOST $PORT <> "$INFILE" > "$OUTFILE" &

		echo "NICK $NICK" >> "$INFILE"
		echo "USER $NICK 8 * : $NICK" >> "$INFILE"
		
		;;
	quit )
		echo QUIT > "$INFILE"

		rm -f "$IRCDIR/"*
		
		;;
	join )
		CHAN="$2"
		PROPERCHAN="${CHAN//%/#}"

		echo "JOIN $PROPERCHAN" >> "$INFILE"

		rm -f "$IRCDIR/$CHAN.in"
		mkfifo "$IRCDIR/$CHAN.in"
		(cat <> "$IRCDIR/$CHAN.in" & echo $! >&3) 3>>"$IRCDIR/$CHAN.pid" | sed -l "s/^/PRIVMSG $PROPERCHAN : /" >> "$INFILE" &

		(tail -f "$OUTFILE" & echo $! >&3) 3>>"$IRCDIR/$CHAN.pid" | grep --line-buffered "PRIVMSG $PROPERCHAN" | sed -lE 's/:([^!]+)![^:]+:(.+)/<\1> \2/' >> "$IRCDIR/$CHAN.out" &
		
		;;
	part )
		CHAN="$2"
		PROPERCHAN="${CHAN//%/#}"

		echo "PART $PROPERCHAN" >> "$INFILE"

		cat "$IRCDIR/$CHAN.pid" | xargs kill
		rm "$IRCDIR/$CHAN".*
		
		;;
	* )
		usage
		;;
esac