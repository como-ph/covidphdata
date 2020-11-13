################################################################################
#
#' Get Philippines Department of Health COVID-19 Data Drop Google Drive specific
#' directory information
#'
#' A wrapper to `googledrive` package functions to extract information on
#' contents of a specific **COVID-19 Data Drop Google Drive** directory
#'
#' @param version A character value specifying whether to get the most
#'   currently available dataset (`"current"`) or to get archive data
#'   (`"archive"`). Default to `"current"`
#' @param .date A character value for date in *YYYY-MM-DD* format. This is the
#'   date up to which extracted data reports to. Only used when `version` is set to
#'   `"archive"` otherwise ignored.
#'
#' @return A tibble containing information on the various files in a specified
#'   **COVID-19 Data Drop Google Drive** directory
#'
#' @examples
#' datadrop_ls()
#'
#' @export
#'
#'
#
################################################################################

datadrop_ls <- function(version = "current", .date = NULL) {
  ## Google Drive deauthorisation
  googledrive::drive_deauth()

  if(version == "current") {
    ## Get current data link folder information and contents
    dropCurrent <- googledrive::drive_ls(
      path = googledrive::drive_get(id = "1ZPPcVU4M7T-dtRyUceb0pMAd8ickYf8o")
    )

    ## Get dropDate
    dropDate <- stringr::str_extract(string = dropCurrent$name,
                                     pattern = "[0-9]{2}/[0-9]{2}|[0-9]{2}\\_[0-9]{2}|[0-9]{2}\\-[0-9]{2}") %>%
      paste(format(Sys.Date(), "%Y"), sep = "/") %>%
      lubridate::mdy()

    ## Provide message to user
    message(
      paste(
        strwrap(
          x = paste("Getting information on Google Drive directory structure of the
                    DoH Data Drop for latest available data up to ",
                    dropDate, ".",
                  sep = ""),
          width = 80,
        ),
        collapse = "\n"
      )
    )

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

    ## Get google drive directory sturcture and information
    y <- googledrive::drive_ls(googledrive::drive_get(id = x))
  }

  if(version == "archive") {
    ## Get dropDate
    dropDate <- .date

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

    ## List contents of Data Drop Archive Google Drive Folder
    dropArchive <- googledrive::drive_ls(
      path = googledrive::drive_get(id = "1w_O-vweBFbqCgzgmCpux2F0HVB4P6ni2")
    )

    ## Get gdriveID based on date
    dropArchiveDate <- dropArchive$name %>%
      lubridate::parse_date_time(orders = "my")

    dropArchiveDate <- paste(lubridate::month(dropArchiveDate),
                             lubridate::year(dropArchiveDate), sep = "/")

    ## Create specified date marker for .date
    specifiedDate <- paste(lubridate::month(lubridate::ymd(.date)),
                           lubridate::year(lubridate::ymd(.date)), sep = "/")

    ## Check if archive contains data for the specified month/year
    if(specifiedDate %in% dropArchiveDate) {
      ## Get drive ID for folder of specified month
      gdriveID <- dropArchive$id[dropArchiveDate == specifiedDate]

      ## Get list of contents directory specified by gdriveID
      w <- googledrive::drive_ls(googledrive::drive_get(id = gdriveID))

      ## Process date
      collapsedDate <- stringr::str_remove_all(string = .date, pattern = "-")

      ## Check of specified .date has corresponding archive data
      if(any(stringr::str_detect(string = w$name, pattern = collapsedDate))) {
        ## Get the unique identifier for directory for specified date
        x <- w$id[stringr::str_detect(string = w$name, pattern = collapsedDate)]

        ## Get listing of contents of specified directory
        y <- googledrive::drive_ls(googledrive::drive_get(id = x))
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
        ## Assign y as NULL
        y <- NULL
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
      ## Assign y as NULL
      y <- NULL
    }
  }

  ## Return list of contents
  return(y)
}


################################################################################
#
#' Pull Philippines data fields information from the publicly available
#' Department of Health COVID-19 Data Drop
#'
#' A wrapper to googledrive functions to pull data from the Philppines'
#' COVID-19 Data Drop resource that is publicly distributed via
#' [Google Drive](https://drive.google.com)
#'
#' @param version A character value specifying whether to get the most
#'   currently available dataset (`"current"`) or to get archive data
#'   (`"archive"`). Default to `"current"`
#' @param .date A character value for date in *YYYY-MM-DD* format. This is the
#'   date up to which extracted data reports to. Only used when `version` is set to
#'   `"archive"` otherwise ignored.
#'
#' @return A tibble of metadata for the fields used in the various datasets
#'   distributed via the COVID-19 Data Drop
#'
#' @examples
#' datadrop_fields()
#'
#' @export
#'
#
################################################################################

datadrop_fields <- function(version = "current", .date = NULL) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_ls(version = version, .date = .date)

  if(!is.null(y)) {
    ## Get identifier of Fields data
    z <- y$id[stringr::str_detect(string = y$name,
                                  pattern = "Fields.csv")]

    ## Get fields data CSV link
    link <- sprintf(fmt = "https://docs.google.com/uc?id=%s", z)

    ## Create temporary file
    destFile <- tempfile()

    ## Download Fields.csv to temp directory
    googledrive::drive_download(file = googledrive::as_id(link),
                                path = destFile, verbose = FALSE)

    ## Read fields CSV
    fields <- utils::read.csv(file = destFile, stringsAsFactors = FALSE)

    ## Convert to tibble
    fields <- tibble::tibble(fields)
  } else {
    ## Assign fields as NULL
    fields <- NULL
  }

  ## Return dataset
  return(fields)
}


################################################################################
#
#' Pull Philippines data on cases information from the publicly available
#' Department of Health COVID-19 Data Drop
#'
#' A wrapper to googledrive and googlesheets4 functions to pull data from the
#' Philppines' COVID-19 Data Drop resource that is publicly distributed via
#' Google Drive
#'
#' @param version A character value specifying whether to get the most
#'   currently available dataset (`"current"`) or to get archive data
#'   (`"archive"`). Default to `"current"`
#' @param .date A character value for date in *YYYY-MM-DD* format. This is the
#'   date up to which extracted data reports to. Only used when `version` is set to
#'   `"archive"` otherwise ignored.
#'
#' @return A tibble of case information on confirmed COVID-19 cases distributed
#'   via the COVID-19 Data Drop
#'
#' @examples
#' datadrop_cases()
#'
#' @export
#'
#
################################################################################

datadrop_cases <- function(version = "current", .date = NULL) {
  ## Get list of contents of specified Google Drive directory
  y <- datadrop_ls(version = version, .date = .date)

  ## Check if y is NULL
  if(!is.null(y)) {
    ## Check if file named Case Information is available
    if(!any(stringr::str_detect(string = y$name, pattern = "Case Information.csv"))) {
      stop(
        paste(
          strwrap(
            x = paste("No cases information on ", .date,
                      ". Try a date earlier or later than date specified.",
                      sep = ""),
            width = 80
          ),
          collapse = "\n"
        ),
        call. = TRUE
      )
    }

    ## Get unique identifier for Cases data
    z <- y$id[stringr::str_detect(string = y$name, pattern = "Case Information.csv")]

    ## Get link for Case Information.csv
    link <- sprintf(fmt = "https://docs.google.com/uc?id=%s", z)

    ## Create temporary file
    destFile <- tempfile()

    ## Download Cases Information.csv
    googledrive::drive_download(file = googledrive::as_id(link),
                                path = destFile, verbose = FALSE)

    ## Read cases CSV
    cases <- utils::read.csv(file = destFile, stringsAsFactors = FALSE)

    ## Convert to tibble
    cases <- tibble::tibble(cases)
  } else {
    ## Set cases to NULL
    cases <- NULL
  }

  ## Return dataset
  return(cases)
}


################################################################################
#
#' Pull Philippines data on testing aggregates from the publicly available
#' Department of Health COVID-19 Data Drop
#'
#' A wrapper to googledrive and googlesheets4 functions to pull data from the
#' Philppines' COVID-19 Data Drop resource that is publicly distributed via
#' Google Drive
#'
#' @param version A character value specifying whether to get the most
#'   currently available dataset (`"current"`) or to get archive data
#'   (`"archive"`). Default to `"current"`
#' @param .date A character value for date in *YYYY-MM-DD* format. This is the
#'   date up to which extracted data reports to. Only used when `version` is set to
#'   `"archive"` otherwise ignored.
#'
#' @return A tibble of case information on testing aggregates distributed
#'   via the COVID-19 Data Drop
#'
#' @examples
#' datadrop_tests()
#'
#' @export
#'
#
################################################################################

datadrop_tests <- function(version = "current", .date = NULL) {
  ## Get list of contents of specified Google Drive directory
  y <- datadrop_ls(version = version, .date = .date)

  ## Check if y is NULL
  if(!is.null(y)) {
    ## Check if file named Testing Aggregates is available
    if(!any(stringr::str_detect(string = y$name, pattern = "Testing Aggregates.csv"))) {
      stop(
        strwrap(
          x = paste("No testing aggregates information on ", .date,
                    ". Try a date earlier or later than date specified.",
                    sep = ""),
          width = 80, prefix = " ", initial = ""
        ),
        call. = TRUE
      )
    }

    ## Get unique identifier for testing aggregates dataset
    z <- y$id[stringr::str_detect(string = y$name, pattern = "Testing Aggregates.csv")]

    ## Get testing aggregates CSV link
    link <- sprintf(fmt = "https://docs.google.com/uc?id=%s", z)

    ## Create temporary file
    destFile <- tempfile()

    ## Download Testing aggregates.csv
    googledrive::drive_download(file = googledrive::as_id(link),
                                path = destFile, verbose = FALSE)

    ## Read testing aggregates CSV file
    tests <- utils::read.csv(file = destFile, stringsAsFactors = FALSE)

    ## Convert to tibble
    tests <- tibble::tibble(tests)
  } else {
    ## Set tests to NULL
    tests <- NULL
  }

  ## Return dataset
  return(tests)
}


################################################################################
#
#' Pull Philippines data on daily facilities status from the publicly available
#' Department of Health COVID-19 Data Drop
#'
#' A wrapper to googledrive and googlesheets4 functions to pull data from the
#' Philppines' COVID-19 Data Drop resource that is publicly distributed via
#' Google Drive
#'
#' @param version A character value specifying whether to get the most
#'   currently available dataset (`"current"`) or to get archive data
#'   (`"archive"`). Default to `"current"`
#' @param .date A character value for date in *YYYY-MM-DD* format. This is the
#'   date up to which extracted data reports to. Only used when `version` is set to
#'   `"archive"` otherwise ignored.
#'
#' @return A tibble of daily facilities status distributed via the COVID-19
#'   Data Drop
#'
#' @examples
#' datadrop_facilities()
#'
#' @export
#'
#
################################################################################

datadrop_facilities <- function(version = "current", .date = NULL) {
  ## Get list of contents of specified Google Drive directory
  y <- datadrop_ls(version = version, .date = .date)

  ## Check if y is NULL
  if(!is.null(y)) {
    ## Check if file named Daily Report is available
    if(!any(stringr::str_detect(string = y$name, pattern = "Case Information.csv"))) {
      stop(
        strwrap(
          x = paste("No daily facilities report information on ", .date,
                    ". Try a date earlier or later than date specified.",
                    sep = ""),
          width = 80, prefix = " ", initial = ""
        ),
        call. = TRUE
      )
    }

    ## Get unique identifier for Daily Report CSV
    z <- y$id[stringr::str_detect(string = y$name,
                                  pattern = "Collect - Daily Report.csv")]

    ## Get link for daily CSV
    link <- sprintf(fmt = "https://docs.google.com/uc?id=%s", z)

    ## Create temporary file
    destFile <- tempfile()

    ## Download daily report.csv
    googledrive::drive_download(file = googledrive::as_id(link),
                                path = destFile, verbose = FALSE)

    ## Read daily report CSV
    facilities <- utils::read.csv(file = destFile, stringsAsFactors = FALSE)

    ## Convert to tibble
    facilities <- tibble::tibble(facilities)
  } else {
    ## Set facilities to NULL
    facilities <- NULL
  }

  ## Return dataset
  return(facilities)
}

