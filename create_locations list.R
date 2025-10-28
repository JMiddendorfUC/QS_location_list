library(httr)
library(base64enc)
library(XML) 

my_id <- "insert your QuakeStudies usercode here"
my_key <- "insert your QuakeStudies API authentication token here"  

#convert credentials into the format needed for the query header
unencoded_credential <- charToRaw(paste(my_id, my_key, sep=":"))
base64_credential <- base64encode(unencoded_credential)
authorisation_header <- paste("Basic", base64_credential)
headers = c('authorization' = authorisation_header, 'content-type' = 'application/x-www-form-urlencoded')

#Import the list of addresses (generated via RISearch query, and including place, title and coverage)
qsr_list <- read.csv("~/R/projects/QS API locations list/data/addresses.csv") 

#####################
###TEST DATASET######
#If testing changes to the script, use this shorter set of addresses instead of qsr_list, 
#to avoid sending all 2457 requests to the API!
#1054 has both description and alternateName, 2227 only has description, 2656 has neither
qsr_test_list <- data.frame(
  place = c('qsr-place:1054','qsr-place:2227','qsr-place:2656'), 
  title = c('137 Cambridge Terrace', '121 Tuam Street', '1 Almont Gardens'),
  coverage = c('-43.5307,172.6326','-43.5351,172.6351','-43.5167,172.7202')
    )
####################

#Add required columns to the dataframe
full_address_list <- qsr_list #if testing, change this line to full_address_list <- qsr_test_list
full_address_list$alternateName <- ""
full_address_list$description <- ""
full_address_list$suburb <- ""
full_address_list$city <- ""
full_address_list$postcode <- ""

#Loop through the qsr-place numbers, sending a request for the RDF datastream of each
#and adding the fields to the dataframe (if they exist)
for(i in 1:nrow(full_address_list)) {
 #create the query URL
 qsr_place <- full_address_list$place[i]
 print(qsr_place)
 query_url <-paste("https://quakestudies.canterbury.ac.nz/fedora/objects",qsr_place,"datastreams/RDF/content?format=xml", sep="/")
 #call the API
 res <- VERB("GET", url = query_url, add_headers(headers))
 #extract the datastream as a dataframe
 body <- content(res, "text")
 body_data <- xmlParse(body)
 body_df <- xmlToDataFrame(nodes = getNodeSet(body_data,"//schema:Place"))
 #populate full_address_list
 if(!is.null(body_df$alternateName)){
   full_address_list$alternateName[i] <- body_df$alternateName
 }
 if(!is.null(body_df$description)){
   full_address_list$description[i] <- body_df$description
 }
 if(!is.null(body_df$suburb)){
   full_address_list$suburb[i] <- body_df$suburb
 }
 if(!is.null(body_df$addressLocality)){
   full_address_list$city[i] <- body_df$addressLocality
 }
 if(!is.null(body_df$postalCode)){
   full_address_list$postcode[i] <- body_df$postalCode
 }
}

#Export the list to a csv
write.csv(full_address_list, "~/R/projects/QS API locations list/data/full_address_list.csv")
