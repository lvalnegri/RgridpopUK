################################################################
# Copy datasets from PUBLIC REPO (or else) to PACKAGE DATA DIR #
################################################################

library(data.table)
library(leaflet)
devtools::load_all()

# MSOA boundaries WGS84 simplified at 20%
fn <- 'MSOA'
y <- qs::qread(file.path(Rfuns::bnduk_path, 's20', 'MSOA21')) |> setnames('MSOA21', 'MSOA')
bbx <- as.numeric(sf::st_bbox(y))
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )
sf::st_write(y, './data-raw/shp/MSOA.shp', append=FALSE)

# initial map
fn <- 'mps'
y <- leaflet() |>
        add_maptile(tiles.lst[[2]]) |> 
        fitBounds(bbx[1], bbx[2], bbx[3], bbx[4]) |>
        regPlugin(spinPlugin) |>
        regPlugin(leafletspinPlugin) |>
        on_render_spin('
                  if(document.getElementById("map_menu_title") === null)
                      $(".leaflet-control-layers-overlays").prepend("<span id=map_menu_title>CENTROIDS</span>");
              ') |>
        clearShapes() |>
        end_spinmap(c(-1.777699, 52.55826))
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )

# MSOA boundaries BNG original
fn <- 'MSOAgb'
y <- qs::qread(file.path(Rfuns::bnduk_path, 's00', 'MSOA21gb')) |> setnames('MSOA21', 'MSOA')
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )
sf::st_write(y, './data-raw/shp/MSOAgb.shp', append=FALSE)

# MSOA data.table
fn <- 'zones'
y1 <- data.table( 
          y |> st_drop_geometry(), 
          area = y |> st_area() |> as.integer(),
          perimeter = y |> lwgeom::st_perimeter() |> as.integer(),
          y |> st_centroid() |> st_geometry() |> st_transform(4326) |> st_coordinates() |> as.data.table() |> setNames(c('gx_lon', 'gy_lat'))
      ) |> setkey('MSOA')
# >>>>>> this should be corrected when ONS publishes its very own Census 2021 weighted centroids <<<<<<<
y2 <- fread(
          'https://opendata.arcgis.com/api/v3/datasets/c0e3f920e20e41b3a994dd7fc7333c91_0/downloads/data?format=csv&spatialRefId=27700&where=1%3D1', 
          select = c('msoa11cd', 'X', 'Y'), 
          col.names = c('MSOA', 'x', 'y')
      ) |>
      st_as_sf(coords = c('x', 'y'), crs = 27700) |> 
      st_transform(4326) 
y2 <- data.table(y2 |> st_drop_geometry(), y2 |> st_coordinates()) |> setkey('MSOA') |> setNames(c('MSOA', 'ox_lon', 'oy_lat'))
y3 <- fst::read_fst(file.path(Rfuns::datauk_path, 'fb_gridpop', 'total')) |> 
          wcentroids(27700, from_wgs = TRUE, id = 'MSOA') |> 
          setkey('MSOA')
y4 <- data.table( 
          y |> st_drop_geometry(), 
          y |> polylabelr::poi() |> rbindlist() |> st_as_sf(coords=c('x', 'y'), crs = 27700) |> st_transform(4326) |> st_coordinates() 
      ) |> setnames(c('MSOA', 'px_lon', 'py_lat')) |> setkey('MSOA')
yno <- fread(
  'https://www.arcgis.com/sharing/rest/content/items/792f7ab3a99d403ca02cc9ca1cf8af02/data', 
  select = c('msoa21cd', 'msoa21nm', 'lad22cd', 'lad22nm'), 
  col.names = c('MSOA', 'MSOAno', 'LAD', 'LADn')
) |> unique()
yn <- fread(
  'https://houseofcommonslibrary.github.io/msoanames/MSOA-Names-Latest2.csv', 
  select = c('msoa21cd', 'msoa21hclnm'), 
  col.names = c('MSOA', 'MSOAn')
)
yn <- yno[yn, on = 'MSOA'][, MSOAd := paste0(MSOAn, ' [', LADn, ']')] |> setkey('MSOA')
y <- yn[y1[y2[y3[y4]]]]
# >>>>>> this should be DELETED when ONS publishes its very own Census 2021 weighted centroids <<<<<<<
y[is.na(ox_lon), `:=`( ox_lon = wx_lon, oy_lat = wy_lat )]
setcolorder(y, c('MSOA', 'MSOAno', 'MSOAn', 'LAD', 'LADn', 'MSOAd'))
yc <- fread('./data-raw/csv/census.csv')
y <- y[yc]
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )
fwrite(y, './data-raw/csv/MSOA.csv')

# MSOA list
fn <- 'msoa.lst'
y <- Rfuns::create_list(y[, .(MSOA, MSOAd)][order(MSOAd)], FALSE) 
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )

# clean
rm(list = ls())
gc()
