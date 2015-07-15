load('data/flavorsNrml.RData')
load('data/flavs.RData')
load('data/prices.RData')
load('data/wordsNrml.RData')

names <- flavorsNrml$name
library('ggvis')
shinyUI(navbarPage("scotchSpace",
    tabPanel('Explore!',  
        sidebarLayout(mainPanel(h3('Welcome to scotchSpace'),
                                htmlOutput('plotText1'),
                                h4('Mouse over to see the names of whiskeys, or add labels manually using the text box on the right.'),
                                ggvisOutput('expPlot'),
                                uiOutput('expPlot_ui'),
                                htmlOutput('plotText2')), 
        sidebarPanel(h3('Plot Settings'),
            selectInput('var1Exp', 
                        label = 'x-axis coordinates',
                        choices = c(c('PC1', 'PC2'),flavs),
                        selected = 'PC1'),
            selectInput('var2Exp', 
                        label = 'y-axis coordinates',
                        choices = c(c('PC1', 'PC2'),flavs),
                        selected = 'PC2'),
            helpText('Tip: the axes \"PC1\" and \"PC2\" are the first two principal components of the data in the eight-dimensional space corresponding to the eight flavor categories.'),
            sliderInput('numReviewsExp',
                        label = 'Minimum Number of Reviews',
                        value = 10,
                        min = 5,
                        max = 20),
            selectInput('labelsExp',
                        label = 'Pick out a scotch below to label it on the map.',
                        choices = names,
                        selected = NULL,
                        multiple = TRUE),
            helpText('Tip: if the label isn\'t appearing, try adjusting the minimum number of reviews.')
            )
            )),
                   #),
    tabPanel("Find a scotch similar to...",  
        sidebarLayout(
              
              mainPanel(
                        htmlOutput('recText'),
                        selectInput('similarTo', 
                                    label = 'I\'m interested in...',
                                    choices = c(names),
                                    selected = NULL),
                        
                        tabsetPanel(
                            tabPanel("Find me something similar.", tableOutput('simTable')),
                            tabPanel("Map those malts!", 
                                     plotOutput('nbhdPlot'),
                                     uiOutput('nbhdPlot_ui'),
                                     h3('Plot Settings'),
                                     h4('Select Axes'),
                                     helpText('The axes \"PC1\" and \"PC2\" are the first two principal components of the data -- that is, the two perpendicular dimensions in which the data has the most variaiton'),
                                     selectInput('var1', 
                                                 label = 'x-axis coordinates',
                                                 choices = c(c('PC1', 'PC2'),flavs),
                                                 selected = 'PC1'),
                                     selectInput('var2', 
                                                 label = 'y-axis coordinates',
                                                 choices = c(c('PC1', 'PC2'),flavs),
                                                 selected = 'PC2')
                                     ),
                            
                        
                            tabPanel('So, what does it taste like?', plotOutput('barPlot')),
                            tabPanel('How do other people like it?',
                                     h3('Rating statistics'),
                                     tableOutput('ratingStats'),
                                     plotOutput('ratingHist')
                                     )
                            )
              ),
              sidebarPanel(h3('Recommendation settings'),
                           sliderInput('displayMax',
                                       label = 'Maximum number of similar scotches displayed',
                                       value = 5,
                                       min = 1,
                                       max = 30),
                           sliderInput('priceRange',
                                       label = 'Price Range',
                                       min = min(prices$price), 
                                       max = max(prices$price),
                                       value = c(min(prices$price), max(prices$price))),
                           sliderInput('minRating',
                                       label = 'Minimum Average Rating',
                                       value = 0,
                                       min = 0,
                                       max = 100),
                           sliderInput('numReviews',
                                       label = 'Minimum Number of Reviews',
                                       value = 5,
                                       min = 5,
                                       max = 20),
                           selectInput('simType',
                                       label = 'Similarity Scoring',
                                       choices = c('by flavor group', 'by word'),
                                       selected = 'by flavor group')
    ))),
    
    
    tabPanel("About",
             htmlOutput('aboutText')
         )
))



