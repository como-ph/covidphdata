################################################################################
#
#'
#' Retrieve datasets from specified DoH Data Drop folders
#'
#' A wrapper to `googledrive` functions to retrieve datasets from the **DoH Data
#' Drop** folders.
#'
#' @param id A 33-character string identifier for the *Google Drive* file
#' @param path A character value for path for output file. If NULL, the
#'   default file name used in *Google Drive* is used and the default location
#'   is the working directory.
#' @param keep Logical. Should file be saved locally? Default to FALSE. If TRUE,
#'   file is kept in the location specified in `path`. If `path` is NULL, the
#'   file is kept in the working directory using the default file name used in
#'   *Google Drive*.
#' @param overwrite Logical. If `path` already exists, should it be overwritten?
#'   Default to FALSE.
#' @param verbose Logical. Should operation progress messages be shown? Default
#'   to TRUE.
#' @return A tibble of retrieved **DoH Data Drop** file. If `keep` is TRUE, a
#'   file is also downloaded into specified `path`.
#' @param version A character value specifying whether to get the latest
#'   available dataset (`latest`) or to get archive data (`archive`). Default
#'   to `latest`.
#' @param .date A character value for date in *YYYY-MM-DD* format. This is the
#'   date for the archive **DoH Data Drop** for which an ID is to be returned.
#'   Should be specified when using `version` is set to `archive` otherwise
#'   ignored.
#'
#' @return A tibble of any of the following datasets:
#'   1. *Metadata - Sheets*;
#'   2. *Metadata - Fields*;
#'   3. *Case Information*;
#'   4. *DOH Data Collect - Daily Report*;
#'   5. *DOH Data Collect - Weekly Report*;
#'   6. *Testing Aggregates*;
#'   7. *Quarantine Facility Data - Daily Report*;
#'   8. *Quarantine Facility Data - Weekly Report*;
#'   9. *DOH Data Collect v3 - Baseline*;
#'   10. *DOH Data Collect v4 - Baseline*; and,
#'   11. *DDC TTMF Tracker v1*.
#'  For Changelog, a named list of two tibbles - *List of Changes* and
#'  *Most Common Changes*. If `keep` is TRUE, a copy of the specified
#'  **DoH Data Drop** *Google Drive* file is saved in the location specified by
#'  `path`.
#'
#' @examples
#' ## Get Google Drive ID for latest case information data
#' id <- datadrop_id_file(tbl = datadrop_ls(id = datadrop_id()),
#'                        fn = "Case")
#'
#' ## Retrieve case information data
#' datadrop_get(id = id, path = tempfile())
#'
#' ## Retrieve latest changelog information
#' datadrop_get_changelog(path = tempfile())
#'
#' ## Retrieve latest metadata - sheets information
#' datadrop_get_sheets(path = tempfile())
#'
#' ## Retrieve latest metadata - fields information
#' datadrop_get_fields(path = tempfile())
#'
#' ## Retrieve latest cases information (same results as first example)
#' datadrop_get_cases(path = tempfile())
#'
#' ## Retrieve latest daily hospital beds and mechanical ventilators information
#' datadrop_get_cdaily(path = tempfile())
#'
#' ## Retrieve latest weekly PPE and other related equipment information
#' datadrop_get_cweekly(path = tempfile())
#'
#' ## Retrieve latest testing aggregates information
#' datadrop_get_tests(path = tempfile())
#'
#' ## Retrieve latest daily quarantine facility beds and mechanical ventilators
#' datadrop_get_qdaily(path = tempfile())
#'
#' ## Retrieve latest weekly quarantine facility PPE and other related equipment
#' datadrop_get_qweekly(path = tempfile())
#'
#' #datadrop_get_collectV3(path = tempfile())
#' #datadrop_get_collectV4(path = tempfile())
#' #datadrop_get_tracker(path = tempfile())
#'
#' @rdname datadrop_get
#' @export
#'
#
################################################################################

datadrop_get <- function(id, path = NULL, keep = FALSE,
                         overwrite = FALSE, verbose = TRUE) {
  ##
  datadrop_download(id = id, path = path,
                    overwrite = overwrite, verbose = verbose)

  ## Try retrieving data as a CSV
  x <- try(
    suppressWarnings(
      read.csv(file = path)
    ),
    silent = TRUE
  )

  ## Check x
  if(class(x) == "try-error") {
    x <- lapply(X = readxl::excel_sheets(path = path),
                FUN = readxl::read_xlsx,
                path = path)
  } else {
    ## Convert x to tibble
    x <- tibble::tibble(x)
  }

  ## Check if keep
  if(!keep) {
    file.remove(path)
  }

  ## Return x
  return(x)
}


################################################################################
#
#'
#' @rdname datadrop_get
#' @export
#'
#
################################################################################

datadrop_get_changelog <- function(version = c("latest", "archive"),
                               .date = NULL, path = NULL, keep = FALSE,
                               overwrite = FALSE, verbose = TRUE) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>%
    datadrop_ls() %>%
    datadrop_id_file(fn = "Changelog.xlsx")

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No changelog information on ",
                    ifelse(is.null(.date), as.character(Sys.Date()), .date),
                    ". Try a date earlier or later than date specified. Returning NULL.",
                    sep = ""),
          width = 80
        ),
        collapse = "\n"
      )
    )
    ## Set changelog to NULL
    changelog <- NULL
  } else {
    ## Retrieve data
    changelog <- datadrop_get(id = y, path = path, keep = keep,
                              overwrite = overwrite, verbose = verbose)
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

datadrop_get_sheets <- function(version = c("latest", "archive"),
                                .date = NULL, path = NULL, keep = FALSE,
                                overwrite = FALSE, verbose = TRUE) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>%
    datadrop_ls() %>%
    datadrop_id_file(fn = "Metadata - Sheets.csv")

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No metadata sheets information on ",
                    ifelse(is.null(.date), as.character(Sys.Date()), .date),
                    ". Try a date earlier or later than date specified. Returning NULL.",
                    sep = ""),
          width = 80
        ),
        collapse = "\n"
      )
    )
    ## Set sheets to NULL
    sheets <- NULL
  } else {
    ## Retrieve data
    sheets <- datadrop_get(id = y, path = path, keep = keep,
                           overwrite = overwrite, verbose = verbose)
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

datadrop_get_fields <- function(version = c("latest", "archive"),
                            .date = NULL, path = NULL, keep = FALSE,
                            overwrite = FALSE, verbose = TRUE) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>%
    datadrop_ls() %>%
    datadrop_id_file(fn = "Metadata - Fields.csv")

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No metadata fields information on ",
                    ifelse(is.null(.date), as.character(Sys.Date()), .date),
                    ". Try a date earlier or later than date specified. Returning NULL.",
                    sep = ""),
          width = 80
        ),
        collapse = "\n"
      )
    )
    ## Set fields to NULL
    fields <- NULL
  } else {
    ## Retrieve data
    fields <- datadrop_get(id = y, path = path, keep = keep,
                           overwrite = overwrite, verbose = verbose)
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

datadrop_get_cases <- function(version = c("latest", "archive"),
                           .date = NULL, path = NULL, keep = FALSE,
                           overwrite = FALSE, verbose = TRUE) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>%
    datadrop_ls() %>%
    datadrop_id_file(fn = "Case Information.csv")

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No cases information on ",
                    ifelse(is.null(.date), as.character(Sys.Date()), .date),
                    ". Try a date earlier or later than date specified. Returning NULL.",
                    sep = ""),
          width = 80
        ),
        collapse = "\n"
      )
    )
    ## Set cases to NULL
    cases <- NULL
  } else {
    ## Retrieve data
    cases <- datadrop_get(id = y, path = path, keep = keep,
                          overwrite = overwrite, verbose = verbose)
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

datadrop_get_tests <- function(version = c("latest", "archive"),
                           .date = NULL, path = NULL, keep = FALSE,
                           overwrite = FALSE, verbose = TRUE) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>%
    datadrop_ls() %>%
    datadrop_id_file(fn = "Testing Aggregates.csv")

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No testing aggregates information on ",
                    ifelse(is.null(.date), as.character(Sys.Date()), .date),
                    ". Try a date earlier or later than date specified. Returning NULL.",
                    sep = ""),
          width = 80
        ),
        collapse = "\n"
      )
    )
    ## Set tests to NULL
    tests <- NULL
  } else {
    ## Retrieve data
    tests <- datadrop_get(id = y, path = path, keep = keep,
                          overwrite = overwrite, verbose = verbose)
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

datadrop_get_cdaily <- function(version = c("latest", "archive"),
                                .date = NULL, path = NULL, keep = FALSE,
                                overwrite = FALSE, verbose = TRUE) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>%
    datadrop_ls() %>%
    datadrop_id_file(fn = "Collect - Daily Report.csv")

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No daily hospital beds and mechanical ventilator information on ",
                    ifelse(is.null(.date), as.character(Sys.Date()), .date),
                    ". Try a date earlier or later than date specified. Returning NULL.", sep = ""),
          width = 80
        ),
        collapse = "\n"
      )
    )
    ## Set facilities to NULL
    facilities <- NULL
  } else {
    ## Retrieve data
    facilities <- datadrop_get(id = y, path = path, keep = keep,
                          overwrite = overwrite, verbose = verbose)
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

datadrop_get_cweekly <- function(version = c("latest", "archive"),
                                .date = NULL, path = NULL, keep = FALSE,
                                overwrite = FALSE, verbose = TRUE) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>%
    datadrop_ls() %>%
    datadrop_id_file(fn = "Collect - Weekly Report.csv")

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No weekly PPE and medical personnel information on ",
                    ifelse(is.null(.date), as.character(Sys.Date()), .date),
                    ". Try a date earlier or later than date specified. Returning NULL.", sep = ""),
          width = 80
        ),
        collapse = "\n"
      )
    )
    ## Set equipment to NULL
    equipment <- NULL
  } else {
    ## Retrieve data
    equipment <- datadrop_get(id = y, path = path, keep = keep,
                              overwrite = overwrite, verbose = verbose)
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

datadrop_get_qdaily <- function(version = c("latest", "archive"),
                                .date = NULL, path = NULL, keep = FALSE,
                                overwrite = FALSE, verbose = TRUE) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>%
    datadrop_ls() %>%
    datadrop_id_file(fn = "Quarantine Facility Data - Daily Report.csv")

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No daily quarantine beds and mechanical ventilator information on ",
                    ifelse(is.null(.date), as.character(Sys.Date()), .date),
                    ". Try a date earlier or later than date specified. Returning NULL.", sep = ""),
          width = 80
        ),
        collapse = "\n"
      )
    )
    ## Set facilities to NULL
    facilities <- NULL
  } else {
    ## Retrieve data
    facilities <- datadrop_get(id = y, path = path, keep = keep,
                               overwrite = overwrite, verbose = verbose)
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

datadrop_get_qweekly <- function(version = c("latest", "archive"),
                                 .date = NULL, path = NULL, keep = FALSE,
                                 overwrite = FALSE, verbose = TRUE) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id(version = version, .date = .date) %>%
    datadrop_ls() %>%
    datadrop_id_file(fn = "Quarantine Facility Data - Weekly Report.csv")

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No weekly quarantine PPE and medical personnel information on ",
                    ifelse(is.null(.date), as.character(Sys.Date()), .date),
                    ". Try a date earlier or later than date specified. Returning NULL.", sep = ""),
          width = 80
        ),
        collapse = "\n"
      )
    )
    ## Set equipment to NULL
    equipment <- NULL
  } else {
    ## Retrieve data
    equipment <- datadrop_get(id = y, path = path, keep = keep,
                              overwrite = overwrite, verbose = verbose)
  }

  ## Return dataset
  return(equipment)
}


