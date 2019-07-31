# Voorbeelden gebruik van beta-versie CBS Open Data in R
# https://beta.opendata.cbs.nl
# Auteur: Jolien Oomens
# Centraal Bureau voor de Statistiek

# In dit voorbeeld worden cijfers over de opbrengst van toeristenbelasting per 
# jaar opgehaald, bewerkt en weergegeven in een grafiek.

library(tidyverse)
library(jsonlite)

get_odata <- function(targetUrl) {
  data <- data.frame()
  
  while(!is.null(targetUrl)){
    response <- fromJSON(url(targetUrl))
    data <- bind_rows(data,response$value)
    targetUrl <- response[["@odata.nextLink"]]
  }
  return(data)
}

# Bekijk welke metadata beschikbaar is
tableUrl <- "https://beta.opendata.cbs.nl/OData4/CBS/84120NED"
get_odata(tableUrl) %>% select(name,kind)

# Zoek de code van toeristenbelasting op
belastingCodes <- get_odata(paste0(tableUrl,"/BelastingenEnWettelijkePremiesCodes"))
belastingCodes %>% filter(str_detect(Title, "Toerist")) %>% select(Identifier,Title,Description)

# Haal de data op
targetUrl <- paste0(tableUrl,"/Observations?$filter=BelastingenEnWettelijkePremies eq 'A045081'")
data <- get_odata(targetUrl)

# Verwijder overbodige kolommen
data <- data %>% select(Perioden, Value)

# Definieer een functie voor datumconversie
# Dit is een aangepaste versie van de functie cbs_add_date_column uit cbsodataR
cbs_add_date_column <- function(x, date_type = c("Date", "numeric"), period_name="Perioden",...){
  if (!period_name %in% colnames(x)){
    warning(paste("No time dimension found called",period_name))
    return(x)
  }
  
  period <- x[[period_name]]
  PATTERN <- "(\\d{4})(\\w{2})(\\d{2})"
  
  year   <- as.integer(sub(PATTERN, "\\1", period))
  number <- as.integer(sub(PATTERN, "\\3", period))
  type   <- factor(sub(PATTERN, "\\2", period))
  
  # year conversion
  is_year <- type %in% c("JJ")
  is_quarter <- type %in% c("KW")
  is_month <- type %in% c("MM")
  
  
  # date
  date_type <- match.arg(date_type)
  
  if (date_type == "Date"){
    period <- as.POSIXct(character())
    period[is_year] <- ISOdate(year, 1, 1, tz="")[is_year]
    period[is_quarter] <- ISOdate(year, 1 + (number - 1) * 3, 1, tz="")[is_quarter]
    period[is_month] <- ISOdate(year, number, 1, tz="")[is_month]
    period <- as.Date(period)
  } else if (date_type == "numeric"){
    period <- numeric()
    period[is_year] <- year[is_year] + 0.5
    period[is_quarter] <- (year + (3*(number - 1) + 2) / 12)[is_quarter]
    period[is_month] <- (year + (number - 0.5) / 12)[is_month]
    if (all(is_year)){
      period <- as.integer(period)
    }
  }
  
  type1 <- factor(levels=c("Y","Q", "M"))
  type1[is_year] <- "Y"
  type1[is_quarter] <- "Q"
  type1[is_month] <- "M"
  type1 <- droplevels(type1)
  
  # put the column just behind the period column
  i <- which(names(x) == period_name)
  x <- x[c(1:i, i, i:ncol(x))]
  idx <- c(i+1, i+2)
  x[idx] <- list(period, type1)
  names(x)[idx] <- paste0(period_name, paste0("_", c(date_type,"freq")))
  x
}

# Datumconversie en selectie van jaarcijfers
data <- data %>% cbs_add_date_column() 
jaarcijfers <- data %>% filter(Perioden_freq == "Y")

# Plot de tijdreeks
ggplot(jaarcijfers, aes(x=Perioden_Date, y=Value)) +
  geom_line() + 
  ylim(0,250)+
  labs(title = "Opbrengst toeristenbelasting per jaar", x = "", y = "mln euro",
       caption = "Bron: CBS")
