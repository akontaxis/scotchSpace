library('ggplot2')
library('reshape2')

setwd('/Users/andrew/Dropbox/whiskey_project/scotchSpace/scotchSpace/preprocessing:extraction')

wordCounts <- read.csv(file = 'scotch_word_counts.csv')
flavorCounts <- read.csv(file = 'scotch_flavor_counts.csv')
wordCounts$X <- NULL
flavorCounts$X <- NULL


#get lists of words and flavors
words <- names(wordCounts[1:206])
flavs <- names(flavorCounts[1:8])



#normalize these guys.
nrm <- function(x) return(sum(x^2)^0.5)

wordsNrml <- wordCounts
flavorsNrml <- flavorCounts
wordsNrml[, words] <- wordCounts[, words]/apply(wordCounts[ , words], 1, nrm)
flavorsNrml[, flavs] <- flavorCounts[, flavs]/apply(flavorCounts[ , flavs], 1, nrm)

wordsPCA <- prcomp(wordsNrml[ , words], center = TRUE, retx = TRUE)$x
head(wordsPCA)
wordsPCA[, 'PC1']

wordsNrml$PC1 <- wordsPCA[, 'PC1']
wordsNrml$PC2 <- wordsPCA[, 'PC2']

flavorsNrml$PC1 <- wordsPCA[, 'PC1']
flavorsNrml$PC2 <- wordsPCA[, 'PC2']


#MANUALLY FILL IN MISSING PRICES 

wordsNrml$avg.price[wordsNrml$name == 'Aberlour 15 Double Cask Matured'] <- 1.56*45
wordsNrml$stddev.price[wordsNrml$name == 'Aberlour 15 Double Cask Matured'] <- 0

wordsNrml$avg.price[wordsNrml$name == 'Ardbeg Blasda'] <- 1.56*45
wordsNrml$stddev.price[wordsNrml$name == 'Ardbeg Blasda'] <- 0

wordsNrml$avg.price[wordsNrml$name == 'BenRiach 21 Authenticus Peated'] <- 133.00
wordsNrml$stddev.price[wordsNrml$name == 'BenRiach 21 Authenticus Peated'] <- 0

wordsNrml$avg.price[wordsNrml$name == 'Benrinnes 14 Lady of the Glen Single Cask 1999'] <- 1.56*65
wordsNrml$stddev.price[wordsNrml$name == 'Benrinnes 14 Lady of the Glen Single Cask 1999'] <- 0

wordsNrml$avg.price[wordsNrml$name == 'Caol Ila 18'] <- 1.56*80
wordsNrml$stddev.price[wordsNrml$name == 'Caol Ila 18'] <- 0

wordsNrml$avg.price[wordsNrml$name == 'Caol Ila Natural Cask Strength'] <- 1.56*90
wordsNrml$stddev.price[wordsNrml$name == 'Caol Ila Natural Cask Strength'] <- 0


wordsNrml$avg.price[wordsNrml$name == 'Chivas Regal 18'] <- 77.0
wordsNrml$stddev.price[wordsNrml$name == 'Chivas Regal 18'] <- 0


wordsNrml$avg.price[wordsNrml$name == 'Longrow 11 Red Cabernet Sauvignon Cask'] <- 83.0
wordsNrml$stddev.price[wordsNrml$name == 'Longrow 11 Red Cabernet Sauvignon Cask'] <- 0

wordsNrml$avg.price[wordsNrml$name == 'Old Pulteney 1990 – Single Cask Bottling for The Official Line'] <- 180.0
wordsNrml$stddev.price[wordsNrml$name == 'Old Pulteney 1990 – Single Cask Bottling for The Official Line'] <- 0

flavorsNrml$avg.price <- wordsNrml$avg.price
flavorsNrml$stddev.price <- wordsNrml$stddev.price

flavorsNrmlLong <- melt(flavorsNrml, id.vars = c('name'))


setwd('/Users/andrew/Dropbox/whiskey_project/scotchSpace/scotchSpace/scotchSpace_app/data/')
save(wordsNrml, file = 'wordsNrml.RData')
flavorsNrml$name <- as.character(flavorsNrml$name)
wordsNrml$name <- as.character(wordsNrml$name)

save(flavorsNrml, file = 'flavorsNrml.RData')
save(flavorsNrmlLong, file = 'flavorsNrmlLong.RData')
save(wordsNrml, file = 'wordsNrml.RData')


save(words, file = 'words.RData')
save(flavs, file = 'flavs.RData')

prices <- read.csv('~/Dropbox/whiskey_project/scotchSpace/scotchSpace/preprocessing:extraction/rscotch_prices_6_30.csv')
ratings <- read.csv('~/Dropbox/whiskey_project/scotchSpace/scotchSpace/preprocessing:extraction/rscotch_ratings_6_30.csv')
ratings <- ratings[which(!is.na(ratings$rating)), ]
prices <- read.csv('~/Dropbox/whiskey_project/rscotch_prices.csv')
prices <- prices[which(!is.na(prices$price)), ]
save(ratings, file = '~/Dropbox/shiny_apps/scotch/data/ratings.RData')
save(prices, file = '~/Dropbox/shiny_apps/scotch/data/prices.RData')





####Additional tf-idf/nmf preprocessing 
library('NMF')

wordsl1 <- wordsNrml
wordsl1[ , words] 
wordsl1.NMF <- wordsl1[ , words][ , apply(wordsl1[ , words], 2, sum) != 0]

for (i in 2:5){
    nmfOutput[[i]] <- nmf(t(wordsl1[ ,words]), rank = i)
}
    

