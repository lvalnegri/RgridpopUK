#' hdx_urls
#' 
#' List of prefix and suffix urls to compose each dataset url
#'
#' @noRd
hdx_urls <- list(
    'pfx' = 'https://data.humdata.org/dataset/b9a7b4a3-75a7-4de1-b741-27d78e8d0564/resource/',
    'sfx' = c(
            'total' = '674a0049-1a75-4f9a-a07b-654bda75456e/download/population_gbr_2019-07-01.csv.zip',
            'males' = 'e59e0fc5-37fc-4278-a7f3-e6d2de5a8166/download/gbr_men_2019-08-03_csv.zip',
            'females' = 'b8b43628-7a86-4ffc-80b7-f44fb135a93d/download/gbr_women_2019-08-03_csv.zip',
            'elderly' = '5ee85e33-60d5-4f44-bde6-c976a3311c0b/download/gbr_elderly_60_plus_2019-08-03_csv.zip',
            'youth' = '9411da18-a7e9-4237-ba37-80839af9fbfc/download/gbr_youth_15_24_2019-08-03_csv.zip',
            'children' = 'ad7bb2fa-8ab7-4e01-9cc5-3fc91afbbc51/download/gbr_children_under_five_2019-08-03_csv.zip',
            'women' = '6a952916-115a-4385-9c77-de9d343b1635/download/gbr_women_of_reproductive_age_15_49_2019-08-03_csv.zip'
    )
)

#' spop.lst
#' 
#' List of the various population segments available in the datasets
#'
#' @export
#' 
spop.lst <- c(
    'Total' = 'total', 
    'Men' = 'men', 
    'Female' = 'women', 
    'Youth (15-24yo)' = 'youth_15_24',
    'Elderly (60yo plus)' = 'elderly_60_plus', 
    'Women of Reproductive Age (15-49yo)' = 'women_of_reproductive_age_15_49', 
    'Children (0-4yo)' = 'children_under_five'
)


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

