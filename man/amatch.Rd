\name{amatch}
\alias{ain}
\alias{amatch}
\title{Approximate string matching}
\usage{
amatch(x, table, nomatch = NA_integer_, matchNA = TRUE, method = c("osa",
  "lv", "dl", "hamming", "lcs", "qgram", "cosine", "jaccard", "jw"),
  useBytes = FALSE, weight = c(d = 1, i = 1, s = 1, t = 1), maxDist = 0.1,
  q = 1, p = 0)

ain(x, table, ...)
}
\arguments{
  \item{x}{vector: elements to be approximately matched:
  will be coerced to \code{character}.}

  \item{table}{vector: lookup table for matching. Will be
  coerced to \code{character}.}

  \item{nomatch}{The value to be returned when no match is
  found. This is coerced to integer. \code{nomatch=0} can
  be a useful option.}

  \item{matchNA}{Should \code{NA}'s be matched? Default
  behaviour mimics the behaviour of base
  \code{\link[base]{match}}, meaning that \code{NA} matches
  \code{NA} (see also the note on \code{NA} handling
  below).}

  \item{method}{Matching algorithm to use. See
  \code{\link{stringdist}}.}

  \item{useBytes}{Perform byte-wise comparison.
  \code{useBytes=TRUE} is faster but may yield different
  results depending on character encoding. See also
  \code{\link{stringdist}}, under encoding issues.}

  \item{weight}{Weight parameters for matching algorithm
  See \code{\link{stringdist}}.}

  \item{maxDist}{Elements in \code{x} will not be matched
  with elements of \code{table} if their distance is larger
  than \code{maxDist}.}

  \item{q}{q-gram size, see \code{\link{stringdist}}.}

  \item{p}{Winklers penalty parameter for Jaro-Winkler
  distance, see \code{\link{stringdist}}.}

  \item{...}{parameters to pass to \code{amatch} (except
  \code{nomatch})}
}
\value{
\code{amatch} returns the position of the closest match of
\code{x} in \code{table}.  When multiple matches with the
same smallest distance metric exist, the first one is
returned.  \code{ain} returns a \code{logical} vector of
length \code{length(x)} indicating wether an element of
\code{x} approximately matches an element in \code{table}.
}
\description{
Approximate string matching equivalents of \code{R}'s
native \code{\link[base]{match}} and \code{\%in\%}.
}
\details{
\code{ain} is currently defined as

\code{ain(x,table,...) <- function(x,table,...) amatch(x,
table, nomatch=0,...) > 0}
}
\section{Note on \code{NA} handling}{
  \code{R}'s native \code{\link[base]{match}} function
  matches \code{NA} with \code{NA}. This may feel
  inconsistent with \code{R}'s usual \code{NA} handling,
  since for example \code{NA==NA} yields \code{NA} rather
  than \code{TRUE}. In most cases, one may reason about the
  behaviour under \code{NA} along the lines of ``if one of
  the arguments is \code{NA}, the result shall be
  \code{NA}'', simply because not all information necessary
  to execute the function is available. One uses special
  functions such as \code{is.na}, \code{is.null}
  \emph{etc.} to handle special values.

  The \code{amatch} function mimics the behaviour of
  \code{\link[base]{match}} by default: \code{NA} is
  matched with \code{NA} and with nothing else. Note that
  this is inconsistent with the behaviour of
  \code{\link{stringdist}} since \code{stringdist} yields
  \code{NA} when at least one of the arguments is
  \code{NA}. The same inconsistency exists between
  \code{\link[base]{match}} and \code{\link[stats]{dist}}.
  However, in \code{amatch} this behaviour can be
  controlled by setting \code{matchNA=FALSE}. In that case,
  if any of the arguments in \code{x} is \code{NA}, the
  \code{nomatch} value is returned, regardless of whether
  \code{NA} is present in \code{table}.
}
\examples{

# lets see which sci-fi heroes are stringdistantly nearest
amatch("leia",c("uhura","leela"),maxDist=5)

# we can restrict the search
amatch("leia",c("uhura","leela"),maxDist=1)

# setting nomatch returns a different value when no match is found
amatch("leia",c("uhura","leela"),maxDist=1,nomatch=0)

# this is always true if maxDist is Inf
ain("leia",c("uhura","leela"),maxDist=Inf)

# Let's look in a neighbourhood of maximum 2 typo's (by default, the OSA algorithm is used)
ain("leia",c("uhura","leela"), maxDist=2)


}

