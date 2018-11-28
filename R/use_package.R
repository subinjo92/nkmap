#'Use package more easily
#'
#'when you use this function you can do install and require at once
#'for installed packages, it only do require
#'
#' @param package package name that you want to install and require
#' @param use you want to require or not, if TRUE it will require the package
#' @example
#'   use_package('ggmap')
#' @export

#package의 설치와 불러오는것을 동시에 해주는 함수
use_package <- function (package, use = TRUE) {
  if (!(package %in% installed.packages()[,'Package']))
    install.packages(package, dep = TRUE)
  if (use)
    require(package, character.only = TRUE)
}

