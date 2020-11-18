## Authentication
googledrive::drive_auth_configure(api_key = Sys.getenv("GOOGLEDRIVE_TOKEN"))
googledrive::drive_deauth()

## Test 1 ----------------------------------------------------------------------
x <- datadrop_id_latest()

test_that("x is appropriate format/class", {
  expect_is(x, "character")
  expect_true(stringr::str_detect(x, "[A-Za-z0-9@%#&()+*$,._\\-]{33}"))
})

## Test 2 ----------------------------------------------------------------------

x <- datadrop_id_archive(.date = "2020-11-01")

test_that("x is appropriate format/class", {
  expect_is(x, "character")
  expect_true(stringr::str_detect(x, "[A-Za-z0-9@%#&()+*$,._\\-]{33}"))
})

## Test 3 ----------------------------------------------------------------------

test_that("expect error", {
  expect_error(datadrop_id_archive())
  expect_error(datadrop_id_archive(.date = Sys.Date()))
  expect_error(datadrop_id_archive(.date = "2020-03-01"))
  expect_warning(datadrop_id_archive(.date = "2020-10-31"))
})

## Test 4 ----------------------------------------------------------------------

x <- datadrop_id()

test_that("x is appropriate format/class", {
  expect_is(x, "character")
  expect_true(stringr::str_detect(x, "[A-Za-z0-9@%#&()+*$,._\\-]{33}"))
})

## Test 5 ----------------------------------------------------------------------

x <- x %>%
  datadrop_ls() %>%
  datadrop_id_file(fn = "Case Information")

test_that("x is appropriate format/class", {
  expect_is(x, "character")
  expect_true(stringr::str_detect(x, "[A-Za-z0-9@%#&()+*$,._\\-]{33}"))
})

## Test 6 ----------------------------------------------------------------------

test_that("expect warning", {
  expect_warning(x %>%
                   datadrop_ls() %>%
                   datadrop_id_file(fn = "Cases"))
})

## Test 7 ----------------------------------------------------------------------

x <- datadrop_id(version = "archive", .date = "2020-11-01")

test_that("x is appropriate format/class", {
  expect_is(x, "character")
  expect_true(stringr::str_detect(x, "[A-Za-z0-9@%#&()+*$,._\\-]{33}"))
})

