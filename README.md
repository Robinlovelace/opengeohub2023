# OpenGeoHub Summer School 2023

<div>

[![](https://github.com/Robinlovelace/opengeohub2023/actions/workflows/publish.yml/badge.svg)](https://github.com/Robinlovelace/opengeohub2023/actions/workflows/publish.yml)

Quarto Publish

</div>

This repo contains code to support sessions that I will deliver for the
OpenGeoHub Summer School 2023.

As shown in the course
[schedule](https://pretalx.earthmonitor.org/opengeohub-summer-school-2023/schedule/)
I will deliver the following sessions:

- [Tidy geographic data with sf, dplyr, ggplot2, geos and
  friends](https://pretalx.earthmonitor.org/opengeohub-summer-school-2023/talk/7JN3FV/)
  - 2023-08-28, 11:00–12:30, Room 21 (Sala 21)  
- [Processing large OpenStreetMap datasets for geocomputational
  research](https://pretalx.earthmonitor.org/opengeohub-summer-school-2023/talk/SRMZVJ)
  - 2023-09-01, 09:00–10:30, Room 18 (Sala 18)

Abstracts for these sessions are provided below.

## Tidy geographic data with sf, dplyr, ggplot2, geos and friends

### Abstract

This lecture will provide an introduction to working with geographic
data using R in a ‘tidy’ way. It will focus on using the `sf` package to
read, write, manipulate, and plot geographic data in combination with
the `tidyverse` metapackage. Why use the `sf` package with the
`tidyverse`? The lecture will outline some of the ideas underlying the
`tidyverse` and how they can speed-up data analysis pipelines, while
making data analysis code easier to read and write. We will see how the
following lines

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

## Processing large OpenStreetMap datasets for geocomputation

OpenStreetMap (OSM) is a free and openly editable map of the world. Like
Wikipedia and unlike government or corperation maintained datasets, OSM
is created and maintained by a community of volunteers, making it the
premier decentralized and fastest evolving source of geographic vector
data focussed on features relevant to human activity (e.g. roads,
buildings, cafes) on planet Earth. Unlike Wikipedia, every data point in
OSM has a geographic location and attributes must be structured as
key-value pairs. OSM is a rich source of data for geocomputational
research, but the decentralized nature of the project and the sheer
volume of data. ‘Planet.osm’ now has more nodes than there are people on
Earth, with more than 8 billion
[nodes](https://wiki.openstreetmap.org/wiki/Node), and the rate of data
creation is increasing as the community grows, to [10 million
users](https://wiki.openstreetmap.org/wiki/Stats) in early 2023. The
size and rapid evolution of OSM are great strengths, democratising
geographic knowledge and ensuring resilience. However, these features
can make it difficult to work with OSM data.

This lecture will provide an introduction to working with OSM and will
cover the following:

- How and where to download OSM data
- How to process small amounts of OSM data using the `osmdata` R package
- How to process large OSM ‘extracts’ data with the `osmextract` R
  package
- Other command line tools for working with OSM data, including the
  mature and widely used `osmium` tool, the `pyrosm` Python package and
  the [`osm2streets`](https://github.com/a-b-street/osm2streets) web
  application and Rust codebase

Finally, the lecture will outline ideas for using OSM data. It will
conclude with a call to action, inspiring the use of this rich resource
to support policy objectives such as the fast and fair decarbonisation
of the global economy as societies transition away from inefficient,
polluting and costly fossil fuels.

<!-- ## Using geocomputation in government
&#10;TBC -->

## Reproducibility

To install the dependencies for this repo, run the following command:

``` r
remotes::install_github("robinlovelace/opengeohub2023")
```

This repo also uses the `renv` package to manage dependencies. We saved
the dependencies with the following command:

``` r
renv::snapshot()
```



    processing file: tidy.qmd

    1/13                   
    2/13 [unnamed-chunk-5] 
    3/13                   
    4/13 [unnamed-chunk-6] 
    5/13                   
    6/13 [unnamed-chunk-7] 
    7/13                   
    8/13 [unnamed-chunk-8] 
    9/13                   
    10/13 [unnamed-chunk-9] 
    11/13                   
    12/13 [unnamed-chunk-10]
    13/13                   

    output file: tidy.R

    [1] "tidy.R"
