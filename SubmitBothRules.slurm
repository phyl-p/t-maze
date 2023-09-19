#!/bin/bash
#SBATCH --array=[10-19,30-39] #this will submit 50 seeds; originally array=10-49 which submitted 100 seeds
#SBATCH -p standard
#SBATCH -A levylab
#SBATCH --time=12:00:00
#SBATCH --job-name=Both
#SBATCH --output=OutputsSLURM/%A%x%a.out #%x=job name; %A=jobid
#SBATCH --mail-type=end
#SBATCH --mail-user=jhl8sb@virginia.edu
#SBATCH --nodes=1                #Number of nodes
#SBATCH --ntasks-per-node=20     #Number of cores per node

if [ $SLURM_ARRAY_TASK_ID -le 29 ]; then # if ($SATI <= 10)
  RULENAME=Bid
  idx=$[${SLURM_ARRAY_TASK_ID}-9 ]
else
  RULENAME=Uni
  idx=$[${SLURM_ARRAY_TASK_ID}-29]
fi

echo "$RULENAME-$idx"


NPAT=10:2:60

SEED=$[$idx*5-4]:$[idx*5]

SESSION=${RULENAME}_npat${NPAT}seed${SEED}

# Load Matlab environment
module load matlab

# Run Matlab parallel program program
matlab -nodisplay -nosplash  \
-r "\
pwd;\
disp('$SESSION');\
attempt_count = 0;\
attempt_limit = 15;\
errorfname=['OutputsFailedTasks/${SLURM_JOB_ID}-failed_task_id','$SLURM_ARRAY_TASK_ID'];\
while attempt_count<attempt_limit;\
  try;\
    parpool('local',19);\
    attempt_count = attempt_limit;\
  catch;\
    attempt_count = attempt_count+1;\
    warning(['parpool init failed ',num2str(attempt_count),\
             ' time',(attempt_count~=1)*'s']) ;\
    if attempt_count == attempt_limit ;\
      errortype='all attempts failed. quitting';\
      warning(errortype);\
      save([errorfname,'-P'],'errortype');\
      exit;\
    end;\
  end;\
end;\
\
\
try;\
  Main('$RULENAME',$NPAT,$SEED);\
catch EM;\
  rethrow(EM);\
  errortype='error occured at Main()';\
  save([errorfname,'-M'],'errortype');\
end;\
\
\
exit;"




