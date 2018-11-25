get_kakao_navermap <- function (center = c(lon = 126.9849208, lat = 37.5664519), zoom = 4,
                                size = c(640, 640), format = c("png", "jpeg", "jpg"),
                                crs = c("EPSG:4326", "NHN:2048", "NHN:128", "EPSG:4258",
                                        "EPSG:4162", "EPSG:2096", "EPSG:2097", "EPSG:2098",
                                        "EPSG:900913"),
                                baselayer = c("default", "satellite"), color = c("color", "bw"),
                                overlayers = c("anno_satellite", "bicycle",
                                               "roadview", "traffic"),
                                markers, markers_ab, naver_key, url_2,
                                keyword = TRUE, address = FALSE,
                                kakao_key, naver_secret, category_group_code,
                                filename = "ggmapTemp", messaging = FALSE, urlonly = FALSE,
                                force = FALSE, where = tempdir(), archiving = TRUE, ...)
{
  args <- as.list(match.call(expand.dots = TRUE)[-1])
  argsgiven <- names(args)
  crs <- match.arg(crs)
  if (address) {
    center <- as.numeric(geocode_naver(center, naver_key, naver_secret))
  }
  if (keyword){
    center_temp <- geocode_keyword_kakao(center, kakao_key, category_group_code)
    print(center_temp)
    demand <- as.numeric(readline('원하는 결과값의 번호를 입력해주세요: '))
    center <- as.numeric(center_temp[demand, 2:3])
  }
  if ("center" %in% argsgiven) {
    if (!((is.numeric(center) && length(center) == 2) ||
          (is.character(center) && length(center) == 1))) {
      stop("center of map misspecified, see ?get_googlemap.",
           call. = F)
    }
    if (all(is.numeric(center))) {
      lon <- center[1]
      lat <- center[2]
      if (lon < -180 || lon > 180) {
        stop("longitude of center must be between -180 and 180 degrees.",
             " note ggmap uses lon/lat, not lat/lon.", call. = F)
      }
      if (lat < -90 || lat > 90) {
        stop("latitude of center must be between -90 and 90 degrees.",
             " note ggmap uses lon/lat, not lat/lon.", call. = F)
      }
    }
  }
  if ("zoom" %in% argsgiven) {
    if (!(is.numeric(zoom) && zoom == round(zoom) && zoom >
          0)) {
      stop("zoom must be a whole number between 1 and 14",
           call. = F)
    }
  }
  if ("size" %in% argsgiven) {
    stopifnot(all(is.numeric(size)) && all(size == round(size)) &&
                all(size > 0))
  }
  if ("markers" %in% argsgiven) {
    markers_stop <- TRUE
    if (is.data.frame(markers) && all(apply(markers[, 1:2],
                                            2, is.numeric)))
      markers_stop <- FALSE
    if (class(markers) == "list" && all(sapply(markers, function(elem) {
      is.data.frame(elem) && all(apply(elem[, 1:2], 2,
                                       is.numeric))
    })))
      markers_stop <- FALSE
    if (is.character(markers) && length(markers) == 1)
      markers_stop <- FALSE
    if (markers_stop)
      stop("improper marker specification, see ?get_navermap.",
           call. = F)
  }
  if ("markers_ab" %in% argsgiven) {
    markers_ab_stop <- TRUE
    if (is.data.frame(markers_ab) && all(apply(markers_ab[, 1:2],
                                               2, is.numeric)))
      markers_ab_stop <- FALSE
    if (class(markers_ab) == "list" && all(sapply(markers_ab, function(elem) {
      is.data.frame(elem) && all(apply(elem[, 1:2], 2,
                                       is.numeric))
    })))
      markers_ab_stop <- FALSE
    if (is.character(markers_ab) && length(markers_ab) == 1)
      markers_ab_stop <- FALSE
    if (markers_ab_stop)
      stop("improper marker specification, see ?get_navermap.",
           call. = F)
  }
  if ("filename" %in% argsgiven) {
    filename_stop <- TRUE
    if (is.character(filename) && length(filename) == 1)
      filename_stop <- FALSE
    if (filename_stop)
      stop("improper filename specification, see ?get_navermap",
           call. = F)
  }
  if ("messaging" %in% argsgiven)
    stopifnot(is.logical(messaging))
  if ("urlonly" %in% argsgiven)
    stopifnot(is.logical(urlonly))
  format <- match.arg(format)
  color <- match.arg(color)
  baselayer <- match.arg(baselayer)
  crs <- match.arg(crs)
  overlayers <- match.arg(overlayers, several.ok = TRUE)
  if (!missing(markers) && class(markers) == "list")
    markers <- list_to_dataframe(markers)
  if (!missing(markers_ab) && class(markers_ab) == "list")
    markers_ab <- list_to_dataframe(markers)
  base_url <- "https://openapi.naver.com/v1/map/staticmap.bin?"
  center_url <- if (all(is.numeric(center))) {
    center <- round(center, digits = 6)
    lon <- center[1]
    lat <- center[2]
    paste0("center=", paste(lon, lat, sep = ","))
  }
  else {
    stop("improper center specification, see ?get_navermap.",
         call. = F)
  }
  zoom_url <- paste0("level=", zoom)
  size_url <- paste0("w=", paste(size, collapse = "&h="))
  format_url <- paste0("format=", format)
  baselayer_url <- paste0("baselayer=", baselayer)
  overlayers_url <- paste0("overlayers=", paste(overlayers,
                                                collapse = ","))
  key_url <- paste0("clientId=", naver_key)
  url_2_url <- paste0("url=", url_2)
  crs_url <- paste0("crs=", crs)
  color_url <- paste0("color=", color)
  markers_url <- if (!missing(markers)) {
    if (is.data.frame(markers)) {
      paste("markers=", paste(apply(markers, 1, function(v) paste(round(v,
                                                                        6), collapse = ",")), collapse = ","), sep = "")
    }
    else {
      paste("markers=", markers, sep = "")
    }
  }
  else {
    ""
  }
  markers_ab_url <- if (!missing(markers_ab)) {
    if (is.data.frame(markers_ab)) {
      paste("markers_ab=", paste(apply(markers_ab, 1, function(v) paste(round(v,
                                                                              6), collapse = ",")), collapse = ","), sep = "")
    }
    else {
      paste("markers_ab=", markers_ab, sep = "")
    }
  }
  else {
    ""
  }
  post_url <- paste(key_url, url_2_url, crs_url, center_url, zoom_url, size_url,
                    baselayer_url, overlayers_url, format_url, markers_url, markers_ab_url,
                    sep = "&")
  url <- paste(base_url, post_url, sep = "")
  url <- gsub("[&]+", "&", url)
  if (substr(url, nchar(url), nchar(url)) == "&") {
    url <- substr(url, 1, nchar(url) - 1)
  }
  url <- URLencode(url)
  if (urlonly)
    return(url)
  if (nchar(url) > 2048)
    stop("max url length is 2048 characters.", call. = FALSE)
  map <- file_drawer_get(url)
  if (!is.null(map) && !force)
    return(map)
  tmp <- tempfile()
  download.file(url, tmp, quiet = !messaging, mode = "wb")
  message(paste0("Map from URL : ", url))
  if (format == "png") {
    map <- png::readPNG(tmp)
  }
  else if (format == "jpg") {
    map <- jpeg::readJPEG(tmp)
  }
  if (color == "color") {
    map <- apply(map, 2, rgb)
  }
  else if (color == "bw") {
    mapd <- dim(map)
    map <- gray(0.3 * map[, , 1] + 0.59 * map[, , 2] + 0.11 *
                  map[, , 3])
    dim(map) <- mapd[1:2]
  }
  class(map) <- c("ggmap", "raster")
  ll <- getBorderLonLat(center[1], center[2], zoom, size[1],
                        size[2])
  attr(map, "bb") <- data.frame(ll.lat = ll[2], ll.lon = ll[1],
                                ur.lat = ll[4], ur.lon = ll[3])
  out <- t(map)
  attr(map, "source") <- "naver"
  attr(map, "maptype") <- "naver"
  attr(map, "zoom") <- zoom
  if (archiving)
    file_drawer_set(url, out)
  out
}