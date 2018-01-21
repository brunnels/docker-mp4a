#!/bin/bash
function _jobs_get_count_e {
   jobs -r | wc -l | tr -d " "
}

function _jobs_set_max_parallel {
   g_jobs_max_jobs=$1
}

function _jobs_get_max_parallel_e {
   [[ $g_jobs_max_jobs ]] && {
      echo $g_jobs_max_jobs

      echo 0
   }

   echo 1
}

function _jobs_is_parallel_available_r() {
   (( $(_jobs_get_count_e) < $g_jobs_max_jobs )) &&
      return 0

   return 1
}

function _jobs_wait_parallel() {
   # Sleep between available jobs
   while true; do
      _jobs_is_parallel_available_r &&
         break

      sleep 0.1s
   done
}

function _jobs_wait() {
   wait
}