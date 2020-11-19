################################################################################
#
#'
#' List files and folders within a specified DoH Data Drop Google Drive folder
#'
#' @param id A 33 character string for the *Google Drive* ID of the latest
#'   officially released **DoH Data Drop**. This can be obtained using the
#'   [datadrop_id_latest()] function or by manually expanding the shortened URL
#'   provided in [bit.ly/DataDropPH](https://bit.ly/DataDropPH) and extracting the
#'   *Google Drive* ID.
#'
#' @return A tibble containing information on the various files and folders in
#'   the specified *Google Drive* for **DoH Data Drop**.
#'
#' @author Ernest Guevarra
#'
#' @examples
#' ## Get Google Drive ID of latest DoH Data Drop
#' id <- datadrop_id_latest()
#'
#' ## List the contents of the latest DoH Data Drop in Google Drive
#' datadrop_ls(id = id)
#'
#' @export
#'
#
################################################################################

datadrop_ls <- function(id) {
  ## Google Drive deauthorisation
  googledrive::drive_deauth()

  ## Get Google Drive directory structure and information
  y <- googledrive::drive_ls(googledrive::drive_get(id = id))

  ## Return info
  return(y)
}


################################################################################
#
#'
#' Download DoH Data Drop file via its Google Drive ID
#'
#' @param id A 33-character string identifier for the *Google Drive* file.
#' @param path A character value for path for output file. If NULL, the
#'   default file name used in *Google Drive* is used and the default location is
#'   the working directory.
#' @param overwrite Logical. If `path` already exists, should it be overwritten?
#'   Default to FALSE.
#' @param verbose Logical. Should operation progress messages be shown? Default
#'   to TRUE.
#'
#' @return A file downloaded into specified path
#'
#' @author Ernest Guevarra
#'
#' @examples
#' ## Get Google Drive ID for Case Information file in latest DoH Data Drop
#' id <- datadrop_id_file(tbl = datadrop_ls(id = datadrop_id()),
#'                        fn = "Metadata - Sheets.csv")
#'
#' ## Download the Case Information file into tempfile()
#' datadrop_download(id = id, path = tempfile())
#'
#' @export
#'
#
################################################################################

datadrop_download <- function(id,
                              path = NULL,
                              overwrite = FALSE,
                              verbose = TRUE) {
  ## Download Fields.csv to temp directory
  googledrive::drive_download(file = googledrive::as_id(id),
                              path = path,
                              overwrite = overwrite,
                              verbose = verbose)
}


##
## Get the bitly link from DoH Data Drop Read Me First PDF
##
get_id <- function(.pdf) {
  ## Extract information from PDF on link to folder of current data
  readme <- pdftools::pdf_text(pdf = .pdf) %>%
    stringr::str_split(pattern = "\n|\r\n") %>%
    unlist()

  ## Get id for current data drop google drive folder
  x <- stringr::word(readme[stringr::str_detect(string = readme,
                                                pattern = "bit.ly/*")][1], -1)

  if(!stringr::str_detect(string = x, pattern = "http")) {
    x <- paste("http://", x, sep = "")
  }

  x <- x %>%
    stringr::str_replace(pattern = "https", replacement = "http") %>%
    RCurl::getURL() %>%
    stringr::str_extract_all(pattern = "[A-Za-z0-9@%#&()+*$,._\\-]{33}") %>%
    unlist()

  ## remove .pdf
  file.remove(.pdf)

  ## Return x
  return(x)
}

##
## Get file extension
##
get_ext <- function(tbl, fn) {
  ## Check if fn is found in tbl$name
  if(any(stringr::str_detect(string = tbl[["name"]], pattern = fn))) {
    ##
    ext <- tbl %>%
      filter(stringr::str_detect(string = name, pattern = fn)) %>%
      select(name) %>%
      as.character() %>%
      str_extract(pattern = ".csv|.xlsx")
  } else {
    ## Set id to NULL
    ext <- NULL
    warning(
      paste(
        strwrap(
          x = paste("File/s with the word/s ", fn, " was not found in the Data
                    Drop folder. Please revise as needed and try again. Returning
                    NULL.", sep = ""),
          width = 80
        ),
        collapse = "\n"
      )
    )
  }

  ##
  return(ext)
}



##
## x <- datadrop_id() %>% datadrop_ls()
##
get_drop_date <- function(tbl, .year = format(Sys.Date(), "%Y")) {
  dropDate <- tbl %>%
    dplyr::filter(stringr::str_detect(string = name, pattern = "READ ME")) %>%
    dplyr::select(name) %>%
    stringr::str_extract(pattern = "[0-9]{2}[/\\_\\-]{1}[0-9]{2}") %>%
    paste(.year, sep = "/") %>%
    lubridate::mdy()

  return(dropDate)
}


