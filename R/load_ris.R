#' Read references into R in multiple object formats
#' 
#' @description Read an RIS file into R to produce one or more of 
#' four different formats of R object: a reference list, a data 
#' frame, a text string, or a vector of lines. Multiple formats 
#' facilitate manipulation of the underlying RIS text.
#' @param ris_file The input RIS file to be read into R.
#' @param output The type of R object output specified as one or 
#' more of the following: "list", "dataframe", 
#' "string", "lines". Multiple output types should be listed as a 
#' vector (e.g. 'c("list", "string")').
#' @param verbose Logical argument for printing a report to the 
#' console. Default is set to TRUE
#' @importFrom synthesisr read_refs
#' @importfrom readr read_file
#' @return An R object containing the RIS file contents in one or 
#' more of three formats, as specified in 'output'
#' @examples 
#' \dontrun{
#' refs <- load_ris(output = c("list", "string", "dataframe", "lines"))
#' }
load_ris <- function(ris_file = NULL, 
                     output,
                     verbose = TRUE) {
  
  if(is.null(ris_file) == TRUE){
    ris_file <- file.choose()
  }
  
  # set up output list
  objects <- list()
    
  # if output is 'list'
  if(any(grepl('list', output)) == TRUE) {
    list <- TRUE
    list_refs <- list(synthesisr::read_refs(ris_file,return_df=FALSE))
    objects <- c(objects, list = list_refs)
    n_list <- length(list_refs[[1]])
  } else {
    n_list <- NULL
    list <- FALSE
  }
  
  # if output is 'dataframe'
  if(any(grepl('dataframe', output)) == TRUE) {
    dataframe <- TRUE
    dataframe_refs <- list(synthesisr::read_refs(ris_file,return_df=TRUE))
    objects <- c(objects, dataframe = dataframe_refs)
    n_dataframe <- nrow(dataframe_refs[[1]])
  } else {
    n_dataframe <- NULL
    dataframe <- FALSE
  }
  
  # if output is 'string'
  if(any(grepl('string', output)) == TRUE) {
    string <- TRUE
    string_refs <- list(readr::read_file(ris_file))
    objects <- c(objects, string = string_refs)
    n_string <- lengths(gregexpr('\nTY', (string_refs)))
  } else {
    n_string <- NULL
    string <- FALSE
  }
  
  # if output is 'lines'
  if(any(grepl('lines', output)) == TRUE) {
    lines <- TRUE
    lines_refs <- list(readLines(ris_file))
    objects <- c(objects, lines = lines_refs)
    n_lines <- length(grep('TY  -', unlist(lines_refs)))
  } else {
    n_lines <- NULL
    lines <- FALSE
  }
  
  # give single n value
  n <- unique(c(n_list, n_dataframe, n_string, n_lines))
  if(length(n) != 1){
    return('Your RIS file could not be read in correctly: inconsistent number of items between input methods\nPlease check the file and try again.')
  }
  
  # optional report
  if(verbose == TRUE) {
    report <- paste0('Your RIS file contains ',
                     n,
                     ' references and has been imported in the following format(s):\n',
                     if(list == TRUE){'list\n'},
                     if(dataframe == TRUE){'dataframe\n'},
                     if(string == TRUE){'string\n'},
                     if(lines == TRUE){'lines\n'}) 
    cat(report)
  }
  
  return(objects)
  
}
