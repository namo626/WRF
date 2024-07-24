#!/bin/bash
 output=report.%q{SLURM_PROCID}.%q{SLURM_JOBID}

 if [[ ${SLURM_PROCID} == "0" ]] ; then
   dcgmi profile --pause
   ncu --target-processes all --kernel-id :::1 -o ${output} "$@"
   dcgmi profile --resume
 else
   "$@"
 fi
