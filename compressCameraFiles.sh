#!/bin/sh 

zip="C:/Program Files/7-Zip/7z.exe"
target="$1"

echo "Starting at `date`"

pause () {
	echo -n "Appuyer sur une touche pour continuer... "
        read v
}

LOCKFILE=/tmp/compressCameraFiles.lock

get_locker ()
{
    head -1 $LOCKFILE
}

take_lock ()
{
    echo $$ >> $LOCKFILE
    _locker=`get_locker`
    if ! [ "$_locker" = $$ ]
    then
	# try to see if the locker still exists
	_proc=`ps agux | awk '{ print $2}' | grep "$_locker"`
	if [ "$_proc" = "" ]
	then
	    # locker has died? Let's take the lock
	    echo "Locker seems dead. Trying to take it..."
	    rm -f $LOCKFILE
	    take_lock
	    return $?
	fi
	return 1
    fi
    return 0
}

release_lock ()
{
    _locker=`get_locker`
    if [ "$_locker" = $$ ]
    then
	rm -f $LOCKFILE
    else
	echo "Cannot unlock '$lockfile'. Am not the locker!" >&2
    fi
}

if ! take_lock
then
    # cannot take the lock, exit
    echo "Cannot take lock. Exiting..." >&2
    exit 1
fi

if [ "`uname -a | grep Linux`" != "" ]
then
    mount ~pi/Box 2>/dev/null
    target="/home/pi/Box/Perso/Cameras"
else
    net use z: https://dav.box.com/dav /savecred /persistent:yes > /dev/null 2>&1
    target="Z:/Perso/Cameras"
fi

if [ ! -d "$target" ]
then
   echo "Cannot find '$target'"
   pause
   exit
fi

status () {
	echo " $1/$2 files moved (`expr $1 '*' 100 / $2`%)"
}

list_files () {
  echo "$1"/*.jpg | grep -v '*'
}

nbfiles () {
  echo `files "$1"` | wc -w
}

cd "$target"
for c in *
  do
  echo "Found camera: '$c'."
  files=`list_files "$c"`

#  cd K:/Downloads/Ext??rieur_Old.zip
#  /bin/ls -l K:/Downloads/Ext*Old.zip
#  "$zip" l K:/Downloads/Ext*Old.zip | /bin/awk '{print $6}' | /bin/awk -F'\' '{print "'"$c"'_Old/" $2}' | /bin/grep -v -e '/$' | /bin/grep -v -e '2[12]$' | /bin/sed -e s/_Old/Old/g

#files=`  "$zip" l K:/Downloads/Ext*Old.zip | /bin/awk '{print $6}' | /bin/awk -F'\' '{print "'"$c"'_Old/" $2}' | /bin/grep -v -e '/$' | /bin/grep -v -e '2[12]$' | /bin/sed -e s/_Old/Old/g`
#/bin/echo $files

  max=10
  n=`echo $files | wc -w`
  if [ $n -eq 0 ]
  then
    echo "No file to move."
  fi
  while [ $n -gt 0 ]
    do
    echo "Found $n file(s) to move."
    i=1
    for f in $files
      do
      echo -n '.'
      if [ `expr $i % $max` = 0 ]
      then  
	status $i $n
      fi
      i=`expr $i + 1`
      rep=`awk 'BEGIN { 
        split("'"$f"'",t,"_"); 
	d=t[3];
	year=substr(d,1,4);
	month=substr(d,5,2);
	day=substr(d,7,2);
	hour=substr(d,9,2);
	printf("%s/%s-%s-%s/%sh", "'"$c"'", year, month, day, hour);
	}' < /dev/null`
      mkdir -p $rep
      mv $f $rep
      done
      if [ `expr $i % $max` != 1 ]
      then
        status $n $n
      fi
    files=`list_files "$c"`
    n=`echo $files | wc -w`
    done
  done


release_lock

exit 0



