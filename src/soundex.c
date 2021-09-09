/*  stringdist - a C library of string distance algorithms with an interface to R.
 *  Copyright (C) 2013  Mark van der Loo
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 *
 *  You can contact the author at: mark _dot_ vanderloo _at_ gmail _dot_ com
 */

#include "utils.h"
#include <ctype.h>

// Translate similar sounding consonants to numeric codes; vowels are all 
// translated to 'a' and voiceless characters (and other characters) are 
// translated to 'h'.
// Upper and lower case ASCII characters are treated as separate cases,
// avoiding the use of 'tolower' whose effect depends on locale.
static unsigned int translate_soundex(unsigned int c) {
  switch ( c ) {
    case 'b':
    case 'f':
    case 'p':
    case 'v':
    case 'B':
    case 'F':
    case 'P':
    case 'V':
      return '1';
    case 'c':
    case 'g':
    case 'j':
    case 'k':
    case 'q':
    case 's':
    case 'x':
    case 'z':
    case 'C':
    case 'G':
    case 'J':
    case 'K':
    case 'Q':
    case 'S':
    case 'X':
    case 'Z':
      return '2';
    case 'd':
    case 't':
    case 'D':
    case 'T':
      return '3';
    case 'l':
    case 'L':
      return '4';
    case 'm':
    case 'n':
    case 'M':
    case 'N':
      return '5';
    case 'r':
    case 'R':
      return '6';
    case 'h':
    case 'w':
    case 'H':
    case 'W':
      return 'h';
    case 'a':
    case 'e':
    case 'i':
    case 'o':
    case 'u':
    case 'y':
    case 'A':
    case 'E':
    case 'I':
    case 'O':
    case 'U':
    case 'Y':
      return 'a'; // use 'a' to encode vowels
    case '!': // we will allow all printable ASCII characters.
    case '"':
    case '#':
    case '$':
    case '%':
    case '&':
    case '\'':
    case '(':
    case ')':
    case '*':
    case '+':
    case ',':
    case '-':
    case '.':
    case '/':
    case ':':
    case ';':
    case '<':
    case '=':
    case '>':
    case '?':
    case '@':
    case '[':
    case '\\':
    case ']':
    case '^':
    case '_':
    case '`':
    case '{':
    case '|':
    case '}':
    case '~':
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
    case ' ':
      return 'h'; // ignored characters; voiceless symbols.
    default:
      return '?'; // other characters are ignored with a warning
  }
}

// Translate a string to a soundex phonetic code
//
// str: the input string
// str_len: the length of the input string
// result: the character vector in which the soundex code is copied. This 
//    should be a vector of a least length 4.
// output: the number of non-ascii or non-printable ascii characters
// encountered during translation.
static unsigned int soundex(const unsigned int* str, unsigned int str_len, unsigned int* result) {
  if (!str || !result) return 0;
  if (str_len == 0) {
    unsigned int j;
    for (j = 0; j < 4; ++j) result[j] = '0';
    return 0;
  }
  unsigned int i = 0, j = 0, nfail = 0;
  unsigned int cj = translate_soundex(str[j]);
  // the first character is copied directly and not translated to a numerical
  // code
  if ( cj == '?' ){
    // the translated character is non-printable ASCII or non-ASCII.
    ++nfail;
    result[0] = str[0];
  } else {
    result[0] = toupper(str[0]);
  }
  //result[0] = str[0] < 128 ? toupper(str[0]) : str[0];
  for (i = 1; i < str_len && j < 3; ++i) {
    unsigned int ci = translate_soundex(str[i]);
    if (ci == 'a') {
      // vowels are not added to the result; but we do set the previous
      // character to the vower because two consonants with a vowel in between
      // are not merged
      cj = ci;
    } else if (ci != 'h') {
      // a consonant that is not equal to the previous consonant is added to 
      // the result
      if (ci != cj) {
        result[++j] = ci;
        cj = ci;
      }
    }
    if ( ci == '?' ){
      // the translated character is non-printable ASCII or non-ASCII.
      ++nfail;
    }
  }
  // pad with zeros
  for (++j ; j < 4; ++j) result[j] = '0';
  return nfail;
}

double soundex_dist(unsigned int *a, int a_len, unsigned int *b, int b_len, unsigned int *nfail) {

  unsigned int sa[4];
  unsigned int sb[4];
  (*nfail) += soundex(a, a_len, sa);
  (*nfail) += soundex(b, b_len, sb);
  for (unsigned int i = 0; i < 4; ++i) 
    if (sa[i] != sb[i]) return 1.0;
  return 0.0;
}

// ================================ R INTERFACE ===============================

static void check_fail(unsigned int nfail){
  if ( nfail > 0 ){
    warning("soundex encountered %d non-printable ASCII or non-ASCII"
    "\n  characters. Results may be unreliable, see ?printable_ascii",nfail);
  }
}

SEXP R_soundex(SEXP x, SEXP useBytes) {
  PROTECT(x);
  PROTECT(useBytes);

  int n = length(x);
  int bytes = INTEGER(useBytes)[0];

  // when a and b are character vectors; create unsigned int vectors in which
  // the elements of and b will be copied
  unsigned int *s = NULL;
  int ml = max_length(x);
  s = (unsigned int *) malloc( (1L+ml) * sizeof(unsigned int));
  if (s == NULL) {
    UNPROTECT(2);
    error("Unable to allocate enough memory");
  }
  if (bytes) {
    // create output variable
    SEXP y = allocVector(STRSXP, n);
    PROTECT(y);
    // compute soundexes, skipping NA's
    unsigned int nfail = 0;
    int len_s, isna_s;
    char sndx[5];
    unsigned int sndx_int[4];
    for (int i = 0; i < n; ++i) {
      get_elem(x, i, bytes,0L, &len_s, &isna_s, s);
      if (isna_s) {
        SET_STRING_ELT(y, i, R_NaString);
      } else { 
        nfail += soundex(s, len_s, sndx_int);
        for (unsigned int j = 0; j < 4; ++j) sndx[j] = (char) sndx_int[j];
        sndx[4] = 0;
        SET_STRING_ELT(y, i, mkChar(sndx));
      } 
    }
    // cleanup and return
    check_fail(nfail);
    free(s);
    UNPROTECT(3);
    return y;
  } else {
    // create output variable
    SEXP y = allocVector(VECSXP, n);
    PROTECT(y);
    // compute soundexes, skipping NA's
    unsigned int nfail = 0;
    int len_s, isna_s;
    for (int i = 0; i < n; ++i) {
      get_elem(x, i, bytes, 0L, &len_s, &isna_s, s);
      if (isna_s) {
        SEXP sndx = allocVector(INTSXP, 1);
        PROTECT(sndx);
        INTEGER(sndx)[0] = NA_INTEGER;
        SET_VECTOR_ELT(y, i, sndx);
        UNPROTECT(1);
      } else { 
        SEXP sndx = allocVector(INTSXP, 4);
        PROTECT(sndx);
        nfail += soundex(s, len_s, (unsigned int *)INTEGER(sndx));
        SET_VECTOR_ELT(y, i, sndx);
        UNPROTECT(1);
      } 
    }
    // cleanup and return
    check_fail(nfail);
    free(s);
    UNPROTECT(3);
    return y;
  }
}



