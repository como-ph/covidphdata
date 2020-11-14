################################################################################
#
#'
#' An Interface to the Philippines Department of Health COVID-19 Data Drop
#'
#' The Philippines [Department of Health](https://www.doh.gov.ph) has made
#' *COVID-19* related data publicly available as part of its mandate to
#' promoting transparency and accountability in governance. The Philippines
#' **COVID-19 Data Drop** is distributed via *Google Drive* with latest updated
#' data provided daily. Data from previous days are archived and also made
#' available through *Google Drive*. This package provides a coherent and
#' performant API to the latest and archived Philippines *COVID-19* data.
#'
#' @name covidphdata
#' @docType package
#' @keywords internal
#' @importFrom googledrive drive_deauth drive_ls drive_get drive_download as_id
#' @importFrom stringr str_extract str_extract_all str_detect str_split word
#'   str_replace str_remove_all
#' @importFrom pdftools pdf_text
#' @importFrom RCurl getURL
#' @importFrom lubridate ymd interval %within% parse_date_time month year
#' @importFrom utils read.csv
#' @importFrom tibble tibble
#' @importFrom magrittr %>%
#' @importFrom dplyr filter select
#' @importFrom readxl excel_sheets read_xlsx
#'
#
################################################################################
"_PACKAGE"

## quiets concerns of R CMD check re: global variables
if(getRversion() >= "2.15.1")  utils::globalVariables(c("id", "name"))
