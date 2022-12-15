#' Download zip files
#'
#' Download and unzip HDX/Meta High Resolution Population Density Files
#' 
#' @param x the folder where the unzipped csv files will be saved
#'
#' @return none
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @references For further details, see the 
#'             [HDX dedicated webpage](https://data.humdata.org/dataset/united-kingdom-high-resolution-population-density-maps-demographic-estimates) 
#' 
#' @export
#'
down_zip <- \(x){
    tmpf <- tempfile()
    for(idx in 1:length(sfx_urls)){
        fn <- hdx_urls$sfx[idx]
        message('\nProcessing ', toupper(names(fn)))
        message(' - download...')
        download.file(file.path(hdx_urls$pfx, fn), tmpf, quiet = TRUE)
        message(' - unzip...')
        unzip(tmpf, exdir = x)
        file.rename(file.path(x, unzip(tmpf, list = TRUE)$Name), file.path(x, paste0(names(fn), '.csv')))
    }
    unlink(tmpf)
}
