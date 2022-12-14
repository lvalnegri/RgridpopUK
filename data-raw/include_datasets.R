################################################################
# Copy datasets from PUBLIC REPO (or else) to PACKAGE DATA DIR #
################################################################

library(data.table)

Rfuns::load_pkgs('data.table', 'leaflet')
devtools::load_all()

y <- basemap(menu = FALSE, tiles = tiles.lst[[2]], add_pb_menu = FALSE, extras = NULL) |>
        fitBounds(bbox.it[1, 1], bbox.it[2, 1], bbox.it[1, 2], bbox.it[2, 2]) |>
        registerPlugin(spinPlugin) |>
        registerPlugin(leafletspinPlugin) |>
        on_render_spin('
            if(document.getElementById("map_menu_title") === null)
                $(".leaflet-control-layers-overlays").prepend("<span id=map_menu_title>CENTROIDS</span>");
        ') |>
        clearShapes() |>
        spin_map_end()

fn <- 'mps'
assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )

fn <- 'yb'
assign(fn, readRDS(file.path(bnduk_path, 's20', 'MSOA')))
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )

fn <- 'ym'
y <- fread(
        'https://houseofcommonslibrary.github.io/msoanames/MSOA-Names-Latest.csv', 
        select = c('msoa11cd', 'msoa11hclnm'), 
        col.names = c('MSOA', 'MSOAd')
)

assign(fn, y)
save( list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip' )

