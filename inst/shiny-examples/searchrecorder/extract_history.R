#' Extract search history from modified RIS file
#' 
#' @description Read a modified RIS file containing a set of search 
#' results along with an embedded search history into R and extract 
#' the search history as a JSON formatted object. 
#' @param ris_file The input RIS file containing the search history 
#' to be read into R.
#' @param save_JSON Logical argument specifying whether to save the 
#' JSON search history file to the working directory. The default is 
#' set to FALSE.
#' @importFrom jsonlite fromJSON
#' @return A formatted text string as a JSON object containing the 
#' search history
#' @examples 
#' \dontrun{
#' search_history <- extract_history(ris_file = 'inst/extdata/ris_output.ris', save_JSON = TRUE)
#' }
extract_history <- function(ris_file = NULL,
                            save_JSON = FALSE){
  
  if(is.null(ris_file) == TRUE){
    ris_file <- file.choose()
  }
  
  #load in RIS file as string
  refs <- load_ris(ris_file, output = c("string"), verbose = FALSE)$string
  
  # extract search history text between tags
  search_record <- (regmatches(refs, regexec("search_history_start(.*?)search_history_end", refs)))[[1]][2]
  
  # ensure escape character '\' is retained whilst other non-useful '\' are removed
  search_record <- gsub("\\\\\\\\", "nnnn", search_record)
  search_record <- gsub("\\\\", "", search_record)
  search_record <- gsub("nnnn", "\\\\", search_record)
  
  if(save_JSON == TRUE) {
    write(search_record, file = "search_record_output.JSON")
    cat('JSON file saved to your working directory: "search_record_output.JSON"')
  }
  
  # convert to JSON object
  search_record <- jsonlite::fromJSON(search_record)
  
  return(search_record)
  
}



