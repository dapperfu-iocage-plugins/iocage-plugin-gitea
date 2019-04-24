#/bin/sh
echo "~~~~~~~~~ Service ~~~~~~~~~"
service -e
echo "~~~~~~~~~ Running Processes ~~~~~~~~~"
ps auxww
echo "~~~~~~~~~ Listening Ports ~~~~~~~~~"
sockstat -l
