#!/bin/bash

export HOME=/pfs/nobackup$HOME

DATES=( 22032020-2145 23032020-1945 24032020-1525 25032020-1445 26032020-0949 27032020-1414 29032020-1014 30032020-1354 31032020-1354 01042020-1614 02042020-1534 03042020-1457 04042020-1357 05042020-2317 07042020-1302 08042020-1622 09042020-1642 10042020-1722 11042020-2203 )

for DATE in "${DATES[@]}"
do
   : 
   echo $DATE

   export DATE=$DATE
   export DATA_PATH="$HOME/sequencer/src/Continuous_Learning/processed/$i"
   export THREAD_ID="greedy-1"
   export LEARNING_RATE=0.125


   RET=`sbatch $DEPENDENCY_PARAM jobscript-greedy`

   JOB_ID=`echo $RET | sed 's/Submitted batch job \([0-9]*\)/\1/'`
   DEPENDENCY_PARAM="--dependency=afterok:$JOB_ID" 

done