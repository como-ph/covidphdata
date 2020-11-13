################################################################################
#
#'
#' List files and folders within a specified DoH Data Drop Google Drive folder
#'
#' @param id A 33 character string for the Google Drive ID of the latest
#'   officially released DoH Data Drop. This can be obtained using the
#'   [datadrop_latest_id()] function or by manually expanding the shortened URL
#'   provided in [bit.ly/DataDropPH](bit.ly/DataDropPH) and extracting the
#'   Google Drive ID.
#'
#' @return A tibble containing information on the various files and folders in
#'   the specified Google Drive for DoH Data Drop.
#'
#' @author Ernest Guevarra
#'
#' @examples
#' id <- datadrop_latest_id()
#'
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

