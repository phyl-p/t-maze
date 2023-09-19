#!/bin/bash
#SBATCH -p standard
#SBATCH -A levylab
#SBATCH --time=6:00:00
#SBATCH --job-name=PatsLearned
#SBATCH --output=OutputsSLURM/%A%x%a.out #%x=job name; %A=jobid
#SBATCH --mail-type=end
#SBATCH --mail-user=jhl8sb@virginia.edu
#SBATCH --nodes=1                #Number of nodes
#SBATCH --ntasks-per-node=20     #Number of cores per node

# Load Matlab environment
module load matlab

# Run Matlab parallel program program
matlab -nodisplay -nosplash  \
-r "tic; addpath('Helpers');\
RetrieveResultsPatternsLearned('Uni');\
RetrieveResultsPatternsLearned('Bid');\
disp('elapsed time');disp(toc) ;\
exit;"




