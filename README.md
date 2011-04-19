Shell-based IRC client

Requires the `nc` utility, standard on Mac OS X (in fact, the whole thing probably is probably hardcoded to just work on Mac OS X).

Usage:

	$ ./irc.sh connect irc.freenode.net 6667 steven
	logging in...success
	$ ./irc.sh join %ubuntu
	$ tail -f var/out/%ubuntu
	<erUSUL> chogoling: the modification. if it fix your boot problems we can only know when you reboot
	<perlsyntax> or is there a package i need to install?
	<chogoling> thanks erUSUL  and ActionParsnip
	^C
	$ echo 'hi guys! :)' > var/in/%ubuntu
	$ ./irc.sh part %ubuntu
	$ ./irc.sh quit

Notes:

* The API uses % because # is a comment character in bash. So use % where # is expected.
* Make sure to part all channels before you quit, or you will have rogue processes!