#!/bin/bash
#SBATCH -p standard
#SBATCH -A levylab
#SBATCH --time=8:00:00
#SBATCH --job-name=SingleTask
#SBATCH --output=OutputsSLURM/%A-%x%a.out #%x=job name; %A=jobid
#SBATCH --mail-type=end
#SBATCH --mail-user=jhl8sb@virginia.edu


# Load Matlab environment
module load matlab

# Run Matlab parallel program program
matlab -nodisplay -nosplash  \
-r "\
MainSingleTask ;exit;"




