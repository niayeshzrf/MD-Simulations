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
srun pmemd.cuda -O -i md1.in -o md6.out -c md5.rst -p *.prmtop -r md6.rst -x md6.nc -inf $SLURM_SUBMIT_DIR/mdinfo -ref md5.rst

# COPY FILE PRODUCTION RUN 200 ns
srun cp $SCRATCH/md6.out $SLURM_SUBMIT_DIR
srun cp $SCRATCH/md6.rst $SLURM_SUBMIT_DIR
srun cp $SCRATCH/md6.nc $SLURM_SUBMIT_DIR


# PRODUCTION RUN 200 ns
srun pmemd.cuda -O -i md1.in -o md7.out -c md6.rst -p *.prmtop -r md7.rst -x md7.nc -inf $SLURM_SUBMIT_DIR/mdinfo -ref md6.rst

# COPY FILE PRODUCTION RUN 200 ns
srun cp $SCRATCH/md7.out $SLURM_SUBMIT_DIR
srun cp $SCRATCH/md7.rst $SLURM_SUBMIT_DIR
srun cp $SCRATCH/md7.nc $SLURM_SUBMIT_DIR




echo Remove scratch
srun rm -rf $SCRATCH
