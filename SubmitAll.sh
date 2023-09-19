#!/bin/bash

JOBSTR_PreK=($(sbatch SubmitNpatPresetK.slurm))
echo ${JOBSTR_PreK[*]}

JID_PreK=${JOBSTR_PreK[-1]}


JOBSTR_Both=($(sbatch --dependency=afterok:$JID_PreK SubmitBothRules.slurm))
echo ${JOBSTR_Both[*]}

JID_Both=${JOBSTR_Both[-1]}

sbatch --dependency=afterok:$JID_Both SubmitGetPatternsLearned.slurm