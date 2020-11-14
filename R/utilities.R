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
#' Get link to a Google Drive file and download
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
#'                        fn = "Case")
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
  ## Get fields data CSV link
  link <- sprintf(fmt = "https://docs.google.com/uc?id=%s", id)

  ## Download Fields.csv to temp directory
  googledrive::drive_download(file = googledrive::as_id(link),
                              path = path,
                              overwrite = overwrite,
                              verbose = verbose)
}


