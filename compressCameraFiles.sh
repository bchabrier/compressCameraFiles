#!/bin/sh 

zip="C:/Program Files/7-Zip/7z.exe"

pause () {
	/bin/echo -n "Appuyer sur une touche pour continuer... "
        read v
}


net use z: https://dav.box.com/dav /savecred /persistent:yes > /dev/null 2>&1
if [ ! -d Z:/Perso/Cameras ]
then
   echo "Cannot find Z:/Perso/Cameras"
   pause
   exit
fi

status () {
	/bin/echo " $1/$2 files moved (`/bin/expr $1 '*' 100 / $2`%)"
}

list_files () {
  /bin/echo "$1"/*.jpg | /bin/grep -v '*'
}

nbfiles () {
  /bin/echo `files "$1"` | /bin/wc -w
}

cd Z:/Perso/Cameras
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
  n=`/bin/echo $files | /bin/wc -w`
  if [ $n -eq 0 ]
  then
    /bin/echo "No file to move."
  fi
  while [ $n -gt 0 ]
    do
    /bin/echo "Found $n file(s) to move."
    i=1
    for f in $files
      do
      /bin/echo -n '.'
      if [ `/bin/expr $i % $max` = 0 ]
      then  
	status $i $n
      fi
      i=`/bin/expr $i + 1`
      rep=`/bin/awk 'BEGIN { 
        split("'"$f"'",t,"_"); 
	d=t[3];
	year=substr(d,1,4);
	month=substr(d,5,2);
	day=substr(d,7,2);
	hour=substr(d,9,2);
	printf("%s/%s-%s-%s/%sh", "'"$c"'", year, month, day, hour);
	}' < /dev/null`
      /bin/mkdir -p $rep
      /bin/mv $f $rep
      done
      if [ `/bin/expr $i % $max` != 1 ]
      then
        status $n $n
      fi
    files=`list_files "$c"`
    n=`/bin/echo $files | /bin/wc -w`
    done
  done





