

dyn.load('src/dl.so')
.Call('R_dl',"aa","bb",as.integer(2),as.integer(2),as.integer(3))


stringdist('aap',c('noot','mies'),method='dl')
stringdist(c('noot','mies'),'aap',method='dl')

