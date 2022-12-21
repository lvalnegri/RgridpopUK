#' leaflet palette
#' 
#' Build a leaflet palette 
#'
#' @param pn the name of the *ColorBrewer* palette (see `palettes.lst`)
#' @param pv the vector values on which calculate the palette
#' @param rv if `TRUE` the colours in the palette must be reversed
#'
#' @return a leaflet palette object
#' 
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @export
#'
leaf_pal <- function(pn, pv, rv = FALSE){
    y <- lapply(names(palettes.lst), \(x) which(names(palettes.lst[[x]]) == pn))
    colorNumeric(as.character(palettes.lst[[which(y > 0)]][unlist(y)]), pv, reverse = rv)
}


#' Draw population points
#' 
#' Add a layer of points representing a high density population grid related to a MSOA
#'
#' @param mp a leaflet object
#' @param pb the points to be displayed in `sf` format. There must also be included a column called `pop` with the values to build a palette.
#' @param pr the radius of the points
#' @param pn the name of the *ColorBrewer* palette (see `palettes.lst`)
#' @param rv if `TRUE` the colours in the palette must be reversed
#' @param dn the name of the population segment
#'
#' @return a leaflet object
#' 
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @export
#'
add_ppop <- function(mp, pb, pr, pn, rv, dn){
    pal <- leaf_pal(pn, pb$pop, rv)
    addGlPoints(mp,
        data = pb, 
        group = 'gridpop',
        radius = pr,
        fragmentShaderSource = 'square',
        fillColor = ~pal(pop), 
        fillOpacity = 1, 
        popup = ~paste('Density: ', formatC(pop, 2))
    ) |> 
    addLegend(
      position = 'bottomright',
      group = 'gridpop',
      layerId = 'legend',
      pal = pal, 
      values = pb$pop,
      opacity = 1,
      title = dn
    ) 
}


#' Name a leaflet marker 
#' 
#' Create a name for each centroid marker or all at once
#'
#' @param x a row of the `centroids` table or all the table 
#'
#' @return an HTML string to use as group name for the centroid markers
#' 
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @export
#'
grp_name <- \(x) paste0('<span style="color:', x$fColour,'">&nbsp<i class="fa fa-', x$icon, '"></i>&nbsp', '</span>', x$description)


#' Draw a Marker
#' 
#' Draw a Marker for a centroid
#'
#' @param mp a leaflet object
#' @param cx the properties of the centroid (see the `centroids` table) 
#' @param cv a vector of coordinates values for the centroids, conveniently named
#'
#' @return a leaflet object
#' 
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @export
#'
add_cmarker <- function(mp, cx, cv){
    tx <- centroids[code == cx]
    mp |> 
        addAwesomeMarkers(
            data = cv, 
            lng = ~get(paste0(tx$code, 'x_lon')), 
            lat = ~get(paste0(tx$code, 'y_lat')),
            group = grp_name(tx),
            icon = makeAwesomeIcon(icon = tx$icona, library = "fa", markerColor = tx$fColour, iconColor = tx$colour),
            label = tx$description
        )
}


#' Draw all Markers
#' 
#' Draw a Marker for all centroids
#'
#' @param mp a leaflet object
#' @param cv a vector of coordinates values for the centroids, conveniently named
#'
#' @return a leaflet object
#' 
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @export
#'
add_cmarkers <- function(mp, cv){
    for(cc in centroids$code) mp <- mp |> add_cmarker(cc, cv)
    mp |> addLayersControl( overlayGroups = grp_name(centroids), options = layersControlOptions(collapsed = FALSE) )
}


#' Draw MSOA polygon
#' 
#' Add an MSOA polygon on a *leaflet* map as a polylines object 
#'
#' @param mp a leaflet object
#' @param yb the boundaries of the `MSOA` in `sf` format
#' @param mn the name of the `MSOA`
#' @param mdn the *display* name for the Area
#' @param mv the values of the population for the cells included in the `MSOA`
#' @param mc the colour for the polygon line 
#' @param mw the weight for the polygon line
#' @param hc the colour for the line when the polygon is highlighted
#' @param hw the weight for the line when the polygon is highlighted
#'
#' @return a leaflet object
#' 
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @export
#'
add_poly_msoa <- function(mp, yb, mn, mdn, mv, mc, mw, hc = 'white', hw = 6){
    addPolylines(mp,
        data = yb,
        group = 'msoa',
        color = mc, 
        weight = mw,
        opacity = 1,
        fillOpacity = 0, 
        label = HTML(paste0('<b>MSOA</b>: ', mn, '<br><b>', mdn, '</b>: ', formatC(sum(mv), big.mark = ','))),
        highlightOptions = highlightOptions(color = hc, weight = hw, opacity = 1, bringToFront = TRUE, sendToBack = TRUE)
    )
}


