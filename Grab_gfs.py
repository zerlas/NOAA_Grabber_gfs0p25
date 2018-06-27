#!/usr/bin/python3

from datetime import datetime

SAVE_DIR = "/home/croise_pe/Documents/nooa"

levels = ['10_m_above_ground', '10_m_above_ground', '2_m_above_ground', 'mean_sea_level']
variables = ['UGRD', 'VGRD', 'TMP', 'PRMSL']

now = datetime.now()
date = now.strftime("%Y%m%d")
time = now.strftime("%H")

i = 0

while i < len(levels):
    forecast_hour = 0
    while forecast_hour <= 120:
        after_hour = str(forecast_hour).zfill(3)
        file_date = date + after_hour
        file_name = "".join(["gfs-", file_date, "-", levels[i], "-", variables[i]])
        print(file_name)
        forecast_hour += 3
    i += 1
