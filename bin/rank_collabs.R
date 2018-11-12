library(tidyverse)
library(stringr)

# store command line arguments
args <- commandArgs(trailingOnly = TRUE)

# read table
full.table <- read.csv(args[1])
colnames(full.table) <- c("Collaborator","Title")

# rank collaborators by number of appearances
ranked.collabs <- full.table %>% 
  group_by(Collaborator) %>%
  summarize(n = n(), 
            titles = paste( as.character(Title) )) %>%
  # only interested in external collaborators
  arrange(desc(n))