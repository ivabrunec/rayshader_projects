
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(dplyr)
library(ggplot2)
library(sf)
library(XML)
library(raster)
library(elevatr)
library(rayshader)
library(rayrender)

gpx_parsed <- htmlTreeParse(file = "Map - March 13, 2024.gpx", useInternalNodes = TRUE)

coords <- xpathSApply(doc = gpx_parsed, path = "//trkpt", fun = xmlAttrs)
elevation <- xpathSApply(doc = gpx_parsed, path = "//trkpt/ele", fun = xmlValue)

sc_df <- data.frame(
  lat = as.numeric(coords["lat", ]),
  lon = as.numeric(coords["lon", ]),
  elevation = as.numeric(elevation)
)

ggplot() +
  geom_point(data = sc_df, aes(x = lon, y = lat))



# coordinates
sc_bbox <- data.frame(x = c(-25.82, -25.74), 
                       y = c(37.83, 37.89))

elev <- get_elev_raster(sc_bbox, z = 14, clip = 'bbox',
                        prj = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0",
                        src = "aws")
elev_df <- as.data.frame(rasterToPoints(elev))
colnames(elev_df) <- c('x', 'y', 'z')
ggplot() +
  geom_tile(data = elev_df, aes(x = x, y = y, fill = z)) +
  geom_point(data = sc_df, aes(x = lon, y = lat))

elev_rs <- raster_to_matrix(elev)

elev_rs %>%
  sphere_shade(texture = create_texture('#50927e', '#0B2B26', '#051F20',
                                        '#235347', '#8EB69B')) |>
  add_water(detect_water(elev_rs),
            color = '#6094e0') |>
  plot_3d(elev_rs,zscale=1,
          solidcolor = "#235347", solidlinecolor = "#235347",
          shadowcolor="black", background = "#E15634",
          zoom=1,
          windowsize = c(1000, 800))

gps_lat <- sc_df$lat
gps_long <- sc_df$lon
gps_alt <- sc_df$elevation + 40
render_path(extent = attr(elev,"extent"), 
            lat = gps_lat, long = gps_long, 
            altitude = gps_alt, zscale=1,color="red", antialias=TRUE, clear_previous = T)

render_highquality(line_radius = 3, samples = 350, 
                   ground_material = rayrender::diffuse(color = '#8EB69B'),
                   filename = 'sc_red.png')

# another approach to path rendering
sc_sf = st_as_sf(sc_df, coords = c("lon", "lat"), 
                 crs = 4326, agr = "constant")

sc_linestring <- st_combine(sc_sf) |> 
  st_cast("LINESTRING")

render_path(sc_linestring, extent = attr(elev,"extent"), heightmap = elev_rs, color="red",
            linewidth = 2, zscale=1, offset = 50, clear_previous = T)
