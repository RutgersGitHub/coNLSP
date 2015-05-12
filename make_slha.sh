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

  TOTAL=`cat $FILENAME | wc -l`

  cd $MAINDIR

  # Appending lines to condor configuration file
  for (( i = 1; i <= $TOTAL; i = i+1 ))
  do

    j=`cat $FILENAME | awk -v number=$i '{if (number == NR) print $1}'`
    k=`cat $FILENAME | awk -v number=$i '{if (number == NR) print $2}'`

    NAME="${TAG}_${NAMEONE}${j}_${NAMETWO}${k}"
    echo ${NAME}

    coNLSPSLHAproducer $j $k $DELTA $NAME

    rm ${NAME}.hwg
    rm ${NAME}.dat
    mv ${NAME}.slha store/slha/.

  done
}

coNLSPSLHAproducer()
{
  # Bino, Wino, and Gluino masses (Gaugino masses)
  echo "Input M2, M3, and M1 (Wino, Gluino, Bino masses) separated by single spaces, followed by [ENTER]:"
  M2=$1
  M3=$2
  M1=`echo $(echo "0.5*${M2}" | bc) | awk '{printf("%.0f", $1)}'`

  # Delta value which is the mass splitting between right-handed stau and
  # right handed sleptons (i.e. selectron and smuon)
  DELTA=$3

  # Name for hwg, dat, and slha files
  echo "Input the name of the slha file to be generated, followed by [ENTER]:"
  FILENAMEINPUT=$4

  # Higgsino mass (in TeV) and Tangent Beta
  echo "Input Mu (Higgsino mass) and TANBETA, separated by a single space, followed by [ENTER]:"
  MU="5000"
  TANBETA="3"

  # Right and Left Handed Slepton and Squark Masses
  echo "Input MeR, MeL, and MQ (Left and Right Handed Slepton and Squark Masses) separated by single spaces, followed by [ENTER]:"
  MSLEPR=`echo $(echo "0.3*${M2}" | bc) | awk '{printf("%.0f", $1)}'`
  MSLEPL=`echo $(echo "0.8*${M2}" | bc) | awk '{printf("%.0f", $1)}'`
  MQ=`echo $(echo "0.8*${M3}" | bc) | awk '{printf("%.0f", $1)}'`

  # Right and Left Handed Stau, Right handed Sbottom and Stop, and Sbottom-Stop doublet masses
  echo "Input MtauR, MtauL, MBR, BTR, MQ3 (Left and Right Handed Stau, Right handed Sbottom, and Stop, and Stop-Sbottom Doublet Masses) separated by single spaces, followed by [ENTER]:"
  MSTAUR=`echo $(echo "${MSLEPR}-${DELTA}" | bc) | awk '{printf("%.0f", $1)}'`
  MSTAUL=${MSLEPL}
  MBR=${MQ}
  MTR=${MQ}
  MQ3=${MQ}

  # Gravitino mass
  echo "Input MGRAV (Gravitino Mass in units of GeV in 1E-9 notation) separated by single spaces, followed by [ENTER]:"
  GRAVITINOTEMP1=`echo "scale=2;2500*(sqrt(1/13))*(sqrt(${MSTAUR}/100))*(sqrt(${MSTAUR}/100))*(sqrt(${MSTAUR}/100))*(sqrt(${MSTAUR}/100))*(sqrt(${MSTAUR}/100))" | bc`
  GRAVITINOTEMP2=`printf "%0.f\n" ${GRAVITINOTEMP1}`

  GRAVITINOMASS=$((GRAVITINOTEMP2))E-12

  # Printing out the Gravitino mass
  GRAVITINOTEMP3="`echo "${GRAVITINOTEMP2}*0.001" | bc`"
  echo ${M2} ${M3} ${GRAVITINOTEMP3}  >> store/info/GravitinoMasses.txt

  # Setting up parameters needed for GMSBneut.sh
  PARAM1="${M1} ${M2} ${M3}"
  PARAM2="${MU} ${TANBETA}"
  PARAM3="${MSLEPR} ${MSLEPL} ${MQ}"
  PARAM4="${MSTAUR} ${MSTAUL} ${MBR} ${MTR} ${MQ3}"
  PARAM5="${GRAVITINOMASS}"

  MUTERM=${MU}
  TANB=${TANBETA}

  MER=${MSLEPR}
  MEL=${MSLEPL}
  MQL1=${MQ}

  MTAUR=${MSTAUR}
  MTAUL=${MSTAUL}
  MBR=${MBR}
  MTR=${MTR}
  MQL3=${MQ3}

  MGRAV=${GRAVITINOMASS}

  MUR=${MQL1}
  MDR=${MQL1}

  XT=0
  XB=0
  XL=0

  T=`echo "scale = 2;${XT}+(${MUTERM}/${TANB})" | bc`
  AT=`printf "%0.f\n" $T`
  B=`echo "scale = 2;${XB}+${MUTERM}*${TANB}" | bc`
  AB=`printf "%0.f\n" $B`
  L=`echo "scale = 2;${XL}+${MUTERM}*${TANB}" | bc`
  AL=`printf "%0.f\n" $L`

  MTOP=172
  MAPOLE=5000

  outputfile="${FILENAMEINPUT}.dat"
  slhafile="${FILENAMEINPUT}.slha"
  herwigfile="${FILENAMEINPUT}.hwg"

  params1="${MTOP}"
  echo ${params1}

  params2="${M3},${MUTERM},${MAPOLE},${TANB}"
  echo ${params2}

  params3="${MQL1},${MDR},${MUR},${MEL},${MER}"
  echo ${params3}

  params4="${MQL3},${MBR},${MTR},${MTAUL},${MTAUR},${AT},${AB},${AL}"
  echo ${params4}

  params5="${MQL1},${MDR},${MUR},${MEL},${MER}"
  echo ${params5}

  params6="${M1},${M2}"
  echo ${params6}

  params7="${MGRAV}"
  echo ${params7}

# Calling isasusy.x (Do not alter indentation)
./ISAGMSB/isasusy.x <<EOF

${outputfile}
${slhafile}
${herwigfile}
${params1}
${params2}
${params3}
${params4}
${params5}
${params6}
${params7}

EOF
}

main ${1}
