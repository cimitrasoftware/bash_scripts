#!/bin/bash
echo "-------------------------"
echo "[ Your Message is Below ]"
echo ""
echo $@
echo ""
echo "[ Message Delievered! ]"
echo "------------------------"
say() { local IFS=+;/usr/bin/mplayer -ao alsa -really-quiet -noconsolecontrols 1> /dev/null 2>/dev/null  "http://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=$*&tl=en"; } 1> /dev/null 2> /dev/null
say $* 1> /dev/null 2> /dev/null


