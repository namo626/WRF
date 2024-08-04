#!/bin/bash 
#SBATCH -N 4
#SBATCH -q debug
#SBATCH -t 0:30:00
#  #SBATCH -J codee_test01
#SBATCH -A nintern
#SBATCH --mail-type=ALL
#SBATCH --mail-user=namo26june@gmail.com
#SBATCH -L scratch,cfs
#SBATCH -C gpu
#SBATCH --ntasks-per-node=4
#SBATCH -o run.out
#SBATCH -e run.err
#SBATCH --gpus-per-task=1


ntile=1  #number of OpenMP threads per MPI task; also need to change WRF namelist variable "numtiles"

#n=128
#n=64 # number of MPI ranks
#n=32
#n=16
#n=8
#n=4

 mod_perftools=""              # not using perftools or perftools-lite
 #mod_perftools=perftools-lite  # perftools-lite
#mod_perftools=perftools       # perftools

 use_gprof=0
#use_gprof=0
 [[ $use_gprof -eq 1 ]] && mod_perftools=""

#Modules --------------------------------------------------------------------
module load gpu
module load PrgEnv-nvidia
module load cudatoolkit

#module for WRF file I/O
#order of loading matters!
module load cray-hdf5  #required to load netcdf library
module load cray-netcdf
module load cray-parallel-netcdf
[[ -n ${mod_perftools} ]] && ml perftools-base && ml ${mod_perftools}
 ml -t

#if to run with a wrf executable from modified source codes:
#1. don't load the wrf module
#2. the modified executable (wrf.exe) has to be placed in the rundir 

#OpenMP settings:
 export OMP_NUM_THREADS=$ntile
 export OMP_PLACES=threads
 export OMP_PROC_BIND=spread
 [[ $OMP_NUM_THREADS -gt 1 ]] && export OMP_STACKSIZE=64M  #increase memory segment to store local variables, needed by each thread

#run simulation
#c = number of cpus per task
#(( c = (n / SLURM_JOB_NUM_NODES) <= 128 ? (128 / (n / SLURM_JOB_NUM_NODES)) * 2 : 1 ))
 
if [[ $use_gprof -eq 1 ]]; then
#   e=../../WRF_gprof/main/wrf.exe
   export GMON_OUT_PREFIX='gmon.out'
   rm -rf gmon.out.*
elif [[ -n ${mod_perftools} ]]; then
#   e=../../WRF_perftools/main/wrf.exe
##  e=../../WRF_perftools/main/wrf.exe+pat
   export PAT_RT_EXPERIMENT=samp_pc_time
   export PAT_RT_SAMPLING_INTERVAL=100000
# else
#   e=../../WRF/main/wrf.exe
fi

e=./wrf.exe.oneconds

export PAT_RT_EXPERIMENT=samp_pc_time
export GMON_OUT_PREFIX='gmon.out'
export NVCOMPILER_ACC_NOTIFY=1
export NV_ACC_CUDA_STACKSIZE=65536
export NV_ACC_CUDA_HEAPSIZE=64MB
#srun  --cpu_bind=cores nsys profile -f true -t nvtx,cuda --event-sampling-interval=50 $e
srun  --cpu_bind=cores  $e
#srun ncu $e
#srun  --cpu_bind=cores compute-sanitizer --target-processes all --report-api-errors=no $e

#capture error code
srunval=$?

#Get the total "elapsed seconds"
 if [[ -f rsl.out.0000 ]]; then
   elapsed_seconds=$(awk '/^Timing for / {s+=$(NF-2)}; END {printf("%20.5f\n", s)}' rsl.out.0000)
   echo "Total elapsed seconds: $elapsed_seconds"
 fi

 #[[ $use_gprof -eq 1 ]] && gprof $e -s gmon.out.* && gprof $e gmon.sum > gmon$n.sbm.cold.rpt
 [[ $use_gprof -eq 1 ]] && gprof $e -s gmon.out.* && gprof $e gmon.sum > gmon$n.rpt
  

#rename and save the process 0 out and err files
cp rsl.error.0000 rsl.error_0_$SLURM_JOB_ID
cp rsl.out.0000 rsl.out_0_$SLURM_JOB_ID

if [ $srunval -ne 0 ]; then
    echo "run failed"
    exit 10
fi

