#| message: false
#| warning: false
# Install remotes if not already installed
if (!requireNamespace("remotes")) {
    install.packages("remotes")
}

# The packages we'll use
pkgs = c(
    "sf",
    "tidyverse",
    "geos",
    "ggspatial",
    "spData"
)


#| eval: false
remotes::install_cran(pkgs)


#| eval: false
#| warning: false
sapply(pkgs, require, character.only = TRUE)



library(tidyverse)



library(sf)
library(spData)



names(world) # check we have the data
poland = world |>
    filter(name_long == "Poland")
world_centroids = world |>
    st_centroid()
country_centroids = world_centroids |>
  st_filter(
    poland,
    .predicate = st_is_within_distance,
    dist = 2e5
  )
countries = world |>
  filter(name_long %in% country_centroids$name_long)
countries_df = countries |>
  select(name_long, pop, area_km2) |>
  st_drop_geometry()



countries_df



class(countries_df)


#| label: fig-plotting-basics
#| fig.cap: "Plotting geographic data with base R (left) and ggplot2 (right)"
#| fig.subcap:
#|   - "Base R"
#|   - "ggplot2"
#| layout-ncol: 2
plot(countries)
countries |>
  ggplot() +
    geom_sf()


#| eval: false
countries_df |>
  filter()



sf::write_sf(countries, "countries.geojson", delete_dsn = TRUE)



countries_new1 = sf::read_sf("countries.geojson")
countries_new2 = sf::st_read("countries.geojson")



countries_new1 |>
  head(2)
countries_new2 |>
  head(2)



waldo::compare(countries_new1, countries_new2)



drvs = sf::st_drivers() |>
  as_tibble()
head(drvs)


#| eval: false
#| echo: false
country_centroids2 = world_centroids[poland, , op = st_is_within_distance, dist = 2e5]
waldo::compare(country_centroids, country_centroids2)
#> ✔ No differences
res = bench::mark(
    base = world_centroids[poland, , op = st_is_within_distance, dist = 2e5],
    st_filter = world_centroids |>
  st_filter(poland, .predicate = st_is_within_distance, dist = 2e5)
)
res
#> # A tibble: 2 × 13
#>   expression      min median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time
#>   <bch:expr> <bch:tm> <bch:>     <dbl> <bch:byt>    <dbl> <int> <dbl>   <bch:tm>
#> 1 base         10.7ms 12.4ms      81.2     208KB     6.58    37     3      456ms
#> 2 st_filter      12ms 12.5ms      79.7     199KB     6.64    36     3      452ms



countries_modified = countries |>
  mutate(pop_density = pop / area_km2) |>
  select(name_long, pop_density) |>
  filter(pop_density > 100) |>
  arrange(desc(pop_density))
countries_modified



countries_summarised = countries |>
  group_by(contains_a = str_detect(name_long, "a")) |>
  summarise(n = n(), mean_pop = mean(pop))
countries_summarised


#| label: fig-summarise
#| fig.cap: "Result of running dplyr group_by() and summarise() functions on countries data"
countries_summarised |>
  ggplot() +
    geom_sf(aes(fill = contains_a)) +
    geom_sf(data = countries, fill = NA, linetype = 3) 


#| eval: false
#| echo: false
# with dplyr:
countries_modified2 = countries |>
  mutate(pop_density = pop / area_km2) |>
  select(name_long, pop_density, area_km2) |>
  filter(pop_density > 100) |>
  arrange(desc(area_km2))
# with base R:
countries_base = countries[countries$pop / countries$area_km2 > 100, ]
countries_base = countries_base[countries_base$area_km2 > 100, c("name_long", "pop", "area_km2")]
countries_base = countries_base[order(countries_base$area_km2, decreasing = TRUE), ]

waldo::compare(countries_modified2$name_long, countries_base$name_long)


#| label: fig-geom-sf-fill
#| fig.cap: "Map created with ggplot2, with fill color controlled by the pop_density variable and multiple layers."
library(ggspatial)
countries |>
  ggplot() +
    geom_sf(fill = "grey80", color = "black") +
    geom_sf(data = countries_modified, aes(fill = pop_density)) +
    scale_fill_viridis_c() +
    theme_minimal()


#| message: false
#| label: fig-annotation-map-tile
#| fig.cap: "Map created with ggplot2, with a basemap added with annotation_map_tile()."
rosm::osm.types()
ggplot() +
  annotation_map_tile() +
  layer_spatial(countries_modified, aes(fill = pop_density),
                linewidth = 3, alpha = 0.3) +
  scale_fill_viridis_c()


#| eval: false
#| echo: false
fair_playce_poznan = stplanr::geo_code("FairPlayce, Poznan")
fair_playce_poznan



poi_df = tribble(
  ~name, ~lon, ~lat,
  "Faculty",        16.9418, 52.4643,
  "Hotel ForZa",    16.9474, 52.4436,
  "Hotel Lechicka", 16.9308, 52.4437,
  "FairPlayce",     16.9497, 52.4604
)
poi_sf = sf::st_as_sf(poi_df, coords = c("lon", "lat"))
sf::st_crs(poi_sf) = "EPSG:4326"


#| eval: false
# column: screen-inset-shaded
library(leaflet)
leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(
    lng = poi_df$lon,
    lat = poi_df$lat,
    popup = poi_df$name
  )



library(tmap)
tmap_mode("view")


#| eval: false
tm_shape(poi_sf) + tm_bubbles(popup.vars = "name")


#| column: screen-inset-shaded
#| layout-ncol: 2
#| echo: false
library(leaflet)
leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(
    lng = poi_df$lon,
    lat = poi_df$lat,
    popup = poi_df$name
  )

tm_shape(poi_sf) +
  tm_symbols(popup.vars = "name") +
  tm_scale_bar()



tmap_mode("plot")



pois_buffer = poi_sf |>
  filter(str_detect(name, "Fair|Faculty")) |>
  st_union() |>
  st_convex_hull() |>
  st_buffer(dist = 500)



extra_tags = c("maxspeed", "foot", "bicycle")


#| eval: false
lines = osmextract::oe_get(
  "Poznan",
  layer = "lines",
  extra_tags = extra_tags,
  boundary = pois_buffer,
  boundary_type = "clipsrc"
)


#| include: false
lines = osmextract::oe_get(
  "Poznan",
  layer = "lines",
  extra_tags = extra_tags,
  boundary = pois_buffer,
  boundary_type = "clipsrc"
)



lines_highways = lines |>
  filter(!is.na(highway)) 
plot(lines$geometry)
table(lines$highway)


#| eval: false
polygons = osmextract::oe_get(
  "Poznan",
  layer = "multipolygons",
  boundary = pois_buffer,
  boundary_type = "clipsrc"
)


#| include: false
polygons = osmextract::oe_get(
  "Poznan",
  layer = "multipolygons",
  boundary = pois_buffer,
  boundary_type = "clipsrc"
)



buildings = polygons |>
  filter(!is.na(building))
polygons_geog = buildings |>
  filter(str_detect(name, "Geog"))


#| label: fig-osm-pois
#| fig.cap: "OSM data from Poznan, Poland, with lines and polygons."
m_osm = tm_shape(buildings) +
  tm_fill("lightgrey") +
  tm_shape(lines_highways) +
  tm_lines() +
  tm_shape(polygons_geog) +
  tm_polygons(col = "red") 


#| eval: false
sf::write_sf(lines_highways, "data/lines_highways.geojson")



u_gpx = "https://www.openstreetmap.org/trace/9741677/data"
f_gpx = paste0(basename(u_gpx), ".gpx")
download.file(u_gpx, f_gpx)
sf::st_layers(f_gpx)
gpx = sf::read_sf(f_gpx, layer = "track_points")



gpx_mutated = gpx |>
  mutate(minute = lubridate::round_date(time, "minute")) |>
  mutate(second = lubridate::round_date(time, "second")) 
summary(gpx_mutated$minute)


#| eval: false
# ?tmap_animation
m_faceted = m_osm +
  tm_shape(gpx_mutated[pois_buffer, ]) +
  tm_dots(size = 0.8, legend.show = FALSE) +
  tm_facets("second", free.coords = FALSE, ncol = 1, nrow = 1) +
  tm_scale_bar()
tmap_animation(m_faceted, delay = 2, filename = "gpx.gif")



library(geos)



suitable_crs = crsuggest::suggest_crs(countries)
suitable_crs



crs1 = paste0("EPSG:", suitable_crs$crs_code[2])
crs1
countries_projected = sf::st_transform(countries, crs = crs1)



countries_geos = as_geos_geometry(sf::st_geometry(countries_projected))
countries_geos



countries_geos_df = bind_cols(countries_df, geos = countries_geos)
countries_summarised_df = countries_geos_df |>
  group_by(contains_a = str_detect(name_long, "a")) |>
  summarise(n = n(), mean_pop = mean(pop))
countries_summarised_df


#| layout-ncol: 2
countries_union1 = countries_geos |>
  geos_unary_union()
plot(countries_union1)
countries_union2 = countries_geos |>
  geos_make_collection() |>
  geos_unary_union()
plot(countries_union2)



countries_summarised_geos = countries_geos_df |>
  group_by(contains_a = str_detect(name_long, "a")) |>
  summarise(n = n(), mean_pop = mean(pop),
  geometry = geos_unary_union(geos_make_collection(geos)))
countries_summarised_geos
plot(countries_summarised_geos$geometry)



countries_summarised_geos_sf = st_as_sf(countries_summarised_geos)
# waldo::compare(
#   countries_summarised,
#   countries_summarised_geos_sf
#   )


#| eval: false
#| echo: false
bench::mark(check = FALSE,
  geos = countries_geos |>
    geos_make_collection() |>
    geos_unary_union(),
  geos_to_sf = countries_geos |>
    geos_make_collection() |>
    geos_unary_union() |>
    st_as_sf(),
  sf = countries_projected |>
    st_union()
)


## # Zip the data folder:

## zip -r data.zip data

## gh release list

## # Create release labelled data and upload the zip file:

## gh release create data data.zip



u = "https://github.com/Robinlovelace/opengeohub2023/releases/download/data/data.zip"
f = basename(u)
if (!dir.exists("data")) {
  download.file(u, f)
  unzip(f)
}



list.files("data")[1:3]



pol_all = sf::read_sf("./data/osm/gis_osm_transport_a_free_1.shp")
pol_all



pol = pol_all |>
  filter(str_detect(name, "Port*.+Poz"))


#| layout-ncol: 3
#| column: screen-inset-shaded
plot(pol)
pol |>
  ggplot() +
  geom_sf()
tm_shape(pol) + tm_polygons()



stops_raw = read_csv('data/gtfs/stops.txt')
stops_df = stops_raw |>
  select(-stop_code)
stops = st_as_sf(stops_df, coords = c("stop_lon", "stop_lat"), crs = "EPSG:4326")



sf::sf_use_s2()
poi_buffers = st_buffer(poi_sf, dist = 150)



areas = st_area(poi_buffers)



areas |>
  units::set_units(ha)



areas |>
  units::set_units(ha) |>
  units::drop_units() |>
  round()



stops_nearby = stops[poi_buffers, ]
stops_nearby



pois_joined = st_join(poi_buffers, stops)
pois_joined



library(terra)


#| label: fig-terra-plot
#| fig.cap: "Plotting a single raster layer with terra"
src = rast('data/hls/HLS.S30.T33UXU.2022200T095559.v2.0.B02.tiff')
terra::plot(src, col = gray.colors(10))



files = list.files("data/hls", pattern = "tiff", full.names = TRUE)
files



r = rast(files)
r
summary(r)


#| label: fig-terra-plot-basic
#| fig.cap: "Output of `plot(r)`, showing the four bands of the raster layer"
plot(r)



r_rgb = r[[c("Red", "Green", "Blue")]]


#| label: fig-terra-plot-rgb
#| fig.cap: "Plotting a RGB raster layer with terra"
plotRGB(r, stretch = "lin")


#| eval: false
# r_clamp = clamp(r, 0, 4000)
r_stretch = stretch(r_rgb, minq = 0.001, maxq = 0.999)
top_01pct = quantile(values(r_rgb), probs = 0.999, na.rm = TRUE)
bottom_01pct = quantile(values(r_rgb), probs = 0.001, na.rm = TRUE)
r_to_plot = r_rgb
r_to_plot[r_rgb > top_01pct] = top_01pct
r_to_plot[r_rgb < bottom_01pct] = bottom_01pct


#| include: false
# r_clamp = clamp(r, 0, 4000)
r_stretch = stretch(r_rgb, minq = 0.001, maxq = 0.999)
top_01pct = quantile(values(r_rgb), probs = 0.999, na.rm = TRUE)
bottom_01pct = quantile(values(r_rgb), probs = 0.001, na.rm = TRUE)
r_to_plot = r_rgb
r_to_plot[r_rgb > top_01pct] = top_01pct
r_to_plot[r_rgb < bottom_01pct] = bottom_01pct


#| echo: false
#| layout-ncol: 2
plotRGB(r_stretch)
plotRGB(r_to_plot)


#| eval: false
# write the r file:
writeRaster(r, "data/hls/combined.tif", overwrite = TRUE)
writeRaster(r_to_plot, "data/hls/r_to_plot.tif", overwrite = TRUE)



pol_projected = sf::st_transform(pol, crs = crs(r))
r_masked = mask(r, pol_projected)
summary(r_masked)



r_cropped = crop(r, sf::st_buffer(pol_projected, dist = 500))


#| label: fig-terra-plot-rgb-cropped
#| fig.cap: "Result of plotting a cropped RGB raster layer with the tmap package"
tm_shape(stretch(r_cropped[[c("Red", "Green", "Blue")]], minq = 0.001, maxq= 0.98)) +
  tm_rgb() +
  tm_shape(pol_projected) +
  tm_borders(col = "white", lty = 3) +
  tm_fill(col = "red", alpha = 0.1) +
  tm_scale_bar(bg.color = "white", bg.alpha = 0.6, text.size = 0.8) 


#| eval: false
install.packages(
  'tidypolars', 
  repos = c('https://etiennebacher.r-universe.dev/bin/linux/jammy/4.3', getOption("repos"))
)


#| eval: false
install.packages('rsgeo', repos = c('https://josiahparry.r-universe.dev', 'https://cloud.r-project.org'))


#| eval: false
library(rsgeo)
countries_rs  = as_rsgeo(sf::st_geometry(countries_projected))
countries_rs
bench::mark(check = FALSE,
  sf = sf::st_union(countries_projected),
  geos = geos::geos_make_collection(geos::geos_unary_union(countries_geos)),
  rsgeo = rsgeo::union_geoms(countries_rs)
)


#| eval: false
library(arrow)

# write countries_projected to parquet file:
write_parquet(countries_projected, "data/countries_projected.parquet") # Fails


