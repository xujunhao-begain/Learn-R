#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#
library(shiny)
#闪亮的应用程序包含在名为 app.R 的单个脚本中。脚本 app.R 生活在一个目录中
#（例如， newdir/ ），并且可以使用 runApp("newdir") 运行应用程序
#app.R 有三个组成部分：
#用户界面对象:应用程序布局和外观
#一个服务器函数：构建应用程序所需的指令
#对 shinyApp 函数的调用：运行应用程序

#您可以创建一个闪亮的应用程序，只需创建一个新的目录并在其中保存一个 app.R 文件
#建议每个应用程序都应位于其独特的目录中,如果你的 Shiny 应用程序位于名为 my_app 
#的目录中，使用以下代码运行它runApp("my_app")

# library(shiny)
# 
# ui <- fluidPage(
# 
#     titlePanel("Old Faithful Geyser Data"),
# 
#     sidebarLayout(
#         sidebarPanel(
#             sliderInput("bins",
#                         "Number of bins:",
#                         min = 1,
#                         max = 50,
#                         value = 30)
#         ),
# 
#         mainPanel(
#            plotOutput("distPlot")
#         )
#     )
# )
# 
# # Define server logic required to draw a histogram
# server <- function(input, output) {
# 
#     output$distPlot <- renderPlot({
#         x    <- faithful[, 2]
#         bins <- seq(min(x), max(x), length.out = input$bins + 1)
# 
#         hist(x, breaks = bins, col = 'darkgray', border = 'white',
#              xlab = 'Waiting time to next eruption (in mins)',
#              main = 'Histogram of waiting times')
#     })
# }
# 
# shinyApp(ui = ui, server = server)

#runApp("Rshiny",display.mode = "showcase") 同时显示app.R 脚本与应用

#内置shiny
# runExample("01_hello")      # a histogram
# runExample("02_text")       # tables and data frames
# runExample("03_reactivity") # a reactive expression
# runExample("04_mpg")        # global variables
# runExample("05_sliders")    # slider bars
# runExample("06_tabsets")    # tabbed panels
# runExample("07_widgets")    # help text and submit buttons
# runExample("08_html")       # Shiny app built from HTML
# runExample("09_upload")     # file upload wizard
# runExample("10_download")   # file download wizard
# runExample("11_timer")      # an automated timer

#runExample("01_hello",display.mode = "showcase")  同时显示app.R 脚本与应用



#--添加控制控件--#
#Rshiy自带一系列预构建的控件，每个控件都由一个透明命名的 R 函数创建
#例如，闪亮提供了一个名为 actionButton 的函数，用于创建操作按钮，以及一个名为 
#sliderInput 的函数，用于创建滑块

# actionButton	      操作按钮
# checkboxGroupInput	一组复选框
# checkboxInput       一个单选框
# dateInput           一个日历来辅助选择日期
# dateRangeInput  	  一对用于选择日期范围的日历
# fileInput           文件上传控制向导
# helpText	          帮助文本，可以添加到输入表单中
# numericInput	      输入数字的字段
# radioButtons	      一组无线电按钮
# selectInput	        一个包含可供选择选项的框
# sliderInput	        滑块
# submitButton        提交按钮
# textInput	          输入文本的字段

#actionButton("action", label = "Action")
#名称是action，该控件的标识
#标签是Action，该控件在ui界面显示的名称

#剩余的参数因控件而异，取决于控件需要完成其工作的具体需求。
#它们包括初始值、范围和增量等。


# library(shiny)
# 
# # Define UI ----
# ui <- page_fluid(
#   titlePanel("Basic widgets"),
#   layout_columns(
#     col_width = 3,
#     card(
#       card_header("Buttons"),
#       actionButton("action", "Action"),
#       submitButton("Submit")
#     ),
#     card(
#       card_header("Single checkbox"),
#       checkboxInput("checkbox", "Choice A", value = TRUE)
#     ),
#     card(
#       card_header("Checkbox group"),
#       checkboxGroupInput(
#         "checkGroup",
#         "Select all that apply",
#         choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3),
#         selected = 1
#       )
#     ),
#     card(
#       card_header("Date input"),
#       dateInput("date", "Select date", value = "2014-01-01")
#     ),
#     card(
#       card_header("Date range input"),
#       dateRangeInput("dates", "Select dates")
#     ),
#     card(
#       card_header("File input"),
#       fileInput("file", label = NULL)
#     ),
#     card(
#       card_header("Help text"),
#       helpText(
#         "Note: help text isn't a true widget,",
#         "but it provides an easy way to add text to",
#         "accompany other widgets."
#       )
#     ),
#     card(
#       card_header("Numeric input"),
#       numericInput("num", "Input number", value = 1)
#     ),
#     card(
#       card_header("Radio buttons"),
#       radioButtons(
#         "radio",
#         "Select option",
#         choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3),
#         selected = 1
#       )
#     ),
#     card(
#       card_header("Select box"),
#       selectInput(
#         "select",
#         "Select option",
#         choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3),
#         selected = 1
#       )
#     ),
#     card(
#       card_header("Sliders"),
#       sliderInput(
#         "slider1",
#         "Set value",
#         min = 0,
#         max = 100,
#         value = 50
#       ),
#       sliderInput(
#         "slider2",
#         "Set value range",
#         min = 0,
#         max = 100,
#         value = c(25, 75)
#       )
#     ),
#     card(
#       card_header("Text input"),
#       textInput("text", label = NULL, value = "Enter text...")
#     )
#   )
# )
# 
# # Define server logic ----
# server <- function(input, output) {
#   
# }
# 
# # Run the app ----
# shinyApp(ui = ui, server = server)

#Shiny 小部件画廊https://github.com/rstudio/shiny-examples/tree/main提供模板，
#您可以使用这些模板快速将小部件添加到您的 Shiny 应用程序中。




#--响应式输出--#
#响应式输出会在用户切换控件时自动响应
# Output function 输出函数	  Creates 创建
# dataTableOutput	           DataTable 数据表
# htmlOutput	               raw HTML 原始 HTML
# imageOutput	               image 图片
# plotOutput	               plot 绘图
# tableOutput	               table 表格
# textOutput	               text 文本
# uiOutput	                 raw HTML 原始 HTML
# verbatimTextOutput	       text 文本

#将 R 对象添加到 UI,告诉 Shiny 您的对象应显示在哪里
# ui <- page_sidebar(
#   title = "censusVis",
#   sidebar = sidebar(
#     helpText(
#       "Create demographic maps with information from the 2010 US Census."
#     ),
#     selectInput(
#       "var",
#       label = "Choose a variable to display",
#       choices = 
#         c("Percent White",
#           "Percent Black",
#           "Percent Hispanic",
#           "Percent Asian"),
#       selected = "Percent White"
#     ),
#     sliderInput(
#       "range",
#       label = "Range of interest:",
#       min = 0, 
#       max = 100, 
#       value = c(0, 100)
#     )
#   ),
#   textOutput("selected_var")
# )


#告诉 Shiny 如何构建该对象
#server 函数构建了一个名为 output 的类似列表的对象
#每个 R 对象都需要在output中拥有自己的条目
#在 server 函数中定义一个新的元素 output 来创建一个条目
#元素名称应与在 ui 中创建的响应式元素的名称匹配

#output$selected_var 匹配了 textOutput("selected_var") 中的 ui
# server <- function(input, output) {
#   
#   output$selected_var <- renderText({
#     "You have selected this"
#   })
#   
# }

#每个指向 output 的条目应包含 Shiny 的 render* 函数之一的输出。
#这些函数捕获一个 R 表达式，并对表达式进行一些轻量级预处理。
# render function 渲染函数	creates 创建
# renderDataTable	          DataTable 数据表
# renderImage             	images (saved as a link to a source file) 
#                           图片（以指向源文件的链接保存）
# renderPlot	              plots 图表
# renderPrint	              any printed output 任何打印输出
# renderTable	              data frame, matrix, other table like structures
#                           数据框，矩阵，其他表格结构
# renderText	              character strings 
#                           字符字符串
# renderUI	                a Shiny tag object or HTML
#                           一个 Shiny 标签对象或 HTML
#这个 R 表达式就像一组指令，你将这些指令交给 Shiny 以备后用
#Shiny 在你首次启动应用时运行这些指令，然后每当 Shiny 需要更新你的对象时
#它会重新运行这些指令


#--小控件--#
#应用有两个小部件，一个名为 "var" ，另一个名为 "range" 
#"var" 和 "range" 的值将被保存在 input 中作为 input$var 和 input$range
#shiny会自动使用 input 值的对象变为响应式
#例如，下面的 server 函数通过调用下拉框组件的值来构建文本，从而创建一个响应式的文本行
# server <- function(input, output) {
#   
#   output$selected_var <- renderText({
#     paste("You have selected", input$var)
#   })
#   
# }
#在命令行中运行 runApp("census-app", display.mode = "showcase") 来启动Shiny 应用

#--本节总结--#
# 在 ui 中使用 *Output 函数将响应式对象放入您的 Shiny 应用中
# 在 server 中使用 render* 函数来告诉 Shiny 如何构建你的对象
# 在每个 render* 函数中，将 R 表达式用花括号 {} 包围
# 将您的 render* 表达式保存在 output 列表中，为应用中的每个响应式对象保留一个条目
# 在 render* 表达式中包含一个 input 值以创建响应性



##--响应表达式--##
# 响应式表达式是一种 R 表达式，它使用控件输入并返回一个值
# 响应式表达式会在原始控件发生变化时更新此值
# 要创建一个响应式表达式，请使用 reactive 函数，该函数接受一个由花括号包围的 
# R 表达式（就像 render* 函数一样）

# 响应式表达式比普通的 R 函数聪明一点。它们会缓存其值，并知道其值是否过时
# 这意味着什么？当你第一次运行响应式表达式时，表达式会将结果保存在计算机的内存中
# 下一次调用响应式表达式时，它可以返回这个保存的结果而无需进行任何计算
# （这将使您的应用程序更快）
# 响应式表达式仅在知道结果为最新时返回保存的结果。如果响应式表达式了解到结果已过时
# （因为某个控件已更改），表达式将重新计算结果。然后返回新结果并保存一个新副本
# 响应式表达式将使用此新副本，直到它本身也变得过时

# 总结
# 响应式表达式在您第一次运行时保存其结果
# 下一次调用反应式表达式时，它会检查保存的值是否过时（即，它所依赖的控件是否发生变化）
# 如果值过时，响应式对象将重新计算它（然后保存新的结果）
# 如果值是最新状态，响应式表达式将返回保存的值，而不进行任何计算

# dataInput <- reactive({
#   getSymbols(input$symb, src = "yahoo",
#              from = input$dates[1],
#              to = input$dates[2],
#              auto.assign = FALSE)
# })
# 
# output$plot <- renderPlot({
#   chartSeries(dataInput(), theme = chartTheme("white"),
#               type = "line", log.scale = input$log, TA = NULL)
# })

#--**注意执行顺序**--#
# 当您点击“在对数尺度上绘制 y 轴”， input$log 将发生变化， renderPlot 将重新执行
# renderPlot 将调用 dataInput()
# dataInput 将检查 dates 和 symb 组件是否未改变
# 将返回其保存的股票价格数据集，而不从雅虎重新获取数据
# renderPlot 将重新绘制图表以使用正确的轴


##依赖项
#如果用户在 symb 小部件中更改了股票代码，会怎样？
#这将使 renderPlot 创建的图表过时，但 renderPlot 不再调用 input$symb 。
#Shiny 是否知道 input$symb 已将图表标记为过时？
#是的，Shiny 会知道并重新绘制图表。Shiny 会跟踪某个 output 对象依赖于哪些反应式
#表达式，以及哪些控件输入。如果需要，Shiny 会自动重建对象对象的 render* 函数中的 
#input 值发生变化，或对象的 render* 函数中的响应式表达式变得过时
#将响应式表达式视为连接 input 值与 output 对象的链条中的链接。
#链条中的对象将响应链中下游任何地方所做的更改。
#（你可以打造一条长链，因为响应式表达式可以调用其他响应式表达式。）
#仅在 reactive 或 render* 函数内调用响应式表达式。为什么？只有这些 R 函数具备
#处理响应式输出的能力，这种输出可能会无预警地改变。
#实际上，Shiny 会阻止您在这些函数之外调用响应式表达式。


#--**总结**--#
#通过使用响应式表达式对代码进行模块化来使你的应用更快
#响应式表达式获取 input 值，或者从其他响应式表达式获取值，并返回新值
#响应式表达式保存其结果，并且只有当其输入发生变化时才会重新计算
#使用 reactive({ }) 创建响应式表达式
#调用响应式表达式，以表达式的名称后跟括号的形式 ()
#仅在其他响应式表达式或 render* 函数内部调用响应式表达式





#--**开始使用**--#
#一个看板应该包括：
#应用的标题
#一系列输入：这些输入中的一些使用下拉菜单进行选择，一些是滑块，一些允许文本输入
#,一些是操作按钮
#一些输出: 用户可以互动更新的图表输出,随着其更新的文本输出,一个数据表格输出，同时也会随着这些内容更新

#shiny的结构
#1. 用户界面（UI） 用户界面是用户与 Shiny 应用交互的界面。它通常由一个或多个 HTML
#元素组成，如`fluidPage`、`sidebarLayout`、`dashboardLayout`等。用户界面定义了应
#用的外观和布局，包括标题、导航栏、侧边栏、主内容区域等。 
#2. 服务器逻辑（server） 服务器逻辑处理用户输入并生成响应。它接收用户界面传递的数
#据，执行必要的计算或数据处理，然后将结果返回给用户界面。服务器逻辑通常使用 R 语
#言编写，但也可以使用其他语言。 
#3. 数据源（data） 数据源是 Shiny 应用的数据输入。这可以是本地文件、数据库、API 
#调用等。数据源定义了应用如何获取和使用数据。 
#4. 交互（interaction） 交互是用户界面与服务器之间的通信。用户界面通过发送事件
#（如按钮点击、滑块移动等）触发服务器逻辑，服务器逻辑响应这些事件并更新用户界面。
#5. 输出（output） 输出是服务器逻辑生成的结果，它更新用户界面的特定部分。输出可以
#是任何类型的 HTML 元素，如文本、图像、表格等。 
#总结 Shiny 应用的结构包括用户界面、服务器逻辑、数据源、交互和输出。通过这些组件
#的组合，开发者可以创建动态、交互式的 Web 应用，这些应用可以从数据中提取见解并提
#供用户友好的界面。

# Load packages
library(shiny)
library(bslib)
library(ggplot2)

# Get the data
# file <- "https://github.com/rstudio-education/shiny-course/raw/main/movies.RData"
# destfile <- "movies.RData"
# 
# download.file(file, destfile)

# Load data
load("movies.RData")

# Define UI
ui <- page_sidebar(
  sidebar = sidebar(
    # Select variable for y-axis
    selectInput(
      inputId = "y",
      label = "Y-axis:",
      choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"),
      selected = "audience_score"
    ),
    # Select variable for x-axis
    selectInput(
      inputId = "x",
      label = "X-axis:",
      choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"),
      selected = "critics_score"
    )
  ),
  # Output: Show scatterplot
  card(plotOutput(outputId = "scatterplot"))
)

# Define server
server <- function(input, output, session) {
  output$scatterplot <- renderPlot({
    ggplot(data = movies, aes_string(x = input$x, y = input$y)) +
      geom_point()
  })
}

# Create a Shiny app object
shinyApp(ui = ui, server = server)













