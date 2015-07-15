# scotchSpace
A recommendation/visualization tool for scotch whiskies. 


The preprocessing:extraction folder contains:

1) a csv of links to review posts, as well as some data about the reviews, obtained from /r/scotch (rscotc.csv)

2) a script for extracting the text of whisky reviews from  using the Python Reddit API Wrapper (PRAW) (rscotch_scrape_6_30.py) and the rscotch.csv file. The results are written into rscotch_reviews.csv.

3) a file with dictionaries of flavor- and aroma-related words for scotch whiskies (flavor_dicts.py).These words are based on the Whiskey Magazine nosing chart (http://www.whiskymag.com/nosing_course/part3.php). This file should not need to be opened at any point.

4) a script which carries out some basic NLP preprocessing and extracts counts of flavor- and and aroma-related words from the review texts (preprocess_rscotch_6_30.py). The output is scotch_word_counts.csv and scotch_flavor_counts.csv (the latter sums up word counts into aggregate counts for each families of flavors of the Whiskey Magazine nosing chart -- e.g. "peaty", "fruity", and so on).


The scotchSpace_app folder contains

1) A data folder with the app_preprocessing.R script, used to do some final preprocessing on the  scotch_word_counts.csv and scotch_flavor_counts.csv data and save the resulting R objects. 

2) The ui and server files for building the R Shiny app.


