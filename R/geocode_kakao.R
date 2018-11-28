#' Geocode from KAKAO
#'
#' geocode_kakao function will get longitude and latitude from KAKAO api.
#'
#' @param address address that you want to know it`s longitude and latitude
#' @param kakao_key you must input your KAKAO REST API key
#' @return longitude and latitude
#' @example
#' geocode_kakao('address', kakao_key)
#' @export

geocode_kakao <- function (address, kakao_key) {

  #주소의 형식이 제대로 들어왔는지 확인
  if (is.character(address) == F){
    stop('address is not character')
  }

  #kakao api에서 요구하는 형식으로 주소를 encoding 함
  enc_address <- URLencode(iconv(address, to="UTF-8"))
  url <- "https://dapi.kakao.com/v2/local/search/address.json"
  url_fed_to_get <- paste0(url, "?query=", enc_address)

  #해당 주소를 kakao key를 이용해 가져옴
  address_result <- GET(url_fed_to_get, add_headers("Authorization" = str_c("KakaoAK ", kakao_key)))
  #json 형식으로 가져와서 보기쉽게 전처리
  json <-  content(address_result , as = "text")
  processed_json <- fromJSON(json)

  #결과가 정상적으로 하나만 가져왔는지 확인
  if (any(processed_json$meta$total_count == 0)){
    stop('uncorrect address')
  }
  else if (processed_json$meta$total_count != 1){
    stop('there are some result more than 1, please input more detail address')
  }

  #결과에서 위경도만 출력
  result <- processed_json$documents[c('y', 'x')]
  colnames(result) <- c('lat', 'lon')
  result
}
