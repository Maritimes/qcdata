#' @title qc_findorphans
#' @description This function creates orph_* tables with records that don't
#' appear to be linked to the other tables (within bio.datawrangling)
#' @param db default is \code{NULL}. This identifies the dataset you are working
#' with.
#' @importFrom bio.datawrangling get_data
#' @importFrom bio.datawrangling self_filter
#' @importFrom bio.datawrangling load_datasources
#' @family bio.datawrangling
#' @author  Mike McMahon, \email{Mike.McMahon@@dfo-mpo.gc.ca}
#' @export
qc_findorphans<-function(db = NULL){
  if (!exists('ds_all', envir = .GlobalEnv)) assign("ds_all", load_datasources(), envir = .GlobalEnv)
  if (is.null(db)) stop("Please supply a value for db")

  prefix = toupper(db)
  name_prefix = "zzz_orph_"
  get_data(db)
  self_filter(db, looponce=TRUE)
  cat("
Orphans within code tables are generally expected.
This will take a moment...\n")
  get_orphans <- function(this){
    x <- rbind(get(this, envir = orig), get(this, envir = .GlobalEnv))
    x = x[! duplicated(x, fromLast=TRUE) & seq(nrow(x)) <= nrow(get(this, envir = orig)), ]
    assign(paste0(name_prefix,this), x, envir = .GlobalEnv)
    cat(paste0("Created ",name_prefix,this," ...\n"))
  }

  these.tables.prefixed = paste0(prefix,".",ds_all[[db]]$tables)
  orig = new.env()
  data(list = these.tables.prefixed, envir =  orig)
  sapply(ds_all[[db]]$tables, get_orphans)
}
