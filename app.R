#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(gggenomes)

data(package="gggenomes")

ggg <- gggenomes(
  genes = emale_genes, seqs = emale_seqs, links = emale_ava,
  feats = list(emale_tirs, ngaros=emale_ngaros, gc=emale_gc))

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("gggenomes Shiny demo"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("geneSize",
                        "Size of genes:",
                        min = 1,
                        max = 5,
                        value = 2),
            checkboxInput("showLinks", "Show links"),
            #checkboxInput("showGC", "Show GC content"),
            checkboxInput("showGeneLabels", "Show gene labels"),
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("gggPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$gggPlot <- renderPlot({
      p <- ggg |> 
        add_sublinks(emale_prot_ava) |>
        sync() + # synchronize genome directions based on links
        geom_feat(position="identity", size=6) +
        geom_seq()
      if(input$showLinks){
        p <- p + geom_link(data=links(2))
      }
      p <- p + geom_bin_label() +
        geom_gene(aes(fill=name), size=input$geneSize)
      if(input$showGeneLabels){
        p <- p + geom_gene_tag(aes(label=name), nudge_y=0.1, check_overlap = TRUE)
      }
      p <- p + geom_feat(data=feats(ngaros), alpha=.3, size=10, position="identity") +
        geom_feat_note(aes(label="Ngaro-transposon"), data=feats(ngaros),
                       nudge_y=.1, vjust=0)
      if(FALSE){#input$showGC){
        p <- p + 
          geom_wiggle(aes(z=score, linetype="GC-content"), feats(gc),
                     fill="lavenderblush4", position=position_nudge(y=-.2), height = .2)
      }
      p <- p +  
        scale_fill_brewer("Genes", palette="Dark2", na.value="cornsilk3")
      p
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
