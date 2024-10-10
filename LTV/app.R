#######################################版本1
#source("update_data.R")
# library(tidyverse)
# library(showtext)
# showtext_auto()
# 
# set_choices <- \(tbl, col_name, desc=FALSE) {
#   tbl %>% 
#     pull(col_name) %>% 
#     unique() %>% 
#     na.omit() %>% 
#     sort(decreasing = desc)
# }
# 
# #head(result)
# opts <- 
#   result %>%
#   select("course_type_detail",  "l1_sku",  "l1_user_group", "l1_goal_channel_type") %>%
#   distinct() %>%
#   collect()
# 
# all_course <- set_choices(opts, "course_type_detail")
# all_sku <- set_choices(opts, "l1_sku")
# all_user_group <- set_choices(opts, "l1_user_group")
# all_channel_type  <- set_choices(opts, "l1_goal_channel_type")
# 
# 
# ui <- fluidPage(
# 
#   titlePanel("LTV"),
# 
#   sidebarLayout(
#     sidebarPanel(
#       # dateRangeInput(inputId = "pay_date",
#       #                label = "支付时间窗口",
#       #                start = Sys.Date() - 365,
#       #                end = Sys.Date()),
#       
#       selectInput(inputId = "course",
#                   label = "起始类型",
#                   choices = all_course,
#                   selected = "编程年课-首单",
#                   multiple = FALSE),
#       
#       # selectInput(inputId = "sku",
#       #             label = "来源SKU",
#       #             choices = all_sku,
#       #             selected = "S低",
#       #             multiple = TRUE),
#       
#       selectInput(inputId = "user_group",
#                   label = "用户群体",
#                   choices = all_user_group,
#                   selected = "思维",
#                   multiple = TRUE),
#       
#       # selectInput(inputId = "channel_type",
#       #             label = "定标渠道",
#       #             choices = all_channel_type,
#       #             selected = "BTC",
#       #             multiple = TRUE),
#       
#       numericInput(inputId = "day_num",
#                    label = "付费后天数",
#                    value = 360)
#     ),
# 
#     mainPanel(
#       #plotOutput("linePlot")
#       plotly::plotlyOutput("linePlot")
#     )
#   )
# )
# 
# server <- function(input, output) {
# 
#   tbl <- result
#   
#   # collect lazy table
#   flt <- reactive({
#     # flt_start_date <- input$pay_date[1] %>% as.character()
#     # flt_end_date <- input$pay_date[2] %>% as.character()
#     flt_course <- input$course
#     #flt_sku <- input$sku
#     flt_user_group <- input$user_group
#     #flt_channel_type <- input$channel_type
#     flt_day_num <- input$day_num
#     
#     tbl %>%
#       #filter(pay_date >= flt_start_date & pay_date <= flt_end_date) %>%
#       filter(course_type_detail %in% flt_course) %>%
#       #filter(l1_sku %in% flt_sku) %>%
#       filter(l1_user_group %in% flt_user_group) %>%
#       # filter(l1_goal_channel_type %in% flt_channel_type) %>%
#       filter(datedif <= flt_day_num) %>%
#       mutate(datedif = as_factor(datedif)) %>%
#       mutate(total_gmv = as.numeric(total_gmv)) %>%
#       mutate(user_cnt = as.numeric(user_cnt)) %>%
#       mutate(user_cnt = ifelse(datedif == 0,user_cnt,0)) %>%
#       collect()
#   })
# 
#   
#   plt_proportion <- eventReactive(flt(), {
#     
#     plt <-
#       flt() %>%
#       group_by(l1_user_group,datedif) %>%
#       summarise(sum_gmv=sum(total_gmv),
#                 sum_user_cnt = sum(user_cnt),
#                 .groups = "drop") %>%
#       group_by(l1_user_group) %>%
#       mutate(
#         cum_gmv = cumsum(sum_gmv),
#         cum_user_cnt = cumsum(sum_user_cnt),
#         avg_gmv = cum_gmv / cum_user_cnt
#       ) %>%
#       ggplot(aes(x = datedif, y = avg_gmv)) +
#       geom_line(aes(colour = l1_user_group , group =  l1_user_group))
#     
#     
#     })
# 
#   
#   output$linePlot <- plotly::renderPlotly({
#     
#     plt <- plt_proportion()
#     
#     plt <- plt + 
#            scale_x_discrete(breaks = seq(0, input$day_num, by = 60))
#     
#     plotly::ggplotly(plt, tooltip = c("all"))
#   })
#   
# }
# 
# shinyApp(ui = ui, server = server)








##################################版本2
# library(yaml)
# library(rlang)
# library(tidyverse)
# library(showtext)
# showtext_auto()
# 
# set_choices <- \(tbl, col_name, desc=FALSE) {
#   tbl %>% 
#     pull(col_name) %>% 
#     unique() %>% 
#     na.omit() %>% 
#     sort(decreasing = desc)
# }
# 
# mapping_colname <- function(ls, col) {
#   col <- as.character(col)
#   re <- names(ls)[ls == col]
#   
#   if (length(re) > 0) {
#     return(re)
#   } else {
#     return(col)
#   }
# }
# 
# 
# con_tab <- yaml::read_yaml("con_tab.yaml")
# 
# opts <- 
#   result %>%
#   select("course_type_detail",  "l1_sku",  "l1_user_group", "l1_goal_channel_type") %>%
#   distinct() %>%
#   collect()
# 
# all_course <- set_choices(opts, "course_type_detail")
# all_sku <- set_choices(opts, "l1_sku")
# all_user_group <- set_choices(opts, "l1_user_group")
# all_channel_type  <- set_choices(opts, "l1_goal_channel_type")
# 
# 
# dim_ls <- list("来源SKU" = "l1_sku",
#                "来源人群" = "l1_user_group",
#                "来源渠道" = "l1_goal_channel_type"
# )
# 
# ui <- fluidPage(
#   
#   titlePanel("LTV"),
#   
#   sidebarLayout(
#     sidebarPanel(
#       # dateRangeInput(inputId = "pay_date",
#       #                label = "支付时间窗口",
#       #                start = Sys.Date() - 365,
#       #                end = Sys.Date()),
#       
#       selectInput(inputId = "course",
#                   label = "起始类型",
#                   choices = all_course,
#                   selected = "编程年课-首单",
#                   multiple = FALSE),
#       
#       selectInput(inputId = "dims",
#                   label = "交叉维度",
#                   choices = dim_ls,
#                   selected = "l1_user_group",
#                   multiple = TRUE),
#       
#       uiOutput(("dim_vars")),
#       
#       numericInput(inputId = "day_num",
#                    label = "付费后天数",
#                    value = 360),
#       
#       actionButton(inputId = ("update"),
#                    label = "Update",
#                    width = "100%",
#                    class = "btn btn-default btn-lg")
# 
#     ),
#     
#     mainPanel(
#       plotly::plotlyOutput("linePlot")
#     )
#   )
# )
# 
# server <- function(input, output) {
#   
#   id <- "ltv"
#   
#   tbl <- result
#   
#   map_ls <-
#     con_tab[[id]] %>%
#     setNames(names(.), .) %>%
#     as.list()
#   
#   flt <- reactive({
#     # flt_start_date <- input$pay_date[1] %>% as.character()
#     # flt_end_date <- input$pay_date[2] %>% as.character()
#     flt_course <- input$course
#     flt_day_num <- input$day_num
#     
#     tbl %>%
#       #filter(pay_date >= flt_start_date & pay_date <= flt_end_date) %>%
#       filter(course_type_detail %in% flt_course) %>%
#       filter(datedif <= flt_day_num) %>%
#       mutate(datedif = as_factor(datedif)) %>%
#       mutate(total_gmv = as.numeric(total_gmv)) %>%
#       mutate(user_cnt = as.numeric(user_cnt)) %>%
#       mutate(user_cnt = ifelse(datedif == 0,user_cnt,0)) %>%
#       collect()
#   })
#   
#   vars <- reactive({
#     
#     req(input$dims)
#     
#     flt() %>%
#       select(one_of(input$dims)) %>%
#       map(~ unique(.))
#     
#   })
#   
#   output$dim_vars <- renderUI({
#     
#     exprs <-
#       vars() %>%
#       imap(\(value, name) {
#         
#         value_c <- paste0('"', paste(value, collapse = '","'), '"')
#         
#         ns_name <- paste0(id,"_",name, "_")
#         
#         str_glue('selectInput(
#                               inputId = "{ns_name}", 
#                               label = mapping_colname(map_ls, "{name}"), 
#                               choices = c({value_c}), 
#                               selected = c({value_c}), 
#                               multiple = TRUE)'
#                  )
#         
#       })
#     
#     tagList(map(exprs, ~ eval(parse_expr(.x))))
#     
#   })
#   
# 
# dat <- eventReactive(input$update,{
#   
#    flt <- flt() 
#   
#     # filter dims
#     par_expr <-
#       flt %>%
#       imap(\(var, name) {
#         
#         if(!is.null(input[[paste0(name, "_")]])) { # 注意这里仍然使用带有 "_" 的 name
#           
#           c_vals <- paste0('c("', paste(input[[paste0(name, "_")]], collapse = '","'), '")')
#           
#           str_glue('filter({name} %in% {c_vals})')
#         }
#         
#       }) %>%
#       unlist()
#     
#   if(length(par_expr) != 0) {
#     expr <- paste0(
#       "flt <- flt %>% ",
#       paste(par_expr, collapse = " %>% ")
#     )
#     
#     eval(parse_expr(expr))
#   }
#   
#     
#     flt <-
#       flt %>%
#       group_by(across(all_of(as.character(input$dims))),datedif) %>%
#       summarise(sum_gmv=sum(total_gmv),
#                 sum_user_cnt = sum(user_cnt),
#                 .groups = "drop") %>%
#       group_by(across(all_of(as.character(input$dims)))) %>%
#       mutate(
#         cum_gmv = cumsum(sum_gmv),
#         cum_user_cnt = cumsum(sum_user_cnt),
#         avg_gmv = cum_gmv / cum_user_cnt
#       ) %>% 
#       ungroup() 
# })
#   
#   
# plt_proportion <- eventReactive(dat(), {
#     
#   dat <- dat()
#     
#     plt <-
#       dat %>%
#       ggplot(aes(x = datedif, y = avg_gmv,
#                  colour = interaction(!!!syms(input$dims)), 
#                  group = interaction(!!!syms(input$dims)))
#             ) +
#       geom_line()
#   })
#   
#   
#   output$linePlot <- plotly::renderPlotly({
#     
#     plt <- plt_proportion()
#     
#     plt <- plt + 
#       scale_x_discrete(breaks = seq(0, input$day_num, by = 60))
#     
#     plotly::ggplotly(plt, tooltip = c("all"))
#   })
#   
# }
# 
# shinyApp(ui = ui, server = server)











##################################版本3
#source("update_data.R")
source("func.R")
library(yaml)
library(rlang)
library(tidyverse)
library(showtext)
showtext_auto()

opts <-
  result %>%
  select("course_type_detail",  "l1_sku",  "l1_user_group", "l1_goal_channel_type") %>%
  distinct() %>%
  collect()

all_course <- set_choices(opts, "course_type_detail")
all_sku <- set_choices(opts, "l1_sku")
all_user_group <- set_choices(opts, "l1_user_group")
all_channel_type  <- set_choices(opts, "l1_goal_channel_type")


dim_ls <- list("来源SKU" = "l1_sku",
               "来源人群" = "l1_user_group",
               "来源渠道" = "l1_goal_channel_type"
)

ui <- fluidPage(

  titlePanel("LTV"),

  sidebarLayout(
    sidebarPanel(
      dateRangeInput(inputId = "pay_date",
                     label = "支付时间窗口",
                     start = Sys.Date() - 365,
                     end = Sys.Date()),

      selectInput(inputId = "course",
                  label = "起始类型",
                  choices = all_course,
                  selected = "编程年课-首单",
                  multiple = FALSE),

      selectInput(inputId = "dims",
                  label = "交叉维度",
                  choices = dim_ls,
                  selected = "l1_user_group",
                  multiple = TRUE),

      uiOutput(("dim_vars")),

      numericInput(inputId = "day_num",
                   label = "付费后天数",
                   value = 360),

      actionButton(inputId = ("update"),
                   label = "Update",
                   width = "100%",
                   class = "btn btn-default btn-lg")

    ),

    mainPanel(
      plotly::plotlyOutput("linePlot")
    )
  )
)

server <- function(input, output) {

  id <- "ltv"

  tbl <- result
  
  map_ls <-
    con_tab[[id]] %>%
    setNames(names(.), .) %>%
    as.list()

  flt <- reactive({
    flt_start_date <- input$pay_date[1] %>% as.character()
    flt_end_date <- input$pay_date[2] %>% as.character()
    flt_course <- input$course
    flt_day_num <- input$day_num

    tbl %>%
      filter(pay_date >= flt_start_date & pay_date <= flt_end_date) %>%
      filter(course_type_detail %in% flt_course) %>%
      filter(datedif <= flt_day_num) %>%
      mutate(datedif = as_factor(datedif)) %>%
      mutate(total_gmv = as.numeric(total_gmv)) %>%
      mutate(user_cnt = as.numeric(user_cnt)) %>%
      mutate(user_cnt = ifelse(datedif == 0,user_cnt,0)) %>%
      collect()
  })

  vars <- reactive({

    req(input$dims)

    flt() %>%
      select(one_of(input$dims)) %>%
      map(~ unique(.))

  })

  output$dim_vars <- renderUI({

    exprs <-
      vars() %>%
      imap(\(value, name) {

        value_c <- paste0('"', paste(value, collapse = '","'), '"')

        ns_name <- paste0(id,"_",name, "_")

        str_glue('selectInput(
                              inputId = "{ns_name}",
                              label = mapping_colname(map_ls, "{name}"),
                              choices = c({value_c}),
                              selected = c({value_c}),
                              multiple = TRUE)'
        )

      })

    tagList(map(exprs, ~ eval(parse_expr(.x))))

  })


  dat <- eventReactive(input$update,{

    flt <- flt()

    par_expr <-
      flt %>%
      imap(\(var, name) {

        if(!is.null(input[[paste0(name, "_")]])) { # 注意这里仍然使用带有 "_" 的 name

          c_vals <- paste0('c("', paste(input[[paste0(name, "_")]], collapse = '","'), '")')

          str_glue('filter({name} %in% {c_vals})')
        }

      }) %>%
      unlist()

    if(length(par_expr) != 0) {
      expr <- paste0(
        "flt <- flt %>% ",
        paste(par_expr, collapse = " %>% ")
      )

      eval(parse_expr(expr))
    }


    flt <-
      flt %>%
      group_by(across(all_of(as.character(input$dims))),datedif) %>%
      summarise(sum_gmv=sum(total_gmv),
                sum_user_cnt = sum(user_cnt),
                .groups = "drop") %>%
      group_by(across(all_of(as.character(input$dims)))) %>%
      mutate(
        cum_gmv = cumsum(sum_gmv),
        cum_user_cnt = cumsum(sum_user_cnt),
        avg_gmv = cum_gmv / cum_user_cnt
      ) %>%
      ungroup()

  })


  plt_proportion <- eventReactive(dat(), {

    dat <- dat()

    plt <-
      dat %>%
      ggplot(aes(x = datedif, y = avg_gmv,
                 colour = interaction(!!!syms(input$dims)),
                 group = interaction(!!!syms(input$dims)))
      ) +
      geom_line()
  })


  output$linePlot <- plotly::renderPlotly({

    plt <- plt_proportion()

    plt <- plt +
      scale_x_discrete(breaks = seq(0, input$day_num, by = 60))

    plotly::ggplotly(plt, tooltip = c("all"))
  })

}

shinyApp(ui = ui, server = server)