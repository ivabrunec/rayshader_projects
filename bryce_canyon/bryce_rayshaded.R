# bryce canyon in 3d

library(sf)
library(elevatr)
library(raster)
library(rayshader)
library(dplyr)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# coordinates
bryce_df <- data.frame(x = c(-112.2011596751243, -112.12774130444471), 
                       y = c(37.58178754715022, 37.63121639148312))

elev <- get_elev_raster(bryce_df, z = 14, clip = 'bbox',
                        prj = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0",
                        src = "aws")

elmat <- raster_to_matrix(elev) 

elmat %>%
  sphere_shade(texture = create_texture('#9e6b46', '#551c15', '#d46c22',
                                        '#9c471c', '#e5b999')) |>
  plot_3d(elmat, solid=T, soliddepth = 2000, 
          solidcolor = '#9e6b46', solidlinecolor = '#9e6b46',
          shadow_darkness = .7, background = '#6094e0')


for(i in 1:159) {
  render_camera(theta=135-i,phi=30,zoom=0.7, fov=40)
  render_highquality(ground_material = rayrender::diffuse(color = '#6094e0'),
                     width=800,height=800, sample_method="sobol_blue",
                     filename=sprintf("bryce%i.png",i),verbose=T)
}

av::av_encode_video(glue::glue("bryce{1:159}.png"), framerate=20, output = "bryce_half1.mp4")
av::av_encode_video(glue::glue("bryce{159:1}.png"), framerate=20, output = "bryce_half2.mp4")


file.remove(glue::glue("bryce{1:159}.png"))

