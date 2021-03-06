% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/amatch.R
\name{seq_amatch}
\alias{seq_amatch}
\alias{seq_ain}
\title{Approximate matching for integer sequences.}
\usage{
seq_amatch(
  x,
  table,
  nomatch = NA_integer_,
  matchNA = TRUE,
  method = c("osa", "lv", "dl", "hamming", "lcs", "qgram", "cosine", "jaccard", "jw"),
  weight = c(d = 1, i = 1, s = 1, t = 1),
  maxDist = 0.1,
  q = 1,
  p = 0,
  bt = 0,
  nthread = getOption("sd_num_thread")
)

seq_ain(x, table, ...)
}
\arguments{
\item{x}{(\code{list} of) \code{integer} or \code{numeric} vector(s) to be
approximately matched. Will be converted with \code{as.integer}.}

\item{table}{(\code{list} of) \code{integer} or \code{numeric} vector(s)
serving as lookup table for matching. Will be converted with
\code{as.integer}.}

\item{nomatch}{The value to be returned when no match is found. This is
coerced to integer.}

\item{matchNA}{Should \code{NA}'s be matched? Default behaviour mimics the 
behaviour of base \code{\link[base]{match}}, meaning that \code{NA} matches
\code{NA}. With \code{NA}, we mean a missing entry in the \code{list}, represented as \code{NA_integer_}. 
If one of the integer sequences stored in the list has an \code{NA} entry,
this is just treated as another integer (the representation of
\code{NA_integer_}).}

\item{method}{Matching algorithm to use. See \code{\link{stringdist-metrics}}.}

\item{weight}{For \code{method='osa'} or \code{'dl'}, the penalty for
deletion, insertion, substitution and transposition, in that order. When
\code{method='lv'}, the penalty for transposition is ignored. When
\code{method='jw'}, the weights associated with integers in elements of \code{a},
integers in elements of \code{b} and the transposition weight, in that order. 
Weights must be positive and not exceed 1. \code{weight} is ignored
completely when \code{method='hamming'}, \code{'qgram'}, \code{'cosine'},
\code{'Jaccard'}, or \code{'lcs'}.}

\item{maxDist}{Elements in \code{x} will not be matched with elements of 
\code{table} if their distance is larger than \code{maxDist}. Note that the
maximum distance between strings depends on the method: it should always be
specified.}

\item{q}{q-gram size, only when method is \code{'qgram'}, \code{'jaccard'},
or \code{'cosine'}.}

\item{p}{Winkler's prefix parameter for Jaro-Winkler distance, with
\eqn{0\leq p\leq0.25}. Only when method is \code{'jw'}}

\item{bt}{Winkler's boost threshold. Winkler's prefix factor is
only applied when the Jaro distance is larger than \code{bt}.
Applies only to \code{method='jw'} and \code{p>0}.}

\item{nthread}{Number of threads used by the underlying C-code. A sensible
default is chosen, see \code{\link{stringdist-parallelization}}.}

\item{...}{parameters to pass to \code{seq_amatch} (except \code{nomatch})}
}
\value{
\code{seq_amatch} returns the position of the closest match of \code{x}
  in \code{table}. When multiple matches with the same minimal distance
  metric exist, the first one is returned. \code{seq_ain} returns a
  \code{logical} vector of length \code{length(x)} indicating wether an
  element of \code{x} approximately matches an element in \code{table}.
}
\description{
For a \code{list} of integer vectors \code{x}, find the closest matches in a
\code{list} of integer or numeric vectors in \code{table.}
}
\section{Notes}{

\code{seq_ain} is currently defined as 

\code{seq_ain(x,table,...) <- function(x,table,...) amatch(x, table, nomatch=0,...) > 0}

All input vectors are converted with \code{as.integer}. This causes truncation for numeric
vectors (e.g. \code{pi} will be treated as \code{3L}).
}

\examples{

x <- list(1:3,c(3:1),c(1L,3L,4L))
table <- list(
  c(5L,3L,1L,2L)
  ,1:4
)
seq_amatch(x,table,maxDist=2)

# behaviour with missings
seq_amatch(list(c(1L,NA_integer_,3L),NA_integer_), list(1:3),maxDist=1)


\dontrun{
# Match sentences based on word order. Note: words must match exactly or they
# are treated as completely different.
#
# For this example you need to have the 'hashr' package installed.
x <- "Mary had a little lamb"
x.words <- strsplit(x,"[[:blank:]]+")
x.int <- hashr::hash(x.words)
table <- c("a little lamb had Mary",
           "had Mary a little lamb")
table.int <- hashr::hash(strsplit(table,"[[:blank:]]+"))
seq_amatch(x.int,table.int,maxDist=3)
}
}
\seealso{
\code{\link{seq_dist}}, \code{\link{seq_sim}}, \code{\link{seq_qgrams}}
}
