################################################################
# Copy datasets from PUBLIC REPO (or else) to PACKAGE DATA DIR #
################################################################

library(data.table)
library(leaflet)
devtools::load_all()

# MSOA boundaries WGS84 simplified at 20%
fn <- 'MSOA'
y <- qs::qread(file.path(Rfuns::bnduk_path, 's20', 'MSOA21')) |> setnames('MSOA21', 'MSOA')
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )

# initial map
bbx <- as.numeric(sf::st_bbox(y))
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

# MSOA list
fn <- 'msoa.lst'
y <- unique(RcensusUK::lookups[, .(MSOA, LTLA)])[RcensusUK::zones[type == 'LTLA', .(LTLA = id, LTLAd = name)], on = 'LTLA'][, LTLA := NULL]
y <- RcensusUK::zones[type == 'MSOA', .(MSOA = id, MSOAd = name)][y, on = 'MSOA'][, MSOAd := paste0(MSOAd, ' [', LTLAd, ']')][, LTLAd := NULL]
y <- Rfuns::create_list(y[order(MSOAd)], FALSE) 
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )
