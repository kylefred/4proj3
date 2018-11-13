library(tidyverse)
library(stringr)

# store command line arguments
args <- commandArgs(trailingOnly = TRUE)

# read table
full.table <- read.csv(args[1])
colnames(full.table) <- c("Collaborator","Title")

# rank collaborators by number of appearances
ranked.collabs <- full.table %>% 
   # needed because csvs were writtten with headers
   filter(Title != 'title') %>%
   group_by(Collaborator) %>%
   # get count for ranking purposes
   summarize(n = n()) %>%
   arrange(desc(n))

top10 <- ranked.collabs %>% 
   head(10)
   
#         titles = paste( as.character(Title) )) %>%
  # only interested in external collaborators
  # arrange(desc(n))

write.csv(top10, file = "ranked.csv", col.names = F, row.names = F, quote = F)
