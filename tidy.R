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
  st_filter(poland, .predicate = st_is_within_distance, dist = 2e5)
countries = world |>
  filter(name_long %in% country_centroids$name_long)
countries_df = countries |>
  select(name_long, pop, area_km2) |>
  st_drop_geometry()



countries_df



class(countries_df)


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



library(ggspatial)
countries |>
  ggplot() +
    geom_sf(fill = "grey80", color = "black") +
    geom_sf(data = countries_modified, aes(fill = pop_density)) +
    scale_fill_viridis_c() +
    theme_minimal()


#| message: false
rosm::osm.types()
ggplot() +
  annotation_map_tile() +
  layer_spatial(countries_modified, aes(fill = pop_density), linewidth = 3, alpha = 0.3) +
  scale_fill_viridis_c()



## # Zip the data folder:

## zip -r data.zip data

## gh release list

## # Create release labelled data and upload the zip file:

## gh release create data data.zip


#| eval: false
u = "https://github.com/Robinlovelace/opengeohub2023/releases/download/data/data.zip"
f = basename(u)
if (!dir.exists("data")) {
  download.file(u, f)
  unzip(f)
}



list.files("data")[1:3]


#| eval: false
#| echo: false
fair_playce_poznan = stplanr::geo_code("FairPlayce, Poznan")
fair_playce_poznan







opengeo_df = tribble(
  ~name, ~lon, ~lat,
  "Faculty",        16.9418, 52.4643,
  "Hotel ForZa",    16.9474, 52.4436,
  "Hotel Lechicka", 16.9308, 52.4437,
  "FairPlayce",     16.9497, 52.4604
)
opengeo_sf = sf::st_as_sf(opengeo_df, coords = c("lon", "lat"))
sf::st_crs(opengeo_sf) = "EPSG:4326"


#| column: screen-inset-shaded

library(leaflet)
leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(
    lng = opengeo_df$lon,
    lat = opengeo_df$lat,
    popup = opengeo_df$name
  )



library(geos)



countries_geos = as_geos_geometry(sf::st_geometry(countries))
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
  sf = countries |>
    st_union()
)


#| eval: false
install.packages(
  'tidypolars', 
  repos = c('https://etiennebacher.r-universe.dev/bin/linux/jammy/4.3', getOption("repos"))
)


#| eval: false
install.packages('rsgeo', repos = c('https://josiahparry.r-universe.dev', 'https://cloud.r-project.org'))



library(rsgeo)
countries_rs  = as_rsgeom(sf::st_geometry(countries))
countries_rs
bench::mark(check = FALSE,
  sf = sf::st_union(countries),
  geos = geos::geos_make_collection(geos::geos_unary_union(countries_geos)),
  rsgeo = rsgeo::union_geoms(countries_rs)
)


