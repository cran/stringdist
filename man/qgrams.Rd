\name{qgrams}
\alias{qgrams}
\title{Get a table of qgram counts from a character vector.}
\usage{
  qgrams(x, q)
}
\arguments{
  \item{x}{character vector}

  \item{q}{size of q-gram, must be non-negative.}
}
\value{
  An object of class \code{table}
}
\description{
  Get a table of qgram counts from a character vector.
}
\section{Details}{
  The input is converted to \code{character}. Each element
  is converted to \code{integer} via \code{utf8} as in
  \code{\link{stringdist}}, prior to passing the data to
  the underlying routine. The \code{names} of the output
  table (i.e. the qgrams) are encoded in \code{utf8}.
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

