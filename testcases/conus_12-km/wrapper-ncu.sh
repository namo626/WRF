#!/bin/bash
 output=report.%q{SLURM_PROCID}.%q{SLURM_JOBID}

 if [[ ${SLURM_PROCID} == "0" ]] ; then
   ncu --target-processes all --kernel-id :::1 -o ${output} "$@"
 else
   "$@"
 fi
