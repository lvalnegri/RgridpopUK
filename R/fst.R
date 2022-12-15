#' Write a dataset in fst format with an index over one of its columns
#'
#' @param dts      The dataset to be saved. If `NA`, both `dname` and `tname` must be provided. 
#' @param fname    The name of the file in output or the table to be read if `dname` is not `NA`
#' @param cname    The name of the column on which to order the dataset and create the index
#' @param out_path The folder where to save the file.
#'
#' @return None
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @import data.table
#' @importFrom fst write_fst
#'
#' @export
#'
write_fst_idx <- function(dts, fname, cname, out_path){
    setorderv(dts, cname)
    yx <- dts[, .N, get(cname)]
    setnames(yx, c(cname, 'N'))
    yx[, n2 := cumsum(N)][, n1 := shift(n2, 1L, type = 'lag') + 1][is.na(n1), n1 := 1]
    setcolorder(yx, c(cname, 'N', 'n1', 'n2'))
    write_fst(yx, file.path(out_path, paste0(fname, '.idx')))
    write_fst(dts, file.path(out_path, fname))
}

#' Read a (partial) dataset from an fst indexed file based on a single value pertaining to one column
#'
#' @param fname the name of the `fst` file complete with its path
#' @param ref the value pertaining to the column that makes up the index
#' @param cols the columns to be returned (the `NULL` default means to return all columns)
#'
#' @return A data.table
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @import data.table
#' @importFrom fst read_fst
#'
#' @export
#'
read_fst_idx <- function(fname, ref, cols = NULL){
    yx <- read_fst(paste0(fname, '.idx'), as.data.table = TRUE)
    y <- yx[get(names(yx)[1]) == ref[1], .(n1 = min(n1), n2 = max(n2))]
    read_fst(fname, from = y$n1, to = y$n2, columns = cols, as.data.table = TRUE)
}
