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
srun cp -r $SLURM_SUBMIT_DIR/*.inpcrd  $SCRATCH 
cd $SCRATCH

##MINIMIZATIONS

srun pmemd.cuda -O -i min1.in -o min1.out -c *.inpcrd -p *.prmtop -r min1.rst -ref *.inpcrd

## COPY FILES OUTPUT MINIMIZATION 1 
srun cp $SCRATCH/min1.rst $SLURM_SUBMIT_DIR 
srun cp $SCRATCH/min1.out $SLURM_SUBMIT_DIR

srun pmemd.cuda -O -i min2.in -o min2.out -c min1.rst -p *.prmtop -r min2.rst -ref min1.rst

## COPY FILES OUTPUT MINIMIZATION 2 
srun cp $SCRATCH/min2.rst $SLURM_SUBMIT_DIR
srun cp $SCRATCH/min2.out $SLURM_SUBMIT_DIR


## HEATING PROCESS

srun pmemd.cuda -O -i heating_T_50.in -o heating_T_50.out -c min2.rst -p *.prmtop -r heating_T_50.rst -x heating_T_50.mdcrd -ref min2.rst

srun pmemd.cuda -O -i heating_T_100.in -o heating_T_100.out -c heating_T_50.rst -p *.prmtop -r heating_T_100.rst -x heating_T_100.mdcrd -ref heating_T_50.rst

srun pmemd.cuda -O -i heating_T_150.in -o heating_T_150.out -c heating_T_100.rst -p *.prmtop -r heating_T_150.rst -x heating_T_150.mdcrd -ref heating_T_100.rst

srun pmemd.cuda -O -i heating_T_200.in -o heating_T_200.out -c heating_T_150.rst -p *.prmtop -r heating_T_200.rst -x heating_T_200.mdcrd -ref heating_T_150.rst

srun pmemd.cuda -O -i heating_T_250.in -o heating_T_250.out -c heating_T_200.rst -p *.prmtop -r heating_T_250.rst -x heating_T_250.mdcrd -ref heating_T_200.rst

srun pmemd.cuda -O -i heating_T_300.in -o heating_T_300.out -c heating_T_250.rst -p *.prmtop -r heating_T_300.rst -x heating_T_300.mdcrd -ref heating_T_250.rst

## COPY FILES OUTPUT HEATING
srun cp $SCRATCH/heating_T*.out $SLURM_SUBMIT_DIR
srun cp $SCRATCH/heating_T*.rst $SLURM_SUBMIT_DIR
srun cp $SCRATCH/heating_T*.mdcrd $SLURM_SUBMIT_DIR

## EQUILIBRATION1(10 ns NPT)

srun pmemd.cuda -O -i equil1.in -o equil1.out -c heating_T_300.rst -p *.prmtop -r equil1.rst -x equil1.nc -ref heating_T_300.rst 

## COPY FILES OUTPUT EQUILIBRATION1(10 ns NPT)
srun cp $SCRATCH/equil1.out $SLURM_SUBMIT_DIR 
srun cp $SCRATCH/equil1.rst $SLURM_SUBMIT_DIR
srun cp $SCRATCH/equil1.nc $SLURM_SUBMIT_DIR

## EQUILIBRATION2(10 ns NVT)
srun pmemd.cuda -O -i equil2.in -o equil2.out -c equil1.rst -p *.prmtop -r equil2.rst -x equil2.nc -inf $SLURM_SUBMIT_DIR/mdinfo -ref equil1.rst

## COPY FILE OUTPUT EQUILIBRATION2(10 ns NVT)
srun cp $SCRATCH/equil2.out $SLURM_SUBMIT_DIR
srun cp $SCRATCH/equil2.rst $SLURM_SUBMIT_DIR
srun cp $SCRATCH/equil2.nc $SLURM_SUBMIT_DIR

## PRODUCTION RUN 200 ns
srun pmemd.cuda -O -i md1.in -o md1.out -c equil2.rst -p *.prmtop -r md1.rst -x md1.nc -inf $SLURM_SUBMIT_DIR/mdinfo -ref equil2.rst

## COPY FILE PRODUCTION RUN 200 ns
srun cp $SCRATCH/md1.out $SLURM_SUBMIT_DIR
srun cp $SCRATCH/md1.rst $SLURM_SUBMIT_DIR
srun cp $SCRATCH/md1.nc $SLURM_SUBMIT_DIR

echo Remove scratch
run rm -rf $SCRATCH
