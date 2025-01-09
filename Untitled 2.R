setwd("~/Downloads")
library(stringr)
library(tidyr)
cb <- read.csv('Case Study - Clearbit Cleaning.csv')
#colnames(cb)
#summary(cb)

#has data as factors
HasData <- function(column) { column <- ifelse(is.na(column),FALSE,TRUE)}

factor_list <- c(
                  "company_site_phone_numbers"
                 ,"company_site_email_addresses"
                 ,"company_logo"
                 ,"company_facebook_handle"
                 ,"company_linkedin_handle"
                 ,"company_twitter_handle"
                 ,"company_twitter_id"
                 ,"company_twitter_avatar"
                 ,"company_crunchbase_handle"
                 ,"company_twitter_site"
                 ,"company_ticker"
                 ,"company_description"
                 ,"company_twitter_bio"
                 ,"company_identifiers_us_ein"   
                 ,"company_phone"
                 ,"company_parent_domain")
factorize <- cb[ , which(names(cb) %in% factor_list) ]

factorize<-apply(factorize,2,HasData)

others<- cb[ , which(!names(cb) %in% factor_list) ]
cb <- cbind(factorize,others)


#count commas for number of aliases
cb$company_domain_aliases <- str_count(cb$company_domain_aliases, ",")


parse
cb$company_tags
company_tech  

split <- do.call("rbind", strsplit(as.character(cb$company_tags), ","))
stack <- sort(rbind(split[,1],split[,2],split[,3],split[,4],split[,5],split[,6],split[,7],split[,8],split[,9]))
unq <- unique(stack)
one_hot <- matrix(nrow(cb),length(unq))
colnames(one_hot) <- sub(paste(unq, collapse = "\",\""),"\\","")


lapply(strsplit(as.character(cb$company_tags), ","), paste, collapse="")
apply(cb$company_tags, 1, strsplit)
matrix(nrow(cb),length())

#remove columns with only one level

