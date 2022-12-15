#' List of [ColorBrewer](https://colorbrewer2.org/) palettes grouped by type of visualization scale
#'
#' @noRd
palettes.lst <- list(
    'SEQUENTIAL' = c( # ordinal data where (usually) low is less important and high is more important
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


#' dd_palette
#' 
#' A tailored `palettePicker` control from the `esquisse` package
#'
#' @param id  id for the  control
#' @param lbl label for the control
#' @param sel colour scheme at start
#'
#' @return a palettePicker control  
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @importFrom esquisse palettePicker
#'
#' @export
#'
dd_palette <- function(id, lbl = 'PALETTE:', sel = 'Red-Yellow-Blue'){
    palettePicker(
        inputId = id, 
        label = lbl,
    	choices = palettes.lst.pkr,
        selected = sel,
        textColor = c( 
            rep('black', length(palettes.lst.pkr[[1]])), 
            rep('white', length(palettes.lst.pkr[[2]])), 
            rep('black', length(palettes.lst.pkr[[3]]))
        ) 
    )
}


#' dd_colour
#' 
#' A tailored `colorPickr` control from the `shinyWidgets` package
#'
#' @param id  id for the  control
#' @param lbl label for the control
#' @param slz colour scheme at start
#' @param full if TRUE returns the full object, otherwise the minimal compact
#'
#' @return a colorPickr control  
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @importFrom shinyWidgets colorPickr
#'
#' @export
#'
dd_colour <- function(id, lbl, slz, full = TRUE){
    if(full){
        colorPickr(
            inputId = id,
            label = lbl,
            selected = slz,
            theme = 'monolith',
            width = '100%'
        )
    } else {
        colorPickr(
            inputId = id,
            label = lbl,
            selected = slz,
            swatches = marker_colours,
            update = 'change',
            preview = FALSE,
            hue = FALSE,
            interaction = list( hex = FALSE, rgba = FALSE, input = FALSE, save = FALSE, clear = FALSE ),
            pickr_width = '230px'
        )
    }
}
