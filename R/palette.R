#' marker_colours
#' 
#' List of the available colours to fill *Awesome Markers* in `leaflet` maps
#'
#' @references \url{https://rstudio.github.io/leaflet/markers.html}
#' 
#' @return a character vector
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @export
#' 
marker_colours <- c(
  'red', 'darkred', 'orange', 'pink', 'beige', 
  'green', 'lightgreen', 'darkgreen', 
  'blue', 'lightblue', 'cadetblue', 'purple', 
  'white', 'gray', 'lightgray', 'black'
)

#' palettes.lst
#' 
#' List of *ColorBrewer* palettes grouped by type of visualization scale:
#' - **sequential**:  ordinal data where *low* is less/more important and *high* is more/less important
#' - **diverging**:   ordinal data where both low and high are equally but opposite important (deviation from some reference *average* point)
#' - **qualitative**: categorical/nominal data where there is no apparent or logical order
#'
#' @references \url{https://colorbrewer2.org/}
#' 
#' @return a list
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @export
palettes.lst <- list(
    'SEQUENTIAL' = c( # 
        'Blues' = 'Blues', 'Blue-Green' = 'BuGn', 'Blue-Purple' = 'BuPu', 'Green-Blue' = 'GnBu', 'Greens' = 'Greens', 'Greys' = 'Greys',
        'Oranges' = 'Oranges', 'Orange-Red' = 'OrRd', 'Purple-Blue' = 'PuBu', 'Purple-Blue-Green' = 'PuBuGn', 'Purple-Red' = 'PuRd', 'Purples' = 'Purples',
        'Red-Purple' = 'RdPu', 'Reds' = 'Reds', 'Yellow-Green' = 'YlGn', 'Yellow-Green-Blue' = 'YlGnBu', 'Yellow-Orange-Brown' = 'YlOrBr',
        'Yellow-Orange-Red' = 'YlOrRd'
    ),
    'DIVERGING' = c(  # ordinal data where both low and high are important (i.e. deviation from some reference "average" point)
        'Brown-Blue-Green' = 'BrBG', 'Pink-Blue-Green' = 'PiYG', 'Purple-Red-Green' = 'PRGn', 'Orange-Purple' = 'PuOr', 'Red-Blue' = 'RdBu', 'Red-Grey' = 'RdGy',
        'Red-Yellow-Blue' = 'RdYlBu', 'Red-Yellow-Green' = 'RdYlGn', 'Spectral' = 'Spectral'
    ),
    'QUALITATIVE' = c(  # categorical/nominal data where there is no logical order
        'Accent' = 'Accent', 'Dark2' = 'Dark2', 'Paired' = 'Paired', 'Pastel1' = 'Pastel1', 'Pastel2' = 'Pastel2',
        'Set1' = 'Set1', 'Set2' = 'Set2', 'Set3' = 'Set3'
    )
)

#' palettes.lst.pkr
#' 
#' A named nested list of colour schemas to be used in Shiny controls
#'
#' @return a list
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @importFrom scales brewer_pal
#' 
#' @export
#'
palettes.lst.pkr <- {
    yx <- lapply(
            1:3, 
            \(z) {
                yxz <- lapply(1:length(palettes.lst[[z]]), \(x) brewer_pal(palette = palettes.lst[[z]][[x]])(8))
                names(yxz) <- names(palettes.lst[[z]])
                yxz
            }
    )
    names(yx) <- names(palettes.lst)
    yx
}
