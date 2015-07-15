import numpy as np
import pandas as pd
from pandas import DataFrame, Series
import praw
import re
import time

rscotch = pd.read_csv('rscotch.csv')
new_cols = rscotch.columns.values
new_cols[1] = 'name'
new_cols[3] = 'link'
new_cols[2] = 'user'
for i in range(len(new_cols)):
    new_cols[i] = new_cols[i].lower()

rscotch = DataFrame(rscotch, columns = new_cols)


urls = [url for url in rscotch.link.values]

'''
NEED TO USE A REDDIT USERNAME HERE
'''

user_agent = ("scotch review bot 0.1 by /u/YOUR_USERNAME_HERE")
r = praw.Reddit(user_agent = user_agent)


initialTime = time.time()
for i in rscotch.index:
    if i % 50 == 0:
        update = time.time()
        print update - initialTime
    try:
        link = rscotch.link[i]
        submission = r.get_submission(link)
        forest_comments = submission.comments
        review = forest_comments[0]
        rscotch.ix[i, 'reviewText'] = review 
    except:
        rscotch.ix[i, 'reviewText'] = 'invalid url?'


def convertReviews(review):
    if review != 'invalid url?':
        return review.body
    else: return 'invalid url?'
        

rscotch['review'] = rscotch['reviewText'].apply(convertReviews)
rscotch.drop('reviewText', 1)
rscotch.to_csv('rscotch_reviews.csv', encoding = 'utf-8')
