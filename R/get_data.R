################################################################################
#
#'
#' Retrieve datasets from specified DoH Data Drop folders
#'
#' A wrapper to `googledrive` functions to retrieve datasets from the DoH Data
#' Drop folders
#'
#' @param version A character value specifying whether to get the latest
#'   available dataset (`latest`) or to get archive data (`archive`). Default
#'   to `latest`.
#' @param .date A character value for date in *YYYY-MM-DD* format. This is the
#'   date for the archive DoH Data Drop for which an ID is to be returned.
#'   Should be specified when using `version` is set to `archive` otherwise
#'   ignored.
#'
#' @return A tibble of any of the following datasets:
#'   * 1) **Metadata - Sheets**;
#'   * 2) **Metadata - Fields**;
#'   * 3) **Case Information**;
#'   * 4) **DOH Data Collect - Daily Report**;
#'   * 5) **DOH Data Collect - Weekly Report**;
#'   * 6) **Testing Aggregates**;
#'   * 7) **Quarantine Facility Data - Daily Report**;
#'   * 8) **Quarantine Facility Data - Weekly Report**;
#'   * 9) **DOH Data Collect v3 - Baseline**;
#'   * 10) **DOH Data Collect v4 - Baseline**; and,
#'   * 11) **DDC TTMF Tracker v1**.
#'  For Changelog, a named list of two tibbles - *List of Changes* and
#'  *Most Common Changes*.
#'
#' @examples
#' datadrop_changelog()
#' datadrop_sheets()
#' datadrop_fields()
#' datadrop_cases()
#' datadrop_collect_daily()
#' datadrop_collect_weekly()
#' datadrop_tests()
#' datadrop_quarantine_daily()
#' datadrop_quarantine_weekly()
#' #datadrop_collect_v3()
#' #datadrop_collect_v4()
#' #datadrop_tracker()
#'
#' @rdname datadrop_get
#' @export
#'
#
################################################################################

datadrop_changelog <- function(version = c("latest", "archive"),
                               .date = NULL) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>% datadrop_ls()

  if(!is.null(y)) {
    ## Check if file named Case Information is available
    if(!any(stringr::str_detect(string = y$name,
                                pattern = "Case Information.csv"))) {
      stop(
        paste(
          strwrap(
            x = paste("No changelog information on ", .date,
                      ". Try a date earlier or later than date specified.",
                      sep = ""),
            width = 80
          ),
          collapse = "\n"
        ),
        call. = TRUE
      )
    }

    ## Get identifier of Fields data
    z <- y$id[stringr::str_detect(string = y$name,
                                  pattern = "Changelog.xlsx")]

    ## Create temporary file
    destFile <- tempfile()

    ## Download file
    datadrop_download(id = z, path = destFile)

    ## Read Changelog.xlsx
    changelog <- lapply(X = readxl::excel_sheets(path = destFile),
                        FUN = readxl::read_xlsx,
                        path = destFile)

    ## Rename changelog
    names(changelog) <- readxl::excel_sheets(path = destFile)

  } else {
    ## Assign fields as NULL
    changelog <- NULL
  }

  ## Return dataset
  return(changelog)
}


################################################################################
#
#'
#' @rdname datadrop_get
#' @export
#'
#
################################################################################

datadrop_sheets <- function(version = c("latest", "archive"),
                            .date = NULL) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>% datadrop_ls()

  if(!is.null(y)) {
    ## Check if file named Metadata - Sheets is available
    if(!any(stringr::str_detect(string = y$name,
                                pattern = "Metadata - Sheets.csv"))) {
      stop(
        paste(
          strwrap(
            x = paste("No metadata sheets information on ", .date,
                      ". Try a date earlier or later than date specified.",
                      sep = ""),
            width = 80
          ),
          collapse = "\n"
        ),
        call. = TRUE
      )
    }

    ## Get identifier of Fields data
    z <- y$id[stringr::str_detect(string = y$name,
                                  pattern = "Metadata - Sheets.csv")]

    ## Create temporary file
    destFile <- tempfile()

    ## Download Fields.csv to temp directory
    datadrop_download(id = z, path = destFile)

    ## Read fields CSV
    sheets <- utils::read.csv(file = destFile, stringsAsFactors = FALSE)

    ## Convert to tibble
    sheets <- tibble::tibble(sheets)
  } else {
    ## Assign fields as NULL
    sheets <- NULL
  }

  ## Return dataset
  return(sheets)
}


################################################################################
#
#'
#' @rdname datadrop_get
#' @export
#'
#
################################################################################

datadrop_fields <- function(version = c("latest", "archive"),
                            .date = NULL) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>% datadrop_ls()

  if(!is.null(y)) {
    ## Check if file named Metadata - Fields is available
    if(!any(stringr::str_detect(string = y$name,
                                pattern = "Metadata - Fields.csv"))) {
      stop(
        paste(
          strwrap(
            x = paste("No metadata fields information on ", .date,
                      ". Try a date earlier or later than date specified.",
                      sep = ""),
            width = 80
          ),
          collapse = "\n"
        ),
        call. = TRUE
      )
    }

    ## Get identifier of Fields data
    z <- y$id[stringr::str_detect(string = y$name,
                                  pattern = "Metadata - Fields.csv")]

    ## Create temporary file
    destFile <- tempfile()

    ## Download Fields.csv to temp directory
    datadrop_download(id = z, path = destFile)

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
#'
#' @rdname datadrop_get
#' @export
#'
#
################################################################################

datadrop_cases <- function(version = c("latest", "archive"), .date = NULL) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>% datadrop_ls()

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

    ## Create temporary file
    destFile <- tempfile()

    ## Download Cases Information.csv
    datadrop_download(id = z, path = destFile)

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
#'
#' @rdname datadrop_get
#' @export
#'
#
################################################################################

datadrop_tests <- function(version = c("latest", "archive"),
                           .date = NULL) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>% datadrop_ls()

  ## Check if y is NULL
  if(!is.null(y)) {
    ## Check if file named Testing Aggregates is available
    if(!any(stringr::str_detect(string = y$name,
                                pattern = "Testing Aggregates.csv"))) {
      stop(
        paste(
          strwrap(
            x = paste("No testing aggregates information on ", .date,
                      ". Try a date earlier or later than date specified.",
                      sep = ""),
            width = 80
          ),
          collapse = "\n"
        ),
        call. = TRUE
      )
    }

    ## Get unique identifier for testing aggregates dataset
    z <- y$id[stringr::str_detect(string = y$name,
                                  pattern = "Testing Aggregates.csv")]

    ## Create temporary file
    destFile <- tempfile()

    ## Download Testing aggregates.csv
    datadrop_download(id = z, path = destFile)

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
#'
#' @rdname datadrop_get
#' @export
#'
#
################################################################################

datadrop_collect_daily <- function(version = c("latest", "archive"),
                                   .date = NULL) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>% datadrop_ls()

  ## Check if y is NULL
  if(!is.null(y)) {
    ## Check if file named Daily Report is available
    if(!any(stringr::str_detect(string = y$name,
                                pattern = "Collect - Daily Report.csv"))) {
      stop(
        paste(
          strwrap(
            x = paste("No daily hospital beds and mechanical ventilator
                      information on ", .date, ". Try a date earlier or later
                      than date specified.", sep = ""),
            width = 80
          ),
          collapse = "\n"
        ),
        call. = TRUE
      )
    }

    ## Get unique identifier for Daily Report CSV
    z <- y$id[stringr::str_detect(string = y$name,
                                  pattern = "Collect - Daily Report.csv")]

    ## Create temporary file
    destFile <- tempfile()

    ## Download daily report.csv
    datadrop_download(id = z, path = destFile)

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


################################################################################
#
#'
#' @rdname datadrop_get
#' @export
#'
#
################################################################################

datadrop_collect_weekly <- function(version = c("latest", "archive"),
                                    .date = NULL) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>% datadrop_ls()

  ## Check if y is NULL
  if(!is.null(y)) {
    ## Check if file named Daily Report is available
    if(!any(stringr::str_detect(string = y$name,
                                pattern = "Collect - Weekly Report.csv"))) {
      stop(
        paste(
          strwrap(
            x = paste("No weekly PPE and medical personnel information on ",
                      .date, ". Try a date earlier or later
                      than date specified.", sep = ""),
            width = 80
          ),
          collapse = "\n"
        ),
        call. = TRUE
      )
    }

    ## Get unique identifier for Daily Report CSV
    z <- y$id[stringr::str_detect(string = y$name,
                                  pattern = "Collect - Weekly Report.csv")]

    ## Create temporary file
    destFile <- tempfile()

    ## Download daily report.csv
    datadrop_download(id = z, path = destFile)

    ## Read daily report CSV
    equipment <- utils::read.csv(file = destFile, stringsAsFactors = FALSE)

    ## Convert to tibble
    equipment <- tibble::tibble(equipment)
  } else {
    ## Set facilities to NULL
    equipment <- NULL
  }

  ## Return dataset
  return(equipment)
}


################################################################################
#
#'
#' @rdname datadrop_get
#' @export
#'
#
################################################################################

datadrop_quarantine_daily <- function(version = c("latest", "archive"),
                                      .date = NULL) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>% datadrop_ls()

  ## Check if y is NULL
  if(!is.null(y)) {
    ## Check if file named Daily Report is available
    if(!any(stringr::str_detect(string = y$name,
                                pattern = "Quarantine Facility Data - Daily Report.csv"))) {
      stop(
        paste(
          strwrap(
            x = paste("No daily quarantine beds and mechanical ventilator
                      information on ", .date, ". Try a date earlier or later
                      than date specified.", sep = ""),
            width = 80
          ),
          collapse = "\n"
        ),
        call. = TRUE
      )
    }

    ## Get unique identifier for Daily Report CSV
    z <- y$id[stringr::str_detect(string = y$name,
                                  pattern = "Quarantine Facility Data - Daily Report.csv")]

    ## Create temporary file
    destFile <- tempfile()

    ## Download daily report.csv
    datadrop_download(id = z, path = destFile)

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


################################################################################
#
#'
#' @rdname datadrop_get
#' @export
#'
#
################################################################################

datadrop_quarantine_weekly <- function(version = c("latest", "archive"),
                                       .date = NULL) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>% datadrop_ls()

  ## Check if y is NULL
  if(!is.null(y)) {
    ## Check if file named Daily Report is available
    if(!any(stringr::str_detect(string = y$name,
                                pattern = "Quarantine Facility Data - Weekly Report.csv"))) {
      stop(
        paste(
          strwrap(
            x = paste("No weekly quarantine PPE and medical personnel
                      information on ", .date, ". Try a date earlier or later
                      than date specified.", sep = ""),
            width = 80
          ),
          collapse = "\n"
        ),
        call. = TRUE
      )
    }

    ## Get unique identifier for Daily Report CSV
    z <- y$id[stringr::str_detect(string = y$name,
                                  pattern = "Quarantine Facility Data - Weekly Report.csv")]

    ## Create temporary file
    destFile <- tempfile()

    ## Download daily report.csv
    datadrop_download(id = z, path = destFile)

    ## Read daily report CSV
    equipment <- utils::read.csv(file = destFile, stringsAsFactors = FALSE)

    ## Convert to tibble
    equipment <- tibble::tibble(equipment)
  } else {
    ## Set facilities to NULL
    equipment <- NULL
  }

  ## Return dataset
  return(equipment)
}

