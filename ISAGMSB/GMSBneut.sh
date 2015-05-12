#!/bin/bash

echo "Input the name of the slha file to be generated, followed by [ENTER]:"
read filename

echo "Input M1, M2, and M3 (Bino, Wino, and Gluino masses) separated by single spaces, followed by [ENTER]:"
read  M1 M2 M3

echo "Input Mu (Higgsino mass) and TANBETA, separated by a single space, followed by [ENTER]:"
read MUTERM TANB

echo "Input MeR, MeL, and MQ (Left and Right Handed Slepton and Squark Masses) separated by single spaces, followed by [ENTER]:"
read MER MEL MQL1

echo "Input MtauR, MtauL, MBR, BTR, MQ3 (Left and Right Handed Stau, Right handed Sbottom, and Stop, and Stop-Sbottom Doublet Masses) separated by single spaces, followed by [ENTER]:"
read MTAUR MTAUL MBR MTR MQL3

echo "Input MGRAV (Gravitino Mass in units of GeV in 1E-9 notation) separated by single spaces, followed by [ENTER]:"
read MGRAV

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

outputfile="${filename}.dat"
slhafile="${filename}.slha"
herwigfile="${filename}.hwg"

params1="${MTOP}"
params2="${M3},${MUTERM},${MAPOLE},${TANB}"
params3="${MQL1},${MDR},${MUR},${MEL},${MER}"
params4="${MQL3},${MBR},${MTR},${MTAUL},${MTAUR},${AT},${AB},${AL}"
params5="${MQL1},${MDR},${MUR},${MEL},${MER}"
params6="${M1},${M2}"
params7="${MGRAV}"

  echo ${params1}
  echo ${params2}
  echo ${params3}
  echo ${params4}
  echo ${params5}
  echo ${params6}
  echo ${params7}

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

rm ${filename}.hwg
