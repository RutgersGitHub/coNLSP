#!/bin/bash

main()
{
  if [ ! -z "$1" ] && [ -e $1 ]
  then

    source $1

  else

    echo Please provide a configuration file.
    exit

  fi

  ###################### No modifications below this line are necessary ###########################

  cd $MAINDIR

  TOTAL=`cat $FILENAME | wc -l`

  # Creating Text and LHE file
  for (( i = 1; i <= $TOTAL; i = i+1 ))
  do

    j=`cat $FILENAME | awk -v number=$i '{if (number == NR) print $1}'`
    k=`cat $FILENAME | awk -v number=$i '{if (number == NR) print $2}'`
    l=`cat store/info/GravitinoMasses.txt | awk -v chargino=${j} -v gluino=${k} '{if ($1 == chargino && $2 == gluino) print $3}'`

    NAME="${TAG}_${NAMEONE}${j}_${NAMETWO}${k}"
    echo "1 5000 13.0D3 ${l} ${NAME}.slha ${NAME}.txt ${NAME}.lhe" | ./test/${TAG}.out

  done
}

main ${1}
