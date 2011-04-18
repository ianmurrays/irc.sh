#!/usr/bin/env bash

function usage () {
	echo "usage: $0 connect <server> <port> <nick>"
	echo "       $0 join    <channel>"
	echo "       $0 part    <channel>"
	echo "       $0 quit"
	echo "       note: for your convenience, any occurrences of '%'"
	echo "             in channel names will be replaced with '#'"
	exit 1
}

IRCDIR="$(dirname $0)/var"

INDIR="$IRCDIR/in"
OUTDIR="$IRCDIR/out"
PIDSDIR="$IRCDIR/pids"

function is_irc_alive () {
	kill -0 $(head -n1 "$PIDSDIR/main") 2> /dev/null
}

case "$1" in
	connect )
		HOST=$2
		PORT=$3
		NICK=$4
		
		rm -rf "$IRCDIR"

		mkdir -p "$INDIR"
		mkdir -p "$OUTDIR"
		mkdir -p "$PIDSDIR"

		mkfifo "$INDIR/main"

		nc $HOST $PORT <> "$INDIR/main" > "$OUTDIR/main" &
		echo $! > "$PIDSDIR/main"
		
		echo "NICK $NICK" >> "$INDIR/main"
		echo "USER $NICK 8 * : $NICK" >> "$INDIR/main"
		
		echo -n 'logging in...'
		
		until grep -qE "001 $NICK :" "$OUTDIR/main" || ! is_irc_alive
		do
			echo -n
		done
		
		if is_irc_alive; then
			echo 'success'
		else
			echo 'fail'
			exit 2
		fi
		
		(tail -f "$OUTDIR/main" & echo $! >&3) 3>> "$PIDSDIR/main" | grep --line-buffered '^PING ' | sed 's/^PING/PONG/' &
		
		;;
	quit )
		echo QUIT > "$INDIR/main"
		
		cat "$PIDSDIR/main" | xargs kill

		rm -rf "$IRCDIR"
		
		;;
	join )
		CHAN="$2"
		PROPERCHAN="${CHAN//%/#}"

		echo "JOIN $PROPERCHAN" >> "$INDIR/main"

		mkfifo "$INDIR/$CHAN"
		(cat <> "$INDIR/$CHAN" & echo $! >&3) 3>>"$PIDSDIR/$CHAN" | sed -l "s/^/PRIVMSG $PROPERCHAN : /" >> "$INDIR/main" &

		(tail -f "$OUTDIR/main" & echo $! >&3) 3>>"$PIDSDIR/$CHAN" | grep --line-buffered "PRIVMSG $PROPERCHAN" | sed -lE 's/:([^!]+)![^:]+:(.+)/<\1> \2/' >> "$OUTDIR/$CHAN" &
		
		;;
	part )
		CHAN="$2"
		PROPERCHAN="${CHAN//%/#}"

		echo "PART $PROPERCHAN" >> "$INDIR/main"

		cat "$PIDSDIR/$CHAN" | xargs kill
		rm "$IRCDIR"/*/"$CHAN"
		
		;;
	* )
		usage
		;;
esac