## Authentication
googledrive::drive_auth_configure(api_key = Sys.getenv("GOOGLEDRIVE_TOKEN"))
googledrive::drive_deauth()

library(magrittr)

x <- datadrop_id() %>% datadrop_ls()

destFile <- tempfile()

y <- x %>% datadrop_get(fn = "Testing", path = destFile, keep = TRUE)

test_that("datadrop_get retrieves correct file", {
  expect_true(all(c("facility_name", "pct_positive_cumulative", "pct_negative_cumulative") %in% names(y)))
})

test_that("file is kept", {
  expect_true(file.exists(destFile))
})

destFile <- tempfile()

y <- x %>% datadrop_get(fn = "Changelog", path = destFile, keep = TRUE)

test_that("datadrop_get retrieves correct file", {
  expect_true(all(names(y) %in% c("List of Changes", "Most Common Changes")))
})

destFile <- tempfile()

test_that("expect warning", {
  expect_warning(y <- x %>% datadrop_get(fn = "Changelogs", path = destFile, keep = TRUE), NULL)
  expect_true(is.null(y))
})


