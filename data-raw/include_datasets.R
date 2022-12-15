################################################################
# Copy datasets from PUBLIC REPO (or else) to PACKAGE DATA DIR #
################################################################

Rfuns::load_pkgs('data.table', 'leaflet', 'qs', 'RShinyUtils')
devtools::load_all()

# initial map
fn <- 'mps'
y <- leaflet() |>
        add_maptile(tiles.lst[[2]]) |> 
        fitBounds(bbox.uk.cut[1, 1], bbox.uk.cut[2, 1], bbox.uk.cut[1, 2], bbox.uk.cut[2, 2]) |>
        registerPlugin(spinPlugin) |>
        registerPlugin(leafletspinPlugin) |>
        on_render_spin('
            if(document.getElementById("map_menu_title") === null)
                $(".leaflet-control-layers-overlays").prepend("<span id=map_menu_title>CENTROIDS</span>");
        ') |>
        clearShapes() |>
        end_spinmap_it()
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )

# MSOA boundaries WGS84 simplified at 20%
fn <- 'MSOA'
y <- qs::qread(file.path(bnduk_path, 's20', 'MSOA21')) |> setnames('MSOA21', 'MSOA')
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )

# MSOA boundaries BNG original
fn <- 'MSOAgb'
y <- qs::qread(file.path(bnduk_path, 's00', 'MSOA21gb')) |> setnames('MSOA21', 'MSOA')
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )

# MSOA list
fn <- 'msoa.lst'
y <- unique(RcensusUK::lookups[, .(MSOA, LTLA)])[RcensusUK::zones[type == 'LTLA', .(LTLA = id, LTLAd = name)], on = 'LTLA'][, LTLA := NULL]
y <- RcensusUK::zones[type == 'MSOA', .(MSOA = id, MSOAd = name)][y, on = 'MSOA'][, MSOAd := paste0(MSOAd, ' [', LTLAd, ']')][, LTLAd := NULL]
y <- create_list(y[order(MSOAd)], FALSE) 
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )
