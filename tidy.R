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
    "data.table",
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



countries_df |>
  filter()


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

