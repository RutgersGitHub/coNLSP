#!/bin/bash

if [ ! -z "$1" ] && [ -e $1 ]
then

source $1

else

echo Please provide a configuration file.
exit

fi

###################### No modifications below this line are necessary ###########################

TOTAL=`cat $FILENAME | wc -l`

# Creating run script for lxplus batch queue
echo '#!/bin/csh

# This file sets up the cshell for lxplus batch queue
# If you have additional custom enhancements to your shell 
# environment, you may need to add them here

setenv CUR_DIR $PWD

setenv SCRAM_ARCH "slc5_amd64_gcc462"
setenv VO_CMS_SW_DIR "/cms/base/cmssoft"
setenv COIN_FULL_INDIRECT_RENDERING 1

# Change to your CMSSW software version
setenv MYREL "CMSSW_6_2_11"
setenv MYPROJECT "private"
setenv MYBASE "${MYPROJECT}/${MYREL}"

# Shown for c shell
# Also change 'username' to your username
cd /afs/cern.ch/user/e/ecampana/${MYBASE}/src
eval `scramv1 runtime -csh`
date

# Switch to your working directory below
cd $CUR_DIR

# Below run your actual commands... typically a cmsRun call' > scripts/run_${TAG}.csh

chmod a+x scripts/run_${TAG}.csh

# Appending lines to run script for lxplus batch queue
echo -e 'setenv MAINDIR' ${MAINDIR} '\n' >> scripts/run_${TAG}.csh
echo -e 'cd $MAINDIR\n' >> scripts/run_${TAG}.csh
echo 'cmsRun test/Hadronizer_LHE_GEN_62X_cfg.py inputFiles=file:store/lhe/${1}.lhe outputFile=store/aodsim/${1}.root tag=${2}_GEN section=${3} maxEvents=${4} \' >> scripts/run_${TAG}.csh
echo -e '>& store/cmsswlogs/${1}_${2}_GEN.log\n' >> scripts/run_${TAG}.csh

echo 'cmsRun test/Hadronizer_Tune4C_13TeV_madgraph_pythia8_Tauola_cfi_py_GEN_SIM_62X.py inputFiles=file:store/aodsim/${1}_${2}_GEN_numEvent100.root outputFile=store/aodsim/${1}.root tag=${2}_GEN_SIM section=${3} \' >> scripts/run_${TAG}.csh
echo -e '>& store/cmsswlogs/${1}_${2}_GEN_SIM.log\n' >> scripts/run_${TAG}.csh

echo -e 'setenv MYREL "CMSSW_7_0_6_patch1"' >> scripts/run_${TAG}.csh
echo 'setenv MYBASE "${MYPROJECT}/${MYREL}"' >> scripts/run_${TAG}.csh
echo -e 'cd /afs/cern.ch/user/e/ecampana/${MYBASE}/src' >> scripts/run_${TAG}.csh
echo -e 'eval `scramv1 runtime -csh`' >> scripts/run_${TAG}.csh
echo -e 'cd ${MAINDIR}\n' >> scripts/run_${TAG}.csh

echo 'cmsRun test/Hadronizer_SIM_DIGI_L1_DIGI2RAW_HLT_RAW2DIGI_L1Reco_70X_cfg.py inputFiles=file:store/aodsim/${1}_${2}_GEN_SIM.root outputFile=store/aodsim/${1}.root tag=${2}_GEN_SIM_RAW section=${3} \' >> scripts/run_${TAG}.csh
echo -e '>& store/cmsswlogs/${1}_${2}_GEN_SIM_RAW.log\n' >> scripts/run_${TAG}.csh

echo 'cmsRun test/Hadronizer_RAW2DIGI_L1Reco_RECO_EI_70X_cfg.py inputFiles=file:store/aodsim/${1}_${2}_GEN_SIM_RAW.root outputFile=store/aodsim/${1}.root tag=${2}_GEN_SIM_RAW_AODSIM section=${3} \' >> scripts/run_${TAG}.csh
echo -e '>& store/cmsswlogs/${1}_${2}_GEN_SIM_RAW_AODSIM.log\n' >> scripts/run_${TAG}.csh

echo 'cmsRun test/miniAOD-prod_PAT.py inputFiles=file:store/aodsim/${1}_${2}_GEN_SIM_RAW_AODSIM.root outputFile=store/miniaodsim/${1}.root tag=${2}_MINIAODSIM section=${3} \' >> scripts/run_${TAG}.csh
echo '>& store/cmsswlogs/${1}_${2}_MINIAODSIM.log' >> scripts/run_${TAG}.csh

# Job submissions
for (( i = 1; i <= $TOTAL; i = i+1 ))
do

  j=`cat $FILENAME | awk -v number=$i '{if (number == NR) print $1}'`
  k=`cat $FILENAME | awk -v number=$i '{if (number == NR) print $2}'`

  NEVENTS=`cat $FILENAME | awk -v number=$i '{if (number == NR) print $3}'`
  NUM=`echo "scale=2;${NEVENTS}/100+0.5" | bc`
  NJOBS=`echo "$NUM/1" | bc`

  for (( JOB = 1; JOB <= ${NJOBS}; JOB = JOB+1 ))
  do

    NAME="${TAG}_${NAMEONE}${j}_${NAMETWO}${k}"
    EVENT=$(echo "1+(${JOB}-1)*100" | bc)
    ARGUMENT="${NAME} ${JOB} ${EVENT} 100"

    BATCHLOG="batchlogs/${NAME}_${JOB}.stdout"

    echo ${ARGUMENT}

    bsub -q 2nd -J ${NAME} -o ${BATCHLOG} -e ${BATCHLOG} "${MAINDIR}/scripts/run_${TAG}.csh ${ARGUMENT}"

  done
done
