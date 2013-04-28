\name{qgrams}
\alias{qgrams}
\title{Get a table of qgram counts from a character vector.}
\usage{
  qgrams(..., q = 1L)
}
\arguments{
  \item{...}{any number of (named) arguments, that will be
  coerced to character with \code{as.character}.}

  \item{q}{size of q-gram, must be non-negative.}
}
\value{
  A table with \eqn{q}-gram counts. Detected \eqn{q}-grams
  are column names and the argument names as row names. If
  no argument names were provided, they will be generated.
}
\description{
  Get a table of qgram counts from a character vector.
}
\section{Details}{
  The input is converted to \code{character}. Each element
  is converted to \code{utf8} and than to \code{integer} as
  in \code{\link{stringdist}}. Next,the data is passed to
  the underlying routine. row names of the output array
  (i.e. the qgrams) are encoded in \code{utf8}.

  Strings with less than \code{q} characters and elements
  containing \code{NA} are skipped. Using \code{q=0}
  therefore counts the number of empty strings \code{""}
  occuring in each argument.
}
\examples{

qgrams('hello world',q=3)

# q-grams are counted uniquely over a character vector
qgrams(rep('hello world',2),q=3)

# to count them separately, do something like
x <- c('hello', 'world')
lapply(x,qgrams, q=3)




}
\seealso{
  \code{\link{stringdist}}.
}

