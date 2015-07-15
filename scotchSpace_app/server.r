shinyServer(function(input, output){
    load('data/flavorsNrml.RData')
    load('data/wordsNrml.RData')
    load('data/flavs.RData')
    load('data/words.RData')
    load('data/flavorsNrmlLong.RData')
    load('data/ratings.RData')
    load('data/prices.RData')
    library('ggvis')
    library('ggplot2')    
    library('dplyr')
      
    
recTable <- function(){
    df <- switch(input$simType,
                 'by flavor group' = flavorsNrml,
                 'by word' = wordsNrml)
    cols <-switch(input$simType,
                  'by flavor group' = flavs,
                  'by word' = words)
    
    simEntry <- filter(df, name == input$similarTo) %>%
        select(match(cols, names(df)))
    
    df <- filter(df, numReviews >= input$numReviews) %>%
        filter(avg.rating >= input$minRating) %>%
        filter(avg.price >= input$priceRange[1], avg.price <= input$priceRange[2]) 
    
    validate(
        need(dim(df)[1] > 0, 'Sorry, there are no matches for your criteria.')
    )
    
    cosSim <- apply(data.matrix(df[,cols]), 
                    1, 
                    (function(x) x %*% t(data.matrix(simEntry))))
    cosSorted <- sort(cosSim, decreasing = TRUE, index.return = TRUE)
    simIx <- cosSorted$ix
    cosSim <- cosSorted$x
    
    df[ , 'average_price'] <- df$avg.price
    df[ , 'average_rating'] <- df$avg.rating
    df[ , 'total_reviews'] <- df$numReviews
    
    simDf <- data.frame(cbind(df[cosSorted$ix, 'name'], cosSorted$x))
    range <- min(input$displayMax, dim(df)[1])
    names(simDf) <- c('whisky', 'cosine_similarity')
    return(select(data.frame(cbind(simDf[1:range, ], df[cosSorted$ix[1:range], ])), name, region, cosine_similarity, total_reviews, average_price, average_rating))

}
    
    
output$simTable <- renderTable({
    
    validate(
        need(dim(recTable())[1] > 0, 'Sorry, there are no matches for your criteria.')
    )
    recTable()
})    

    
    
output$barPlot <- renderPlot({
    barDf <- flavorsNrmlLong[(flavorsNrmlLong$name == input$similarTo)&(flavorsNrmlLong$variable %in% flavs),]
    barDf$value <- as.numeric(barDf$value)
    ggplot(data = barDf)+ 
    geom_bar(aes(x = variable, y = value, fill = variable), stat = 'identity', position = 'dodge') +
    scale_fill_manual(values=c("blue", "gold4", 'black', 'darkgreen', 'sienna4', 'yellow3', "deeppink4", 'red3')) +
    ggtitle(paste('Flavor profile for',input$similarTo))
})




output$ratingHist <- renderPlot({
    ggplot(data = ratings[which(ratings$name == input$similarTo), ]) + 
        geom_histogram(aes(x = rating), binwidth = 2.5) + 
        ggtitle(paste(input$similarTo, 'Rating Distribution'))
})


output$ratingStats <- renderTable({
    ratingsLocal <-ratings$rating[ratings$name == input$similarTo]
    statTable <- summary(ratingsLocal)
    statTable['Standard Deviation'] <- sd(ratingsLocal)
    statTable['Total Ratings'] <- length(ratingsLocal)
    
    df <- data.frame(list('Minimum' = statTable['Min.'],   "Median" = statTable["Median"],  "Mean" = statTable["Mean"], 'Maximum' = statTable['Max.'],  "Standard Deviation" = statTable[ "Standard Deviation"]))
    df
}, include.rownames = FALSE)


output$nbhdPlot <- renderPlot({
                                    
        validate(
            need(dim(recTable())[1] > 0, 'Sorry, there are no matches for your criteria.')
        )

        localDf <- recTable()
        plotDf <- flavorsNrml[flavorsNrml$name %in% localDf$name, ]
        
            ggplot(data = plotDf, aes_string(x = input$var1, y = input$var2)) + 
                geom_point(aes(size = numReviews, color = region)) + 
                scale_color_discrete(name = 'Region') + 
                scale_size_continuous(name = 'Total reviews', range = c(2,7)) +
                geom_text(aes(label = name, hjust = -0.05, vjust = -0.15))  +
                theme_bw()

})

expVis <- reactive({
            df <- filter(flavorsNrml, numReviews >= input$numReviewsExp)                         
            
            labels <- input$labelsExp         
            
            labelSelector <- function(name){
                if(name %in% labels){
                    return(name)
                } else {
                    return('')
                }
            }
            
            df$labels <- sapply(df$name, labelSelector)
            df$labeled <- (df$label != '')
            df$labeled <- as.factor(df$labeled)
            
            df %>%
                ggvis(key := ~name) %>%
                layer_points(prop('x', as.name(input$var1Exp)),
                             prop('y', as.name(input$var2Exp)),
                             prop('fill', as.name('region'))) %>%
                layer_text(text := ~labels,
                           prop('x', as.name(input$var1Exp)),
                           prop('y', as.name(input$var2Exp))) %>%
                add_tooltip(function(df) df$name)   
})

expVis %>% bind_shiny("expPlot", "expPlot_ui")
    


output$plotText1 <- renderUI(HTML('
     <p>
         You\'re looking at a 2D plot of scotch whiskies that was created from 
         the text of user-submitted reviews on reddit\'s /r/scotch community. 
    </p> 
    <p>
        Specifically, it was generated from counts of the roughly 200 flavor-
        and aroma-related words of the <a href = http://www.whiskymag.com/media/nosing_course/Whiskywheel-Big.jpg> Whiskey Magazine nosing chart</a>; 
        each dram is associated with a point in 200 dimensional space, which was 
        then projected down to a 2D plot.
    </p>                             
'))


output$plotText2 <- renderUI(HTML('
<p> <b> Projected how? </b> There are a couple of choices:
    <ul>
        <li> We can project onto the first two 
            <a href= https://en.wikipedia.org/wiki/Principal_component_analysis> principal components </a>
            of the word-count data. This choice means that the 2D plot will preserve as much of 
            the variability of the original data as possible. The downside is that the meaning of the 
            axes is hard to intrepret.
        <li> We can sum up the counts for words that belong to separate flavor categories per the 
             nosing chart (e.g. \"tar\" belongs to the \"peaty\" category, \"apple\", belongs to 
             the \"fruity\" category, and so on) and plot the data with axes corresponding to each
             category. This is more intuitive to read, but may tend to stretch and compress the data unnecessarily.
    </ul>
</p>
'    
))


output$recText <- renderUI(HTML('
    <p>    
        If you name a malt, I can tell you which ones are close by in the 200-dimensional 
        space corresponding to word counts (or the eight-dimensional space corresponding to its scores 
        in each of the eight flavor categories). This is a simple way of finding a whisky that\'s similar to yours.
    </p>

    <p>
        You can also filter these results for price, rating, and number of reviews with the sliders on the right.
    </p>

    <p>
        Check out the other tabs for a plot of your whisky\'s neighborhood in these spaces,
        as well as info on its flavor profile and ratings.
    </p>'
))



output$aboutText <- renderUI(HTML('
    <h3> scotchSpace is a visualization tool and recommendation engine for scotch whiskies. </h3>
    <h4>The data </h4>
        <p>
            scotchSpace was built using roughly 11,000 user-submitted reviews from the /r/scotch community on reddit, which were scraped with the
              help of PRAW, the Python Reddit API Wrapper. 
        </p>
    <h4? The approach </h4>
        <p>
              The review texts were used to score each whisky in the eight flavor categories of the Whiskey Magazine 
              scotch nosing wheel: \"winey\", \"fruity\", \"peaty\", \"floral\", \"woody\", \"feinty\", \"sulphury\", 
              and \"cereal\". The scores are really just raw counts of occurrences of words related to each flavor 
              family, normalized so that each eight-tuple of scores has unit norm. Of course, some some basic 
              preprocessing was needed to make these counts reasonably accurate; the reviews were tokenized and stemmed 
              using the Python Natural Language Toolkit so that, for instance, various forms of the stem \"peat\" would 
              be counted in the same way.
        </p>
    <h4> Features </h4>
        <p>
            Given a whisky of interest, the recommendation feature will list the nearest whiskies in the eight-dimensional 
            space corresponding to flavor scores (more precisely, cosine similarity is used). Recommendations can then be 
            filtered by price, average rating, or popularity (number of reviews). There is also the option of obtaining 
            recommendations by measuring distance in 200+-dimensional space corresponding to counts of the individual 
            flavor-words considered. This provides a much finer measure of similarity for whiskies with many reviews, but 
            can give somewhat erratic recommendations for whiskies with few reviews; if the reviews for two very similar 
            whiskies happen to contain distinct but closely related words (e.g. \"oloroso\" instead of \"sherry\"), they will 
            be scored as disimilar. This effect tends to be more pronounced when word counts are sparse, i.e. when a whisky 
            has few reviews. In future versions, we may get around this by using incorporating some dimension reduction to 
            the word count data (e.g. looking at cosine similarity after applying PCA).
        </p>
    <h4> Why raw counts? </h4>
        <p>
            While using raw word counts for scores is a convenient, simple choice, it also seems to give the most reasonable results for our case. The usual alternative would be to rescale the counts in a way that 
            gives more influence to rare words (for example, to consider term frequency-inverse document frequency). In practice these additional scalings don\'t seem to change things much for popular whiskies, but give strange results for whiskies with few reviews that happen to contain rare words. With td-idf, a single mention of \"carnations\" means that floral aromas figure dominantly in the flavor profile of the Benrinnes 14 Lady of the Glen 1999, a whisky known more for its winey, sweet, sherried taste. This effect is more common than one might expect; rare words are disporportionately likely to appear when a whisky has few reviews (perhaps because these whiskies are more expensive or rare, and so attract seasoned reviewers with sensitive palates and larger, more specialized vocabularies).
        </p>
    <h4> A few not-so-innocent assumptions </h4>
        <p>    
            As mentioned above, we DO normalize the eight-tuple associated to each whisky; the cosine similarity measure does this implicitly, and we incorporate this normalization into our visualizations. This means we can pick up the relative balance of flavors in a whisky, but cannot distinguish whether the entire flavor profile as a whole is bold or subdued. As a result, Johnnie Walker Black, an approachable blend with gentle smoke and notes of wood and fruit, is scored as similar to Ardbeg Alligator, a more aggressively peaty Islay which also scores high for fruitiness and woodiness. This issue is compounded by the fact that we ignore modifiers; the text \"faint peat\" is treated the same as \"this one is a peat monster\".
        </p>
    <h4> Possible extensions... </h4>
        <p>
            Since our data also contains ratings given by each reviewer, we plan to add a collaborative filtering component to the recommendation tool. We have also experimented with applying non-negative matrix factorization to the reviews. In addition to providing another dimension reduction technique for visualization, NMF actually generates \'topics\' from the text data. Interestingly, these roughly correspond to the eight flavor categories; there is almost always a peat-dominated NMF basis element, as well as a wine/sherry-dominated basis element. We are also considering experimenting with other topic modeling techniques, such as LDA.
        </p>
    
'    
))


})
    
   





