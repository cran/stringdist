

dyn.load("src/dl.so")
a <- "c"
b <- "bc"
.Call('R_dl',as.character(NA),b,nchar(a),nchar(b),c(1,1,1,1),0,max(pmax(nchar(a),nchar(b))))

.Call('R_dl',as.character(NA),b,nchar(a),nchar(b),c(2,1,1,1),0)
nchar(c('a',NA,'bcde'))
nchar(NA)



