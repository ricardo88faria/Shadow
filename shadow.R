#!/usr/bin/env Rscript

#packages:
library(insol)
library(ncdf4)


#limpeza ambiente e objetos:
rm(list=ls())
cat("\014")

#####################################
cat("Programado por Ricardo Faria \n
    ")
#####################################

t_tot <- Sys.time()

system("mkdir nc Images")

source("config.txt")

source("matrix_rotation.R")
source("open_topo.R")


topo_list <- open_topo()   #[""]

topo <- topo_list[["topography"]]
topo_type <- topo_list[[2]]
cellsize <- topo_list[["cellsize"]]
file_name <- topo_list[[4]]
header <- topo_list[[5]]

if (ext_file == "nc") {
      
      topo <- mat_rot(mat_rot(mat_rot(topo)))
      
      setwd("topo")
      nc_path <- Sys.glob("*.nc")
      nc <- nc_open(nc_path)
      setwd("../")
      
      lat <- unique(as.vector(ncvar_get(nc, nc_var_lat)))
      long <- unique(as.vector(ncvar_get(nc, nc_var_lon)))
      
      ncols <- length(long)
      nrows <- length(lat)
      
      nc_close(nc)
      
} else if (ext_file == "asc" ) {
      
      topo <- as.matrix(topo)
      
      long <- seq(header[3,2], header[3,2]+header[1,2]*header[5,2], by=header[5,2])
      long <- long[1: (length(long)-1)]
      lat <-seq(header[4,2], header[4,2]+header[2,2]*header[5,2], by=header[5,2])
      lat <- lat[1: (length(lat)-1)]
      
      ncols <- header[1,2]
      nrows <- header[2,2]
}

options(digits=16)

year <- format(Sys.Date(), "%Y")
#year <- paste(year, "-01-01", sep = "")
#year <- format(as.Date(year), "%Y") #-%m-%d

julian_day <- JDymd(as.numeric(year), 01, 01, 00)

day_year <- seq(day_i - 1, day_f - 1, by = 1)
#julian_year <- JD(as.Date(year))
julian_hour <- seq(0, 1, by = 1/day_sample)
julian_hour <- julian_hour[1:(length(julian_hour)-1)]
hour_seq <- seq(0, 24, by = 24/day_sample)

count <- 0
julian_list <- list()
for (i in 1:length(day_year)) {
      
      for (j in 1:length(julian_hour)) {
            
            count <- count + 1
            julian <- julian_day + day_year[i] + julian_hour[j]
            julian_list[[count]] <- julian
            
      }
      
}

for (i in 1:day_sample) {
      
      assign(paste("shadow_", hour_seq[i], sep = ""), 0)
      
}

shadow <- 0
for (i in 1:length(julian_hour)) {
      
      lengt_count <- 0
      julian <- julian_day + julian_hour[i]
      
      for (j in 1:length(day_year)) {
            
            julian <- julian + 1
            print(julian)
            
            sun_vect <- sunvector(jd = julian ,latitude = lat_degrees ,longitude = lon_degrees ,timezone= tmz)
            
            topo_nv <- cgrad(topo, cellsize)
            sun_vect_inc <- topo_nv[,,1]*sun_vect[1]+topo_nv[,,2]*sun_vect[2]+topo_nv[,,3]*sun_vect[3]
            
            sun_vect_inc <- (sun_vect_inc + abs(sun_vect_inc))/2
            shadows <- doshade(topo, sun_vect, cellsize)
            shadows_inc <- shadows*sun_vect_inc
            
            #shadow <- shadow + shadows_inc
            assign(paste("shadow_", hour_seq[i], sep = ""), shadows_inc + get(paste("shadow_", hour_seq[i], sep = "")))
            
            
            lengt_count <- lengt_count + 1
            print(lengt_count)
      }
      
}

for (i in 1:day_sample) {
      assign(paste("shadow_", hour_seq[i], sep = ""), get(paste("shadow_", hour_seq[i], sep = ""))/length(day_year))
}

shadows_hour_list <- list()
for (i in 1:length(julian_hour)) {
      
      shadows_hour_list[[i]] <- mat_rot(get(paste("shadow_", hour_seq[i], sep = "")))
      
}

#pass to array then remove all non necessary objects
shadows_hour_array <- array(unlist(shadows_hour_list), dim=c(ncols, nrows, length(julian_hour)))
rm(shadows_hour_list)

for (i in 1:length(julian_hour)) {
      
      #var <- paste("shadow_", hour_seq[i], sep = "")
      rm(list=paste("shadow_", hour_seq[i], sep = ""))
      #rm(var)
      
}

#vector do sol com a horizontal a variar no dia juliano
#sun_vect <- sunvector(jd = julian_day ,latitude = lat_degrees ,longitude = lon_degrees ,timezone= tmz)
#vector do sol com a horizontal. ex 45 graus meio dia, sol a sul
#sun_vect <- normalvector(45,180)

#topo_nv <- cgrad(topo, cellsize)
#sun_vect_inc <- topo_nv[,,1]*sun_vect[1]+topo_nv[,,2]*sun_vect[2]+topo_nv[,,3]*sun_vect[3]

#remove negative incidence angles (self shading) 
#anual med
#sun_vect_inc <- (sun_vect_inc + abs(sun_vect_inc))/2
#shadows <- doshade(topo, sun_vect, cellsize)
#shadows_inc <- shadows*sun_vect_inc

#image(t(shadows_inc[nrow(shadows_inc): 1, ]), col = grey(1 : 100/100), asp=asp)
#contour(mat_rot(topo), add = TRUE, col = terrain.colors(20), levels = c(seq(min(topo), max(topo), length.out = 21)), lwd=0.5, labcex=0.7)#, levels=c(10, seq(10, 500, 50), seq(500, 1900, 100)))

#normal shadows for sun_vect[i]
#shadows <- doshade(dem = topo, sv = sun_vect, dl = cellsize)
#image(t(shadows[nrow(shadows): 1, ]), col = grey(1 : 100/100), asp=0.75)
#contour(mat_rot(topo), add = TRUE, col = "sienna1", lwd=0.5, labcex=0.7, levels=c(10, seq(10, 500, 50), seq(500, 1900, 100)))

#grafico def
asp <- nrows/ncols

if (img_output_ex == "y" ) {
      
      st_jd <- c((julian_day + 0.5 + 0), (julian_day + 0.5 + 91), (julian_day + 0.5 + 182), (julian_day + 0.5 + 274))
      st_name <- c("winter", "spring", "summer", "autumn")
      
      for (i in 1:length(st_name)) {
            
            
            #vector do sol com a horizontal a variar no dia juliano
            sun_vect <- sunvector(jd = st_jd[i] ,latitude = lat_degrees ,longitude = lon_degrees ,timezone= tmz)
            #add intensity of illumination
            #normal vector every terrain grid & sun normal relative to the terrain
            topo_nv <- cgrad(topo, cellsize)
            sun_vect_inc <- topo_nv[,,1]*sun_vect[1]+topo_nv[,,2]*sun_vect[2]+topo_nv[,,3]*sun_vect[3]
            
            #remove negative incidence angles (self shading) 
            #anual med
            sun_vect_inc <- (sun_vect_inc + abs(sun_vect_inc))/2
            shadows <- doshade(topo, sun_vect, cellsize)
            shadows_inc <- shadows*sun_vect_inc
            
            png(paste("Images/shadow_", st_name[i], "_", local, ".png", sep = ""), width = 10000, height = 12200*asp, units = "px", res = 675)
            image(t(shadows_inc[nrow(shadows_inc):1,]),col=grey(1:100/100), asp= asp)
            contour(mat_rot(topo), add = T, col = terrain.colors(21), lwd=0.4, labcex=0.5, levels = c(seq(min(topo), max(topo), length.out = 21)))#c(1, seq(50, 1900, 100))) #, levels=c(10, seq(10, 500, 50), seq(500, 1900, 100))
            dev.off()
            
      }
      
}


shadows_list <- list()
shadows_array <- 0
count <- 0
for (i in 1:length(day_year)) {
      
      t <- Sys.time()
      
      sun_vect <- sunvector(jd = i ,latitude = lat_degrees ,longitude = lon_degrees ,timezone= tmz)
      
      topo_nv <- cgrad(topo, cellsize)
      sun_vect_inc <- topo_nv[,,1]*sun_vect[1]+topo_nv[,,2]*sun_vect[2]+topo_nv[,,3]*sun_vect[3]
      
      sun_vect_inc <- (sun_vect_inc + abs(sun_vect_inc))/2
      shadows <- doshade(topo, sun_vect, cellsize)
      shadows_inc <- shadows*sun_vect_inc
      
      #shadows_list[[i]] <- shadows_inc
      
      #shadows_array <- array(c(shadows_array, mat_rot(shadows_inc)), dim=c(ncols, nrows, i))
      
      shadows_list[[i]] <- mat_rot(shadows_inc)
      #shadows_array <- array(c(shadows_array, mat_rot(shadows_inc)), dim=c(ncols, nrows, i))
      
      count = count+1
      perc <- count*100/365
      t <- (Sys.time() - t)
      
      print(paste(round(perc), "% - [", count, "-", length(day_year), "], it time =", round(t), "sec,", round(t*(length(day_year) - count)), "sec until finish "))
}

shadows_array <- array(unlist(shadows_list), dim=c(ncols, nrows, length(day_year)))
rm(shadows_list)

#define dimensions
nc_londim <- ncdim_def(name = "lon", units = "degrees_east", vals = long) 
nc_latdim <- ncdim_def(name = "lat", units = "degrees_north", vals = lat) 
nc_daydim <- ncdim_def(name = "day", units = "day_year", vals = day_year)
nc_hourdim <- ncdim_def(name = "hour", units = "hour_day", vals = hour_seq[1:length(hour_seq)-1])

#define variables
nc_shadow_hour <- ncvar_def(name = "shadow_day", units = "%", dim = list(nc_londim ,nc_latdim ,nc_hourdim), prec = "single")
nc_shadow <- ncvar_def(name = "shadow", units = "%", dim = list(nc_londim ,nc_latdim ,nc_daydim), prec = "single")
nc_hgt <- ncvar_def(name = "hgt", units = "m", dim = list(nc_londim ,nc_latdim), prec = "single")

#create netCDF file and put arrays
nc_name <- paste("nc/shadow_", local, ".nc", sep = "")
ncout <- nc_create(filename = nc_name, vars = list(nc_shadow_hour, nc_shadow, nc_hgt), force_v4 = T, verbose = F)

#put variables
ncvar_put(ncout ,nc_shadow_hour, shadows_hour_array)
ncvar_put(ncout ,nc_shadow, shadows_array)
ncvar_put(ncout ,nc_hgt, mat_rot(topo))

#put additional attributes into dimension and data variables
ncatt_put(ncout, "lon", "axis", "X") #,verbose=FALSE) #,definemode=FALSE)
ncatt_put(ncout, "lat", "axis", "Y")
ncatt_put(ncout, "day", "axis", "T")
ncatt_put(ncout, "hour", "axis", "T")

#add global attributes
#ncatt_put(ncout,0,"title","Shadow median per Julian day")
name <- paste("Created by: Ricardo Faria", Sys.time(), "Shadow median per Julian day", sep=", ")
ncatt_put(ncout, 0, "title", name)

nc_close(ncout)

d_t <- (Sys.time() - t_tot)

cat("Programado por Ricardo Faria \n
    Finalizado em", d_t, "mnts")

print(d_t)
