# Download files from Zenodo
install.packages("zen4R")
library(zen4R)

# Connect anonymously for public records
zenodo <- ZenodoManager$new()

# Example DOI
doi <- "10.5281/zenodo.3378733"

# Create local download folder
dir.create("zenodo_downloads", showWarnings = FALSE)

# Download all files from the record
download_zenodo(path = "zenodo_downloads", doi)

# See what was downloaded
list.files("zenodo_downloads", full.names = TRUE)

# Example if one of the files is a CSV
dat <- read.csv("zenodo_downloads/myfile.csv")


