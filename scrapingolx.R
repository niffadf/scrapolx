library(rvest)
library(xml2)
library(stringr)
#Take all the url linkfrom 20 page Olx 
link<-"https://www.olx.co.id/mobil/jakarta-dki/?page="
getLINK<-function(links){
  news<-suppressWarnings(readLines(links))
  URL1<-grep("<a href=\"https://www.olx.co.id/iklan/",x=news,value=T)
  URL2<-gsub('.+href=\"',"",x=URL1)
  URL<-gsub('\" class=\"marginright5.+',"",x=URL2)
  return(data.frame(URL))
}
tautan<-c()
all<-list()
for (i in 1:20){
  tautan[i]<-paste0(link,i)
  all[[i]]<-getLINK(tautan[i])
}
df<-do.call(rbind.data.frame, all)
df<-unique(df)
df<-as.vector(df$URL)


#Take all the specification from the car 
cars<-function(link){
  webpage <- read_html(link)
  results <- webpage %>% html_nodes(".detail-extra")
  detail<- str_c(results[1] %>% html_nodes("span") %>% html_text(trim = TRUE), "")
  isi<- str_c(results[1] %>% html_nodes("a") %>% html_text(trim = TRUE), "")
  title<-webpage %>% html_nodes(".lheight28")
  title<-str_c(title[1] %>% html_text(trim = TRUE), "")
  price<-webpage %>% html_nodes(".xxxx-large")
  price<-str_c(price[1] %>% html_text(trim = TRUE), "")
  data.cars<-rbind.data.frame(isi)
  names(data.cars)<-as.vector(detail)
  data.cars$price<-price
  return(data.cars)}
temp<-lapply(df, cars)
#Change the list to data frame
datacars<-data.table::rbindlist(lapply(temp, as.data.frame.list), fill = TRUE)
datacars<-datacars[,-1]
#Clean the data 
clean<-datacars[complete.cases(datacars),]
clean<-clean[clean$price!="",]
clean$price<- sapply(clean$price, gsub, pattern='Rp', replacement="")
clean$price<- sapply(clean$price, gsub, pattern='\\.', replacement="")
#write.csv(clean,"datacarstdy.csv",row.names = F)
