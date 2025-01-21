library(shiny)
library(DT)
library(rlang)
library(tidyverse)
library(yaml)
#source("../../update_mysql.R")

con_tab <- yaml.load_file("../../con_tab.yaml")

# ads_l1_eda_multidimensional_indicators_df %>%
#head(5)
#n_distinct()
#ncol()
#str()
# colnames()

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

calculated_metrics_ls <- list(
  "首日续报率" = "首日续报率 = round(sum(renewal_t0) / sum(enroll),2)" ,
  "二日续报率" = "二日续报率 = round(sum(renewal_t1) / sum(enroll),2)" ,
  "三日续报率" = "三日续报率 = round(sum(renewal_t2) / sum(enroll),2)" ,
  "四日续报率" = "四日续报率 = round(sum(renewal_t3) / sum(enroll),2)" ,
  "累计续报率" = "累计续报率 = round(sum(renewal_acc) / sum(enroll),2)"
)

# 定义UI
# ui <- fluidPage(
#   # 页面标题
#   titlePanel("多维指标"),
# 
#   br(),
#   sidebarPanel(width = 3,
#                class = "scrollable-default",
#   
#       hr(),
#       selectInput(width = "50%",
#                   inputId = "date_col",
#                   label = "范围选择",
#                   choices = list("按支付日期" = "pay_date",
#                                  "按开课日期" = "term_start_date"),
#                   selected = "term_start_date"),
#       dateRangeInput(inputId = "flt_date",
#                      label = "",
#                      start = Sys.Date() - 180,
#                      end = Sys.Date()),
# 
#       hr(),
#       selectInput(inputId = "user_group",
#                   label = "人群",
#                   choices = set_choices(opts, "user_group"),
#                   selected = "思维",
#                   multiple = TRUE),
#       selectInput(inputId = "sku",
#                   label = "SKU",
#                   choices = set_choices(opts, "sku"),
#                   selected = "S低",
#                   multiple = TRUE),
#       selectInput(inputId = "business_line",
#                   label = "业务线",
#                   choices = set_choices(opts, "business_line"),
#                   selected = "9.9",
#                   multiple = TRUE),
#       selectInput(inputId = "goal_operation_group",
#                   label = "团队",
#                   choices = set_choices(opts, "goal_operation_group"),
#                   selected = "9元团队",
#                   multiple = TRUE),
#       selectInput(inputId = "goal_class_tag",
#                   label = "班型",
#                   choices = set_choices(opts, "goal_class_tag"),
#                   selected = "常规学期",
#                   multiple = TRUE),
# 
#       checkboxGroupInput(inputId = "is_target",
#                          label = "",
#                          choices = list("包含标内班级" = 1,
#                                         "包含标外班级" = 0),
#                          selected = c(1, 0)),
# 
#       hr(),
# 
#       checkboxInput(inputId = "mannual_sele",
#                     label = "高级筛选",
#                     value = FALSE),
# 
#       conditionalPanel(
#         condition = paste0("input[\'", 'mannual_sele', "\'] == 1"),
#         selectInput(inputId = "dims_sele",
#                     label = tags$small("筛选维度"),
#                     choices = dim_ls,
#                     selected = "goal_class_tag",
#                     multiple = TRUE),
# 
#         uiOutput("dim_vars_sele")
#       ),
# 
#       hr(),
# 
#       selectInput(width = "50%",
#                   inputId = ("flt_method"),
#                   label = "学期筛选",
#                   choices = c("全部", "仅选中", "仅剔除")),
# 
#       conditionalPanel(
#         condition = paste0("input[\'", ('flt_method'), "\'] != \'全部\'"),
#         selectInput(inputId = ("term"),
#                     label = "",
#                     choices = NULL,
#                     multiple = TRUE)
#       ),
# 
#       hr(),
# 
#       selectInput(inputId = "dims",
#                   label = "交叉维度",
#                   choices = dim_ls,
#                   selected = "goal_class_tag",
#                   multiple = TRUE),
# 
#       uiOutput("dim_vars"),
# 
#       hr(),
# 
#       selectInput(width = "50%",
#                   inputId = ("x_axis"),
#                   label = "时序类型(X轴)",
#                   choices = list("学期" = "term",
#                                  "学期id" = "term_id",
#                                  "订单支付月" = "pay_month",
#                                  "开课月" = "term_start_month"
#                                  ),
#                   selected = "term"),
# 
#       hr(),
# 
#       selectInput(inputId = "metrics_sele",
#                   label = "要展示的指标(量)",
#                   choices = metrics_ls,
#                   multiple = TRUE
#       ),
# 
#       hr(),
# 
#       selectInput(
#         inputId = "calculated_metrics_sele",
#         label = "要展示的指标(率)",
#         choices = calculated_metrics_ls,
#         multiple = TRUE
#       ),
# 
#       hr(),
# 
#       actionButton(inputId = "update",
#                    label = "Update",
#                    width = "100%",
#                    class = "btn btn-default btn-lg",
#                    icon  = icon("circle-notch"))
#   ),
# 
#    mainPanel(
#      DT::dataTableOutput("data_table")
#    )
# )


ui <- fluidPage(
  
  # 在 UI 中添加自定义 CSS 样式
  tags$head(
    tags$style(HTML("
    .custom-date-range {
      height: 38px !important; /* 设置控件高度 */
    }
    .custom-date-range input {
      height: 36px !important; /* 设置输入框高度 */
      line-height: 38px;       /* 调整输入框内文本居中 */
    }
  "))
  ),
  
  # 页面标题
  titlePanel("多维指标"),
  
  hr(),
  
  # # 设置布局
  # fluidRow(
  #   # 横向：筛选维度
  #   column(2,
  #          selectInput(width = "100%",
  #                      inputId = "date_col",
  #                      label = "范围选择",
  #                      choices = list("按支付日期" = "pay_date",
  #                                     "按开课日期" = "term_start_date"),
  #                      selected = "term_start_date"),
  #         dateRangeInput(inputId = "flt_date",
  #                        label = "",
  #                        start = Sys.Date() - 180,
  #                        end = Sys.Date())
  #          ),
  #   # column(2,
  #   #        dateRangeInput(inputId = "flt_date",
  #   #                       label = "",
  #   #                       start = Sys.Date() - 180,
  #   #                       end = Sys.Date())),
  #   column(2,
  #          selectInput(inputId = "user_group",
  #                      label = "人群",
  #                      choices = set_choices(opts, "user_group"),
  #                      selected = "思维",
  #                      multiple = TRUE)),
  #   column(2,
  #          selectInput(inputId = "sku",
  #                      label = "SKU",
  #                      choices = set_choices(opts, "sku"),
  #                      selected = "S低",
  #                      multiple = TRUE)),
  #   column(2,
  #          selectInput(inputId = "business_line",
  #                      label = "业务线",
  #                      choices = set_choices(opts, "business_line"),
  #                      selected = "9.9",
  #                      multiple = TRUE)),
  #   column(2,
  #          selectInput(inputId = "goal_operation_group",
  #                      label = "团队",
  #                      choices = set_choices(opts, "goal_operation_group"),
  #                      selected = "9元团队",
  #                      multiple = TRUE))
  #   column(1.5,
  #          selectInput(inputId = "goal_class_tag",
  #                      label = "班型",
  #                      choices = set_choices(opts, "goal_class_tag"),
  #                      selected = "常规学期",
  #                      multiple = TRUE)),
  #   column(1.5,
  #          selectInput(inputId = "is_target",
  #                      label = "标内外学期",
  #                      choices = list("标内班级" = 1,
  #                                     "标外班级" = 0),
  #                      selected = c(1, 0),
  #                      multiple = TRUE))
  # ),
  
  # fluidRow(
  # 
  #   # column(3,
  #   #        checkboxGroupInput(inputId = "is_target",
  #   #                           label = "",
  #   #                           choices = list("包含标内班级" = 1,
  #   #                                          "包含标外班级" = 0),
  #   #                           selected = c(1, 0)))
  #   
  # 
  # ),
  
  # fluidRow(
  #   # 第一列，占两行，纵向布局
  #   column(2,
  #          selectInput(width = "100%",
  #                      inputId = "date_col",
  #                      label = "范围选择",
  #                      choices = list("按支付日期" = "pay_date",
  #                                     "按开课日期" = "term_start_date"),
  #                      selected = "term_start_date"),
  #          dateRangeInput(inputId = "flt_date",
  #                         label = "",
  #                         start = Sys.Date() - 180,
  #                         end = Sys.Date())
  #   ),
  #   # 右侧区域横向布局
  #   column(10,
  #          fluidRow(
  #            # 第一行：5个控件
  #            column(2,
  #                   selectInput(inputId = "user_group",
  #                               label = "人群",
  #                               choices = set_choices(opts, "user_group"),
  #                               selected = "思维",
  #                               multiple = TRUE)),
  #            column(2,
  #                   selectInput(inputId = "sku",
  #                               label = "SKU",
  #                               choices = set_choices(opts, "sku"),
  #                               selected = "S低",
  #                               multiple = TRUE)),
  #            column(2,
  #                   selectInput(inputId = "business_line",
  #                               label = "业务线",
  #                               choices = set_choices(opts, "business_line"),
  #                               selected = "9.9",
  #                               multiple = TRUE)),
  #            column(2,
  #                   selectInput(inputId = "goal_operation_group",
  #                               label = "团队",
  #                               choices = set_choices(opts, "goal_operation_group"),
  #                               selected = "9元团队",
  #                               multiple = TRUE)),
  #            column(2,
  #                   selectInput(inputId = "goal_class_tag",
  #                               label = "班型",
  #                               choices = set_choices(opts, "goal_class_tag"),
  #                               selected = "常规学期",
  #                               multiple = TRUE))
  #          ),
  #          fluidRow(
  #            # 第二行：2个控件
  #            column(2,
  #                   selectInput(inputId = "is_target",
  #                               label = "标内外学期",
  #                               choices = list("标内班级" = 1,
  #                                              "标外班级" = 0),
  #                               selected = c(1, 0),
  #                               multiple = TRUE))
  #          )
  #   )
  # ),  
  
  
  fluidRow(
    column(3,
           selectInput(width = "100%",
                       inputId = "date_col",
                       label = "范围选择",
                       choices = list("按支付日期" = "pay_date",
                                      "按开课日期" = "term_start_date"),
                       selected = "term_start_date")
    ),
    # column(3,
    #        dateRangeInput(inputId = "flt_date",
    #                       label = "日期选择",
    #                       start = Sys.Date() - 180,
    #                       end = Sys.Date(),
    #                       class = "custom-date-range")
    # ),
    column(3,
           div(
             class = "custom-date-range",  # 包装 div 应用样式
             dateRangeInput(
               inputId = "flt_date",
               label = "",
               start = Sys.Date() - 180,
               end = Sys.Date()
             )
           )
    ),
    column(3,
           selectInput(inputId = "user_group",
                       label = "人群",
                       choices = set_choices(opts, "user_group"),
                       selected = "思维",
                       multiple = TRUE)),
    column(3,
           selectInput(inputId = "sku",
                       label = "SKU",
                       choices = set_choices(opts, "sku"),
                       selected = "S低",
                       multiple = TRUE))
  ),
  
  fluidRow(
    column(3,
           selectInput(inputId = "business_line",
                       label = "业务线",
                       choices = set_choices(opts, "business_line"),
                       selected = "9.9",
                       multiple = TRUE)
    ),
    column(3,
           selectInput(inputId = "goal_operation_group",
                       label = "团队",
                       choices = set_choices(opts, "goal_operation_group"),
                       selected = "9元团队",
                       multiple = TRUE)
    ),
    column(3,
           selectInput(inputId = "goal_class_tag",
                       label = "班型",
                       choices = set_choices(opts, "goal_class_tag"),
                       selected = "常规学期",
                       multiple = TRUE)
    ),
    column(3,
           selectInput(inputId = "is_target",
                       label = "标内外学期",
                       choices = list("标内班级" = 1,
                                      "标外班级" = 0),
                       selected = c(1, 0),
                       multiple = TRUE)
    )
  ),  
  
  hr(),
  
  
  # fluidRow(
  #   column(3,
  #          checkboxInput(inputId = "mannual_sele",
  #                        label = "高级筛选",
  #                        value = FALSE)),
  # 
  #         conditionalPanel(
  #           condition = paste0("input[\'", 'mannual_sele', "\'] == 1"),
  #           selectInput(inputId = "dims_sele",
  #                       label = tags$small("筛选维度"),
  #                       choices = dim_ls,
  #                       selected = "goal_class_tag",
  #                       multiple = TRUE),
  # 
  #           uiOutput("dim_vars_sele")
  #         ),
  # 
  #   column(3,
  #          selectInput(width = "100%",
  #                      inputId = ("flt_method"),
  #                      label = "学期筛选",
  #                      choices = c("全部", "仅选中", "仅剔除"))),
  # 
  #         conditionalPanel(
  #           condition = paste0("input[\'", ('flt_method'), "\'] != \'全部\'"),
  #           selectInput(inputId = ("term"),
  #                       label = "",
  #                       choices = NULL,
  #                       multiple = TRUE)
  #         ),
  # 
  #   column(3,
  #          selectInput(inputId = "dims",
  #                      label = "交叉维度",
  #                      choices = dim_ls,
  #                      selected = "goal_class_tag",
  #                      multiple = TRUE)),
  # 
  #         uiOutput("dim_vars"),
  # 
  #   column(3,
  #          selectInput(width = "100%",
  #                      inputId = ("x_axis"),
  #                      label = "时序类型(X轴)",
  #                      choices = list("学期" = "term",
  #                                     "学期id" = "term_id",
  #                                     "订单支付月" = "pay_month",
  #                                     "开课月" = "term_start_month"
  #                      ),
  #                      selected = "term"))
  # ),
  
  fluidRow(
    column(3,
           checkboxInput(inputId = "mannual_sele",
                         label = "高级筛选",
                         value = FALSE),
           
           conditionalPanel(
             condition = paste0("input[\'", 'mannual_sele', "\'] == 1"),
             selectInput(inputId = "dims_sele",
                         label = tags$small("筛选维度"),
                         choices = dim_ls,
                         selected = "goal_class_tag",
                         multiple = TRUE),
             
             uiOutput("dim_vars_sele")
           )
    ),
    
    column(3,
           selectInput(width = "100%",
                       inputId = ("flt_method"),
                       label = "学期筛选",
                       choices = c("全部", "仅选中", "仅剔除")),
           
           conditionalPanel(
             condition = paste0("input[\'", ('flt_method'), "\'] != \'全部\'"),
             selectInput(inputId = ("term"),
                         label = "",
                         choices = NULL,
                         multiple = TRUE)
           )
    ),
    
    column(3,
           selectInput(inputId = "dims",
                       label = "交叉维度",
                       choices = dim_ls,
                       selected = "goal_class_tag",
                       multiple = TRUE),
           
           uiOutput("dim_vars")
    ),
    
    column(3,
           selectInput(width = "100%",
                       inputId = ("x_axis"),
                       label = "时序类型",
                       choices = list("学期" = "term",
                                      "学期id" = "term_id",
                                      "订单支付月" = "pay_month",
                                      "开课月" = "term_start_month"
                       ),
                       selected = "term")
    )
  ),
  
  hr(),
  
  fluidRow(
    column(3,
           selectInput(inputId = "metrics_sele",
                       label = "要展示的指标(量)",
                       choices = metrics_ls,
                       multiple = TRUE)),
    column(3,
           selectInput(inputId = "calculated_metrics_sele",
                       label = "要展示的指标(率)",
                       choices = calculated_metrics_ls,
                       multiple = TRUE)),
    column(3,
           actionButton(inputId = "update",
                        label = "Update",
                        width = "100%",
                        class = "btn btn-default btn-lg",
                        icon  = icon("circle-notch")))
  ),
  
  hr(),
  
  # 数据表格展示
  fluidRow(
    column(12, 
           mainPanel(DT::dataTableOutput("data_table"),
                     downloadButton("download_csv", "下载 CSV"))
    )
  )
)


# 定义Server
server <- function(input, output, id = "ads_l1_eda_multidimensional_indicators_df") {
  
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
    
    req(input$mannual_sele, input$dims_sele)
    
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
                 choices = c({value_c}), 
                 selected = c({value_c}), 
                 multiple = TRUE)')
        
      })
    
    tagList(map(exprs, ~ eval(parse_expr(.x))))
  })
  
  
  scope_sele_after <-reactive({
    
    scope_sele <- scope_sele()
    
    if (input$mannual_sele) { # 仅当“高级筛选”复选框被选中时才应用筛选条件
      
      par_expr <-
        vars_sele() %>%
        imap(\(var, name) {
          
          if(!is.null(input[[paste0(id, "-",name, "_")]])) {
            
            c_vals <- paste0('c("', paste(input[[paste0(id, "-",name, "_")]], collapse = '","'), '")')
            
            str_glue('filter({name} %in% {c_vals})')
          }
          
        }) %>%
        unlist()
      
      if(length(par_expr) != 0) {
        expr <- paste0(
          "scope_sele <- scope_sele %>% ",
          paste(par_expr, collapse = " %>% ")
        )
        
        eval(parse_expr(expr))
      } else { scope_sele <- scope_sele }
      
    }
    
    return(scope_sele)
  })
  
  # update term filter
  observeEvent(scope_sele_after(), {
    
    isTruthy(scope_sele_after())
    
    term <- set_choices(scope_sele_after(), "term", desc = TRUE) 
    
    updateSelectInput(inputId = "term",
                      choices = term)
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
                 choices = c({value_c}), 
                 selected = c({value_c}), 
                 multiple = TRUE)')
      })
    
    tagList(map(exprs, ~ eval(parse_expr(.x))))
    
  })
  
  
  dat <- eventReactive(input$update, {
    
    scope <- scope_sele_after()
    
    # filter term_id
    if(input$flt_method == "仅选中" & !is.null(input$term)) {
      scope <- scope %>% filter(term %in% input$term)
    }
    
    if(input$flt_method == "仅剔除" & !is.null(input$term_id)) {
      scope <- scope %>% filter(!term %in% input$term)
    }
    
    # filter dims
    par_expr <-
      vars() %>%
      imap(\(var, name) {
        
        if(!is.null(input[[paste0(id, "-", name, "__")]])) { # 注意这里仍然使用带有 "_" 的 name
          c_vals <- paste0('c("', paste(input[[paste0(id, "-", name, "__")]], collapse = '","'), '")')
          
          str_glue('filter({name} %in% {c_vals})')
        }
        
      }) %>%
      unlist()
    
    if(length(par_expr) != 0) {
      expr <- paste0(
        "scope <- scope%>% ",
        paste(par_expr, collapse = " %>% ")
      )
      
      eval(parse_expr(expr))
    }
    
    # calculate
    scope_amount <-scope %>%
      group_by(!!sym(input$x_axis),across(all_of(input$dims))) %>%
      summarise(across(all_of(input$metrics_sele), 
                       sum, 
                       na.rm = TRUE),
                .groups = "drop")
    
    # 动态构建 summarise 的计算公式
    summarise_expr_parsed <- lapply(input$calculated_metrics_sele, function(metric_formula) {
      parsed_expr <- parse(text = metric_formula)[[1]]  # 解析公式为表达式
      return(rlang::expr(!!parsed_expr))  # 返回作为 R 表达式对象
    })
    
    scope_rate <-scope %>%
      group_by(!!sym(input$x_axis),across(all_of(input$dims))) %>%
      summarise(!!!summarise_expr_parsed,
                .groups = "drop")
    
    # 提取公式的中文列名部分
    metric_names <- sapply(input$calculated_metrics_sele, function(metric_name) {
      strsplit(metric_name, " = ")[[1]][1]
    })
    
    # 将列名替换为用户选择的指标名称
    new_column_names <- c(names(scope_rate)[1:length(c(input$x_axis,input$dims))], metric_names)  # 保留分组列
    names(scope_rate) <- new_column_names
    
    scope_join <-scope_amount %>%
      full_join(scope_rate, by=c(input$x_axis,input$dims))
    
    return(scope_join) 
  })
  
  
  # 输出过滤后的数据到表格
  output$data_table <- renderDT({
    #datatable(dat(), options = list(pageLength = 10))
    
    dat<-rename_col_name(dat(), con_tab[[id]])
    
    datatable(dat) 
  })
  
  output$download_csv <- downloadHandler(
    filename = function() {
      paste("data-", Sys.Date(), ".csv", sep = "")  # 设置下载文件名
    },
    content = function(file) {
      write.csv(dat, file, row.names = FALSE, fileEncoding = "GBK")  # 将数据框写入 CSV 文件
    }
  )
  
}

# 运行Shiny应用
shinyApp(ui = ui, server = server)