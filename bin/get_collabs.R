library(tidyverse)
library(stringr)

# store command line arguments
args = commandArgs(trailingOnly = TRUE)

# list of unique post-secondary institutions
inst.campus <- read.csv(args[2], header = T)
unique.inst <- inst.campus$ParentName %>% 
               unique() %>% 
               as.character()

# added several other common institutions, based on exploratory data analysis
# however, this is certainly not an exhaustive list
unique.inst <- c(unique.inst,
                 "National Institutes of Health",
                 "Brigham and Women's Hospital",
                 "Harvard T.H. Chan School of Public Health",
                 "Centers for Disease Control and Prevention",
                 "Baylor College of Medicine")
      
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
  
  # combine author line and title
  results <- c(str_subset(lines, author.info),
               lines[2]) 
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
nrows <- dim(collab.df)[1]

# clear file before writing, since we will be appending
close( file( "collab.csv", open="w" ) )

# check size because some tables are empty after filtering out UNC-CH
if (nrows >= 1)
  for (i in 1:nrows)
    write(paste0(unlist(collab.df[i, 1]), ",", collab.df[i, 2]),
                 "collab.csv", append = T)
