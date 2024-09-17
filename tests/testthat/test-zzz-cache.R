test_that("Cache exists and delete", {
  if(!fs::dir_exists("_mall_cache")) skip("Missing '_mall_cache' folder")
  expect_snapshot(fs::dir_ls("_mall_cache", recurse = TRUE))
  fs::dir_delete("_mall_cache")
})

