# plotting tre cime in the dolomites

library(sf)
library(elevatr)
library(raster)
library(rayshader)
library(dplyr)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# coordinates
tre_cime <- data.frame(x = c(12.243, 12.366), y = c(46.595, 46.656))

elev <- get_elev_raster(tre_cime, z = 14, clip = 'bbox',
                        prj = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0",
                        src = "aws")

elmat <- raster_to_matrix(elev) 


elmat %>%
  sphere_shade(texture = create_texture('#46657b', '#000000', '#103D05','#7D462B',  '#8CA9BE'),
               sunangle = 270) %>%
  plot_3d(elmat, zscale = 1, baseshape = 'circle', theta = 0, phi = 30, zoom = .6, 
          windowsize = c(1200, 800), background = '#f3c2b9', solid = T, shadow = T,
          solidcolor = 'grey30')
render_clouds(elmat, start_altitude = 2900, end_altitude = 2999, 
              fractal_levels = 4, baseshape = 'circle')

render_movie(filename = 'test3_clouds_phi20_bg', type = 'orbit', phi = 20)

