\name{stringdist}
\alias{stringdist}
\alias{stringdistmatrix}
\title{Compute distance between strings}
\usage{
  stringdist(a, b, method = c("osa", "lv", "dl", "h"),
    weight = c(d = 1, i = 1, s = 1, t = 1), maxDist = 0)

  stringdistmatrix(a, b,
    method = c("osa", "lv", "dl", "h"),
    weight = c(d = 1, i = 1, s = 1, t = 1), maxDist = 0,
    ncores = 1)
}
\arguments{
  \item{a}{R object (target); will be converted by
  \code{as.character}.}

  \item{b}{R object (source); will be converted by
  \code{as.character}.}

  \item{method}{Method for distance calculation (see
  details)}

  \item{weight}{The penalty for deletion, insertion,
  substitution and transposition, in that order.  Weights
  must be positive and not exceed 1. \code{weight[4]} is
  ignored when \code{method='lv'} and \code{weight} is
  ignored completely when \code{method='h'}.}

  \item{maxDist}{Maximum string distance before calculation
  is stopped, \code{maxDist=0} means calculation goes on
  untill the distance is computed.}

  \item{ncores}{number of cores to use. Parallelisation is
  over \code{b}, so the speed gain by parallelisation is
  highest when \code{b} is shorter than \code{a}.}
}
\value{
  For \code{stringdist}, a vector with string distances of
  size \code{max(length(a),length(b))}.  For
  \code{stringdistmatrix}, a \code{length(a)xlength(b)}
  \code{matrix}. The returned distance is \code{-1} when
  \code{maxDist} is exceeded and \code{NA} if any of
  \code{a} or \code{b} is \code{NA}.
}
\description{
  Compute distance between strings
}
\section{Details}{
  \code{stringdist} computes pairwise string distances
  between elements of \code{character} vectors \code{a} and
  \code{b}, where the shorter argument is recycled.
  \code{stringdistmatrix} computes the string distance
  matrix with rows according to \code{a} and columns
  according to \code{b}.

  The string distance metrics in this package are based on
  counting the (weighted) number of edit operations it
  takes to turn character \code{b} into character \code{a}.
  Currently, the following distance metrics are supported:
  \tabular{ll}{ \code{osa} \tab Optimal string aligment,
  (restricted Damerau-Levenshtein distance).\cr \code{lv}
  \tab Levenshtein distance.\cr \code{dl} \tab Full
  Damerau-Levenshtein distance.\cr \code{h} \tab Hamming
  distance (\code{a} and \code{b} must have same nr of
  characters). } The Hamming distance counts the number of
  character substitutions that turns \code{b} into \code{a}
  so \code{a} and \code{b} must have the same number of
  characters. The Levenshtein distance allows deletions,
  insertions and substitutions. The Optimal String
  Alignment distance also allows transpositions, but each
  substring may be edited only once, so a character cannot
  be transposed twice. The Damerau-Levensthein distance
  alows multiple transpositions.
}

\section{Encoding issues}{
  Input strings are re-encoded to \code{utf8} an then to
  \code{integer} vectors prior to the distance calculation
  (which works on unsigned ints). This double conversion is
  necessary as it seems the only way to reliably convert
  (possibly multibyte) characters to integers on all
  systems supported by \code{R}. (\code{R}'s native
  \code{\link[utils]{adist}} function does this as well).
  See \code{\link[base]{Encoding}} for further details.
}

\section{Paralellization}{
  The \code{stringdistmatrix} function uses
  \code{\link[parallel]{makeCluster}} to generate a cluster
  and compute the distance matrix in parallel.  As the
  cluster is local, the \code{ncores} parameter should not
  be larger than the number of cores on your machine. Use
  \code{\link[parallel]{detectCores}} to check the number
  of cores available.
}
\examples{

# Simple example using optimal string alignment
stringdist("ca","abc")

# The same example using Damerau-Levenshtein distance (multiple editing of substrings allowed)
stringdist("ca","abc",method="dl")

# string distance matching is case sensitive:
stringdist("ABC","abc")

# so you may want to normalize a bit:
stringdist(tolower("ABC"),"abc")

# stringdist recycles the shortest argument:
stringdist(c('a','b','c'),c('a','c'))

# stringdistmatrix gives the distance matrix:
stringdist(c('a','b','c'),c('a','c'))

# different edit operations may be weighted; e.g. weighted substitution:
stringdist('ab','ba',weight=c(1,1,1,0.5))

# Non-unit weights for insertion and deletion makes the distance metric asymetric
stringdist('ca','abc')
stringdist('abc','ca')
stringdist('ca','abc',weight=c(0.5,1,1,1))
stringdist('abc','ca',weight=c(0.5,1,1,1))


}
\references{
  \itemize{ \item{ R.W. Hamming (1950). Error detecting and
  Error Correcting codes, The Bell System Technical Journal
  29, 147-160 } \item{ V.I. Levenshtein. (1960). Binary
  codes capable of correcting deletions, insertions, and
  reversals. Soviet Physics Doklady 10 707-711. } \item{
  F.J. Damerau (1964) A technique for computer detection
  and correction of spelling errors. Communications of the
  ACM 7 171-176. } \item{ Many algorithms are available in
  pseudocode from wikipedia:
  http://en.wikipedia.org/wiki/Damerau-Levenshtein_distance.
  } }
}

