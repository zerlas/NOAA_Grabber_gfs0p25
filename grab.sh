#!/bin/bash

# issue 1427
# get GFS files from NOAA (http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl) and save to $SAVE_DIR directory

### Global Configuration ###

# absolute path of the directory which saves all downloading files
SAVE_DIR=/home/croise_pe/Documents/nooa

# set the how many hours before current UTC time
hours=9

# the GFS fetch configuration: levels & vars
# each one is an array, each element of an array is mapping to same element in the another array
# ex: levels[0] is mapping to vars[0], levels[1] is mapping to vars[1] ...
# THE LENGTH OF THESE TWO ARRAYS MUST BE THE SAME!
levels=('200_mb' 'mean_sea_level' '200_mb' '200_mb')
vars=('UGRD' 'PRMSL''VGRD' 'TMP')

# explain how to using this script
SELF=$(basename $0)
usage()
{
  cat << EOF
USAGE 1: ${SELF}
         bash ${SELF}
USAGE 2: ${SELF} yyyymmdd hh
         bash ${SELF} 20110830 06
EOF
}

# checking if there any arg input by user
# or run the default configuration using current date and time calculated with UTC hours
chk_arg()
{
    case $args in
        0)
            gfs_date=`date -u +%Y%m%d -d "$hours hours ago"`
            gfs_hour=`date -u +%H -d "$hours hours ago"`
            fetch
            ;;
        2)
            gfs_date=$1
            gfs_hour=$2
            fetch
            ;;
        *)
            usage
            exit 0
            ;;
    esac
}

# function to generate file name and fetch file
fetch()
{
    n=`echo "${#levels[@]}-1" | bc`
    for i in `seq 0 $n`
    do
        forecast_hour=0
        while [ ${forecast_hour} -le 120 ]
        do
            after_hour=${forecast_hour};

            if [ ${forecast_hour} -le 9 ]; then
                after_hour='0'${forecast_hour};
            fi

            # calcuating the forecasting time after X hours, X is max to 120, the forecasting time will be target file
            file_date=`date --utc +%Y%m%d%H --date "${gfs_date} ${gfs_hour} ${after_hour} hours"`
            file_name='gfs-'${file_date}-${levels[$i]}-${vars[$i]}

            mkdir -p ${SAVE_DIR}/${gfs_date}${gfs_hour} && cd ${SAVE_DIR}/${gfs_date}${gfs_hour}
            wget "http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t${gfs_hour}z.pgrb2.0p25.f0${after_hour}&lev_${levels[$i]}=on&var_${vars[$i]}=on&leftlon=0&rightlon=360&toplat=90&bottomlat=-90&dir=%2Fgfs.${gfs_date}${gfs_hour}" -O $file_name -a $SAVE_DIR/log

            echo "downloading ${gfs_date}${gfs_hour} for ${levels[$i]} with ${vars[$i]}, forecast hours: ${after_hour}"

            let forecast_hour=forecast_hour+3
            sleep 1
        done

    done
}

# purge last log content before running
touch $SAVE_DIR/log && echo > $SAVE_DIR/log

# main command
args=$#
chk_arg $1 $2