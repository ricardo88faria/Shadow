# this function opens topografic files (.nc & .asc) 
# inside a topo folder in root and return a matrix 
# called topography and topography type in a list.

library(ncdf4)
library(geosphere)
library(tools)

source("config.txt")

open_topo <- function() {
      
      setwd("topo")
      file_nc <- Sys.glob("*.nc")
      file_asc <- Sys.glob("*.asc")
      
      if (ext_file == "nc") {
            
            nc <- nc_open(file_nc)
            print("encontrado ficheiro com a extenção .nc")
            
            #search for list of topo variables updatable
            pos <- match(c("HGT", "hgt", "topo", "TOPO"), names(nc$var))
            pos <- max(pos, na.rm = TRUE)
            var_name <- names(nc$var)[pos]
            
            if (length(ncvar_get(nc, var_name)[,,1]) >= 0) {
                  topo <- ncvar_get(nc, var_name)[,,1]
            } else {
                  topo <- ncvar_get(nc, var_name)
            }
            topo_type <- "nc"
            
            lat <- unique(as.vector(ncvar_get(nc, "XLAT")))
            lat_size <- lat[2] - lat[1]
            long <- unique(as.vector(ncvar_get(nc, "XLONG")))
            long_size <- long[2] - long[1]
            p1 <-c(long[2], lat[1])
            p2 <-c(long[2], lat[2])
            p3 <-c(long[3], lat[3])
            #alongTrackDistance(p1, p2, p3)
            
            cellsize <- alongTrackDistance(p1, p2, p3)[1,]/2
            
            if (topo == -99.9) {
                  topo[topo == -99.9] <- 0
            } else if (topo == -999.000) {
                  topo[topo == -999.000] <- 0
            } else if (topo == NA) {
                  topo[topo == NA] <- 0
            }
            
            file_name <- file_nc
            header <- NULL
            
            nc_close(nc)
            
      } else if (ext_file == "asc") {
            
            header <- read.table(file_asc ,nrows=6)
            topo <- read.table(file_asc ,skip=6)
            
            print("encontrado ficheiro com a extenção .asc")
            
            topo_type <- "asc"
            
            if (latlon == "degree") {
                  
                  long <- seq(header[3,2], header[3,2]+header[1,2]*header[5,2], by=header[5,2])
                  long_size <- long[2] - long[1]
                  lat <-seq(header[4,2], header[4,2]+header[2,2]*header[5,2], by=header[5,2])
                  lat_size <- long[2] - long[1]
                  p1 <-c(lat[1], long[1])
                  p2 <-c(lat[2], long[2])
                  p3 <-c(lat[3], long[3])
                  #alongTrackDistance(p1, p2, p3)
                  
                  cellsize <- alongTrackDistance(p1, p2, p3)[1,]/2
                  
            } else if (latlon != "degree") {
                  
                  cellsize = header[5, 2]
                  
            }
            
            #vals_exc <- c(NA, -99.9, -999.000, -999)
            
            if (topo == -99.9) {
                  topo[topo == -99.9] <- 0
            } else if (topo == -999.000) {
                  topo[topo == -999.000] <- 0
            } else if (topo == NA) {
                  topo[topo == NA] <- 0
            }
            
            file_name <- file_asc
      }
      
      setwd("../")
      
      #return a list of objects
      return(list(topography = topo, topography_type = topo_type, cellsize = cellsize, file_name = file_name, header = header))
      #return(topo_type)
}

