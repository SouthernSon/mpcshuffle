#!/bin/bash


getLast()
{
	#Get the number of songs in the current playlist
	mpc playlist | wc -l
}

getCurrent()
{
	#Get the currently playing songs position in the playlist
	#sed is used to prevent wrong output if mpd is stopped
	#(Output will be null instead of wrong line from status)
	mpc -f %position% | head -n 1 | sed -n /^[0-9].*/p
}

#For future use
getStatus()
{
	if $(mpc | grep playing 2>&1 >/dev/null); then
		 echo "playing"
	else
		if $(mpc | grep paused 2>&1 >/dev/null); then
			echo "paused"
		else
			echo "stopped"
		fi
	fi
}

#Sleep in 20 sec intervals unitl mpd is started
while [[ ! -f /var/run/mpd/pid ]]; do
	sleep 20
done

#Start playback in case MPD was in any other state besides play on last shutdown
mpc play

#MPC will idle unitl track change, then check to see if it is the last song, in
#which case MPC will shuffle the playlist.
while true; do
	lastsong=$(getLast)
	currentsong=$(getCurrent)
	#This if just keeps the nested if from throwing an error if
	# currentsong is empty, in case MPD is stopped
	if [ -z $currentsong ]; then
		mpc idle
	else
		if [ $currentsong -eq $lastsong ]; then
			mpc shuffle
		else
			mpc idle
		fi
	fi
done
exit 0
