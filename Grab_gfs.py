#!/usr/bin/python3
import os
import urllib.request
from datetime import datetime

# Relative path of the directory which saves all downloading files
SAVE_DIR = "./NOAA_Files/"
if not os.path.exists(SAVE_DIR):
    os.makedirs(SAVE_DIR)

# the GFS fetch configuration: [[Variable_1, Level], [Variable_2, Level], ...]
value = [["UGRD", "10_m_above_ground"], ["VGRD", "10_m_above_ground"], ["TMP", "2_m_above_ground"], ["PRMSL", "mean_sea_level"]]

now = datetime.now()
date = now.strftime("%Y%m%d")
time = now.strftime("%H")
last_scan = int(time)

while last_scan % 6 != 0:
    last_scan -= 1

# If the last simulation is not available yet, uncomment the following line :
#last_scan = last_scan - 6

str_scan = str(last_scan)
str_scan = str_scan.zfill(2)


i = 0

while i < len(value):
    forecast_hour = 0
    while forecast_hour <= 120:
        after_hour = str(forecast_hour).zfill(3)
        file_date = date + after_hour
        file_name = "".join(["gfs-", file_date, "-", value[i][1], "-", value[i][0]])
        print(value[i][0], value[i][1])
        url = "".join(["http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t", str_scan, "z.pgrb2.0p25.f", after_hour, "&lev_", value[i][1], "=on&var_", value[i][0], "=on&leftlon=0&rightlon=360&toplat=90&bottomlat=-90&dir=%2Fgfs.", date, str_scan])
        print(url)
        print("Downloading", file_name)
        directory = "".join([SAVE_DIR, file_name])
        urllib.request.urlretrieve(url, directory)
        forecast_hour += 1
    i += 1
