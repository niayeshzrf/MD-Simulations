# Molecular Dynamics (MD) Simulations using Amber

## Overview
This guide provides a comprehensive step-by-step protocol for setting up and running molecular dynamics (MD) simulations using **Amber**. The workflow involves preparing input structures, running simulations on an **HPC cluster** using **Slurm**, and post-processing trajectories. This protocol supports long MD simulations (e.g., **2 microseconds or longer**) and is based on **FF19SB force field** with **OPC water model**.

---

## 1. Structure Preparation

Before running MD, prepare the input structure using **Process_PDB.py**:
```bash
python Process_PDB.py <input_pdb> <output_pdb> --remove-solvent --renumber
```
This removes solvent, ligands, **ANISOU** records, and renumbers residues to ensure compatibility with Amber.

Next, convert the **processed PDB** for Amber:
```bash
pdb4amber -i <output_pdb> -o <amber_pdb> --dry
```
This step removes non-standard residues and ensures proper formatting.

### **If ligands are present:**
Prepare ligand parameters using **Antechamber**:
```bash
antechamber -i lig.pdb -fi pdb -o lig.prep -fo prepi -j 4 -at amber -c bcc -nc 0
parmchk2 -i lig.prep -f prepi -o lig.frcmod
```
Verify atom types in `lig.prep` before proceeding.

Ensure hydrogens are properly handled:
```bash
reduce <amber_pdb> -trim > <noH_pdb>
```

---

## 2. System Preparation in **TLeap**
Create a topology file and solvate the system:
```bash
tleap -f tleap.in
```
### **Example `tleap.in` file:**
```
source leaprc.protein.ff19SB
source leaprc.gaff
source leaprc.water.opc
loadamberprep lig.prep
loadamberparams lig.frcmod
mol = loadpdb <noH_pdb>
center mol
solvatebox mol TIP3PBOX 10
charge mol
addions mol Cl- 0
addions mol Na+ 0
saveamberparm mol system.prmtop system.inpcrd
savePdb mol system_solv.pdb
quit
```
This step **solvates** the system, **neutralizes charges**, and generates **topology (`prmtop`) and coordinate (`inpcrd`) files**.

---

## 3. Running Molecular Dynamics Simulations

### **Step 1: Energy Minimization**
Run energy minimization using **equilibration input files**:
```bash
pmemd.cuda -O -i equil1.in -o equil1.out -p system.prmtop -c system.inpcrd -r equil1.rst -ref system.inpcrd
pmemd.cuda -O -i equil2.in -o equil2.out -p system.prmtop -c equil1.rst -r equil2.rst -ref equil1.rst
```

### **Step 2: Gradual Heating**
Gradually heat the system to **300K** in steps (e.g., 50K → 100K → 150K → 200K → 250K → 300K):
```bash
pmemd.cuda -O -i heating_T_50.in -o heating_T_50.out -p system.prmtop -c equil2.rst -r heating_50.rst
pmemd.cuda -O -i heating_T_100.in -o heating_T_100.out -p system.prmtop -c heating_50.rst -r heating_100.rst
pmemd.cuda -O -i heating_T_150.in -o heating_T_150.out -p system.prmtop -c heating_100.rst -r heating_150.rst
pmemd.cuda -O -i heating_T_200.in -o heating_T_200.out -p system.prmtop -c heating_150.rst -r heating_200.rst
pmemd.cuda -O -i heating_T_250.in -o heating_T_250.out -p system.prmtop -c heating_200.rst -r heating_250.rst
pmemd.cuda -O -i heating_T_300.in -o heating_T_300.out -p system.prmtop -c heating_250.rst -r heating_300.rst
```

### **Step 3: Equilibration at 300K**
Perform equilibration at **300K** under **NPT ensemble**:
```bash
pmemd.cuda -O -i md1.in -o md1.out -p system.prmtop -c heating_300.rst -r md1.rst
```
This ensures that the system reaches stable density before production.

### **Step 4: Production MD (e.g., 2 microseconds)**
To run a **long MD simulation**, create multiple restart jobs:
```bash
pmemd.cuda -O -i md1.in -o md1.out -p system.prmtop -c md1.rst -r md2.rst -x md1.nc
pmemd.cuda -O -i md1.in -o md2.out -p system.prmtop -c md2.rst -r md3.rst -x md2.nc
...
```
For **Slurm-based HPC clusters**, submit the MD job using `send.slurm`:
```bash
sbatch send.slurm
```
### **Example `send.slurm` file:**
```
#!/bin/bash
#SBATCH --job-name=MD_run
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --time=48:00:00
#SBATCH --output=md_run.out
#SBATCH --error=md_run.err
#SBATCH --mem=16G

module load amber
pmemd.cuda -O -i md1.in -o md1.out -p system.prmtop -c md1.rst -r md2.rst -x md1.nc
```
Modify `--time=` and `--mem=` as needed for longer runs.

---

## 4. Notes & Best Practices
- **Run on GPUs**: Use `pmemd.cuda` for performance.
- **Extend Simulations**: Use `-x mdX.nc` to output NetCDF trajectory files.
- **Backup data**: Save **restart (`.rst`) and NetCDF (`.nc`)** files regularly.
- **Adjust parameters**: Modify heating/equilibration `.in` files for different systems.
- **Post-processing**: The files `ptraj_top.in` and `ptraj_dcd.in` can be used to create the trajectory and topology files for later analysis.

---

## References
- **Amber**: https://ambermd.org/
- **MD Protocol from Manuscript**: Refer to *MD_Protocol.txt* for additional details.

This workflow was designed to **efficiently set up and run long MD simulations on HPC clusters** using Amber. 🚀


