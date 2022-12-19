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
#' @return a character vector
#'
#' @export
#' 
spop.lst <- c(
    'Population' = 'total', 
    'Men' = 'men', 
    'Female' = 'women', 
    'Children (0-4yo)' = 'children_under_five',
    'Youth (15-24yo)' = 'youth_15_24',
    'Elderly (60yo plus)' = 'elderly_60_plus', 
    'Women of Reproductive Age (15-49yo)' = 'women_of_reproductive_age_15_49'
)


#' centroids
#' 
#' List of properties associated with the various centroids included in the `MSOA` data.table and used in the shiny app:
#' - `g` geometric
#' - `w` weighted according to ONS
#' - `d` weighted dynamically based on grid
#' - `p` *pole of inaccessibility* or *visual centre*
#'
#' @return a data.table
#'
#' @export
#' 
centroids <- data.table(
    code = c('g', 'o', 'w', 'p'),
    description = c('Geometric', 'ONS Weighted', 'Weighted', 'Visual'),
    icon = c('hexagon', 'scale-balanced', 'atom', 'atom'), 
    colour = c('#FFFFFF', '#FFFFFF', '#FFFFFF', '#000000'),         # icon colour
    fColour = c('cadetblue', 'darkpurple', 'darksalmon', 'red')     # marker colour
)

#' credits
#' 
#' List of attributions in HTML format
#'
#' @export
#' 
credits <- '
    <ul>
        <li>
            Facebook Connectivity Lab and Center for International Earth Science Information Network - CIESIN - Columbia University. 2016. \n
            High Resolution Settlement Layer (HRSL). Source imagery for HRSL \u00A9 2016 DigitalGlobe. \n
            <a href="https://data.humdata.org/dataset/united-kingdom-high-resolution-population-density-maps-demographic-estimates">Data accessed 15 Dec 2022</a>.
        </li>
        <li> Contains OS data \u00A9 Crown copyright and database rights 2023. </li>
        <li>
            Source: Office for National Statistics licensed under the 
            [Open Government Licence v.3.0](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/)
        </li>
        <li>
            Contains Parliamentary information licensed under the 
            <a href="https://www.parliament.uk/site-information/copyright/open-parliament-licence/">Open Parliament Licence v3.0</a>.
        </li>
    </ul>
'
