shinyServer(function(input,output,session){
  amoney <- reactive({as.numeric(input$money)})
  result <- reactive({
    lpteam_2(playerdata, team="custom",
               numgk = input$numgk, 
               numde = input$numde,
               nummi = input$nummi, 
               numfw = input$numfw,  
               money=amoney())
        
  })
  typeres <- reactive({
       if(nrow(result())==input$numgk+input$numde+input$nummi+input$numfw){
            printresult=result()
            paste0("Here's your team!")           
       }else{
            printresult=data.frame()
            paste0("can't make a team with given options :( :(")            
       }
  })
  output$inputs <- renderText(paste0(input$numgk," goalkeeper(s)\n",
                                     input$numde," defender(s)\n",
                                     input$nummi," midfielder(s)\n",
                                     input$numfw," forward(s)"))
  output$res <- renderText(if(nrow(result())==input$numgk+input$numde+input$nummi+input$numfw){
       printresult=result()
       paste0("Here's your fantasy team! Money spent = ",sum(result()$Price))           
  }else{
       printresult=data.frame()
       paste0("can't make a team with given options :( :(")            
  })
 output$team <- renderDataTable({
      if(nrow(result())==input$numgk+input$numde+input$nummi+input$numfw){
       result()       
      }else{
       data.frame()       
      }
 })
 
}
)