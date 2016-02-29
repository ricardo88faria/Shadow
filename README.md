# WRF output for hydrology analysis
This code is capable of making calcs of the shadows any time of the year and hour from any input ascii and netcdf (.nc) file.
It outupts netcdf (.nc) file with year median shadows representated in one day, shadows in the middle of the day in one year, and outputs image (.png) files from all stations of the year at midday.

**To implement:**

* Compare data obtained from Stations and WRF simulation

## Results:
**(example of the Madeira Island shadows study)**

* Shadows in Winter at midday and sunrise time
![alt text](obs/shadow_winter_MAD.png)
![alt text](obs/shadow_winter_sr_MAD.png)

* Shadows in Autumn at midday and sunrise time
![alt text](obs/shadow_autumn_MAD.png)
![alt text](obs/shadow_autumn_sr_MAD.png)

* Shadows in Spring at midday and sunrise time
![alt text](obs/shadow_spring_MAD.png)
![alt text](obs/shadow_spring_sr_MAD.png)

* Shadows in Summer at midday and sunrise time
![alt text](obs/shadow_summer_MAD.png)
![alt text](obs/shadow_summer_sr_MAD.png)


## Usage:

* Run:
```r
make run
```

* kill application:
```r
make kill
```

Contacts:

<ricardo88faria@gmail.com>
