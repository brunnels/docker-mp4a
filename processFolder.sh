#!/bin/bash
source "_lib_jobs.sh"

# Script expects movie files to be tagged with the IMDB id last in the filename.  Like:
# Apollo 18 (2011) HDTV-720p x264 DTS tt1772240.mkv

MAX_NPROC=2 # default
USAGE="Manual MP4 Conversion for video files found in a directory.
Usage: `basename $0` [-h] [-j nb_jobs]
    -h      Shows this help
    -j nb_jobs  Set number of simultanious jobs [2]
 Examples:
    `basename $0` /videos
    `basename $0` -j 3 /videos"

# parse command line
if [ $# -eq 0 ]; then #  must be at least one arg
    echo "$USAGE" >&2
    exit 1
fi

while getopts j:rh OPT; do # "j:" waits for an argument "h" doesnt
    case $OPT in
    h)  echo "$USAGE"
        exit 0 ;;
    j)  MAX_NPROC=$OPTARG ;;
    \?) # getopts issues an error message
        echo "$USAGE" >&2
        exit 1 ;;
    esac
done


echo Using $MAX_NPROC parallel threads
shift `expr $OPTIND - 1` # shift input args, ignore processed args
FOLDER=$1
shift
_jobs_set_max_parallel $MAX_NPROC

find "${FOLDER}" -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" \) | while read file; do
  _jobs_wait_parallel

  m_filename=`basename "$file"`
  m_dirname=`dirname "$file"`
  m_basedirname=`basename "$m_dirname"`
  m_filename_wo_ext="${m_filename%.*}"
  imdb=`echo "$m_filename_wo_ext" | rev | cut -d ' ' -f1 | rev`

  if [ ! -d "/outgoing/${m_basedirname}/" ]; then
    echo "Now converting: $m_filename"
    (
        /usr/share/mp4_automator/manual.py -i "${file}" -imdb ${imdb} -m "/outgoing/${m_basedirname}/"
    ) > "/outgoing/${m_filename_wo_ext}.log" &
  else
    echo "$m_filename already converted"
  fi

done

while true; do
   n_jobs=$(_jobs_get_count_e)

   [[ $n_jobs = 0 ]] &&
      break

   sleep 0.1s
done

