test_that("Cache exists and delete", {
  if(!fs::dir_exists("_mall_cache")) skip("Missing '_mall_cache' folder")
  expect_snapshot(fs::dir_ls("_mall_cache", recurse = TRUE))
  #fs::dir_delete("_mall_cache")
})

# test_that("Ollama cache exists and delete", {
#   skip_if_no_ollama()
#   expect_snapshot(fs::dir_ls("_ollama_cache", recurse = TRUE))
#   fs::dir_delete("_ollama_cache")
# })

