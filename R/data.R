#' @importFrom data.table data.table
NULL

#' @import sf
NULL

#' msoa.lst
#' 
#' List of Medium Super Output Areas (MSOA) names and ONS codes in England and Wales for use in a Shiny *select* control. 
#' The name of each Zone is completed with the name in brackets of the correspondent `LTLA`
#'
#' For more details, consult the [ONS Geoportal](https://geoportal.statistics.gov.uk/search?sort=-modified&tags=msoa) and 
#' the [House of Commons Library MSOA Names](https://houseofcommonslibrary.github.io/msoanames/])
#' 
'msoa.lst'

#' MSOA
#'
#' Geographic Digital Boundaries in `sf` format of Medium Super Output Areas (MSOA) in England and Wales as of last Census 2021 (last update: Dec 2021).
#' 
#' The CRS is WGS84, EPSG:4326, the lines have been simplified at 20%
#'
#' For more details, consult the [ONS Geoportal](https://geoportal.statistics.gov.uk/]
#'
'MSOA'

#' MSOAgb
#'
#' Geographic Boundaries in `sf` format of Medium Super Output Areas (MSOA) in England and Wales as of last Census 2021 (last update: Dec 2021).
#'
#' The CRS is BNG, EPSG:27700, the lines have been kept at their original shape.
#'
#' For more details, consult the [ONS Geoportal](https://geoportal.statistics.gov.uk/]
#'
'MSOAgb'

#' mps
#'
#' Initial leaflet map of England and Wales
#'
'MSOA'
