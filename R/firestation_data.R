#' Korea firestation data
#'
#' This data include national firestation address, telephone number, longitude
#' and latitude
#'
#' @docType data
#'
#' @usage data(firestation)
#'
#' @format An object of class \code{"cross"}; see \code{\link[qtl]{read.cross}}.
#'
#' @keywords datasets
#'
#' @source \href{https://www.data.go.kr/}{Korea Public Data Portals}
#'
#' @examples
#' data(firestation)
#' \donttest{
#' iplotCurves(phe, times, phe[,c(61,121)], phe[,c(121,181)],
#'             chartOpts=list(curves_xlab="Time (hours)", curves_ylab="Root tip angle (degrees)",
#'                            scat1_xlab="Angle at 2 hrs", scat1_ylab="Angle at 4 hrs",
#'                            scat2_xlab="Angle at 4 hrs", scat2_ylab="Angle at 6 hrs"))}
"firestation"
