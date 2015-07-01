from numpy import linalg as LA
from pandas import Series, DataFrame
import nltk
from nltk.corpus import stopwords
from nltk.stem.snowball import SnowballStemmer
import pandas as pd
import numpy as np
import re
import unicodedata
import time
from flavor_dicts import *



'''
Basic filtering method for dataframes
'''
def mask(df, f):
    return df[f(df)]



#standard stemmer and basic tokenizer to separate words, remove punctuation.
rscotch = pd.read_csv('rscotch_reviews.csv', encoding = 'utf-8')
stemmer = SnowballStemmer('english')
tokenizer = nltk.RegexpTokenizer(r'\w+')


'''
Basic text preprocessing functions.
'''

def getTokens(review):
	tokens = tokenizer.tokenize(review.lower())
	return tokens

def removeStopwords(stoptext):
	return nltk.Text([word for word in stoptext 
                      if word not in stopwords.words('english')])

def stemTokens(tokens):
	return nltk.Text([stemmer.stem(word) for word in tokens])

#TSS stands for tokenize, stem, and remove stopwords

def TSS(review):
    return stemTokens(removeStopwords(getTokens(review)))
    




'''
Filtering out non-scotches from the dataframe. 
region dict is needed to accomodate misspellings of the various regions. 
'''

regionDict = {'blend': ['Blend'], 
              'highland': ['Highland ', 'Highland', 'HIghland', 'highland'], 
              'speyside': ['Speyside', 'Speyside ', 'speyside'],
              'island': ['Island' 'Island ', 'island'], 
              'islay': ['Islay' ,'Islay ', 'Islay  '], 
              'lowland': ['Lowland'],
              'campbeltown': ['Campbeltown']}

regions = {'Blend', 'Island' 'Island ', 'island','Highland ', 'Highland', 
           'HIghland', 'highland','Lowland','Islay' ,'Islay ', 'Islay  ',
           'Speyside', 'Speyside ', 'speyside', 'Campbeltown'}


scotch = rscotch.ix[rscotch.region.isin(regions), :]        
scotch['reviewTSS'] = scotch.review.apply(TSS,1)

'''
Filter out scotches with very few reviews. 
We work with scotches with at least 5 reviews (~250 disctinct scotches)
'''        





names = list(scotch.name.unique())
nameCounts = DataFrame(np.zeros((len(names), 2)), 
                       columns = ['name', 'numReviews'])
nameCounts.name = names

initial_time = time.time()
for name in scotch.name:
    nameCounts.ix[names.index(name), 'numReviews'] += 1
print time.time() - initial_time



'''
Check the distribution of reviews.
'''

for i in range(20):
    print 'at least %d reviews: ' % i, \
          len(nameCounts.ix[nameCounts.numReviews >= i, :])
          
names5 = nameCounts.ix[nameCounts.numReviews >= 5, 'name']
countWords['numReviews'] = nameCounts.ix[nameCounts['name'].isin(names5), 
                                         'numReviews'].reset_index(drop = True)





'''
Wordcounts of individual words in the nosing chart
'''



flavorWords = []
for key in flavors.keys():
    flavorWords = flavorWords + flatten_flavor(flavors[key])
flavorWordsStem = [stemmer.stem(word) for word in flavorWords]

countWords = DataFrame(np.zeros((len(names5), len(flavorWordsStem))),
                       columns = flavorWordsStem)
countNames = Series(data = list(names5), index = range(len(names5)))
countWords['name'] = countNames


scotch5 = scotch.ix[scotch.name.isin(names5), :]

total_entries = scotch5.shape[0]
initial_time = time.time()

for i in list(scotch5.index):
    if i % 100 == 0:
        print 'index %d out of %d' % (i, total_entries)
        print 'time elapsed ', time.time() - initial_time
    for word in scotch5.ix[i, 'reviewTSS']:
        stem = stemmer.stem(word)
        for flavorWord in flavorWordsStem:
            if stem == flavorWord:
                countWords.ix[countWords['name'] == scotch5.ix[i, 'name'], flavorWord] += 1
        









'''

        for word in scotch.reviewTSS[i]:
            stem = stemmer.stem(word)
            for flavorWord in flavorWordsStem:
                if stem == flavorWord:
                    countWords.ix[countWords['name'] == scotch5.ix[i, 'name'], flavorWord]  += 1
'''








'''
Add normalized region names for scotches in countFlavs
'''

def get_region(name):
    nameDf = scotch5.ix[scotch5.name == name, 'region']
    for i in range(nameDf.shape[0]):
        reg = nameDf.iloc[0]
        for key in regionDict.keys():
            if reg in regionDict[key]:
                return key.title()
                
countWords['region'] = countWords.name.apply(get_region)


'''
We add numerical data like average price and average rating.
'''

countWords['avg.price'] = 0
countWords['avg.rating'] = 0
countWords['stddev.rating'] = 0
countWords['stddev.price'] = 'NA'



'''
Some simple code to parse weirdly written ratings and reviews,
e.g. 83/100. 
'''



def Find(pat, text):
    match = re.search(pat, text)
    if match: return match.group()
    else: 
        print 'not found'
        return None


def  cleanRatings(rating):
    if type(rating) == float:
        return rating
    elif type(rating) == unicode:
        match = Find(r'\d\d', rating)
        if match: 
            return float(Find(r'\d\d', rating))
        else: return 'NaN'
    else: return 'NaN'

cleanRating = scotch5.rating.apply(cleanRatings)
cleanRating = cleanRating.apply(lambda x: float(x))


def cleanPrices(price):
    if type(price) == unicode:
        match = Find(r'\d+',  price)
        if match:
            return float(match)
        else: 
            return 'NaN'
            
    
cleanPrice = scotch5.price[scotch.price.apply(type) == unicode]
cleanPrice = cleanPrice[cleanPrice.apply(lambda x: '$' in x)]
cleanPrice = cleanPrice.apply(cleanPrices)


for i in countWords.index:
    tempRating = cleanRating[scotch5.name == countWords.name[i]]
    tempPrice = cleanPrice[scotch5.name == countWords.name[i]]
    countWords.ix[i, 'avg.rating'] =  np.mean(tempRating)
    countWords.ix[i, 'stddev.rating'] = np.std(tempRating)
    countWords.ix[i, 'avg.price'] = np.mean(tempPrice)
    countWords.ix[i, 'stddev.price'] = np.std(tempPrice)



ratings = DataFrame(np.zeros((cleanRating.shape[0],2)), 
                    columns = ['name', 'rating'],
                    index = cleanRating.index) 

prices = DataFrame(np.zeros((cleanPrice.shape[0],2)), 
                    columns = ['name', 'price'],
                    index = cleanPrice.index) 

ratings.rating = cleanRating
ratings.name = scotch.name.ix[list(cleanRating.index)]

prices.price = cleanPrice
prices.name = scotch.name[cleanPrice.index]

ratings.to_csv('rscotch_ratings_6_30.csv', encoding = 'utf-8')
prices.to_csv('rscotch_prices_6_30.csv', encoding = 'utf-8')





'''
There are some issues with the Cambeltown region--a number of whiskys which
are obviously not from Cambeltown have been labeled Cambeltown. 
Below we deal with these manually.

THIS USES NUMERICAL/POSITION BASED INDICES, SO YOU SHOULD ONLY DO THIS ONCE
WHEN THE DATAFRAME IS CREATED.
'''

drop_names = ['Evan Williams Single Barrel 2004', 
             'New Holland Beer Barrel Bourbon',
             'Nikka From The Barrel',
             'Nikka Whisky from the Barrel']

countWordsEdit = countWords.copy()
for name in dropNames:
    countWordsEdit = countWordsEdit[countWordsEdit.name != name]

countWordsEdit.ix[165, 'region'] = 'Speyside'
countWordsEdit.ix[185, 'region'] = 'Island'
countWordsEdit.ix[200, 'region'] = 'Speyside'
countWordsEdit.ix[236, 'region'] = 'Blend'
countWordsEdit.ix[237, 'region'] = 'Speyside'

countWords = countWordsEdit








'''
A dataframe for counts of words belonging to flavor groups as well.
'''


countFlavs = DataFrame(np.zeros((countWords.shape[0], len(flavors.keys()))),
                       columns = flavors.keys())

shared_columns = ['name', 'region', 'numReviews', 
                  'avg.price', 'stddev.price', 'avg.rating', 'stddev.rating']

for column in shared_columns:
    countFlavs[column] = countWords[column].copy()


for family in flavors.keys():
    flavorWordsStem = [stemmer.stem(word) 
                       for word in flatten_flavor(flavors[family])]
    countFlavs.ix[:, family] = countWords.ix[:,flavorWordsStem].apply(sum, 1)
    
    
    
    
    
'''
Finally, we save everything.
'''    

countFlavs.to_csv('scotch_flavor_counts.csv', encoding = 'utf-8')
countWords.to_csv('scotch_word_counts.csv', encoding = 'utf-8')




















countWords.to_csv('rscotch_flavor_counts_by_word_6-30.csv', 
                  encoding = 'utf-8')




