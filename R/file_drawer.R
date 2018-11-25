file_drawer_exists <- function() {
  file.exists(file_drawer())
}

file_drawer_create <- function() {
  if (file_drawer_exists()) return()

  dir.create(file_drawer(), recursive = TRUE, showWarnings = FALSE)
  saveRDS(list(), file_drawer("index.rds"))

  invisible(TRUE)
}

file_drawer_index <- function() {
  file_drawer_create()
  readRDS(file_drawer("index.rds"))
}

file_drawer_set <- function(url, map, name = NULL) {
  if (is.null(name)) {
    name <- paste0(digest::digest(url), '.rds')
  }

  index <- file_drawer_index()

  if (url %in% names(index)) {
    file.remove(file_drawer(index[[url]]))
  }
  index[[url]] <- name
  saveRDS(index, file_drawer("index.rds"))
  saveRDS(map, file_drawer(name))

  invisible(TRUE)
}

file_drawer_get <- function(url) {
  index <- file_drawer_index()
  name <- index[[url]]

  if (is.null(name)) return(NULL)
  readRDS(file_drawer(name))
}
