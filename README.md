Shell-based IRC client

Requires the `nc` utility, standard on Mac OS X (in fact, the whole thing probably is probably hardcoded to just work on Mac OS X).

Usage:

* connect with `bin/connect server port nick`
* join channel with `bin/join %channelname`
	* When you join %channel, writing to the file `io/%channel.in` sends to the channel, and `io/%channel.out` will be what's said in the channel (tail -f works nicely for viewing it).
* leave channel with `bin/part %channelname`
* quit with `bin/quit`

Notes:

* The API uses % because # is a comment character in bash. So use % where # is expected.
* Make sure to part all channels before you quit, or you will have rogue processes!