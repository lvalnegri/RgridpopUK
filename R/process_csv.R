#' Process CSV Files
#'
#' Download HDX/Meta High Resolution Population Density Files
#' 
#' @param in_path  the folder that stores the unzipped csv files
#' @param out_path the folder where the binary `fst` files will be saved
#'
#' @return none
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @export
#'
process_csv <- \(in_path, out_path = in_path){
    bbox <- st_bbox(MSOA)
    fns <- list.files(in_path, 'csv$', full.names = TRUE)
    tns <- gsub('.*/(.*).csv$', '\\1', fns) 
    for(idx in 1:length(fns)){
        message('\n===============================================')
        message('\nSTARTING: ', toupper(tns[idx]))
        y <- fread(fns[idx], col.names = c('y_lat', 'x_lon', 'pop'))
        y <- y[!(x_lon < bbox[1] | x_lon > bbox.uk[2] | y_lat < bbox.uk[3] | y_lat > bbox.uk[4]) & pop > 0][, id := 1:.N] |> setcolorder('x_lon')
        yt <- rbindlist(lapply(
            MSOAgb$MSOA,
            \(x){
                message('Processing: ', x)
                ybx <- MSOAgb |> subset(MSOA == x) 
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
        write_fst_idx(yt, tns[idx], 'MSOA', out_path)
    }
}