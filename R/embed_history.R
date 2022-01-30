#' Combine RIS search results with search record
#' 
#' @description Read an RIS file containing a set of search results 
#' into R and combine with a JSON search history file, embedding the 
#' search history into a custom field within the first record in the 
#' RIS file. The output is then exported as a modified RIS file.
#' @param ris_input The input RIS file to be read into R.
#' @param search_record The search record saved as a JSON file in 
#' the standardised search data format.
#' @return An RIS file containing the search record embedded in the 
#' custom field of the first record in the file.
#' @examples 
#' \dontrun{
#' embed_history(ris_input = 'references.ris', search_record = 'search_record.JSON')
#' }
embed_history <- function(ris_input,
                          search_record){
  
  # import RIS file as lines
  ref_lines <- load_ris(ris_input, output = c("lines"), verbose = FALSE)$lines
  
  #import search history as a string
  search_history <- load_searchrecord(search_record, output = "string")
  
  # extract the lines up to and including the first line of the first record
  start <- ref_lines[1:grep('TY  -', ref_lines)[1]]
  # extract everything else
  rest <- ref_lines[(grep('TY  -', ref_lines)[1]+1):length(ref_lines)]
  # slot the search history in between and recombine with the history as a 'C1' RIS field
  ris_output <- c(start, 
                  paste0('\nC1  - search_history_start', search_history, 'search_history_end\n'), 
                  rest)
  # compress all lines into a single RIS string
  ris_output <- paste0(ris_output, collapse='\n')
  
  # write as an RIS file
  write.table(ris_output, file = "ris_output.ris", sep = "")
  cat('Your modified RIS file ("ris_output.ris") has been saved to your working directory')
  
}
