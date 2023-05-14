
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(rayshader)
library(raster)
library(elevatr)

# triglav as contours
# coordinates
triglav <- data.frame(x = c(13.81203, 13.865824), 
                      y = c(46.36267, 46.3960570))

# get elevation raster
elev <- get_elev_raster(triglav, z = 10, clip = 'bbox',
                        prj = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0",
                        src = "aws")
plot(elev)
elmat <- raster_to_matrix(elev) 




elmat |>
  height_shade() |>
  plot_3d(elmat, zscale =10)


render_contours(elmat, clear_previous = F, offset=1,color="purple",
                zscale=10, nlevels = 20)

render_snapshot('test.png')

for(i in 1:360) {
  render_camera(theta=135-i,phi=50,zoom=0.818731)
  render_highquality(light=T, lightaltitude = 90, lightintensity = 70,
                     lightcolor ="pink",samples=50,
                     smooth_line = T,line_radius = 0.1, 
                     path_material = rayrender::light, ground_size = 0,
                     path_material_args = list(importance_sample=FALSE,
                                               color="purple",intensity=5),
                     width=800,height=800, sample_method="sobol_blue",
                     filename=sprintf("neoncontours%i.png",i),verbose=T)
}

av::av_encode_video(glue::glue("neoncontours{1:360}.png"), framerate=50, output = "neon_video_version1.mp4")
file.remove(glue::glue("neoncontours{1:360}.png"))
