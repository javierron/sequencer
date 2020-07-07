#!/bin/bash

export HOME=/pfs/nobackup$HOME

MODELS=( final-model_step_10000.pt final-model_step_10500.pt final-model_step_11000.pt final-model_step_11500.pt final-model_step_12000.pt )

for i in "${!MODELS[@]}"
do
   : 

   export THREAD_ID="pilot1"
   export MODEL_PATH=${MODELS[$i]}
   export RESULT_PATH="$HOME/sequencer/src/Continuous_Learning/Codrep_Results/pilot1/augment-$i"
   
   echo "$THREAD_ID/$MODEL_PATH"

   sbatch jobscript-single-translate

done