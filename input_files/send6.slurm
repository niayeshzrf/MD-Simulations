#!/bin/bash
#SBATCH -n 1
#SBATCH --gres=gpu:1
#SBATCH --time=5-00:00:00 
#SBATCH --no-requeue 
module load Amber/Amber18_Ambertools19_CUDA-8.0.44

##HERE YOU HAVE TO PUT THE SCRATCH
SCRATCH=/scratch/$USER/$SLURM_JOB_ID
echo Creating temp dir $SCRATCH
srun mkdir -p $SCRATCH || exit $?
echo Coping files. srun cp is equivalent to loop over each node + scp
srun cp -r $SLURM_SUBMIT_DIR/*.in  $SCRATCH
srun cp -r $SLURM_SUBMIT_DIR/*.prmtop  $SCRATCH
srun cp -r $SLURM_SUBMIT_DIR/*.rst  $SCRATCH 
cd $SCRATCH

# PRODUCTION RUN 200 ns
srun pmemd.cuda -O -i md1.in -o md10.out -c md9.rst -p *.prmtop -r md10.rst -x md10.nc -inf $SLURM_SUBMIT_DIR/mdinfo -ref md9.rst

# COPY FILE PRODUCTION RUN 200 ns
srun cp $SCRATCH/md10.out $SLURM_SUBMIT_DIR
srun cp $SCRATCH/md10.rst $SLURM_SUBMIT_DIR
srun cp $SCRATCH/md10.nc $SLURM_SUBMIT_DIR

echo Remove scratch
srun rm -rf $SCRATCH
