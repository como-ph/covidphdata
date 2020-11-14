################################################################################
#
#'
#' Get link to a Google Drive file and download
#'
#' @param id A 33-character string identifier for the Google Drive file
#' @param path Path to download the file to.
#'
#' @return A file downloaded into specified path
#'
#' @author Ernest Guevarra
#'
#' @export
#'
#
################################################################################

datadrop_download <- function(id, path) {
  ## Get fields data CSV link
  link <- sprintf(fmt = "https://docs.google.com/uc?id=%s", id)

  ## Download Fields.csv to temp directory
  googledrive::drive_download(file = googledrive::as_id(link),
                              path = path, verbose = FALSE)
}
