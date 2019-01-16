#'Geocode from KAKAO using keyword
#'
#'geocode_keyword_kakao will get longitude and latitude from KAKAO api.
#'it will use nomination or building name
#'it will narrow range by category_group_code or radius.
#'
#' @param keyword it use nomination that you want to know it`s latitude and longitude
#' @param kakao_key you must input your KAKAO REST API key
#' @param category_group_code tou can input this to narrow range
#' @param radius you can input this to narrow range and the center of range is lon and lat
#' @return latitude and longitude
#' @examples
#'   geocode_keyword_kakao(keyword = 'keyword', kakao_key = kakao_key, category_group_code = 'SC4')
#'   geocode_keyword_kakao(keyword = '성균관대학교', kakao_key = kakao_key, lon = 126.99, lat = 37.58, radius = 1000)
#' @export

geocode_keyword_kakao <- function (keyword, kakao_key, category_group_code, lon, lat, radius, rect) {

  if (is.character(keyword) == F){
    stop('address is not character')
  }

  #kakao api가 원하는 url로 encoding
  if (Encoding(keyword) == "UTF-8"){
    enc_address <- URLencode(keyword)
  }
  if (Encoding(keyword) != "UTF-8"){
    enc_address <- URLencode(iconv(keyword, localeToCharset()[1], to = "UTF-8"))
  }
  url <- "https://dapi.kakao.com/v2/local/search/keyword.json?"

  url_fed_to_get <- paste0(url, "query=", enc_keyword)


  #query이외에 추가로 함수에 넣을 수 있는 옵션들
  #옵션을 사용자가 입력하면 url에 추가하고 입력하지 않으면 빈값으로 둠
  category_group_code_url <- ifelse(!missing(category_group_code),
                                    paste0('category_group_code=', category_group_code, sep = ""),
                                    "")

  lon_url <- ifelse(!missing(lon), paste0('x=', lon, sep = ""), "")

  lat_url <- ifelse(!missing(lat), paste0('y=', lat, sep = ""), "")

  radius_url <- ifelse(!missing(radius), paste0('radius=', radius, sep = ""), "")

  rect_url <- ifelse(!missing(rect), paste0('rect=', rect, sep = ""), "")


  url_fed_to_get <- paste(url_fed_to_get, category_group_code_url, lon_url, lat_url, radius_url, rect_url,
                          sep = '&')

  #위에서 ""로 추가된 항목은 중복해서 &가 들어가서 하나만 남김
  url_fed_to_get <- gsub("[&]+", "&", url_fed_to_get)
  #마지막이 &문자로 끝나면 이를 제거해줌
  if (substr(url_fed_to_get, nchar(url_fed_to_get), nchar(url_fed_to_get)) == "&") {
    url_fed_to_get <- substr(url_fed_to_get, 1, nchar(url_fed_to_get) - 1)
  }

  #kakao key를 이용해 해당 정보를 가져옴
  address_result <- GET(url_fed_to_get, add_headers("Authorization" = str_c("KakaoAK ", kakao_key)))
  message(paste0("LONLAT from URL : ", url_fed_to_get))

  #json 파일로 받아와 전처리
  json <-  content(address_result, as = "text")
  processed_json <- fromJSON(json)

  #결과가 없거나 하나 이상인 경우 멈추거나 경고를 반환
  if (processed_json$meta$total_count == 0){
    stop('No results found')
  }

  if (processed_json$meta$total_count != 1){
    warning('There are some results more than 1, please input more detail keyword or category_group_code')
  }

  result <- processed_json$documents[, c('place_name', 'x', 'y')]
  colnames(result) <- c('place_name', 'lon', 'lat')
  result$lat <- as.numeric(result$lat)
  result$lon <- as.numeric(result$lon)
  result
}
