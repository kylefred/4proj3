library(tidyverse)
library(stringr)

# store command line arguments
args = commandArgs(trailingOnly = TRUE)

# list of unique post-secondary institutions
inst.campus <- read.csv(args[2], header = T)

# make new table, turning important factors into characters
inst.campus <- inst.campus %>%
  transmute(ParentName = as.character(ParentName),
            LocationName = as.character(LocationName))

# use parentname if present, locationname otherwise
unique.inst <- inst.campus %>% 
  mutate(name = ifelse(ParentName == "-", LocationName, ParentName)) %>%
  .$name %>%
  unique()

# get author information line and title 
get.author.title <- function(file.p) {
  
  # will store author info line
  results <- c()
  
  # content of file
  file.con <- file(file.p, "r")
  
  # vector of file lines
  lines <- c()
  
  # regular expression to detect author info line
  author.info <- "Author information:"
  
  # store only author info line
  while ( TRUE ) {
    line = readLines(file.con, n = 1)
    if ( length(line) == 0 )
      break
    lines <- c(lines, line)
  }
  close(file.con)
  
  # usually line 2 is title, sometimes it's lines 3 if there's a conflict of interest statement
  abs.title <- lines[2]
  if ( str_detect(abs.title, "doi:") )
    abs.title <- lines[3]

  # combine author line and title
  results <- c(str_subset(lines, author.info),
               abs.title) 
  return(results)
}

# get collaborative institutions
get.collaborators <- function(file.p) {
  # uncleaned collaborator data
  raw.collabs <- get.author.title(file.p)
  
  # split author info at "," and ", "
  split.authors <- raw.collabs[1] %>% 
    str_split(", ?") %>%
    unlist()

  # raw data frame of possible collaborator names
  raw.df <- tibble(authors = split.authors,
                   # collapse on white space, since some names aren't spaced well
                   nospace = gsub(" ", "", split.authors, fixed = T),
                   title = raw.collabs[2])
  
  # data frame of post-secondary institutions
  df.inst <- tibble(institute = unique.inst, 
                    # collapse on white space, to inner join with above column
                    nospace = gsub(" ", "", unique.inst, fixed = T))
  
  # inner join to get simple collaborator institution names
  simple.tib <- inner_join(raw.df, df.inst, by = "nospace") %>% 
    select(institute, title)
  
  return(simple.tib)
}

# generate table of collabs for abstract at argument 1 location
collab.df <- get.collaborators( args[1] ) %>%
  # filtering out internal researchers, which will result in many empty output files
  filter(institute != "University of North Carolina at Chapel Hill")

collab.df <- collab.df$institute %>%
  unique() %>%
  tibble(institute = .) %>%
  mutate(title = collab.df$title[1])

# clear file before writing, since we will be appending
write.csv(collab.df, file = "collab.csv", row.names = F, col.names = F)
