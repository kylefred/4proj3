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
   summarize(collab.count = n()) %>%
   arrange(desc(collab.count))

# top 10 collaborators
top10 <- ranked.collabs %>% 
   head(10)

# titles for top10 collaborators
top10.titles <- full.table %>%
   filter(Collaborator == top10$Collaborator[1])

for (i in 2:10) {
   new.df <- full.table %>%
      filter(Collaborator == top10$Collaborator[i]) 
   top10.titles <- top10.titles %>%
      rbind(new.df)
}

# common words that don't convey much meaning
common.words <- c("of", "in", "the", "and", "for", "end", "to",
                  "a", "by", "with", "among", "patients", "from",
                  "10", "as", "patient", "after", "towards", "an",
                  "is", "between", "at", "do", "across")
# typos noticed in exploratory data analysis
typos = c("andrisk", "inyeast", "ofcolorectal", "humanglioma", 
          "thecanine", "integratinggenomic")
# list of all words to ignore
ignore = c(common.words, typos)

top10.titles$Title <- as.character(top10.titles$Title)

# get collapsed titles
collected.titles <- top10.titles %>% 
  group_by(Collaborator) %>%
  summarise(all = paste(Title, collapse = " "),
            collab.count = n()) 

# get 10 most common words at collab.ind
get.common.words <- function(collab.ind) {
  # generate vector of words in collapsed title
  words <- gregexpr("[a-zA-Z0-9'\\-]+", collected.titles$all[collab.ind])
  words <- regmatches (collected.titles$all[collab.ind], words) %>%
    unlist() %>% tolower()  
  
  # ignore selected words, see above
  words <- which(!(words %in% ignore)) %>%
    words[.]
  
  # get 10 most common words
  common.df <- tibble(words = words) %>%
    group_by(words) %>%
    summarise(word.count = n()) %>%
    arrange(desc(word.count)) %>%
    mutate(Collaborator = collected.titles$Collaborator[collab.ind]) %>%
    .[1:10,]
  return(common.df)
}

# table for all common words
total.df <- get.common.words(1)

for (i in 2:10) {
  total.df <- total.df %>%
    rbind(get.common.words(i))
}

# join with table of collaborator totals
total.df <- total.df %>%
  left_join(collected.titles, by = 'Collaborator') %>%
  select(Collaborator, collab.count, words, word.count)

# output the file
write.csv(total.df, file = "final.csv")
