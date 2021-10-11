################################################################################
# COLETA
################################################################################
library(rtweet)
library(dplyr)

#coloque entre aspas o diretorio onde deseja salvar os arquivos .RData com os 
#dados baixados da coleta do twitter
setwd("D:XXXXX")

#coloque os valores obtidos na plataforma  partir de desenvolvedores 
create_token(
    app = "XXXXXXXXXXXXXXX",
    consumer_key = "xXxXxXxxXXXxxXXxxXX" ,
    consumer_secret = "XX1XxXxxXXxXxx11xxxXXX1X111XX1xXxxXXxxX1X11Xxx1xXx",
    access_token = "1111111111111111111-XX11XX1X1xxxXxX11xxXxx1111XXxX",
    access_secret = "XXxxXXXXXXX1xXXXXxxXxXXx1xXXx1XxXx1xx1X1xXxxx")

# pegar o codigo woeid (Where On Earth IDentifier) para o brazil 
aux <- trends_available()
woeid_brazil <- aux$woeid[which(aux$name == "Brazil")]

# pegar os 50 trending topics do brazil
trends_brazil <- get_trends(woeid=woeid_brazil)

# filtrar os trending topics do brazil com hashtags 
trends_brazil_com_hashtags <- trends_brazil |> 
  filter(grepl("#", trend)) |> 
  select(trend) |> 
  pull()

# criar objeto da classe character com as hashtags separadas por OR
trends_para_consulta <- paste0(trends_brazil_com_hashtags, collapse=" OR ")

# consulta
tweets <- search_tweets(q=trends_para_consulta, 
                        n=18000, 
                        include_rts=FALSE, 
                        lang="pt")

################################################################################
# SELECAO DAS VARIAVEIS E SALVAR EM ARQUIVO
################################################################################

# selecionar variaveis de interesse
tweets <- tweets |> 
  select(DATE_TIME = created_at, 
         USERNAME = screen_name, 
         TEXT = text, 
         TEXT_WIDTH = display_text_width, 
         IS_QUOTE = is_quote)

# criar variaveis logicas para cada hashtags
presenca_hashtags <- 
   sapply(
      (1:length(trends_brazil_com_hashtags)),
      FUN = function(x){
         grepl(trends_brazil_com_hashtags[x],tweets$TEXT)
      }
      )

colnames(presenca_hashtags) <- trends_brazil_com_hashtags

tweets <- cbind(tweets, presenca_hashtags)

# salvar arquivo
filename <- paste0("TwitterData_", 
                   strftime(Sys.time(), format="%d%m%Y_%H"), 
                   "h.RData")

# salvar arquivo .RData
save(tweets, file=filename)
