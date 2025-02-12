library(yaml)
library(rlang)
library(tidyverse)
library(showtext)
showtext_auto()

#source("../../update_mysql.R")
source("func.R")

tbl <- ads_eda_btc_business_regular_df

opts <- 
  tbl %>%
  select("user_group", "sku", "business_line", "goal_class_tag", "goal_operation_group") %>% 
  distinct() %>% 
  collect()

# 默认筛选维度
dim_ls <- c("用户群体" = "user_group", 
            "定标SKU" = "sku", 
            "定标业务线" = "business_line", 
            "定标班型" = "goal_class_tag",
            "定标团队" = "goal_operation_group",
            "定标核算组" = "goal_mkt_group", 
            "定标渠道类型" = "goal_channel_type",
            "续报老师组基地" = "renewal_counselor_group_city", 
            "续报老师组名称" = "renewal_counselor_group_name",
            "续报班级老师真名" = "renewal_staff_name",
            "续报老师组id" = "renewal_counselor_group_id",
            "渠道类型" = "channel_type_name",
            "渠道子类型" = "channel_subtype_name", 
            "渠道组名称" = "channel_group_name",
            "等待开课天数" = "diff_term_start",
            "是否重复购买" = "is_repeat_order",
            "支付年级" = "pay_grade", 
            "家长所在城市线级" = "city_level", 
            "家长所在城市" = "parents_city",
            "续报老师是否新人" = "is_new_renewal_staff",
            "本期次老师的班型是否与上期次一致" = "is_new_class_ct_business"
)

opts <-
  ads_eda_ltv_course_type_hdf %>%
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
  
  titlePanel("BTC"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(width = "100%",
                  inputId = "date_col",
                  label = "范围选择",
                  choices = list("按L1续报开始日期" = "l1_term_renewal_start_date",
                                 "按L1续报结束日期" = "l1_term_renewal_end_date"),
                  selected = "l1_term_renewal_start_date"),
      
      dateRangeInput(inputId = ns("flt_date"),
                     label = "",
                     start = Sys.Date() - 180,
                     end = Sys.Date()),
      
      hr(),
      
      selectInput(inputId = ns("user_group"),
                  label = "人群",
                  choices = set_choices(opts, "user_group"),
                  selected = "思维",
                  multiple = TRUE),
      selectInput(inputId = ns("sku"),
                  label = "SKU",
                  choices = set_choices(opts, "sku"),
                  selected = "S低",
                  multiple = TRUE),
      selectInput(inputId = ns("business_line"),
                  label = "业务线",
                  choices = set_choices(opts, "business_line"),
                  selected = "9.9",
                  multiple = TRUE),
      selectInput(inputId = ns("goal_operation_group"),
                  label = "团队",
                  choices = set_choices(opts, "goal_operation_group"),
                  selected = "9元团队",
                  multiple = TRUE),
      selectInput(inputId = ns("goal_class_tag"),
                  label = "班型",
                  choices = set_choices(opts, "goal_class_tag"),
                  selected = "常规学期",
                  multiple = TRUE),
      
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
  
  tbl <- ads_eda_ltv_course_type_hdf
  
  map_ls <-
    con_tab[[id]] %>%
    setNames(names(.), .) %>%
    as.list()
  
  # flt <- reactive({
  #   flt_start_date <- input$pay_date[1] %>% as.character()
  #   flt_end_date <- input$pay_date[2] %>% as.character()
  #   flt_course <- input$course
  #   flt_day_num <- input$day_num
  #
  #   tbl %>%
  #     filter(pay_date >= flt_start_date & pay_date <= flt_end_date) %>%
  #     filter(course_type_detail %in% flt_course) %>%
  #     mutate(datedif = as.numeric(datedif)) %>%
  #     filter(datedif <= flt_day_num) %>%
  #     mutate(total_gmv = as.double(total_gmv)) %>%
  #     mutate(user_cnt = as.numeric(user_cnt)) %>%
  #     collect()
  # })
  
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