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

write.csv(top10, file = "top10.csv", col.names = F, row.names = F, quote = F)

top10.titles <- full.table %>%
   filter(Collaborator == top10$Collaborator[1])

for (i in 2:10) {
   new.df <- full.table %>%
      filter(Collaborator == top10$Collaborator[i]) 
   top10.titles <- top10.titles %>%
      rbind(new.df)
}

write.csv(top10.titles, file = "titles.csv", row.names = F)
