\name{stringdist}
\alias{stringdist}
\alias{stringdistmatrix}
\title{Compute distance between strings}
\usage{
  stringdist(a, b,
    method = c("osa", "lv", "dl", "h", "lcs", "qgram"),
    weight = c(d = 1, i = 1, s = 1, t = 1), maxDist = 0,
    q = 1)

  stringdistmatrix(a, b,
    method = c("osa", "lv", "dl", "h", "lcs", "qgram"),
    weight = c(d = 1, i = 1, s = 1, t = 1), maxDist = 0,
    q = 1, ncores = 1, cluster = NULL)
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
  ignored completely when \code{method='h'},
  \code{method='qgram'} or \code{method='lcs'}.}

  \item{maxDist}{Maximum string distance before calculation
  is stopped, \code{maxDist=0} means calculation goes on
  untill the distance is computed. Ignored for
  \code{method='qgram'}.}

  \item{q}{size of the \eqn{q}-gram, must be nonnegative.
  Ignored for all but \code{method='qgram'}.}

  \item{ncores}{number of cores to use. If \code{ncores>1},
  a local cluster is created using
  \code{\link[parallel]{makeCluster}}. Parallelisation is
  over \code{b}, so the speed gain by parallelisation is
  highest when \code{b} is shorter than \code{a}.}

  \item{cluster}{(optional) a custom cluster, created with
  \code{\link[parallel]{makeCluster}}. If \code{cluster} is
  not \code{NULL}, \code{ncores} is ignored.}
}
\value{
  For \code{stringdist}, a vector with string distances of
  size \code{max(length(a),length(b))}.  For
  \code{stringdistmatrix}, a \code{length(a)xlength(b)}
  \code{matrix}. The returned distance is nonnegative if it
  can be computed, \code{NA} if any of the two argument
  strings is \code{NA} and \code{-1} when it cannot be
  computed. See details for the meaning of \code{-1} for
  the various algorithms.
}
\description{
  Compute distance between strings
}
\section{Details}{
  \code{stringdist} computes pairwise string distances
  between elements of \code{character} vectors \code{a} and
  \code{b}, where the vector with less elements is
  recycled. \code{stringdistmatrix} computes the string
  distance matrix with rows according to \code{a} and
  columns according to \code{b}.

  Currently, the following distance metrics are supported:
  \tabular{ll}{ \code{osa} \tab Optimal string aligment,
  (restricted Damerau-Levenshtein distance).\cr \code{lv}
  \tab Levenshtein distance.\cr \code{dl} \tab Full
  Damerau-Levenshtein distance.\cr \code{h} \tab Hamming
  distance (\code{a} and \code{b} must have same nr of
  characters).\cr \code{lcs} \tab Longest common
  substring.\cr \code{qgram} \tab \eqn{q}-gram distance. }
  The Hamming distance counts the number of character
  substitutions that turns \code{b} into \code{a}. If
  \code{a} and \code{b} have different number of characters
  \code{-1} is returned.

  The Levenshtein distance (\code{ld}) counts the number of
  deletions, insertions and substitutions necessary to turn
  \code{b} into \code{a}. This method is equivalent to
  \code{R}'s native \code{adist} function. The computation
  is aborted when \code{maxDist} is exceeded, in which case
  \code{-1} is returned.

  The Optimal String Alignment distance (\code{osa}) is
  like the Levenshtein distance but also allows
  transposition of adjacent characters. Here, each
  substring may be edited only once so a character cannot
  be transposed twice. The computation is aborted when
  \code{maxDist} is exceeded, in which case \code{-1} is
  returned.

  The full Damerau-Levensthein distance (\code{dl}) allows
  for multiple transpositions. The computation is aborted
  when \code{maxDist} is exceeded, in which case \code{-1}
  is returned.

  The longest common substring is defined as the longest
  string that can be obtained by pairing characters from
  \code{a} and \code{b} while keeping the order of
  characters intact. The lcs-distance is defined as the
  number of unpaired characters. The distance is equivalent
  to the edit distance allowing only deletions and
  insertions, each with weight one. The computation is
  aborted when \code{maxDist} is exceeded, in which case
  \code{-1} is returned.

  A \eqn{q}-gram is a subsequence of \eqn{q}
  \emph{consecutive} characters of a string. If \eqn{x}
  (\eqn{y}) is the vector of counts of \eqn{q}-gram
  occurrences in \code{a} (\code{b}), the \eqn{q}-gram
  distance is given by the sum over the absolute
  differences \eqn{|x_i-y_i|}. The computation is aborted
  when \code{q} is is larger than the length of any of the
  strings. In that case \code{-1} is returned.
}

\section{Encoding issues}{
  Input strings are re-encoded to \code{utf8} an then to
  \code{integer} vectors prior to the distance calculation
  (since the underlying \code{C}-code expects unsigned
  ints). This double conversion is necessary as it seems
  the only way to reliably convert (possibly multibyte)
  characters to integers on all systems supported by
  \code{R}. (\code{R}'s native \code{\link[utils]{adist}}
  function does this as well). See
  \code{\link[base]{Encoding}} for further details.
}

\section{Paralellization}{
  The \code{stringdistmatrix} function uses
  \code{\link[parallel]{makeCluster}} to generate a cluster
  and compute the distance matrix in parallel.  As the
  cluster is local, the \code{ncores} parameter should not
  be larger than the number of cores on your machine. Use
  \code{\link[parallel]{detectCores}} to check the number
  of cores available. Alternatively, you can create a
  cluster by yourself, using
  \code{\link[parallel]{makeCluster}} and pass that to
  \code{stringdistmatrix}.
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

# stringdistmatrix gives the distance matrix (by default for optimal string alignment):
stringdist(c('a','b','c'),c('a','c'))

# different edit operations may be weighted; e.g. weighted substitution:
stringdist('ab','ba',weight=c(1,1,1,0.5))

# Non-unit weights for insertion and deletion makes the distance metric asymetric
stringdist('ca','abc')
stringdist('abc','ca')
stringdist('ca','abc',weight=c(0.5,1,1,1))
stringdist('abc','ca',weight=c(0.5,1,1,1))

# Hamming distance is undefined (or sometimes called infinite) for 
# strings of unequal lengths  (stringdist returns -1)
stringdist("ab","abc",method="h")
# For strings of eqal length it counts the number of unequal characters as they occur
# in the strings from beginning to end
stringdist("hello","HeLl0",method="h")

# The lcm (longest common substring) distance returns the number of 
# characters that are not part of the lcs.
#
# Here, the lcs is either 'a' or 'b' and one character cannot be paired:
stringdist('ab','ba',method="lcs")
# Here the lcs is 'surey' and 'v', 'g' and one 'r' of 'surgery' are not paired
stringdist('survey','surgery',method="lcs")


# q-grams are based on the difference between occurrences of q consecutive characters.
#
# since each character abc occurs in 'abc' and 'cba', the q=1 distance equals 0:
stringdist('abc','cba',method='qgram',q=1)

# since the first string consists of 'ab','bc' and the second 
# of 'cb' and 'ba', the q=2 distance equals 4 (they have no q=2 grams in common):
stringdist('abc','cba',method='qgram',q=2)


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
  } \item{The code for the full Damerau-Levenshtein
  distance was adapted from Nick Logan's public github
  repository:
  \url{https://github.com/ugexe/Text--Levenshtein--Damerau--XS/blob/master/damerau-int.c}.
  }

  \item{ A good reference for qgram distances is E. Ukkonen
  (1992), Approximate string matching with q-grams and
  maximal matches. Theoretical Computer Science, 92,
  191-211. } }
}

