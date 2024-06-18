## heat dome, june 2024
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(raster)
library(sf)
library(ggplot2)
library(dplyr)
library(rayshader)
library(rayrender)

america <- giscoR::gisco_get_countries(region = "Americas") |>
  elevatr::get_elev_raster(z = 4, clip = 'location')

plot(america)

bbox <- extent(-130, -50, 25, 150)
clipped_raster <- crop(america, bbox)

plot(clipped_raster)

dat_df <- as.data.frame(rasterToPoints(clipped_raster))
colnames(dat_df) <- c('x','y','elev')

dat_df <- dat_df |>
  mutate(elev_level = ntile(elev, 20))

col_pal = colorRampPalette(colors = c(
    "#030503", 
    "#64532b", 
    "#cfa94d", 
    "#b4e0aa"
))
cur_pal = rev(col_pal(100))

temp <- ggplot() +
  geom_tile(data = dat_df, aes(x = x, y = y, fill = elev)) +
  scale_fill_gradientn(colors=cur_pal)+
  theme(legend.position = '',
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        plot.background = element_rect(fill = 'grey10', color=NA),
        panel.background = element_rect(fill = 'grey10', color=NA)) +
  coord_equal(ratio = 1.3)

bg_col = 'grey10'

plot_gg(temp,
        raytrace = T,
        scale=30,
        windowsize=c(1400,866),
        zoom = 0.55, 
        background = bg_col,
        shadow_intensity = .8,
        solid =F
        )

render_highquality('heat_dome_fog2.png', 
                  ground_material = diffuse(color = 'grey10'),
                   samples = 500,
                   scene_elements = rayrender::add_object(sphere(x = 120, y = -5, z = 130, radius = 100,
                                                                 material = rayrender::diffuse(fog = T, fogdensity = .02)
                   )))

