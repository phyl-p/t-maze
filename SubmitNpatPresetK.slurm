#!/bin/bash
#SBATCH -p standard
#SBATCH -A levylab
#SBATCH --time=6:00:00
#SBATCH --job-name=NPatPresetK
#SBATCH --output=OutputsSLURM/%A%x%a.out #%x=job name; %A=jobid
#SBATCH --mail-type=end
#SBATCH --mail-user=jhl8sb@virginia.edu
#SBATCH --nodes=1                #Number of nodes
#SBATCH --ntasks-per-node=20     #Number of cores per node

TIMESCALE=4
NPAT=10:60

# Load Matlab environment
module load matlab

# Run Matlab parallel program program
matlab -nodisplay -nosplash  \
-r "parpool('local',19)        ;\
tic; NpatPresetK($NPAT,$TIMESCALE)        ;\
disp('elapsed time');disp(toc) ;\
exit;"




