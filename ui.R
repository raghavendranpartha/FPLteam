shinyUI(fluidPage(
  titlePanel('Fantasy Premier League Team'),
  sidebarLayout(
    sidebarPanel(
      sliderInput("numgk","Number of Goalkeepers",0,2,2,step=1),
      sliderInput("numde","Number of Defenders",0,5,5,step=1),
      sliderInput("nummi","Number of Midfielders",0,5,5,step=1),
      sliderInput("numfw","Number of Forwards",0,3,3,step=1),
      textInput("money","Money available to buy players","100"),
      submitButton("Get my team!"),
      width=3
      ),
    mainPanel(
         tabsetPanel(
              tabPanel("Build your fantasy premier league team ",
                   h3("You want a team with:"),
                   verbatimTextOutput("inputs"),
                   h3("Result:"),
                   verbatimTextOutput("res"),
                   div(dataTableOutput("team"), style = "font-size:100%")
                   ),
              tabPanel("Documentation",
                   h3("Application usage:"),
                   p("This application is a guide for users who are football(soccer!) fans to build their own fantasy English Premier League team. Currently there are \nroughly 700 
footballers registered for one of the 20 different clubs participating in the English Premier League. Each player has a price in millions of pounds(£), that usually varies from 4 to 13, that is assigned to them by experts. Fantasy managers are initially given a sum of 100£ to build
their teams. Some of the several constraints that this team must follow are:"),
p("a. The squad must consist of 15 players, specifically:",br(),
"2 Goalkeepers",br(),
"5 Defenders",br(),
"5 Midfielders",br(),
"3 Forwards",br(),br(),
"b. The total value of your squad must not exceed 100 million.",br(),br(),"
c. Managers can select up to 3 players from a single Barclays Premier League team.",br(),br(),"

In each gameweek the fantasy football players will earn points based on their performance in the Barclays Premier League. There are additional rules that allow managers to
transfer players in and out of their team every week.",br(),"
The objective of a manager is thus to build a team that scores the highest points at the end of the season. The winner gets to take home a nice sum of £25,000!",br(),br(),"

The task of choosing an initial team thus lends itself nicely as a constraint optimization problem. We have to select 15 players from a pool of 700, based on the above constraints.
The current season is already underway with 8 of the 38 gameweeks completed. This application is designed to help an incoming manager select a team based on the performance 
of players in these 8 gameweeks.",br(),br(),"

The optimization problem is thus to choose a team of 15 players who have scored the highest points combined in the first 8 gameweeks, subject to the constraints a team must
follow (as discussed above). The player data is freely available at",
a("http://fantasy.premierleague.com/stats/elements/",href="http://fantasy.premierleague.com/stats/elements/"),". In this application, I solve this problem by implementing linear programming using the lpSolveAPI R package. The various constraints are mathematically encoded into the model, and finally it tries to come up 
with an optimal team subject to these constraints. The code is available at ",
a("https://github.com/raghavendranpartha/FPLteam",href="https://github.com/raghavendranpartha/FPLteam"),
br(),br(),"

The app additionally allows the user to select a custom team, bypassing the constraints on the default number of players in each position, the total money available etc. This
allows managers, based on their intuition, to choose players who might not be selected by the model if they have currently not scored significantly high points, but the manager feels must be present in their team. The model accordingly figures out the
best combination of players under the specific conditions that meets the needs of the users. If a user enters an unallowed value, such as insufficient money to build a team,
the app reports its failure to find a team.",br(),br(),"

The inputs of the app therefore are essentially the number of players in each position in the team, and the total money available to build the team. If the optimization is successful
the app returns the team. The various attributes of the players that are displayed are",br(),"Name: Player's name",br(),"Team: Premier league team to which they belong"
,br(),"Pos: Playing position",br(),"Price: Cost of the player",br(),"Total: Total points scored by the player")
                   )
              )
      
    )
    )
  )
  
        )