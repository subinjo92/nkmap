#package의 설치와 불러오는것을 동시에 해주는 함수
use_package <- function (package, use = TRUE) {
  if (!(package %in% installed.packages()[,'Package']))
    install.packages(package, dep = TRUE)
  if (use)
    require(package, character.only = TRUE)
}
