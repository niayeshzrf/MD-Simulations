#!/bin/bash
#SBATCH -n 1
#SBATCH --gres=gpu:1
#SBATCH -J 7K4U-ts
#SBATCH --time=5-00:00:00 
#SBATCH --no-requeue 
module load Amber/Amber18_Ambertools19_CUDA-8.0.44
##AQUI HAY QUE PONER LO DEL SCRATCH
SCRATCH=/scratch/$USER/$SLURM_JOB_ID
echo Creating temp dir $SCRATCH
srun mkdir -p $SCRATCH || exit $?
echo Coping files. srun cp is equivalent to loop over each node + scp
srun cp -r $SLURM_SUBMIT_DIR/*.in  $SCRATCH
srun cp -r $SLURM_SUBMIT_DIR/*.prmtop  $SCRATCH
srun cp -r $SLURM_SUBMIT_DIR/*.rst  $SCRATCH 
cd $SCRATCH

# PRODUCTION RUN 200 ns
srun pmemd.cuda -O -i md1.in -o md4.out -c md3.rst -p *.prmtop -r md4.rst -x md4.nc -inf $SLURM_SUBMIT_DIR/mdinfo -ref md3.rst

# COPY FILE PRODUCTION RUN 200 ns
srun cp $SCRATCH/md4.out $SLURM_SUBMIT_DIR
srun cp $SCRATCH/md4.rst $SLURM_SUBMIT_DIR
srun cp $SCRATCH/md4.nc $SLURM_SUBMIT_DIR


## PRODUCTION RUN 200 ns
srun pmemd.cuda -O -i md1.in -o md5.out -c md4.rst -p *.prmtop -r md5.rst -x md5.nc -inf $SLURM_SUBMIT_DIR/mdinfo -ref md4.rst

# COPY FILE PRODUCTION RUN 200 ns
srun cp $SCRATCH/md5.out $SLURM_SUBMIT_DIR
srun cp $SCRATCH/md5.rst $SLURM_SUBMIT_DIR
srun cp $SCRATCH/md5.nc $SLURM_SUBMIT_DIR




echo Remove scratch
srun rm -rf $SCRATCH
