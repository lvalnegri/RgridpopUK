#' @importFrom data.table data.table
NULL

#' @import sf
NULL

#' zones
#'
#' A list of all the *Middle-Layer Super Output Areas* in England and Wales as of the 2021 Census, 
#' together with their *embellished* names and some geographic characteristics.
#'
#' @format A data.table with the following columns:
#' \describe{
#'   \item{\code{MSOA}}{ The *ONS* identifier }
#'   \item{\code{MSOAno}}{ The *ONS* name }
#'   \item{\code{MSOAn}}{ A *presentable* name }
#'   \item{\code{LAD}}{ The *ONS* identifier for the `LAD` the `MSOA` is included into }
#'   \item{\code{LADn}}{ The *ONS* name for the `LAD` }
#'   \item{\code{MSOAd}}{ The name for the `MSOA` complete with its `LAD` name }
#'   \item{\code{area}}{ The geographic area  }
#'   \item{\code{perimeter}}{ The perimeter or boundary length }
#'   \item{\code{gx_lon}}{ The longitude of the Geometric Centroid }
#'   \item{\code{gy_lat}}{ The latitude of the Geometric Centroid }
#'   \item{\code{ox_lon}}{ The longitude of the ONS Weighted Centroid }
#'   \item{\code{oy_lat}}{ The latitude of the ONS Weighted Centroid }
#'   \item{\code{wx_lon}}{ The longitude of the (internal) simple mean Weighted Centroid }
#'   \item{\code{wy_lat}}{ The latitude of the (internal) simple mean Weighted Centroid }
#'   \item{\code{px_lon}}{ The longitude of the *Pole of Inaccessibility* }
#'   \item{\code{py_lat}}{ The latitude of the *Pole of Inaccessibility* }
#'   \item{\code{population}}{ Population as of Census England and Wales 2021 }
#'   \item{\code{males}}{ Males as of Census England and Wales 2021 }
#'   \item{\code{females}}{ Females as of Census England and Wales 2021 }
#'   \item{\code{children}}{ Children (age 0-4) as of Census England and Wales 2021 }
#'   \item{\code{youth}}{ Youth (age 15-24) as of Census England and Wales 2021 }
#'   \item{\code{elderly}}{ Elderly (age 60+) as of Census England and Wales 2021 }
#' }
#'
#' For further details, see:
#' - the [House of Commons Library MSOA Names](https://houseofcommonslibrary.github.io/msoanames/)
#' - the [ONS Weighted centroids for MSOA](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=name&tags=all(CTD_MSOA)) 
#' - the [Census 2021 for England and Wales](https://www.nomisweb.co.uk/sources/census_2021_ts)
#' - the [*polylabelr*](https://github.com/jolars/polylabelr) $R$ package, wrapper for
#'   the [mapbox *polylabel*](https://github.com/mapbox/polylabel) JS library, a fast algorithm for 
#'   finding the *pole of inaccessibility*, aka the most distant internal point from a polygon outline, also called *visual centre*.
#' 
'zones'

#' msoa.lst
#' 
#' List of Medium Super Output Areas (MSOA) names and ONS codes in England and Wales for use in a Shiny *select* control. 
#' The name of each `MSOA` is completed with the name in brackets of the correspondent `LAD`.
#'
#' For more details, consult the [ONS Geoportal](https://geoportal.statistics.gov.uk/search?sort=-modified&tags=msoa) and 
#' the [House of Commons Library MSOA Names](https://houseofcommonslibrary.github.io/msoanames/)
#' 
'msoa.lst'

#' MSOA
#'
#' Geographic Digital Boundaries in `sf` format of Medium Super Output Areas (MSOA) in England and Wales as of last Census 2021 (last update: Dec 2021).
#' 
#' The CRS is WGS84, EPSG:4326
#'
#' For more details, consult the [ONS Geoportal](https://geoportal.statistics.gov.uk/)
#'
'MSOA'

#' mps
#'
#' Initial leaflet map centred on England and Wales
#'
'mps'
