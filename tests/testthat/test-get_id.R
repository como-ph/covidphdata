x <- datadrop_id_latest()

test_that("x is appropriate format/class", {
  expect_is(x, "character")
  expect_true(stringr::str_detect(x, "[A-Za-z0-9@%#&()+*$,._\\-]{33}"))
})


x <- datadrop_id_archive(.date = "2020-11-01")

test_that("x is appropriate format/class", {
  expect_is(x, "character")
  expect_true(stringr::str_detect(x, "[A-Za-z0-9@%#&()+*$,._\\-]{33}"))
})


x <- datadrop_id()

test_that("x is appropriate format/class", {
  expect_is(x, "character")
  expect_true(stringr::str_detect(x, "[A-Za-z0-9@%#&()+*$,._\\-]{33}"))
})

x <- datadrop_id(version = "archive", .date = "2020-11-01")

test_that("x is appropriate format/class", {
  expect_is(x, "character")
  expect_true(stringr::str_detect(x, "[A-Za-z0-9@%#&()+*$,._\\-]{33}"))
})
