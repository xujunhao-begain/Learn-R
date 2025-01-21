library(shiny)
library(shinyjs)
library(DT)
library(rlang)
library(tidyverse)
library(yaml)
#source("../../update_mysql.R")

con_tab <- yaml.load_file("../../con_tab.yaml")

# 提取 calculated_metrics 并将其转为 named list
calculated_metrics_ls <- setNames(
  unlist(con_tab$calculated_metrics),
  names(unlist(con_tab$calculated_metrics))
)

calculated_metrics_ls[["加微率"]]

set_choices <- \(tbl, col_name, desc=FALSE) {
  tbl %>% 
    pull(col_name) %>% 
    unique() %>% 
    na.omit() %>% 
    sort(decreasing = desc)
}

rename_col_name <- function(data, rename_map){
  # 检查数据中是否存在需要重命名的列名
  existing_cols <- colnames(data)
  rename_cols <- names(rename_map)
  valid_rename_cols <- intersect(existing_cols, rename_cols)
  
  # 将重命名映射列表转换为命名向量
  rename_map <- unlist(rename_map)
  
  # 如果存在需要重命名的列名，则进行重命名
  if (length(valid_rename_cols) > 0) {
    data <- data %>% 
      rename_with(~ rename_map[.], all_of(valid_rename_cols))
  }
  
  return(data)
}

mapping_colname <- function(ls, col) {
  col <- as.character(col)
  re <- names(ls)[ls == col]
  
  if (length(re) > 0) {
    return(re)
  } else {
    return(col)
  }
}


tbl <- ads_l1_eda_multidimensional_indicators_df

opts <- 
  tbl %>%
  select("user_group", "sku", "business_line", "goal_class_tag", "goal_operation_group") %>% 
  distinct() %>% 
  collect()

# 默认筛选维度
dim_ls <- c("学期名称" = "term",
            "学期id"    = "term_id",
            "订单支付月" = "pay_month",                  
            "学期开始月" = "term_start_month",
            "用户群体" = "user_group", 
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

# 展示的指标
metrics_ls <- list(
  "招生人数" = "enroll",
  "加微相关" = list("加微人数(累计当前)" = "wx_add", "加微人数(T3)" = "wx_add_t3", "加微人数(首课解锁前)" = "wx_add_ahead_unlocked1"),
  "到课相关" = list("到准备课人数(首课解锁前)" = "attend0_ahead_unlocked1", "到1课人数(T6)" = "attend1_t6",
                "到2课人数(T6)" = "attend2_t6", "到3课人数(T6)" = "attend3_t6", "到4课人数(T6)" = "attend4_t6",
                "到5课人数(T6)" = "attend5_t6", "到末课人数(T6)" = "attend_last_t6"),
  "完课相关" = list("完1课人数(T6)" = "finish1_t6", "完2课人数(T6)" = "finish2_t6", "完3课人数(T6)" = "finish3_t6",
                "完4课人数(T6)" = "finish4_t6", "完5课人数(T6)" = "finish5_t6", "完末课人数(T6)" = "finish_last_t6"),
  "续报相关" = list("累计续报人数" = "renewal_acc", "首日续报人数" = "renewal_t0", "2日续报人数" = "renewal_t1",
                "3日续报人数" = "renewal_t2", "4日续报人数" = "renewal_t3", "末日续报人数" = "renewal_lst")
)

# calculated_metrics_ls <- list(
#   "首日续报率" = "首日续报率 = round(sum(renewal_t0) / sum(enroll),2)" ,
#   "二日续报率" = "二日续报率 = round(sum(renewal_t1) / sum(enroll),2)" ,
#   "三日续报率" = "三日续报率 = round(sum(renewal_t2) / sum(enroll),2)" ,
#   "四日续报率" = "四日续报率 = round(sum(renewal_t3) / sum(enroll),2)" ,
#   "累计续报率" = "累计续报率 = round(sum(renewal_acc) / sum(enroll),2)"
# )

ui <- fluidPage(
  
  useShinyjs(), 

  # 在 UI 中添加自定义 CSS 样式
  tags$head(
    tags$style(HTML("
      .custom-date-range .form-control {
        height: 34px !important;
        line-height: 34px;
      }
    "))
  ),


  # 页面标题
  titlePanel("多维指标"),

  hr(),

  fluidRow(
    actionButton("toggle3", label = "范围筛选", class = "btn btn-link", icon = icon("angle-down")),
    div(id = "collapse3", class = "collapse-content",
    column(12,
               fluidRow(
                 column(2,
                        selectInput(width = "100%",
                                    inputId = "date_col",
                                    label = "类型选择",
                                    choices = list("按支付日期" = "pay_date",
                                                   "按开课日期" = "term_start_date"),
                                    selected = "term_start_date"
                                    )
                 ),
                 column(4,
                        div(
                          class = "custom-date-range",
                          dateRangeInput(
                            inputId = "flt_date",
                            label = "时间范围",
                            start = Sys.Date() - 180,
                            end = Sys.Date(),
                            width = "100%"
                          )
                        )
                 )
               ),

               fluidRow(
                 column(2,
                        selectInput(inputId = "user_group",
                                    label = "人群",
                                    choices = set_choices(opts, "user_group"),
                                    selected = "思维",
                                    multiple = TRUE)),
                 column(2,
                        selectInput(inputId = "sku",
                                    label = "SKU",
                                    choices = set_choices(opts, "sku"),
                                    selected = "S低",
                                    multiple = TRUE)),
                 column(2,
                        selectInput(inputId = "business_line",
                                    label = "业务线",
                                    choices = set_choices(opts, "business_line"),
                                    selected = "9.9",
                                    multiple = TRUE)
                 ),
                 column(2,
                        selectInput(inputId = "goal_operation_group",
                                    label = "团队",
                                    choices = set_choices(opts, "goal_operation_group"),
                                    selected = "9元团队",
                                    multiple = TRUE)
                 ),
                 column(2,
                        selectInput(inputId = "goal_class_tag",
                                    label = "班型",
                                    choices = set_choices(opts, "goal_class_tag"),
                                    selected = "常规学期",
                                    multiple = TRUE)
                 ),
                 column(2,
                        selectInput(inputId = "is_target",
                                    label = "标内外学期",
                                    choices = list("标内班级" = 1,
                                                   "标外班级" = 0),
                                    selected = c(1, 0),
                                    multiple = TRUE)
                 )
               ),

               fluidRow(
                 column(12,
                        checkboxInput(inputId = "mannual_sele",
                                      label = "高级筛选",
                                      value = FALSE),

                        conditionalPanel(
                          condition = paste0("input[\'", 'mannual_sele', "\'] == 1"),
                          selectInput(inputId = "dims_sele",
                                      label = tags$small("筛选维度"),
                                      choices = dim_ls,
                                      selected = "term",
                                      multiple = TRUE,
                                      width = "100%"
                                      ),

                          uiOutput("dim_vars_sele")
                        )
                 )
               )
          )
    )
  ),

  hr(),
  
    fluidRow(
      actionButton("toggle4", label = "维度筛选", class = "btn btn-link", icon = icon("angle-down")),
      div(id = "collapse4", class = "collapse-content",
          column(12,
                   selectInput(inputId = "dims",
                               label = "交叉维度",
                               choices = dim_ls,
                               selected = "term",
                               multiple = TRUE,
                               width = "100%"
                   ),
                   
                   uiOutput("dim_vars")
          )
      )
    ),

    hr(),

    fluidRow(
      actionButton("toggle5", label = "指标筛选", class = "btn btn-link", icon = icon("angle-down")),
      div(id = "collapse5", class = "collapse-content",
      column(12,
                 fluidRow(
                   column(6,
                          selectInput(inputId = "metrics_sele",
                                      label = "要展示的指标(量)",
                                      choices = metrics_ls,
                                      multiple = TRUE,
                                      width = "100%")),
                   column(6,
                          selectInput(inputId = "calculated_metrics_sele",
                                      label = "要展示的指标(率)",
                                      choices = calculated_metrics_ls,
                                      multiple = TRUE,
                                      width = "100%"))
                 )
             )
      )
    ),

    fluidRow(
      column(12,
                div(style = "margin-bottom: 20px;",
                    actionButton(inputId = "update",
                                 label = "Update",
                                 class = "btn btn-default btn-lg",
                                 icon  = icon("circle-notch"),
                                 width = "100%",
                                 style = "background-color: #d3d3d3; border-color: gray;"))

            )
        ),
  
  fluidRow(
    column(12,
           div(style = "width: 100%; overflow-x: auto; white-space: nowrap;",
               DT::dataTableOutput("data_table")
           )
    )
  )
  
)

  

# 定义Server
server <- function(input, output, id = "ads_l1_eda_multidimensional_indicators_df") {

  observeEvent(input$toggle3, {
    toggle("collapse3")  # 切换内容的可见性
    toggleClass("toggle3", "collapsed")  # 切换箭头方向
  })
  
  observeEvent(input$toggle4, {
    toggle("collapse4")
    toggleClass("toggle4", "collapsed") 
  })
  
  observeEvent(input$toggle5, {
    toggle("collapse5")
    toggleClass("toggle5", "collapsed")
  })
  
  map_ls <- 
    con_tab[[id]] %>% 
    setNames(names(.), .) %>% 
    as.list()
  
  # filter data scope
  scope_sele <- reactive({
    flt_date_col <- input$date_col
    flt_start_date <- input$flt_date[1] %>% as.character()
    flt_end_date <- input$flt_date[2] %>% as.character()
    flt_user_group <- input$user_group
    flt_sku <- input$sku
    flt_business_line <- input$business_line
    flt_goal_class_tag <- input$goal_class_tag
    flt_goal_operation_group <- input$goal_operation_group
    flt_is_target <- input$is_target
    
    tbl %>%
      filter(!!sym(flt_date_col) >= flt_start_date) %>%
      filter(!!sym(flt_date_col) <= flt_end_date) %>%
      filter(user_group %in% flt_user_group) %>%
      filter(sku %in% flt_sku) %>%
      filter(business_line %in% flt_business_line) %>%
      filter(goal_class_tag %in% flt_goal_class_tag) %>%
      filter(goal_operation_group %in% flt_goal_operation_group) %>%
      filter(is_target %in% flt_is_target) %>% 
      collect()
  })
  
  #values in selected dims-col
  vars_sele <- reactive({
    
    req(input$mannual_sele,input$dims_sele)
    
    scope_sele() %>%
      select(one_of(input$dims_sele)) %>%
      map(~ unique(.))
  })
  
  # Use meta programming to render UI
  output$dim_vars_sele <- renderUI({
    
    req(vars_sele())
    
    exprs <-
      vars_sele() %>%
      imap(\(value, name) {
        
        value_c <- paste0('"', paste(value, collapse = '","'), '"')
        
        ns_name <- paste0(id, "-",name, "_")
        
        str_glue('selectInput(inputId = "{ns_name}", 
                 label = mapping_colname(map_ls, "{name}"), 
                 choices = c("全部",{value_c}), 
                 selected = c("全部"), 
                 multiple = TRUE)')
        
      })
    
    fluidRow(
      map(exprs, ~ column(2, eval(parse_expr(.x))))
    )
  })
  
  # 筛选逻辑处理
  scope_sele_after <- reactive({
    
    scope_sele <- scope_sele()
    
    if (input$mannual_sele) { # 仅当“高级筛选”复选框被选中时才应用筛选条件
    
      par_expr <-
        vars_sele() %>%
        imap(\(var, name) {
          
          selected_vals <- input[[paste0(id, "-", name, "_")]] # 获取用户选择的值
          
          if (!is.null(selected_vals)) {
            if ("全部" %in% selected_vals && length(selected_vals) == 1) {
              actual_vals <- paste0('c("', paste(var, collapse = '","'), '")')
              str_glue('filter({name} %in% {actual_vals})')
            } else {
              selected_actual_vals <- paste0('c("', paste(setdiff(selected_vals, "全部"), collapse = '","'), '")')
              str_glue('filter({name} %in% {selected_actual_vals})')
            }
          }
        }) %>%
        unlist()
      
      if (length(par_expr) != 0) {
        expr <- paste0(
          "scope_sele <- scope_sele %>% ",
          paste(par_expr, collapse = " %>% ")
        )
        eval(parse_expr(expr))
      } else {
        scope_sele <- scope_sele
      }
    
    }
    
    return(scope_sele)
  })
  
  
  # values in selected dims-col
  vars <- reactive({
    
    req(input$dims)
    
    scope_sele_after() %>%
      select(one_of(input$dims)) %>%
      map(~ unique(.))
    
  })
  
  # Use meta programming to render UI
  output$dim_vars <- renderUI({
    
    exprs <-
      vars() %>%
      imap(\(value, name) {
        
        value_c <- paste0('"', paste(value, collapse = '","'), '"')
        
        ns_name <- paste0(id, "-", name, "__")
        
        str_glue('selectInput(inputId = "{ns_name}", 
                 label = mapping_colname(map_ls, "{name}"), 
                 choices = c("全部",{value_c}), 
                 selected = c("全部"), 
                 multiple = TRUE)')
      })
    
    fluidRow(
      map(exprs, ~ column(2, eval(parse_expr(.x))))
    )
  })
  
  
  
  
  
  dat <- eventReactive(input$update, {
    
    scope <- scope_sele_after()
    
    # filter dims
    par_expr <- 
      vars() %>%
      imap(\(var, name) {
        
        selected_values <- input[[paste0(id, "-", name, "__")]] # 获取用户选择的值

        if (!is.null(selected_values)) {
          if ("全部" %in% selected_values & length(selected_values) == 1) { 
            actual_values <- paste0('c("', paste(var, collapse = '","'), '")')
            str_glue('filter({name} %in% {actual_values})')
          } else { 
            selected_actual_values <- paste0('c("', paste(setdiff(selected_values, "全部"), collapse = '","'), '")')
            str_glue('filter({name} %in% {selected_actual_values})')
          }
        }
      }) %>%
      unlist()
    
    if(length(par_expr) != 0) {
      expr <- paste0(
        "scope <- scope%>% ",
        paste(par_expr, collapse = " %>% ")
      )
      
      eval(parse_expr(expr))
    } else {
      scope <- scope
    }

    # calculate
    scope_amount <-scope %>%
      group_by(across(all_of(input$dims))) %>%
      summarise(across(all_of(input$metrics_sele), 
                       sum, 
                       na.rm = TRUE),
                .groups = "drop")
    
    
    summarise_expr_parsed <- lapply(input$calculated_metrics_sele, function(metric) {

      metric_name <- sub("^(.*?) =.*", "\\1", metric)
      
      metric_formula <- calculated_metrics_ls[[metric_name]]  
      
      # 解析公式为表达式
      parsed_expr <- parse(text = metric_formula)[[1]]
      
      # 返回表达式对象，并为其命名
      setNames(list(rlang::expr(!!parsed_expr)), metric_name)
    })
    
    # 将所有表达式合并成一个列表，确保每个表达式都有相应的名称
    summarise_exprs <- do.call(c, summarise_expr_parsed)
    
    scope_rate <- scope %>%
      group_by(across(all_of(input$dims))) %>%
      summarise(!!!summarise_exprs, .groups = "drop")
    
    scope_join <-scope_amount %>%
      full_join(scope_rate, by=input$dims)
    
    return(scope_join) 
  })
  
  output$data_table <- renderDataTable(server = FALSE,{
    
    dat<-rename_col_name(dat(), con_tab[[id]])
    
    datatable(data = dat,
              extension = "Buttons",
              options = list(dom = 'Bfrtip',
                             buttons = c("copy", "csv"),
                             scrollX = TRUE,
                             columnDefs = list(
                               list(targets = "_all", width = "auto")  # 设置所有列的宽度为自动
                             )
                             ),

              rownames = FALSE)
  })
  
}

shinyApp(ui = ui, server = server)