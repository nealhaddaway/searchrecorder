suppressPackageStartupMessages({
  library(shiny)
  library(jsonlite)
  library(readr)
  library(synthesisr)
})

source('embed_history.R')
source('extract_history.R')
source('load_ris.R')
source('load_searchrecord.R')

# error supression CSS
#options(shiny.sanitize.errors = TRUE)
#tags$style(type="text/css",
#           ".shiny-output-error { visibility: hidden; }",
#           ".shiny-output-error:before { visibility: hidden; }"
#)

# Define UI for application that draws a histogram
ui <- navbarPage("searchrecorder", id = "tabs",
                 
                 # Sidebar with a slider input for number of bins 
                 tabPanel("Home",
                          fluidRow(
                            column(10,
                                   h3('searchrecorder'),
                                   br(),
                                   'This app demonstrates the functionality of the searchrecorder R package - a tool for embedding search history information within an RIS reference file.',
                                   br(),br(),
                                   'Click on the "Search history" tab to see what a comprehensive, standardised search history file can look like.',
                                   br(),br(),
                                   'Click on the "RIS data" tab to see how the power of an RIS file can be harnessed to hold even more rich data about how the file was generated.',
                                   br(),br(),
                                   'Click on the "Embedded search data" tab to see what a modified RIS file looks like.',
                                   br(),br(),
                                   'Click on the "Try it yourself" tab to upload your own RIS and search history files to examine and download the modified output!',
                                   br(),
                                   hr(),
                                   'This app uses a standardised search history data structure developed in consultation with a group of information specialists and librarians. Read more about how the data structure was developed ', tags$a(href="https://docs.google.com/document/d/1ve-K5EAwxJo0vosKVLiDtoHAsU9SZ387A990Mek80DA/edit?usp=sharing", 'here.'), 
                                   hr()),
                            column(2,
                                   br(),tags$img(height = 200, src = "https://github.com/nealhaddaway/searchrecorder/blob/master/inst/extdata/hex.png?raw=true")),
                            column(12,
                                   'If you\'d like to cite this work, please use:',
                                   br(),
                                   'Haddaway, N. R. (2022) searchrecorder: A tool for transparent reporting of search histories within reference files. doi:', tags$a(href="https://www.doi.org/10.5281/zenodo.5920473", "10.5281/zenodo.5920473"),
                                   br(),
                                   icon("save"),tags$a(href="citation.ris", "Download package citation (.ris)", download=NA, target="_blank"),
                                   br(),br(),
                                   icon("github"),tags$a(href="https://github.com/nealhaddaway/searchrecorder", "See the GitHub repository")
                            )
                          )
                 ),
                 tabPanel("Search history",
                          fluidRow(
                            column(12,
                                   'The following data constitute an example of the minimum information required to repeat or evaluate a search on a bibliographic database:',
                                   br(),br(),
                                   tags$head(tags$style(HTML("pre { white-space: pre-wrap; word-break: keep-all; }"))),
                                   verbatimTextOutput('JSON')
                            )
                          )
                 ),
                 tabPanel("RIS data",
                          fluidRow(
                            column(12,
                                   'The following shows the content of an RIS file. As you can see, it is a plain text file where each record consists of a set of fields, each denoted by a two-letter code, and each on a new line. Each record begins with the field "TY", meaning "type", and each record ends with the empty field "ER" (end reference).',
                                   br(),br(),
                                   tags$head(tags$style(HTML("pre { white-space: pre-wrap; word-break: keep-all; }"))),
                                   verbatimTextOutput('RIS')
                            )
                          )
                 ),
                 tabPanel("Embedded search data",
                          fluidRow(
                            column(12,
                                   'RIS files have a suite of mostly unused fields that can be "hijacked" to embed information within the RIS file. The file still functions perfectly normally in reference management software, but it carries the rich search history data as well.',
                                   br(),br(),
                                   'All we have to do is to splice the raw JSON file (a string of text and special characters) inside a custom field in the first record of our RIS file. We use "search_history_start" and "search_history_end" to easily find where the search history is:',
                                   br(),br(),
                                   tags$head(tags$style(HTML("pre { white-space: pre-wrap; word-break: keep-all; }"))),
                                   verbatimTextOutput('mod_RIS')
                            )
                          )
                 ),
                 tabPanel("Try it yourself",
                          fluidRow(
                            column(12,
                                   'Try combining your own RIS files with a search history record.',
                                   br(),br(),
                                   'Download and edit this example JSON search history file. You can use any text editor, but be careful not to modify the formatting or special characters.',
                                   br(),br(),
                                   downloadButton('www/search_record.JSON', 'Download the example JSON file'),
                                   hr(),
                                   fileInput("upload_ris", "Upload your RIS file",
                                             multiple = FALSE,
                                             accept = c("text/csv",
                                                        "text/comma-separated-values,text/plain",
                                                        ".ris",
                                                        ".RIS")),
                                   fileInput("upload_json", "Upload your JSON file",
                                             multiple = FALSE,
                                             accept = c("text/csv",
                                                        "text/comma-separated-values,text/plain",
                                                        ".json",
                                                        ".JSON")),
                                   hr(),
                                   'Here is a preview of the contents of your files:'
                                   ),
                            column(6,
                                   h3('RIS file'),br(),verbatimTextOutput('RIS_upload'),
                                   tags$head(tags$style("#RIS_upload{overflow-y:scroll; max-height: 500px;}"))
                                   ),
                            column(6,
                                   h3('Search record'),br(),verbatimTextOutput('JSON_upload'),
                                   tags$head(tags$style("#JSON_upload{overflow-y:scroll; max-height: 500px;}"))
                                   ),
                            column(12,
                                   hr(),
                                   'Click the button below to produce a modified version of your RIS file containing the search history information embedded in the first record. Scroll through the display to see the output.',
                                   br(),br(),
                                   actionButton("convert", "Modify RIS file"),
                                   br(),br(),
                                   verbatimTextOutput('modified_RIS'),
                                   tags$head(tags$style("#modified_RIS{overflow-y:scroll; max-height: 500px;}")),
                                   br(),
                                   hr(),
                                   'Download the modified RIS file and open it in your preferred reference management software to see that the RIS file is still functional.',
                                   br(),br(),
                                   downloadButton('download_RIS', 'Download modified RIS file')
                                   )
                          )
                 )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  output$JSON<-renderPrint({
    jsonlite::fromJSON('www/search_record.JSON')
  })
  
  output$RIS<-renderText({
    lines <- load_ris('www/references.ris', output = "lines", verbose = FALSE)$lines
    head_lines <- lines[1:42]
    paste0(head_lines, collapse = '\n')
  })
  
  output$mod_RIS<-renderText({
    lines <- load_ris('www/ris_output.ris', output = "string", verbose = FALSE)$string
    #head_lines <- lines[1:42]
    #paste0(head_lines, collapse = '\n')
  })
  
  rv <- reactiveValues()
  
  observeEvent(input$upload_ris,{
    lines <- load_ris(input$upload_ris$datapath, output = "lines", verbose = FALSE)$lines
    head_lines <- lines[1:25]
    rv$upload_ris <- paste0(head_lines, collapse = '\n')
    rv$lines <- lines
  })
  
  observeEvent(input$upload_json,{
    if(is.null(input$upload_json)) return(NULL)
    rv$json <- jsonlite::fromJSON(input$upload_json$datapath)
    rv$json_raw <- load_searchrecord(input$upload_json$datapath, output = "string")
  })
  
  output$RIS_upload<-renderText({
    rv$upload_ris
  })
  
  output$JSON_upload<-renderPrint({
    rv$json
  })
  
  observeEvent(input$convert,{
    # extract the lines up to and including the first line of the first record
    start <- rv$lines[1:grep('TY  -', rv$lines)[1]]
    # extract everything else
    rest <- rv$lines[(grep('TY  -', rv$lines)[1]+1):length(rv$lines)]
    # slot the search history in between and recombine with the history as a 'C1' RIS field
    ris_output <- c(start, 
                    paste0('C1  - search_history_start', rv$json_raw, 'search_history_end'), 
                    rest)
    # compress all lines into a single RIS string
    ris_output <- paste0(ris_output, collapse='\n')
    
    rv$ris_output <- ris_output
  })
  
  output$modified_RIS<-renderText({
    rv$ris_output
  })
  
  output$download_RIS <- downloadHandler(
    filename = "modified_ris.ris",
    content = function(file){
      write(rv$ris_output, file = file)
    }
  )

}

# Run the application 
shinyApp(ui = ui, server = server)

