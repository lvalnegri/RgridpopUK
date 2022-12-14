#' fb_pop.lst
#' 
#' Lista dei segmenti di popolazione presenti nei microdati Facebook
#'
#' @export
#' 
fb_pop.lst <- c(
    'Total' = 'general', 
    'Men' = 'men', 
    'Female' = 'women', 
    'Youth (15-24yo)' = 'youth_15_24',
    'Elderly (60yo plus)' = 'elderly_60_plus', 
    'Women of Reproductive Age (15-49yo)' = 'women_of_reproductive_age_15_49', 
    'Children (0-4yo)' = 'children_under_five'
)

#' msoa.lst
#' 
#' List of Medium Super Output Areas (MSOA)
#'
#' @export
#' 
msoa.lst <- Rshiny::create_lst('MSOA', FALSE) # false means the list is not structured 

#' centroids
#' 
#' List of centroids
#'
#' @export
#' 
centroids <- data.table(
    acro = c('', 'w', 'p'),
    description = c('Geometric', 'Weighted', 'Visual'),
    icon = c('hexagon', 'scale-balanced', 'atom'), 
    colour = c('#FFFFFF', '#FFFFFF', '#000000'),         # icon colour
    fColour = c('cadetblue', 'darkpurple', 'red')        # marker colour
)

