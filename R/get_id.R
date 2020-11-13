################################################################################
#
#'
#' Get Google Drive IDs for latest or archive DoH Data Drop folders
#'
#' The Philippines Department of Health currently distributes the latest data
#' drop via a fixed shortened URL ([bit.ly/DataDropPH](bit.ly/DataDropPH))
#' which links/points to a new Google Drive endpoint daily or whenever the
#' daily updated data drop is available. This Google Drive endpoint is a
#' **README** document in portable document format (PDF) which contains a
#' privacy and confidentiality statement, technical notes with regard to the
#' latest data, technical notes with regard to previous (archive data) and two
#' shortened URLs - one linking to the Google Drive folder that contains all
#' the latest officially released datasets, and the other linking to the
#' datasets released previously (archives). Of these, the first shortend URL
#' linking to the Google Drive folder containing the latest officially relased
#' datasets is different for everyday and can only be obtained through the
#' **README** document released for a specific day.
#'
#' The function [datadrop_latest_id()] reads that PDF file, extracts the
#' shortened URL for the latest official released datasets written in that file,
#' expands that shortened URL and then extracts the unique Google Drive ID for
#' the latest officially released datasets. With this Google Drive ID, other
#' functions can then be used to retrieve information and data from the Google
#' Drive specified by this ID.
#'
#' The DoH Data Drop archives, on the other hand, is distributed via a fixed
#' shortened URL ([bit.ly/DataDropArchives](https://bit.ly/DataDropArchives))
#' which links/points to a Google Drive folder containing the previous Data Drop
#' releases.
#'
#' The function [datadrop_archive_id()] expands that shortened URL and then
#' extracts the unique Google Drive ID for the DoH Data Drop archives folder.
#' With this Google Drive ID, other functions can then be used to retrieve
#' information and data from the Google Drive specified by this ID.
#'
#' @param verbose Logical. Should message on operation progress be shown.
#'   Default is TRUE.
#' @param version A character value specifying whether to get the latest
#'   available DoH Data Drop (`latest`) or to get DoH Data Drop archive
#'   (`archive`). Default to `latest`.
#' @param .date A character value for date in *YYYY-MM-DD* format. This is the
#'   date for the archive DoH Data Drop for which an ID is to be returned.
#'   Should be specified when using [datadrop_archive_id()]. For [datadrop_id()],
#'   only used when `version` is set to `archive` otherwise ignored.
#'
#' @return A 33-character string for the Google Drive ID of the latest
#'   DoH Data Drop or the archive DoH Data Drop
#'
#' @author Ernest Guevarra
#'
#' @examples
#' datadrop_latest_id()
#' datadrop_archive_id(.date = "2020-11-01")
#' datadrop_id()
#' datadrop_id(version = "archive", .date = "2020-11-01")
#'
#' @rdname datadrop_id
#' @export
#'
#
################################################################################

datadrop_latest_id <- function(verbose = TRUE) {
  ## Get current data link folder information and contents
  dropCurrent <- googledrive::drive_ls(
    path = googledrive::drive_get(id = "1ZPPcVU4M7T-dtRyUceb0pMAd8ickYf8o")
  )

  ## Get dropDate
  dropDate <- stringr::str_extract(string = dropCurrent$name,
                                   pattern = "[0-9]{2}[/\\_\\-]{1}[0-9]{2}") %>%
    paste(format(Sys.Date(), "%Y"), sep = "/") %>%
    lubridate::mdy()

  if(verbose) {
    ## Provide message to user
    message(
      paste(
        strwrap(
          x = paste("Getting the Google Drive ID for the latest available DoH
                     Data Drop for ",
                    dropDate, ".",
                    sep = ""),
          width = 80,
        ),
        collapse = "\n"
      )
    )
  }

  ## Create temporary file
  destFile <- tempfile()

  ## Create link for download of README
  link <- sprintf(fmt = "https://docs.google.com/uc?id=%s", dropCurrent$id)

  googledrive::drive_download(file = googledrive::as_id(link),
                              path = destFile, verbose = FALSE)

  ## Extract information from PDF on link to folder of current data
  readme <- pdftools::pdf_text(pdf = destFile) %>%
    stringr::str_split(pattern = "\n|\r\n") %>%
    unlist()

  ## Ged id for current data google drive folder
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

  ## return x
  return(x)
}


################################################################################
#
#'
#' @rdname datadrop_id
#' @export
#'
#
################################################################################

datadrop_archive_id <- function(verbose = TRUE,
                                .date = NULL) {
  ## Deauthorise
  googledrive::drive_deauth()

  ## Check if .date is not NULL
  if(is.null(.date)) {
    stop(
      paste(
        strwrap(
          x = "Date needs to be specified if version is set to archive. Please try again.",
          width = 80
        ),
        collapse = "\n"
      ),
      call. = TRUE
    )
  }

  ## Check if .date is current date
  if(lubridate::ymd(.date) == Sys.Date()) {
    stop(
      paste(
        strwrap(
          x = "Date should be earlier than current date to access data archive. Please try again.",
          width = 80
        ),
        collapse = "\n"
      ),
      call. = TRUE
    )
  }

  ## Check whether date is within range
  if(!lubridate::ymd(.date) %within% lubridate::interval(lubridate::ymd("2020-04-14"), Sys.Date())) {
    stop(
      paste(
        strwrap(
          x = "Earliest COVID-19 Data Drop record is for 2020-04-14. Only provide
                 dates as early as 2020-04-14 or later. Please try again.",
          width = 80
        ),
        collapse = "\n"
      ),
      call. = TRUE
    )
  }

  ## Provide message to user if verbose
  if(verbose) {
    message(
      paste(
        strwrap(
          x = paste("Getting the Google Drive ID for the DoH Data Drop archive for ",
                    .date, sep = ""),
          width = 80,
        ),
        collapse = "\n"
      )
    )
  }

  ## Get ID
  x <- "bit.ly/DataDropArchives" %>%
    RCurl::getURL() %>%
    stringr::str_extract_all(pattern = "[A-Za-z0-9@%#&()+*$,._\\-]{33}") %>%
    unlist()

  y <- googledrive::drive_get(id = x) %>%
    googledrive::drive_ls() %>%
    dplyr::filter(name == "COVID-19 DATA") %>%
    dplyr::select(id) %>%
    as.character()

  ## Get dropDate
  #dropDate <- .date

  ## List contents of Data Drop Archive Google Drive Folder
  dropArchive <- googledrive::drive_get(id = y) %>%
    googledrive::drive_ls()

  ## Get gdriveID based on date
  dropArchiveDate <- dropArchive$name %>%
    lubridate::parse_date_time(orders = "my")

  dropArchiveDate <- paste(lubridate::month(dropArchiveDate),
                           lubridate::year(dropArchiveDate), sep = "/")

  ## Create specified date marker for .date
  month_year <- .date %>%
    lubridate::ymd() %>%
    lubridate::month() %>%
    paste(lubridate::year(lubridate::ymd(.date)), sep = "/")

  ## Process date
  collapsedDate <- stringr::str_remove_all(string = .date, pattern = "-")

  ## Check if archive contains folder for data for the specified month/year
  if(month_year %in% dropArchiveDate) {
    ## Get drive ID for folder of month_year
    month_year_id <- dropArchive$id[dropArchiveDate == month_year]

    ## Get month_year contents
    month_year_contents <- googledrive::drive_get(id = month_year_id) %>%
      googledrive::drive_ls()

    ## Check if collapsedDate is in month_year_contents
    if(any(stringr::str_detect(string = month_year_contents$name,
                               pattern = collapsedDate))) {
      archiveID <- month_year_contents %>%
        dplyr::filter(stringr::str_detect(string = name,
                                          pattern = collapsedDate)) %>%
        dplyr::select(id) %>%
        as.character()
    } else {
      warning(
        paste(
          strwrap(
            x = paste("Data Drop archives do not contain a folder for the day of ",
                      .date, ". Returning NULL.", sep = ""),
            width = 80
          ),
          collapse = "\n"
        ),
        call. = FALSE
      )

      ## Set archiveID to NULL
      archiveID <- NULL
    }
  } else {
    warning(
      paste(
        strwrap(
          x = paste("Data Drop archives do not contain a folder for the day of ",
                    .date, ". Returning NULL.", sep = ""),
          width = 80
        ),
        collapse = "\n"
      ),
      call. = FALSE
    )

    ## Set archiveID to NULL
    archiveID <- NULL
  }

  ## return archiveID
  return(archiveID)
}


################################################################################
#
#'
#' @rdname datadrop_id
#' @export
#'
#
################################################################################

datadrop_id <- function(verbose = TRUE,
                        version = c("latest", "archive"),
                        .date = NULL) {
  ## Get version
  version <- match.arg(arg = version)

  ## Get id
  if(version == "latest") {
    id <- datadrop_latest_id(verbose = verbose)
  } else {
    id <- datadrop_archive_id(verbose = verbose)
  }

  ## return id
  return(id)
}

