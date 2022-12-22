#' regPlugin
#' 
#' Helper function to register plugins in `leaflet` maps
#'
#' @param mp a leaflet object
#' @param plugin the definition of a `leaflet` plugin
#' 
#' @return a leaflet object
#' 
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#' 
#' @export
#' 
regPlugin <- function(mp, plugin) {
    mp$dependencies <- c(mp$dependencies, list(plugin))
    mp
}


#' faPlugin
#' 
#' Defines a dependency to allow the use of *fontawesome pro* icons pro in `leaflet` maps
#'
#' @references `https://fontawesome.com/v6/docs/web/style/styling`
#'
#' @importFrom htmltools htmlDependency
#'
#' @export
#' 
faPlugin <- htmlDependency(
    name = 'fontawesome',
    version = '99.0',
    src = c(href = 'https://analytics-hub.ml/assets/icons/fontawesome'),
    stylesheet = 'css/all.css'
)


#' spinPlugin
#' 
#' Dependency (1) needed for the spin plugin in leaflet maps during a proxy in shiny apps
#'
#' @references \url{https://spin.js.org/}
#'
#' @importFrom htmltools htmlDependency
#'
#' @export
#' 
spinPlugin <- htmlDependency(
    name = 'spin.js',
    version = '2.3.2',
    src = c(href = 'https://cdnjs.cloudflare.com/ajax/libs/spin.js/2.3.2'),
    script = 'spin.min.js'
)

#' leafletspinPlugin
#' 
#' Dependency (2) needed for the spin plugin in leaflet maps during a proxy in shiny apps
#'
#' @references \url{https://github.com/makinacorpus/Leaflet.Spin}
#'
#' @importFrom htmltools htmlDependency
#'
#' @export
#' 
leafletspinPlugin <- htmlDependency(
  name = 'Leaflet.Spin', 
  version = '1.1.2',
  src = c(href = 'https://cdnjs.cloudflare.com/ajax/libs/Leaflet.Spin/1.1.2'),
  script = 'leaflet.spin.min.js'
)

#' on_render_spin
#' 
#' Helper JS function to (de)activate the spin plugin in leaflet maps during a proxy in shiny apps
#'
#' @param mp a leaflet object
#' @param x  additional functionality to be executed after having stopped the spin plugin
#'
#' @return none 
#' 
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#' 
#' @importFrom htmlwidgets onRender
#'
#' @export
#' 
on_render_spin <- function(mp, x = ''){
    mp |> onRender(paste0('
            function(el, x) {
                var mymap = this;
                mymap.on("layerremove", function(e) {
                    if (e.layer.options.layerId == "spinnerMarker") { mymap.spin(true); }
                });
                mymap.on("layeradd", function(e) {
                    if (e.layer.options.layerId == "spinnerMarker") {
                        mymap.spin(false);', 
            x, '
                    }
                });
            }
    '))
}


#' end_spinmap 
#' 
#' end the *spin plugin* in a `leaflet` map embedded in `Shiny` apps
#'
#' @param mp a leaflet object
#' @param y  the reference centroid (longitude and latitude, in this order)
#'
#' @return a leaflet object
#' 
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#' 
#' @importFrom leaflet addCircles
#'
#' @export
#' 
end_spinmap <- function(mp, y = centers.uk$EW) mp |> addCircles( lng = y[1], lat = y[2], radius = 0, opacity = 0, layerId = 'spinnerMarker')
