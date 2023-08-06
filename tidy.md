# Tidy geographic data with sf, dplyr, ggplot2, geos and friends

These materials were created for the OpenGeoHub Summer School 2023.

See the [parent repo](https://github.com/robinlovelace/opengeohub2023)
and [session description in the
agenda](https://pretalx.earthmonitor.org/opengeohub-summer-school-2023/talk/7JN3FV/)
for context.

## Abstract

This lecture will provide an introduction to working with geographic
data using R in a ‘tidy’ way. It will focus on using the `sf` package to
read, write, manipulate, and plot geographic data in combination with
the `tidyverse` metapackage. Why use the `sf` package with the
`tidyverse`? The lecture will outline some of the ideas underlying the
`tidyverse` and how they can speed-up data analysis pipelines, while
making data analysis code easier to read and write. We will see how the
following lines:

``` r
library(sf)
library(tidyverse)
```

can provide a foundation on which the many geographic data analysis
problems can be solved. The lecture will also cover on more recently
developed packages that integrate with the `tidyverse` to a greater and
lesser extent. We will look at how the `geos` package, which provides a
simple and high-performance interface to the GEOS library for performing
geometric operations on geographic data, integrates with the
`tidyverse`. The `tidyverse` is not the right tool for every data
analysis task and we touch on alternatives for working with raster data,
with reference to the `terra` package, and alternative frameworks such
as `data.table`. Finally, we will also look at how the ‘tidy’ philosophy
could be implemented in other programming languages, such as Python.

The focus throughout will be on practical skills and using packages
effectively within the wider context of project management tools,
integrated development environments (we recommend VS Code with
appropriate extensions or RStudio), and version control systems.

## Learning objectives

By the end of the session, participants will be able to:

- Read, write, manipulate, and plot geographic data using the `sf`
  package
- Use the `tidyverse` metapackage to speed-up the writing of geographic
  data analysis pipelines
- Use the `geos` package to perform geometric operations on geographic
  data
- Understand the strengths and weaknesses of the `tidyverse` for
  geographic data analysis

## Prerequisites

We recommend you run the code in the practical session with a modern
integrated development environment (IDE) such as

- RStudio: an IDE focussed on data science and software development
  with R. See [posit.co](https://posit.co/download/rstudio-desktop/) for
  installation instructions.
- VS Code: a general purpose, popular and future-proof IDE with support
  for R. See
  [github.com/REditorSupport/vscode-R](https://github.com/REditorSupport/vscode-R#getting-started)
  and [quarto.org](https://quarto.org/docs/get-started/) for
  installation instructions.

After you have installed a suitable IDE you will need to install R
packages used in this tutorial. You can install the packages we’ll use
with the following commands:

``` r
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
```

``` r
remotes::install_cran(pkgs)
```

``` r
sapply(pkgs, require, character.only = TRUE)
```

            sf  tidyverse       geos data.table     spData 
          TRUE       TRUE       TRUE       TRUE       TRUE 

## An introduction to the tidyverse

The `tidyverse` is a collection of packages that provides a unified set
of functions for data science. A good way to understand it is to get
started with a small dataset.

After loading the packages run the following commands to create an
object called countries, containing countries whose centroids are within
200km of the Polish border:

``` r
names(world) # check we have the data
```

     [1] "iso_a2"    "name_long" "continent" "region_un" "subregion" "type"     
     [7] "area_km2"  "pop"       "lifeExp"   "gdpPercap" "geom"     

``` r
poland = world |>
    filter(name_long == "Poland")
world_centroids = world |>
    st_centroid()
```

    Warning: st_centroid assumes attributes are constant over geometries

``` r
country_centroids = world_centroids |>
  st_filter(poland, .predicate = st_is_within_distance, dist = 2e5)
countries = world |>
  filter(name_long %in% country_centroids$name_long)
countries_df = countries |>
  select(name_long, pop, area_km2) |>
  st_drop_geometry()
```

Don’t worry about the syntax for now, we’ll explain it later. The
important thing is that we now have a data frame with three columns,
representing the name, population and area of four countries. We can
print out the contents of the data frame by typing its name (this is
equivalent to `print(countries_df)`):

``` r
countries_df
```

    # A tibble: 4 × 3
      name_long           pop area_km2
    * <chr>             <dbl>    <dbl>
    1 Poland         38011735  310402.
    2 Lithuania       2932367   63831.
    3 Slovakia        5418649   47068.
    4 Czech Republic 10525347   81208.

The output above shows information about each country in a tabular. A
feature of the tidyverse is that its data frame class (the `tibble`
which extends base R’s `data.frame` as shown below) prints results in an
informative and space-efficient way.

``` r
class(countries_df)
```

    [1] "tbl_df"     "tbl"        "data.frame"

## Exercises

1.  Re-create the `country_centroids` object, using `world_centroids`
    and `poland` and inputs, but this time using base R syntax with the
    `[` operator.

- Bonus: use the `bench::mark()` function to compare the performance of
  the base R and tidyverse implementation
