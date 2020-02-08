library(shiny)
library(shiny.router)
library(shinythemes)
library(DT)
library(shinyBS)
library(shinyjs)
library(shinyWidgets)
library(waiter)
library(pushbar)

#####################################

library(plotly)
library(ggExtra)
library(MSstatsQC)
library(MSstatsQCgui)
library(grid)
library(gridExtra)

if (!"package:MSstatsQCgui" %in% search())
  import_fs("MSstatsQCgui", incl = c("shiny","shinyBS","dplyr","plotly","RecordLinkage","ggExtra","gridExtra","grid"))

# RecordLinkageURL <- "https://cran.r-project.org/src/contrib/Archive/RecordLinkage/RecordLinkage_0.4-11.tar.gz"
# install.packages(RecordLinkageURL, repos=NULL, type="source")

library(RecordLinkage)



# Sourcing all modules pages to the main routing app.
source("src/module1-ui.R")
source("src/module1-server.R")
source("src/module2-ui.R")
source("src/module2-server.R")
source("src/module3-ui.R")
source("src/module3-server.R")



# Part of both pages.
home_page <- fluidPage( h1("Home Page"),
                        fluidRow(
                          column(4,wellPanel(includeMarkdown("www/mod1.md"))),
                          column(4,wellPanel(includeMarkdown("www/mod2.md"),actionButton("switch_mod2", "Launch Longitudinal Tool"))),
                          column(4,wellPanel(includeMarkdown("www/mod3.md")))
                        )
)



# Callbacks on the server side for the sample pages
home_server <- function(input, output, session) {
  observeEvent(input$switch_mod2, {
    if (!is_page("module2")) {
      change_page("module2")}
    })
}

# Create routing. We provide routing path, a UI as well as a server-side callback for each page.
router <- make_router(
  route("home", home_page, home_server),
  route("module2", mod2_ui, mod2_server)
)

# Create output for our router in main UI of Shiny app.
ui <- fluidPage(
  waiter::use_waiter(),
  pushbar::pushbar_deps(),
  shinyjs::useShinyjs(),
  router_ui()
)

# Plug router into Shiny server.
server <- function(input, output, session) {
 
  loading_screen <- tagList(
    h3("Initializing MSstatsQC", style = "color:white;"),
    br(),
    waiter::spin_flower(),
    div(style='padding:15vh')
  )
  
  loadScreen <- Waiter$new(html = loading_screen, color='#242424')
  
  router(input, output, session)
  
  loadScreen$show()
  
  Sys.sleep(2)
  
  loadScreen$update(html = tagList(img(src="logo.png", height=150),div(style='padding:15vh')))
  
  Sys.sleep(1)
  
  loadScreen$hide()
}

# Run server in a standard way.
shinyApp(ui=ui, server=server)
