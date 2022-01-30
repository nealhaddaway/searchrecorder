#' Read search record into R
#' 
#' @description Read a search record file as a JSON object. See 
#' xxx for details of how to format the JSON file.
#' @param search_record The input search record saved as a JSON 
#' file.
#' @param output Specification of what output format should be 
#' provided: a "list" of items from the search record, a "string" 
#' containing the JSON formatted text (for embedding into an RIS 
#' file), or "both". The default is set to "both".
#' @importFrom jsonlite fromJSON
#' @importFrom readr read_file
#' @return A formatted text string as a JSON object containing 
#' the search history
#' @examples 
#' \dontrun{
#' search_history <- load_searchrecord(output = "both")
#' }
load_searchrecord <- function(search_record = NULL,
                              output = "both") {
  
  # if search_record is not specified then use file chooser
  if(is.null(search_record) == TRUE){
    search_record <- file.choose()
  }
  
  # set up output list
  objects <- list()
  
  if(output == 'list') {
    output_list <- list(jsonlite::fromJSON(search_record))
    objects <- c(objects, list = output_list)
  }
  if(output == 'string') {
    output_string <- readr::read_file(search_record)
    objects <- c(objects, string = output_string)
  }
  if(output == 'both') {
    output_list <- list(jsonlite::fromJSON(search_record))
    output_string <- readr::read_file(search_record)
    objects <- c(objects, list = output_list, string = output_string)
  }
  
  return(objects)
  
}
