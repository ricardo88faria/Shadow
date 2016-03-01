#stl load into matrix test


library(rgl)
obj <- readSTL("ny_bin.stl", plot = F)
xyz <- data.frame(obj)
colnames(xyz) <- c("x", "y", "z")


library(raster)
xyz_mat <- rasterFromXYZ(xyz)
tab<-xtabs(z~x+y, data = test) 
tab[tab==0]<-NA 


library(RSAGA)
write.ascii.grid(obj, "test.asc")
test <- grid.to.xyz(obj)
