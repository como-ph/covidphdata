################################################################################
#
#'
#' Retrieve datasets from specified DoH Data Drop folders
#'
#' A wrapper to `googledrive` functions to retrieve datasets from the **DoH Data
#' Drop** folders.
#'
#' @param tbl A tibble output produced by [datadrop_ls()] that lists the files
#'   within a particular **DoH Data Drop** *Google Drive* folder
#' @param fn A character string composed of a word or words that can be used to
#'   match to the name of a file within a particular **DoH Data Drop**
#'   *Google Drive* folder listed in `tbl`.
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
#' ## Get tbl for files in latest Data Drop
#' library(magrittr)
#' x <- datadrop_id() %>% datadrop_ls()
#'
#' ## Retrieve case information data
#' datadrop_get(tbl = x, fn = "Case Information", path = tempfile())
#'
#' ## Retrieve latest changelog information
#' datadrop_get_changelog(tbl = x, path = tempfile())
#'
#' ## Retrieve latest metadata - sheets information
#' datadrop_get_sheets(tbl = x, path = tempfile())
#'
#' ## Retrieve latest metadata - fields information
#' datadrop_get_fields(tbl = x, path = tempfile())
#'
#' ## Retrieve latest cases information (same results as first example)
#' datadrop_get_cases(tbl = x, path = tempfile())
#'
#' ## Retrieve latest daily hospital beds and mechanical ventilators information
#' datadrop_get_cdaily(tbl = x, path = tempfile())
#'
#' ## Retrieve latest weekly PPE and other related equipment information
#' datadrop_get_cweekly(tbl = x, path = tempfile())
#'
#' ## Retrieve latest testing aggregates information
#' datadrop_get_tests(tbl = x, path = tempfile())
#'
#' ## Retrieve latest daily quarantine facility beds and mechanical ventilators
#' datadrop_get_qdaily(tbl = x, path = tempfile())
#'
#' ## Retrieve latest weekly quarantine facility PPE and other related equipment
#' datadrop_get_qweekly(tbl = x, path = tempfile())
#'
#' #datadrop_get_collectV3(tbl = x, path = tempfile())
#' #datadrop_get_collectV4(tbl = x, path = tempfile())
#' #datadrop_get_tracker(tbl = x, path = tempfile())
#'
#' @rdname datadrop_get
#' @export
#'
#
################################################################################

datadrop_get <- function(tbl, fn, path = NULL, keep = FALSE,
                         overwrite = FALSE, verbose = TRUE) {
  ## Deauthorise to access public Google Drive
  #googledrive::drive_deauth()

  ## Get Google Drive file ID for specified tbl and fn
  id <- datadrop_id_file(tbl = tbl, fn = fn)
  ext <- get_ext(tbl = tbl, fn = fn)

  if(!is.null(id)) {
    ## Download Google Drive file
    datadrop_download(id = id,
                      path = path,
                      overwrite = overwrite,
                      verbose = verbose)

    ## Check file extension
    if(ext == ".csv") {
      x <- read.csv(file = path)
      x <- tibble::tibble(x)
    } else {
      x <- lapply(X = readxl::excel_sheets(path = path),
                  FUN = readxl::read_xlsx,
                  path = path)

      ## Rename output
      names(x) <- c("List of Changes", "Most Common Changes")
    }
  } else {
    x <- NULL
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

datadrop_get_changelog <- function(tbl, path = NULL, keep = FALSE,
                                   overwrite = FALSE, verbose = TRUE) {
  ## Get Google Drive ID for Changelog.xlsx
  y <- datadrop_id_file(tbl = tbl, fn = "Changelog.xlsx")

  .date <- get_drop_date(tbl = tbl)

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No changelog information on ", .date,
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
    changelog <- datadrop_get(tbl = tbl, fn = "Changelog.xlsx",
                              path = path, keep = keep,
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

datadrop_get_sheets <- function(tbl, path = NULL, keep = FALSE,
                                overwrite = FALSE, verbose = TRUE) {
  ## Get Google Drive ID for Sheets file
  y <- datadrop_id_file(tbl = tbl, fn = "Metadata - Sheets.csv")

  .date <- get_drop_date(tbl = tbl)

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No metadata sheets information on ", .date,
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
    sheets <- datadrop_get(tbl = tbl, fn = "Metadata - Sheets.csv",
                           path = path, keep = keep,
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

datadrop_get_fields <- function(tbl, path = NULL, keep = FALSE,
                            overwrite = FALSE, verbose = TRUE) {
  ## Get Google Drive ID for Fields file
  y <- datadrop_id_file(tbl = tbl, fn = "Metadata - Fields.csv")

  .date <- get_drop_date(tbl = tbl)

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No metadata fields information on ", .date,
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
    fields <- datadrop_get(tbl = tbl, fn = "Metadata - Fields.csv",
                           path = path, keep = keep,
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

datadrop_get_cases <- function(tbl, path = NULL, keep = FALSE,
                               overwrite = FALSE, verbose = TRUE) {
  ## Get Google Drive ID for Case Information file
  y <- datadrop_id_file(tbl = tbl, fn = "Case Information.csv")

  .date <- get_drop_date(tbl = tbl)

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No cases information on ", .date,
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
    cases <- datadrop_get(tbl = tbl, fn = "Case Information.csv",
                          path = path, keep = keep,
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

datadrop_get_tests <- function(tbl, path = NULL, keep = FALSE,
                               overwrite = FALSE, verbose = TRUE) {
  ## Get Google Drive ID for Testing file
  y <- datadrop_id_file(tbl = tbl, fn = "Testing Aggregates.csv")

  .date <- get_drop_date(tbl = tbl)

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No testing aggregates information on ", .date,
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
    tests <- datadrop_get(tbl = tbl, fn = "Testing Aggregates.csv",
                          path = path, keep = keep,
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

datadrop_get_cdaily <- function(tbl, path = NULL, keep = FALSE,
                                overwrite = FALSE, verbose = TRUE) {
  ## Get Google Drive ID for Daily report file
  y <- datadrop_id_file(tbl = tbl, fn = "Collect - Daily Report.csv")

  .date <- get_drop_date(tbl = tbl)

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No daily hospital beds and mechanical ventilator information on ",
                    .date,
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
    facilities <- datadrop_get(tbl = tbl, fn = "Collect - Daily Report.csv",
                               path = path, keep = keep,
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

datadrop_get_cweekly <- function(tbl, path = NULL, keep = FALSE,
                                 overwrite = FALSE, verbose = TRUE) {
  ## Get Google Drive ID for Weekly report file
  y <- datadrop_id_file(tbl = tbl, fn = "Collect - Weekly Report.csv")

  .date <- get_drop_date(tbl = tbl)

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No weekly PPE and medical personnel information on ", .date,
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
    equipment <- datadrop_get(tbl = tbl, fn = "Collect - Weekly Report.csv",
                              path = path, keep = keep,
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

datadrop_get_qdaily <- function(tbl, path = NULL, keep = FALSE,
                                overwrite = FALSE, verbose = TRUE) {
  ## Get Google Drive ID for Daily report file
  y <- datadrop_id_file(tbl = tbl, fn = "Quarantine Facility Data - Daily Report.csv")

  .date <- get_drop_date(tbl = tbl)

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No daily quarantine beds and mechanical ventilator information on ",
                    .date,
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
    facilities <- datadrop_get(tbl = tbl, fn = "Quarantine Facility Data - Daily Report.csv",
                               path = path, keep = keep,
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

datadrop_get_qweekly <- function(tbl, path = NULL, keep = FALSE,
                                 overwrite = FALSE, verbose = TRUE) {
  ## Get list of contents of specified Google drive directory
  y <- datadrop_id_file(tbl = tbl, fn = "Quarantine Facility Data - Weekly Report.csv")

  .date <- get_drop_date(tbl = tbl)

  if(is.null(y)) {
    warning(
      paste(
        strwrap(
          x = paste("No weekly quarantine PPE and medical personnel information on ",
                    .date,
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
    equipment <- datadrop_get(tbl = tbl, fn = "Quarantine Facility Data - Weekly Report.csv",
                              path = path, keep = keep,
                              overwrite = overwrite, verbose = verbose)
  }

  ## Return dataset
  return(equipment)
}


