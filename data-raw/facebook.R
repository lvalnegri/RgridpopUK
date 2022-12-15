######################################
# Grid Population - Facebook - 30 mt #
######################################
# https://data.humdata.org/dataset/united-kingdom-high-resolution-population-density-maps-demographic-estimates

Rfuns::load_pkgs('data.table', 'qs', 'sf')

in_path <- file.path(ext_path, 'uk', 'fb_gridpop')
out_path <- file.path(datauk_path, 'fb_gridpop')

down_unz <- FALSE
if(down_unz){
    pfx_url <- 'https://data.humdata.org/dataset/b9a7b4a3-75a7-4de1-b741-27d78e8d0564/resource/'
    sfx_urls <- c(
        'total' = '674a0049-1a75-4f9a-a07b-654bda75456e/download/population_gbr_2019-07-01.csv.zip',
        'males' = 'e59e0fc5-37fc-4278-a7f3-e6d2de5a8166/download/gbr_men_2019-08-03_csv.zip',
        'females' = 'b8b43628-7a86-4ffc-80b7-f44fb135a93d/download/gbr_women_2019-08-03_csv.zip',
        'elderly' = '5ee85e33-60d5-4f44-bde6-c976a3311c0b/download/gbr_elderly_60_plus_2019-08-03_csv.zip',
        'youth' = '9411da18-a7e9-4237-ba37-80839af9fbfc/download/gbr_youth_15_24_2019-08-03_csv.zip',
        'children' = 'ad7bb2fa-8ab7-4e01-9cc5-3fc91afbbc51/download/gbr_children_under_five_2019-08-03_csv.zip',
        'women' = '6a952916-115a-4385-9c77-de9d343b1635/download/gbr_women_of_reproductive_age_15_49_2019-08-03_csv.zip'
    )
    tmpf <- tempfile()
    for(idx in 1:length(sfx_urls)){
        fn <- sfx_urls[idx]
        message('Processing ', toupper(names(fn)))
        download.file(file.path(pfx_url, fn), tmpf, quiet = TRUE)
        unzip(tmpf, exdir = in_path)
        file.rename(file.path(in_path, unzip(tmpf, list = TRUE)$Name), file.path(in_path, paste0(names(fn), '.csv')))
    }
    unlink(tmpf)
}

yb <- qs::qread(file.path(bnduk_path, 's00', 'MSOA21gb'))

fns <- list.files(in_path, 'csv$', full.names = TRUE)
tns <- gsub('.*/(.*).csv$', '\\1', fns) 
for(idx in 1:length(fns)){
    message('\n===============================================')
    message('\nSTARTING: ', toupper(tns[idx]))
    y <- fread(fns[idx], col.names = c('y_lat', 'x_lon', 'pop'))
    y[, `:=`( id = 1:.N, x_lon = x_lon + 0.00025 )]
    y <- y[!(x_lon < bbox.uk[1, 1] | x_lon > bbox.uk[1, 2] | y_lat < bbox.uk[2, 1] | y_lat > bbox.uk[2, 2]) & pop > 0]
    yt <- rbindlist(lapply(
              yb$MSOA,
              \(x){
                  message('Processing: ', x)
                  ybx <- yb |> subset(MSOA == x) 
                  ybb <- ybx |> st_transform(4326) |> st_bbox()
                  yx <- y[x_lon %between% c(ybb[1], ybb[3]) & y_lat %between% c(ybb[2], ybb[4])] |> 
                          st_as_sf(coords = c('x_lon', 'y_lat'), crs = 4326) |> 
                          st_transform(27700) |> 
                          st_join(ybx, join = st_within) |> 
                          st_transform(4326) |> 
                          subset(!is.na(MSOA))
                  y <<- y[!id %in% yx$id]
                  data.table(x, yx |> subset(select = pop) |> st_drop_geometry(), yx |> st_coordinates())
              }
    ))
    setnames(yt, c('MSOA', 'pop', 'x_lon', 'y_lat'))
    setcolorder(yt, c('MSOA', 'x_lon', 'y_lat'))
    write_fst_idx(tns[idx], 'MSOA', yt, out_path)
}

rm(list = ls())
gc()
