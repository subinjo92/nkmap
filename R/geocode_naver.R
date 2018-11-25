geocode_naver <- function (address, naver_key, naver_secret) {

  if (is.character(address) == F){
    stop('address is not character')
  }

  #url을 encoding시킴
  enc_address <- URLencode(address)
  url <- "https://openapi.naver.com/v1/map/geocode?"
  #query에 우리가 요구하는 주소를 붙여 url에 붙임
  url_fed_to_get <- paste0(url, "query=", enc_address)

  #naver api가 요구하는 형식의 url을 만들기 위해 key와 secret을 붙여서 정보를 가져옴
  address_result <- GET(url_fed_to_get, add_headers("X-Naver-Client-Id" = naver_key,
                                                    "X-Naver-Client-Secret" = naver_secret))
  #json 파일로 가져와서 보기 쉽게 전처리
  json <-  content(address_result , as = "text")
  processed_json <- fromJSON(json)

  #제대로 작동했으면 결과를 주고 결과가 없거나 하나 이상인 경우 경고를 출력
  if (any(processed_json %in% '검색 결과가 없습니다.')){
    stop('uncorrect address')
  }

  if (processed_json$result$total != 1){
    stop('there are some result more than 1, please input more detail address')
  }

  #결과 list에서 위경도만 뽑아 출력함
  item <- processed_json$result$items
  colnames(item$point) <- c('lon', 'lat')
  item$point
}
