if (dir.exists("src/lantern")) {
  cat("Building lantern .... \n")

  dir.create("src/lantern/build", showWarnings = FALSE, recursive = TRUE)

  withr::with_dir("src/lantern/build", {
    system("cmake ..")
    system("cmake --build . --target lantern --config Release --parallel 8")
  })

  # copy lantern
  source("R/install.R")
  source("R/lantern_sync.R")
  lantern_sync(TRUE)

  # download torch
  install_torch(path = normalizePath("inst/"), load = FALSE)
}


