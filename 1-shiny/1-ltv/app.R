library(yaml)
library(rlang)
library(tidyverse)
library(showtext)
showtext_auto()
source("func.R")
source("global.R")

opts <-
  ads_eda_ltv_course_type_hdf_tbl %>%
  select(course_type_detail) %>%
  distinct() %>%
  collect()

all_course <- set_choices(opts, "course_type_detail")

dim_ls <- list("来源业务线" = "l1_business_line",
               "来源SKU" = "l1_sku",
               "来源人群" = "l1_user_group",
               "来源渠道" = "l1_goal_channel_type",
               "来源运营团队" = "l1_goal_operation_group",
               "来源城市等级" = "l1_parents_city_level",
               "来源年级" = "l1_pay_grade"
)

dim_sele <- list("来源业务线" = "l1_business_line",
                 "来源SKU" = "l1_sku",
                 "来源人群" = "l1_user_group",
                 "来源渠道" = "l1_goal_channel_type",
                 "来源运营团队" = "l1_goal_operation_group",
                 "来源城市等级" = "l1_parents_city_level",
                 "来源年级" = "l1_pay_grade"
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
      
      hr(),
      
      checkboxInput(inputId = ("mannual_sele"),
                    label = "高级筛选",
                    value = FALSE),
      
      conditionalPanel(
        
        condition = paste0("input[\'", ('mannual_sele'), "\'] == 1"),
        
        selectInput(inputId = ("dims_sele"),
                    label = tags$small("筛选维度"),
                    choices = dim_sele,
                    selected = "l1_user_group",
                    multiple = TRUE),
        
        uiOutput(("dim_vars_sele"))
      ),
      
      hr(),
      
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
  
  tbl <- ads_eda_ltv_course_type_hdf_tbl
  
  map_ls <-
    con_tab[[id]] %>%
    setNames(names(.), .) %>%
    as.list()
  
  flt_sele <- reactive({
    flt_start_date <- input$pay_date[1] %>% as.character()
    flt_end_date <- input$pay_date[2] %>% as.character()
    flt_course <- input$course
    flt_day_num <- input$day_num
    
    tbl %>%
      filter(pay_date >= flt_start_date & pay_date <= flt_end_date) %>%
      filter(course_type_detail %in% flt_course) %>%
      mutate(datedif = as.numeric(datedif)) %>%
      filter(datedif <= flt_day_num) %>%
      mutate(total_gmv = as.double(total_gmv)) %>%
      mutate(user_cnt = as.numeric(user_cnt)) %>%
      collect()
  })
  
  vars_sele <- reactive({
    
    req(input$mannual_sele,input$dims_sele)
    
    flt_sele() %>%
      select(one_of(input$dims_sele)) %>%
      map(~ unique(.))
  })
  
  
  output$dim_vars_sele <- renderUI({
    
    req(vars_sele())
    
    exprs <-
      vars_sele() %>%
      imap(\(value, name) {
        
        value_c <- paste0('"', paste(value, collapse = '","'), '"')
        
        ns_name <- paste0(name, "_")
        
        str_glue('selectInput(
                              inputId = "{ns_name}",
                              label = tags$small(paste0(mapping_colname(map_ls, "{name}"), ":")),
                              choices = c({value_c}),
                              selected = c({value_c}),
                              multiple = TRUE)'
        )
        
      })
    
    tagList(map(exprs, ~ eval(parse_expr(.x))))
    
  })
  
  
  flt_sele_after <- reactive({
    
    flt_sele <-  flt_sele()
    
    if (input$mannual_sele) { # 仅当“高级筛选”复选框被选中时才应用筛选条件
      
      par_expr <-
        vars_sele() %>%
        imap(\(var, name) {
          
          if(!is.null(input[[paste0(name, "_")]])) { # 注意这里仍然使用带有 "_" 的 name
            c_vals <- paste0('c("', paste(input[[paste0(name, "_")]], collapse = '","'), '")')
            
            str_glue('filter({name} %in% {c_vals})')
          }
          
        }) %>%
        unlist()
      
      if(length(par_expr) != 0) {
        expr <- paste0(
          "flt_sele <- flt_sele %>% ",
          paste(par_expr, collapse = " %>% ")
        )
        
        eval(parse_expr(expr))
      } else { flt_sele <- flt_sele }
      
    }
    
    return(flt_sele)
    
  })
  
  
  vars <- reactive({
    
    req(input$dims)
    
    flt_sele_after() %>%
      select(one_of(input$dims)) %>%
      map(~ unique(.))
    
  })
  
  output$dim_vars <- renderUI({
    
    exprs <-
      vars() %>%
      imap(\(value, name) {
        
        value_c <- paste0('"', paste(value, collapse = '","'), '"')
        
        ns_name <- paste0(name, "__")
        
        str_glue('selectInput(
                              inputId = "{ns_name}",
                              label = tags$small(paste0(mapping_colname(map_ls, "{name}"), ":")),
                              choices = c({value_c}),
                              selected = c({value_c}),
                              multiple = TRUE)'
        )
        
      })
    
    tagList(map(exprs, ~ eval(parse_expr(.x))))
    
  })
  
  
  dat <- eventReactive(input$update,{
    
    flt_sele_after <- flt_sele_after()
    
    par_expr <-
      vars() %>%
      imap(\(var, name) {
        
        if(!is.null(input[[paste0(name, "__")]])) { # 注意这里仍然使用带有 "_" 的 name
          
          c_vals <- paste0('c("', paste(input[[paste0(name, "__")]], collapse = '","'), '")')
          
          str_glue('filter({name} %in% {c_vals})')
        }
        
      }) %>%
      unlist()
    
    if(length(par_expr) != 0) {
      expr <- paste0(
        "flt_sele_after <- flt_sele_after %>% ",
        paste(par_expr, collapse = " %>% ")
      )
      
      eval(parse_expr(expr))
    }
    
    
    flt_sele_after <-
      flt_sele_after %>%
      group_by(across(all_of(as.character(input$dims))),datedif) %>%
      summarise(total_gmv = sum(total_gmv),
                user_cnt = sum(ifelse(datedif == 0 & go_course_type_detail %in% input$course,user_cnt, 0))
                #.groups = "drop"
      ) %>%
      mutate(
        cum_gmv = cumsum(total_gmv),
        cum_user_cnt = cumsum(user_cnt),
        avg_gmv = cum_gmv / cum_user_cnt
      ) %>%
      ungroup() %>% 
      mutate(datedif=as.factor(datedif)) %>% 
      rowwise() %>%
      mutate(dims_tag = paste(across(all_of(input$dims)) %>% as.character(),
                              collapse = "-")) %>%
      mannual_dims_factor(., input$dims)
  })
  
  plt_proportion <- eventReactive(dat(), {
    
    dat <- dat()
    
    plt <-
      dat %>%
      ggplot(aes(x = datedif, y = avg_gmv)) +
      geom_line(aes(group = dims_tag,
                    col = dims_tag))+
      labs(x = "支付后天数",
           y = "人均GMV",
           col = NULL)
    
    mannual_dims_color(plt, input$dims, "col")
  })
  
  
  output$linePlot <- plotly::renderPlotly({
    
    plt <- plt_proportion()
    
    plt <- plt +
      scale_x_discrete(breaks = seq(0, input$day_num, by = 60))
    
    plotly::ggplotly(plt, tooltip = c("all"))
  })
  
}

shinyApp(ui = ui, server = server)