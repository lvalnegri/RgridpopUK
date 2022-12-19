#' wcentroids
#' 
#' Calculates a series of *weighted* centroids with an output in CRS WGS84
#' 
#' @param y      a data.table
#' @param crs    the projection CRS of the data in input, if any (see `from_wgs`)
#' @param coords the name of the columns with the coordinates (first longitude, then latitude)
#' @param from_wgs if `TRUE` accept the input as from geographic coordinates
#' @param cn     the name of the column with the values to be weighted
#' @param id     an optional column name to use for grouping
#' @param fexp   a value to add as exponent (fexp==1, mean; fexp=0.5, square root; fexp=2, quad mean; and so on)
#' @param prfx   a prefix to add to `coords` in output
#' 
#' @return a data.table
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @import data.table
#' @importFrom stats weighted.mean
#' 
#' @export
#'
wcentroids <- function(y, crs, coords = c('x_lon', 'y_lat'), from_wgs = FALSE, cn = 'pop', id = NULL, fexp = 1, prfx = 'w'){
    if(from_wgs){
        y <- y |> st_as_sf(coords = coords, crs = 4326) |> st_transform(crs)
    } else {
        y <- y |> st_as_sf(coords = coords, crs = crs)
    }
    y <- data.table( y |> st_drop_geometry(), y |> st_coordinates() |> as.data.table() |> setnames(coords) )
    ncoords <- paste0(prfx, coords)
    if(is.null(id)){
        y <- y[, .( weighted.mean(get(coords[1]), get(cn) ** fexp), weighted.mean(get(coords[1]), get(cn) ** fexp) )] |> 
                setnames(ncoords)
        data.table( y |> st_as_sf(coords = ncoords, crs = crs) |> st_transform(4326) |> st_coordinates() )
    } else {
        y <- y[, .( weighted.mean(get(coords[1]), get(cn) ** fexp), weighted.mean(get(coords[2]), get(cn) ** fexp) ), get(id)] |> 
                setnames(c(id, ncoords))
        data.table( y[[id]], y |> st_as_sf(coords = ncoords, crs = crs) |> st_transform(4326) |> st_coordinates() |> as.data.table() ) |> 
          setnames(c(id, ncoords))
    }
}
