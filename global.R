require(dplyr)
require(data.table)
require(XML)
require(httr)
require(tidyr)
require(lpSolveAPI)
require(shiny)

data <- data.frame()
url <- "http://fantasy.premierleague.com/stats/elements/?page=1"
nPages <- 10
for(page in c(1:nPages)){
  url<-paste0("http://fantasy.premierleague.com/stats/elements/?page=",page)
  html2=GET(url)
  cont =  content(html2, as= "text")
  ph = htmlParse(cont, asText = T)
  dd<-xpathSApply(ph,"//ismTable",xmlValue)
  dd<-readHTMLTable(ph)
  names(dd)[c(1:2)] <- c("t1","t2")  
  names(dd$t1)[c(1:2)] <- c("v1","v2")
  thisiter <- dd$t1 %>%
    select(c(Player:Total))
  if(page==1) data <- thisiter
  else data <- rbind_list(data,thisiter, use.names = T, fill =T)
}
pt <- "[0-9]+(\\.)[0-9]+"
poundSymbl <- gsub(pt,"",data$Price[[1]])
playerdata <- data %>%
  mutate(Selected = as.numeric(gsub("%","",Selected))) %>%
  mutate(Price = as.numeric(gsub(poundSymbl,"",Price))) %>%
  mutate(Total = as.numeric(Total)) %>%
  mutate(Pos = factor(Pos,levels=c("GKP","DEF","MID","FWD"))) %>%
  mutate(ID=seq(1,n()))

  

lpteam_2 <- function(pdata, team = "full", numgk = 2, numde = 5,nummi = 5, numfw = 3, money = 100){
  pdatanew <- pdata %>%
    filter(Total > 5) %>%
    mutate(gk = ifelse(Pos == "GKP",1,0)) %>%
    mutate(de = ifelse(Pos == "DEF",1,0)) %>%
    mutate(mi = ifelse(Pos == "MID",1,0)) %>%
    mutate(fw = ifelse(Pos == "FWD",1,0)) %>%
    mutate(present = 1)
  pdatafull <- pdatanew %>%
    spread(Team, present, fill = 0)
  nPls <- nrow(pdatafull)
  nTeams <- ncol(pdatafull)-ncol(pdata) - 3
  
  #team = "full" #full or main or subs
  if(team == "full") {
    ngks <- 2
    ndes <- 5
    nmis <- 5
    nfws <- 3    
  } else if(team == "custom"){
    ngks <- numgk
    ndes <- numde
    nmis <- nummi
    nfws <- numfw      
  }
  maxCost <- money
  
  lprec <- make.lp(0,nPls)
  #binary
  set.type(lprec, columns = 1:nPls, "binary")
  
  #costs
  #set.objfn(lprec, 0.25*pdatafull[["Total"]]+0.75*pdatafull[["Selected"]])
  set.objfn(lprec, pdatafull[["Total"]])
  add.constraint(lprec, xt = pdatafull$Price, "<=",maxCost)
  #N GKs = 2
  add.constraint(lprec, xt = pdatafull$gk, "=",ngks)
  #N DEFs = 5
  add.constraint(lprec, xt = pdatafull$de, "=",ndes)
  #N MIDs = 5
  add.constraint(lprec, xt = pdatafull$mi, "=",nmis)
  #N FWDs = 5
  add.constraint(lprec, xt = pdatafull$fw, "=",nfws)
  #teams
  for(ii in c(1:nTeams)) {
    add.constraint(lprec, xt = pdatafull[[10+ii]], "<=", 3)
  }
  lp.control(lprec, sense = "max")
  #write.lp(lprec, "fpl_lp.lp","lp")
  
  solve(lprec)
  
  inds <- as.logical(get.variables(lprec))
  arrange(pdata[inds,],Pos) %>%
       select(c(ID,Player,Team,Pos,Price,Total))
  
}