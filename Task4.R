#Loading libraries
library(ggplot2, quietly = T)
library(dplyr, quietly = T)
library(caret, quietly = T)
library(arules, quietly = T)
library(arulesViz, quietly = T)
library(klaR, quietly = T)
library(RColorBrewer, quietly = T)
library(shiny, quietly = T)

#Loading transactional file (no attributes)
df <- read.transactions("data/ElectronidexTransactions2017.csv", 
                  format = "basket", 
                  sep=",", 
                  rm.duplicates=F,
                  cols = NULL)

#load product categories list
productCatList <- read.csv("data/ProductCategoryList.csv", sep=",")
#remove "" as they are not necessary and may give us wrong results
df@itemInfo$labels <- gsub("\"","",df@itemInfo$labels)
#add level1 to categories our products
df@itemInfo$level1 <- productCatList$ProductCategory

#find item that was consumed alone
oneCat <- df[which(size(df) == 1), ] #2163 items consumed alone

#summary giving us lots of good information
summary(df)

#plot items frequency
itemFrequencyPlot(df,
   topN=10,
   #col=brewer.pal(8,'Pastel2'),
   main='Absolute Item Frequency Plot',
   type="absolute",
   ylab="Item Frequency (Absolute)")

#least products in one cat transactions
barplot(sort(itemFrequency(oneCat, type="absolute"), decreasing=FALSE))

#run apriori with sup at 0.01 and conf at 0.5
basket_rules <- apriori(df, parameter = list(sup = 0.01,
                                             conf = 0.4,
                                             minlen = 2,
                                             target="rules"))
basket_rules
inspect(basket_rules)

#scatter plot of association rules we found use apriori
plot(basket_rules)

rules_conf <- sort (basket_rules, by="confidence", decreasing=TRUE) # 'high-confidence' rules.
inspect(head(rules_conf)) # show the support, lift and confidence for all rules

#Interactive Scatterplot
interactiveScatter <- plot(rules_conf, measure=c("support", "lift"), 
          shading = "confidence",
          interactive = TRUE)

#contingency table
tbl <- crossTable(df, sort=TRUE)
tbl[1:5,1:5]

#check for redundant rules (obsolute)
is.redundant(basket_rules)

#load external csv files 
changingConf <- read.csv("data/changingconf.csv", sep=",")
changingSupp <- read.csv("data/changingsupp.csv", sep=",")

#conf vs rules found line graph
ggplot(data = changingConf, aes(x=minConf, y=numRules))+
  geom_point()+
  geom_smooth(se=F, color="#2471A3")+
  ggtitle("Mean Confidence against Rules found (Min supp. = 0.1)")+
  xlab("Mean Conf") + 
  ylab("No. of Rules")+
  theme_bw()

#conf vs rules found line graph
ggplot(data = changingSupp, aes(x=minSupp, y=numRules))+
  geom_point()+
  geom_smooth(se=F, color="#2471A3")+
  ggtitle("Mean Support against Rules found (Min conf. = 0.4)")+
  xlab("Mean Supp") + 
  ylab("No. of Rules")+
  theme_bw()

#Finding the product categories in common between task 4 and task3
#Running the clustering algorithm, with support at 0.005 and confidence of 0.4
#we find that only 3 product types make the cut generating 336 rules
tempDesktop <- c("iMac", "Dell Desktop", "Lenovo Desktop Computer")
tempLaptop <- c("HP Laptop")
tempMonitors <- c("ViewSonic Monitor")

#Run apriori algorithm to find how many rules we have
#predicting next purchase is a Desktop
ruleGeneral <- apriori(df, parameter = list(sup = 0.005, 
                                          conf = 0.4, 
                                          minlen = 2, 
                                          maxlen = 20))

#Subsetting rules with a desktop in the right hand side 
#(means that people are more likely to purchase it based on thier current purchases)
ruleDesktop <- subset(ruleGeneral, subset = rhs %in% tempDesktop)
summary(ruleDesktop)

#remove redundant rules
ruleDesktop <- ruleDesktop[!is.redundant(ruleDesktop)]

#Sort by top 15 support/conf/lift
inspect(sort(ruleDesktop, decreasing = TRUE, by = "support")[1:15])
inspect(sort(ruleDesktop, decreasing = TRUE, by = "confidence")[1:15])
inspect(sort(ruleDesktop, decreasing = TRUE, by = "lift")[1:15])




#Subsetting rules with a Laptop in the right hand side 
#(means that people are more likely to purchase it based on thier current purchases)
ruleLaptop <- subset(ruleGeneral, subset = rhs %in% tempLaptop)

#remove redundant rules
ruleLaptop <- ruleLaptop[!is.redundant(ruleLaptop)]

summary(ruleLaptop)

inspect(sort(ruleLaptop, decreasing = TRUE, by = "support")[1:15])
inspect(sort(ruleLaptop, decreasing = TRUE, by = "confidence")[1:15])
inspect(sort(ruleLaptop, decreasing = TRUE, by = "lift")[1:15])



#Subsetting rules with a monitors in the right hand side 
#(means that people are more likely to purchase it based on thier current purchases)
ruleMonitors <- subset(ruleGeneral, subset = rhs %in% tempMonitors)

#remove redundant rules
ruleMonitors <- ruleMonitors[!is.redundant(ruleMonitors)]

summary(ruleMonitors)

#Sort by top 15 support/conf/lift
inspect(sort(ruleMonitors, decreasing = TRUE, by = "support"))
inspect(sort(ruleMonitors, decreasing = TRUE, by = "confidence"))
inspect(sort(ruleMonitors, decreasing = TRUE, by = "lift"))







#####
#aggregate by cats
dfByType <- aggregate(df, by= df@itemInfo$level1)

#plot items frequency for categories
itemFrequencyPlot(dfByType,
                  topN=10,
                  col=brewer.pal(8,'Pastel2'),
                  main='Absolute Item Frequency Plot',
                  type="absolute",
                  ylab="Item Frequency (Absolute)")

ruleByType <- apriori(dfByType, parameter = list(sup = 0.005, 
                                            conf = 0.4, 
                                            minlen = 3, 
                                            maxlen = 20))

ruleByBWCats <- subset(ruleByType, subset = rhs %in% c("Desktop", 
                                                       "Laptops", 
                                                       "Monitors",
                                                       "Accessories", 
                                                       "Computer Tablets",
                                                       "Printers"))

ruleByBWCats <- subset(ruleByType, subset = rhs %in% c("Desktop") & lift > 1.5)
#remove duplicates
ruleByBWCats <- ruleByBWCats[!is.redundant(ruleByBWCats)]
summary(ruleByBWCats)

#Sort by top 15 support/conf/lift to explore
inspect(sort(ruleByBWCats, decreasing = TRUE, by = "support")[1:15])
inspect(sort(ruleByBWCats, decreasing = TRUE, by = "confidence")[1:15])
inspect(sort(ruleByBWCats, decreasing = TRUE, by = "lift")[1:15])


#Notes: Bad support and medium confidence, only lift is good. Will be very rare for the rules to happen

ruleExplorer(rules_conf)

# Rules Visualization -----------------------------------------------------

plot(ruleDesktop, measure=c("support", "confidence"), shading="lift")
plot(ruleMonitors, measure=c("support", "confidence"), shading="lift")
plot(ruleLaptop, measure=c("support", "confidence"), shading="lift")
