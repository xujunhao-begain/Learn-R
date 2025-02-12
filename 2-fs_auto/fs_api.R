library(httr)
library(rlang)
library(jsonlite)

# 获取 tenant_access_token -----------------------------------------------------
get_tenant_access_token <- function() {
  # 接口地址
  url <- "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal"
  
  # 构造请求体
  body <- list(
    app_id = config_$app_id,
    app_secret = config_$app_secret
  )
  
  # 发起 POST 请求
  response <- httr::POST(
    url,
    body = body,
    encode = "json",
    add_headers(`Content-Type` = "application/json; charset=utf-8")
  )
  
  # 检查响应状态
  if (status_code(response) != 200) {
    stop("Failed to get tenant_access_token. Status code: ", status_code(response), "\n",
         "Response content: ", content(response, as = "text"))
  }
  
  # 解析响应内容
  response_content <- content(response, as = "parsed", type = "application/json")
  
  # 检查接口返回的错误码
  if (response_content$code != 0) {
    stop("Error in response: ", response_content$msg)
  }
  
  # 提取 token 
  tenant_access_token =paste("Authorization: Bearer ",response_content$tenant_access_token)
  
  return(tenant_access_token)
}










#----------------------------以下是xgw代码-------------------------------------#
library(httr)
library(rlang)
library(jsonlite)
retry_statu_codes <- c(400, 429, 500, 502, 503, 504)
retry_times <- 7
# 获取 tenant_access_token -----------------------------------------------------
form_request_headers <- function() {
  #定义了一个名为 form_request_headers 的 R 函数，用于生成 API 请求所需的请求头，
  #主要目的是获取租户级访问令牌 (tenant_access_token)，并将其包装为 Authorization头
  addr <- "{domain}/auth/v3/tenant_access_token/internal"
  get_tenant_token_url <- with(config_, stringr::str_glue(addr))

  response  <-
    httr::POST(
      get_tenant_token_url,
      body = list(
        app_id = config_$app_id,
        app_secret = config_$app_secret
      ),
      encode = "json"
      #encode = "json"：将请求体编码为 JSON 格式
    )

  if(status_code(response) != 200){
    stop("Failed in form_request_headers(). Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  token <- purrr::pluck(content(response), "tenant_access_token")

  add_headers(Authorization = stringr::str_glue("Bearer {token}"))
  #使用 httr::add_headers() 生成请求头，添加 Authorization 字段
  #stringr::str_glue("Bearer {token}")：构建认证字段的值，格式为："Bearer <tenant_access_token>"
}

# 转换wiki节点 -----------------------------------------------------------------
trans_wiki_token <- function(token){
  api <- "{domain}/wiki/v2/spaces/get_node?token={token}&obj_type=wiki"
  #api：定义 API URL 模板，表示请求 Wiki 节点对象的接口
  #{domain}：API 的域名，需通过外部变量或配置提供
  #{token}：传入的应用 token，会被动态替换
  #obj_type=wiki：固定参数，表示请求的对象类型为 Wiki
  url <- with(config_, stringr::str_glue(api))
  #通过 str_glue 函数将模板中的变量（如 domain 和 token）替换为实际值，生成完整的 API 请求 URL
  #url：生成的最终请求地址
  
  response <- httr::GET(url, config_$req_headers)
  #使用 httr::GET() 向生成的 url 发送 HTTP GET 请求
  #config_$req_headers：外部配置的 HTTP 请求头（获取的应用机器人的token）

  if(status_code(response) != 200){
    stop("Failed in trans_wiki_token(). Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  obj_token <- purrr::pluck(content(response), "data", "node", "obj_token")
  return(obj_token)
}


# Bitable API ------------------------------------------------------------------

# 单页爬取多维表格，返回response对象
res_bitbl <- function(app_token, tableID, page_token="", max_attempts = retry_times, wiki = FALSE) {
  attempt <- 1
  # 当文档所在节点为wiki时，需转换token
  if(wiki) app_token <- trans_wiki_token(app_token)
  #如果 wiki = TRUE，通过 trans_wiki_token 函数将 app_token 转换为 wiki 节点对应的 token
  api <- "{domain}/bitable/v1/apps/{app_token}/tables/{tableID}/records?page_token={page_token}&page_size=500"
  #定义 API 模板字符串 api，包含：
  #domain：API 域名，需通过外部变量或配置指定
  #app_token、tableID：由函数参数动态填充
  #page_token：分页参数，用于获取下一页数据
  #固定的 page_size=500，表示一次请求最多获取 500 条记录
  
  url <- with(config_, stringr::str_glue(api))

  repeat{
    response <- httr::GET(url, config_$req_headers)
    #请求发送：调用 httr::GET() 向指定 url 发送 GET 请求，config_$req_headers 是外部定义的请求头配置
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      #如果状态码属于 retry_statu_codes（外部预定义的重试状态码，例如 429 或 503），并且未达到最大重试次数，则执行以下操作：
      message(paste0("res_bitbl() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in res_bitbl(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}
  #如果最终的状态码不是 200（成功），抛出错误，并附带状态码和响应内容供调试使用

  return(response)
  #如果请求成功（状态码为 200），返回完整的 response 对象
}

# 多页爬取多维表格，返回tibble数据框
# get_dat_from_bitbl <- function(app_token, tableID, wiki = FALSE){
#   has_more <- TRUE
#   page_token = ""
#   df_ls <- list()
#   id_vec <- list()
#
#   extra_flds_to_df <- \(resp){
#     resp |>
#       content() |>
#       purrr::pluck("data", "items") |>
#       map(pluck, "fields") |>
#       map( ~ {
#         .x |>
#           map(paste, collapse = ",")
#       }) |>
#       bind_rows()
#   }
#
#   extr_ids_to_vec <- \(resp){
#     purrr::pluck(content(resp), "data", "items") |>
#       map(pluck, "record_id") |>
#       unlist()
#   }
#
#   while(has_more == TRUE){
#     response <- res_bitbl(app_token, tableID, page_token, wiki = wiki)
#     page_token <- purrr::pluck(content(response), "data", "page_token")
#     has_more <- purrr::pluck(content(response), "data", "has_more")
#     df_ls <- c(df_ls,  list(extra_flds_to_df(response)))
#     id_vec <- c(id_vec, c(extr_ids_to_vec(response)))
#   }
#
#   result <-
#     list(data = bind_rows(df_ls),
#          ids = unlist(id_vec))
#
#   return(result)
# }
# 多页爬取多维表格，返回tibble数据框
get_dat_from_bitbl <- function(app_token, tableID, wiki = FALSE) {
  # """
  # 参数
  # app_token：应用的访问令牌，用于认证 API 请求。
  # tableID：飞书多维表的表 ID，用于指定要提取数据的表。
  # wiki：布尔值，指定是否将 app_token 转换为 Wiki 节点的 obj_token。
  # 返回值
  # 返回一个包含以下两部分的列表：
  # data：从多维表提取的字段数据，形式为数据框。
  # ids：提取的记录 ID，形式为向量。
  # """
  has_more <- TRUE #是否还有下一页数据，初始值为 TRUE
  page_token <- "" #分页标记，用于从 API 获取下一页数据，初始值为空字符串
  df_ls <- list() #用于存储分页数据的列表
  id_vec <- list() #用于存储分页记录 ID 的列表

  # 提取字段到数据框的函数
  # 处理一个包含结构化数据的 HTTP 响应对象，将其中的 "fields" 数据提取出来并
  # 转换为一个整齐的数据框（data frame）
  extra_flds_to_df <- \(resp) {
  # \(resp) 等价于 function(resp)
  #resp 是一个 HTTP 响应对象，通常由某个 API 请求返回。
    items <- resp |>
      content() |>
      #content(): 从 HTTP 响应对象中提取内容，通常会返回 JSON 结构
      purrr::pluck("data", "items")
      #purrr::pluck("data", "items"): 从内容中提取 data 字段，再从中提取 items 字段

    if (length(items) == 0) {
      # 返回一个结构化但空的数据框，如果没有行数据
      tibble()
    } else {
      items |>
        map(pluck, "fields") |>
        #map(pluck, "fields"): 遍历 items 列表，提取每个元素的 fields 数据
        map(~ {
          .x |>
            map(paste, collapse = ",")
        }) |>
        #内层 map(~ { ... }): 对每个 fields 的字段值进行处理，将列表中的元素
        #合并为字符串，用逗号（,）分隔
        bind_rows()
        #bind_rows(): 将处理后的所有元素行绑定，形成一个数据框
    }
  }

  # 提取ID向量的函数
  extr_ids_to_vec <- \(resp) {
    purrr::pluck(content(resp), "data", "items") |>
      map(pluck, "record_id") |>
      #map(pluck, "record_id") 遍历 items 列表，对每个元素提取其 record_id 字段
      unlist()
      #将提取到的 record_id 列表转换为一个简单的向量  list() 转为c()
  }

  # 循环爬取所有页数据
  while (isTRUE(has_more)) {
    response <- res_bitbl(app_token, tableID, page_token, wiki = wiki)
    #调用 res_bitbl函数 获取当前页的response
    
    # 确保 page_token 和 has_more 都有值，避免 NULL 错误
    page_token <- purrr::pluck(content(response), "data", "page_token", .default = "")
    #提取当前页的 page_token 和 has_more：page_token：用于获取下一页
    has_more <- purrr::pluck(content(response), "data", "has_more", .default = FALSE)
    #has_more：判断是否还有下一页
    
    df_ls <- c(df_ls, list(extra_flds_to_df(response)))
    #使用 extra_flds_to_df 函数提取字段数据，并添加到 df_ls
    #(df_ls, list(...))：将当前页的字段数据添加到数据列表中
    id_vec <- c(id_vec, c(extr_ids_to_vec(response)))
    #使用 extr_ids_to_vec 提取记录 ID，并添加到 id_vec
    #c(id_vec, c(...))：将当前页的记录 ID 添加到 ID 列表中
  }
  #当 has_more 为 FALSE 时，退出循环，表示所有分页数据已被提取

  #合并结果，确保返回的数据框即使为空也有列结构
  result <- list(
    data = if (length(df_ls) > 0) bind_rows(df_ls) else tibble(),
    #如果 df_ls（分页字段数据列表）非空，则合并为一个完整的数据框
    #如果 df_ls 为空，则返回一个空数据框
    ids = unlist(id_vec)
    #将 id_vec 中的所有记录 ID 合并为一个向量
  )

  return(result)
}

# 从返回的tibble中提取订阅人信息
#str <- 'email = "user1@example.com", en_name = "User One", id = "12345"; email = "user2@example.com", en_name = "User Two", id = "67890"'
extr_user_list <- function(str){
  # """
  # 参数
  # str：字符串或字符串向量，其中包含用户信息的文本数据。
  # 返回值
  # 数据框（data.frame），包含以下列：
  # email：提取的用户电子邮件。
  # en_name：提取的用户英文名。
  # id：提取的用户 ID。
  # 如果输入字符串为空（length(str) == 0），返回一个空数据框。
  # """
  if(length(str) == 0) return(data.frame())

  # email
  emails <- regmatches(str, gregexpr('email = \\"(.*?)\\"', str))[[1]]
  #regexpr('email = \\"(.*?)\\"', str)
  # email = \\"：匹配 email = "（转义了双引号）
  # (.*?)：捕获任意内容，直到下一个双引号
  # \\"：匹配结束的双引号
  # 返回结果是所有匹配项的位置
  #regmatches(...)[[1]] 提取所有匹配到的字符串
  emails <- gsub('email = \\"|\\"', '', emails)
  #使用 gsub 删除多余的 email = " 和末尾的 "，保留实际的邮箱地址
  # en_name
  en_names <- regmatches(str, gregexpr('en_name = \\"(.*?)\\"', str))[[1]]
  en_names <- gsub('en_name = \\"|\\"', '', en_names)
  # id
  ids <- regmatches(str, gregexpr('id = \\"(.*?)\\"', str))[[1]]
  ids <- gsub('id = \\"|\\"', '', ids)

  df <- data.frame(email = emails,
                   en_name = en_names,
                   id = ids,
                   stringsAsFactors = FALSE)
  #将提取到的 emails, en_names, 和 ids 组合成一个数据框
  #stringsAsFactors = FALSE：防止字符列被自动转换为因子类型
  return(df)
}

# 从返回的tibble中提取订阅群信息
extr_group_list <- function(str){
  if(length(str) == 0) return(data.frame())

  # avatar
  avatar_urls <- regmatches(str, gregexpr('avatar_url = \\"(.*?)\\"', str))[[1]]
  avatar_urls <- gsub('avatar_url = \\"|\\"', '', avatar_urls)

  # id
  ids <- regmatches(str, gregexpr('id = \\"(.*?)\\"', str))[[1]]
  ids <- gsub('id = \\"|\\"', '', ids)

  # name
  names <- regmatches(str, gregexpr('name = \\"(.*?)\\"', str))[[1]]
  names <- gsub('name = \\"|\\"', '', names)

  df <- data.frame(avatar_url = avatar_urls,
                   id = ids,
                   name = names,
                   stringsAsFactors = FALSE)

  return(df)
}


# 向多维表格推送json
push_bitbl <- function(app_token, tableID, records, max_attempts = retry_times, wiki = FALSE){
  # """
  # 这段代码定义了一个函数 push_bitbl，用于将批量创建的记录（records）上传到一个指定
  # 的 API 表格（bitable）中。这是一个典型的 R 脚本，结合了 API 调用、错误重试机制
  # 和 JSON 数据构建。以下是详细的代码解析：
  # 
  # 参数说明：
  # app_token：API 应用的令牌，用于授权访问目标表格。
  # tableID：目标表格的唯一 ID，用于指定操作的表。
  # records：要上传的数据，通常是一个包含记录信息的列表。
  # max_attempts：最大重试次数，默认为全局变量 retry_times。
  # wiki：布尔值，指示当前是否处理 wiki 类型的文档（需要转换 app_token）
  # """
  attempt <- 1
  # 当文档所在节点为wiki时，需转换token
  if(wiki) app_token <- trans_wiki_token(app_token)

  api <- "{domain}/bitable/v1/apps/{app_token}/tables/{tableID}/records/batch_create"
  url <- with(config_, stringr::str_glue(api))
  body <- jsonlite::toJSON(list(records = records), auto_unbox = TRUE, na = "null")
  # 使用 jsonlite::toJSON 将 records 转换为 JSON 格式
  # list(records = records)：构造 JSON 的顶级结构为 {"records": ...}
  # auto_unbox = TRUE：确保单一值不会被包装成数组
  # na = "null"：将 R 中的 NA 转换为 JSON 中的 null
  
  repeat{
    response <- httr::POST(url, config_$req_headers, body = body)
    # 循环发送请求：
    # 使用 httr::POST 向 API 发送 POST 请求。
    # 包含请求头 config_$req_headers 和 JSON 格式的请求体 body
    if (!is.null(content(response)$error)) {
      print(content(response)$error$message)
      # 如果响应内容中包含 error 字段，打印错误消息
    }

    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("res_bitbl() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in push_bitbl(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  return(response)
  #如果执行成功，返回 API 的响应对象
}

# 向多维表格推送dataframe
push_df_to_bitbl <- function(app_token, tableID, df, wiki = FALSE) {
  # """
  # 这段代码定义了一个函数 push_df_to_bitbl，用于将一个数据框（df）中的数据批量上
  # 传到指定的 API 表格（bitable）中。该函数特别考虑了接口的行限制（分页处理）并
  # 通过批量处理提升了上传效率。
  # app_token：API 应用的令牌，用于授权访问目标表格。
  # tableID：目标表格的唯一 ID，用于指定操作的表。
  # df：包含待上传数据的数据框。
  # wiki：布尔值，指示当前是否处理 wiki 类型的文档（需要转换 app_token）
  # """
  if(nrow(df) == 0) stop("Failed: push_df_to_bitbl, nrow(df) is 0")

  # 分页处理，解决接口的行限制
  chunk_size <- 500

  trans_to_fields <- \(df) {df |> pmap(function(...){list(fields = list(...))})}
  #目的：将数据框的每一行转换为 API 接受的格式
  #pmap：逐行遍历数据框，处理每一行的数据
  #对于每一行，将所有列数据封装为一个名为 fields 的列表
  #这里的 function(...) 是一个匿名函数，... 表示函数的参数会接收每一行的所有列的值
  #由于 pmap 会逐行遍历数据框，因此每一行的所有列值都会被传递到 ... 中，供 function(...) 使用
  #list(...) 是将接收到的每一行的数据封装成一个列表
  #... 代表当前行的所有列的值，这些列的值会成为列表的元素
  #这个 list(...） 会将每行数据的所有列值按顺序存入一个列表
  #外面的 list(fields = list(...)) 将这个列表嵌套在一个名为 fields 的列表中，形成一个更深层次的结构
  
  df |>
    split(ceiling(seq_along(df[,1]) / chunk_size)) |>
    # df[,1]：选取数据框的第一列
    # seq_along：生成序列，表示每一行的索引
    # ceiling(seq_along(...) / chunk_size)：计算每行所属的批次编号
    # split：根据批次编号将数据框分成多个子数据框
    map(trans_to_fields)|>
    # 对每个子数据框调用 trans_to_fields，将其转换为 API 接受的记录格式
    walk(~ push_bitbl(app_token, tableID, .x, wiki = wiki))
    # 对每个批次的数据（.x）调用 push_bitbl
    # 通过 push_bitbl 将批次数据上传到目标表格
    # walk 不返回结果，只执行副作用操作（上传数据）
}

# 删除多维表格的指定多行
delt_records <- function(app_token, tableID, record_ids, max_attempts = retry_times, wiki = FALSE){
  #这段代码构建了一个删除记录的 API 请求 URL
  #函数通过构建正确的 API 请求 URL 和请求体（包含要删除的记录 ID），然后使用 POST 请求发送删除请求
  attempt <- 1

  # 当文档所在节点为wiki时，需转换token
  if(wiki) app_token <- trans_wiki_token(app_token)

  api <- "{domain}/bitable/v1/apps/{app_token}/tables/{tableID}/records/batch_delete"
  url <- with(config_, stringr::str_glue(api))
  body <- list(records = record_ids)

  repeat{
    response <- httr::POST(url, config_$req_headers, body = body, encode = "json")
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("delt_records() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in delt_records(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  return(response)
}


# 清空多维表格所有行
# clean_bitbl <- function(app_token, tableID, wiki = FALSE) {
#   chunk_size <- 1000
#
#   ids <-
#     get_dat_from_bitbl(app_token, tableID, wiki = wiki) |>
#     pluck("ids")
#
#   ids_ls <- split(ids,
#                   rep(1: ceiling(length(ids)/ chunk_size),
#                       each = chunk_size,
#                       length.out = length(ids)))
#
#   ids_ls |>
#     walk(~ delt_records(app_token, tableID, .x, wiki = wiki))
# }
clean_bitbl <- function(app_token, tableID, wiki = FALSE) {
  chunk_size <- 1000

  # 获取表格中的 ids
  ids <-
    get_dat_from_bitbl(app_token, tableID, wiki = wiki) |>
    pluck("ids")

  # 检查 ids 是否为向量且长度大于 0
  if (is.null(ids) || !is.vector(ids) || length(ids) == 0) {
    message("表格存在，但没有任何行，跳过清空操作")
    return(invisible(NULL))
  }

  # 将 ids 分块处理
  ids_ls <- split(ids,
                  rep(1:ceiling(length(ids) / chunk_size),
                      each = chunk_size,
                      length.out = length(ids)))
  
  # 这部分代码生成了一个向量，表示将 ids 向量分割成多个小块的索引。让我们逐步解读：
  # length(ids)：获取 ids 向量的长度，即记录的数量。
  # chunk_size：定义每个小批次的大小，最多包含 chunk_size 个记录（在这个例子中，默认是 1000）。
  # ceiling(length(ids) / chunk_size)：计算需要多少个小批次来容纳所有记录。
  # 如果记录数量不能被 chunk_size 整除，ceiling() 会向上取整。
  # 例如，如果有 1500 个记录，且 chunk_size = 1000，则需要 2 个批次。
  # rep(1:ceiling(length(ids) / chunk_size))：生成一个重复的向量，表示每个小批次的
  # 编号。例如，如果需要 2 个批次，则会生成 [1, 2, 1, 2, ...]，其中每个批次的元素
  # 数量接近 chunk_size，但最后一个批次可能包含少于 chunk_size 个元素（如果总记录
  # 数不能被 chunk_size 整除）。
  # each = chunk_size：指定每个批次中有 chunk_size 个元素。
  # length.out = length(ids)：确保生成的向量的总长度与 ids 向量的长度相同。

  # 执行删除操作
  ids_ls |>
    walk(~ delt_records(app_token, tableID, .x, wiki = wiki))
}



# Message Bot API --------------------------------------------------------------

# 向群组发送纯文本消息(自定义机器人)
send_msg <- function(msg, webhook, max_attempts = retry_times){
  # """
  # msg: 发送的消息内容，类型为文本。
  # webhook: Webhook URL，消息会发送到这个地址。
  # max_attempts: 最大重试次数，默认值是 retry_times，即一个预设的重试次数。
  # retry_times 是在其他地方定义的常量或变量。
  # """
  attempt <- 1
  body <- list(msg_type = "text", content = list(text = msg))

  repeat{
    #repeat: 这是一个无限循环，会一直尝试发送消息，直到成功或达到最大重试次数
    response <- httr::POST(url = webhook, body = body, encode = "json", add_headers("Content-Type" = "application/json"))
    #httr::POST(): 使用 httr 包的 POST 函数向指定的 webhook URL 发送 POST 请求
    #请求体（body）是消息内容，编码格式为 json，
    #并指定请求头 Content-Type: application/json，以指示服务器请求的内容格式
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("send_msg() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in send_msg(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  return(response)
}

# 向群组发送纯文本消息(通用机器人)
send_msg_to_group <- function(chat_id, msg, max_attempts = retry_times){
  attempt <- 1
  api <- "{domain}/im/v1/messages?receive_id_type=chat_id"
  url <- with(config_, stringr::str_glue(api))
  body <- list(receive_id = chat_id,
               msg_type = "text",
               content = paste0("{\"text\":\"", msg, "\"}")
               #content: 消息内容，使用 paste0 进行字符串拼接，将文本 msg 包裹在
               #JSON 格式的文本中。最终的格式是 {"text": "消息内容"}
  ) %>%
    jsonlite::toJSON(auto_unbox = TRUE, pretty = TRUE)
  #将 body 列表转换为 JSON 格式的字符串，并设置 auto_unbox = TRUE，确保没有数组
  #元素时不添加额外的数组层级。

  repeat{
    response <- httr::POST(url = url, config_$req_headers, body = body)
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("send_msg_to_group() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in send_msg_to_group(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  return(response)
}

# 向群组发送富文本消息(自定义机器人)
send_post <- function(title, content, webhook, max_attempts = retry_times){
  # """
  # title: 消息的标题，字符串类型。
  # content: 消息的内容，格式化为特定结构（通常是一个嵌套列表，用于构建富文本消息的结构）。
  # webhook: 自定义机器人的 Webhook URL，用于发送请求。
  # max_attempts: 最大重试次数，默认为 retry_times，即一个预定义的变量，指定最大重试次数。
  # """
  attempt <- 1
  body <- list(msg_type = "post",
               content = list(
                 post = list(
                   zh_cn = list(
                     title = title,
                     content = content))))
  # body: 构造 HTTP 请求体，表示要发送的富文本消息，结构为嵌套的 JSON：
  # msg_type = "post"：指定消息类型为 "post"，表示富文本消息。
  # content：消息内容，包含以下结构：
  # post：富文本消息的主体。
  # zh_cn：中文消息部分，包含两个子字段：
  # title：消息的标题，值由参数 title 提供。
  # content：消息的具体内容，值由参数 content 提供，通常是一个嵌套列表结构，
  # 用于描述富文本的内容布局（例如段落、超链接等）

  repeat{
    response <- httr::POST(url = webhook, body = body, encode = "json", add_headers("Content-Type" = "application/json"))
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("send_post() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in send_post(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  return(response)
}

# 向群组发送富文本消息(通用机器人)
send_post_to_group <- function(chat_id, title, content, max_attempts = retry_times){
  attempt <- 1
  api <- "{domain}/im/v1/messages?receive_id_type=chat_id"
  url <- with(config_, stringr::str_glue(api))

  content <- list(
    zh_cn = list(
      title = title,
      content = content))
  # 创建 content 列表，表示消息内容，格式如下：
  # zh_cn：中文部分内容：
  # title：中文消息的标题，值来自 title 参数。
  # content：中文消息的内容，值来自 content 参数（通常是一个嵌套列表，表示格式化内容布局）。

  body <- list(
    receive_id = chat_id,
    content = toJSON(content, auto_unbox = TRUE),
    msg_type = "post") |>
    toJSON(auto_unbox = TRUE, pretty = TRUE)
  # body：构造完整的请求体，包含以下字段：
  # receive_id：接收者 ID，这里是群组的 chat_id。
  # content：消息内容，将 content 转换为 JSON 字符串（通过 toJSON）。
  # msg_type：消息类型为 "post"，表示发送富文本消息。
  # 使用管道符 (|>) 再次将整个 body 转换为 JSON 格式，带有美化选项 pretty = TRUE（便于阅读和调试）

  repeat{
    response <- httr::POST(url, config_$req_headers, body = body)
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("send_post_to_group() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in send_post_to_group(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  return(response)
}

# 向群组发送消息卡片(自定义机器人)
send_card_to_webhook <- function(title, subtitle, elements, webhook, color = "blue", max_attempts = retry_times){
  # """
  # title：卡片的标题，用于概述卡片的主要信息。
  # subtitle：卡片的副标题，用于补充描述卡片内容。
  # elements：卡片的主要内容部分，通常是一个列表，包含卡片的核心交互组件（如按钮、文本、图片等）。
  # webhook：用于发送消息的 Webhook 地址。
  # color：卡片的颜色模板，默认为 "blue"，可用于区分卡片类型或状态（例如蓝色表示信息，红色表示警告）。
  # max_attempts：最大重试次数，默认值为 retry_times，控制发送失败时的重试机制。
  # """
  
  attempt <- 1

  body <- list(
    msg_type = "interactive", #msg_type：指定消息类型为 "interactive"，表示这是一个交互式卡片
    card = list(
      # 卡片头
      header = list( #卡片的头部
        template = color, #template：卡片的颜色模板，值为 color 参数（例如 "blue"）
        title = list( #title：卡片标题，使用 plain_text 格式，内容为 title 参数
          tag = "plain_text",
          content = title
        ),
        subtitle = list( # subtitle：卡片副标题，同样使用 plain_text 格式，内容为 subtitle 参数
          tag = "plain_text",
          content = subtitle
        )
      ),
      # 卡片内容
      elements = elements
    )) |>
    jsonlite::toJSON(auto_unbox = TRUE)
  #使用 jsonlite::toJSON 将构造的列表转化为 JSON 格式。
  #参数 auto_unbox = TRUE 确保简单元素（如字符串或数值）不会被额外嵌套为数组

  repeat{
    response <- httr::POST(url = webhook, body = body, add_headers("Content-Type" = "application/json"))
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("send_card_to_webhook() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in send_card_to_webhook(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  return(response)
}

# 向群组发送消息卡片(通用机器人)
send_card_to_group <- function(chat_id, title, subtitle, elements, color = "blue", max_attempts = retry_times){
  attempt <- 1
  api <- "{domain}/im/v1/messages?receive_id_type=chat_id"
  url <- with(config_, stringr::str_glue(api))

  content <- list(
    config = list(
      wide_screen_mode = TRUE
    ), #config: 设置卡片的配置参数 wide_screen_mode = TRUE: 开启宽屏模式，使卡片在支持宽屏的界面中显示更宽的内容
    elements = elements, #卡片的主要内容部分（比如文本、按钮等），由调用者传递进来
    header = list(
      template = color, #定义头部的颜色（如蓝色、红色等）
      title = list(
        content = title,
        tag = "plain_text" #卡片的主标题，格式为纯文本（plain_text）
      ),
      subtitle = list(
        content = subtitle, #卡片的副标题，格式同上
        tag = "plain_text")))

  body <- list(
    receive_id = chat_id,
    content = toJSON(content, auto_unbox = TRUE), #将构造好的卡片内容转为 JSON 字符串
    msg_type = "interactive") |> #指定消息类型为交互式卡片
    toJSON(auto_unbox = TRUE, pretty = TRUE)

  repeat{
    response <- httr::POST(url, config_$req_headers, body = body)
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("send_card_to_group() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in send_card_to_group(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  return(response)
}

# 向个人批量发送富文本私信(通用机器人)
send_post_to_user <- function(union_ids, title, content, max_attempts = retry_times){
  # """
  # union_ids：表示用户的唯一标识符（可能是用户的 Union ID）。支持发送给单个或多个用户。
  # title：消息帖子的标题。
  # content：消息帖子的具体内容（应该是一个列表，包含文本或格式化信息）。
  # max_attempts：最大重试次数，默认为外部定义的 retry_times。
  # """
  attempt <- 1
  api <- "{domain}/message/v4/batch_send/"
  url <- with(config_, stringr::str_glue(api))

  if(length(union_ids) == 1) union_ids <- list(union_ids)
  #如果 union_ids 只有一个值，将其转换为列表格式，确保可以兼容单个和多个用户

  body <-
    list(union_ids = union_ids, #接收消息的用户 ID 列表
         msg_type = "post", #指定消息类型为 post，表示这是一条帖子消息
         content = list(
           post = list( #post：表示帖子内容
             zh_cn = list( #zh_cn：帖子内容是中文
               title = title, #title 和 content：分别是帖子标题和内容
               content = content)))) |>
    jsonlite::toJSON(auto_unbox = TRUE)
  #jsonlite::toJSON 将 R 的列表对象转换为 JSON 格式，并通过 auto_unbox = TRUE 来去除多余的嵌套

  repeat{
    response <- httr::POST(url, config_$req_headers, body = body)
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("send_post_to_user() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in send_post_to_user(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  return(response)
}

# 向个人批量发送消息卡片(通用机器人)
send_card_to_user <- function(open_ids, title, subtitle, elements, color = "blue", max_attempts = retry_times){
  # """
  # open_ids：接收消息的用户的唯一标识符（可能是用户的 Open ID）。可以支持多个用户。
  # title：卡片的标题。
  # subtitle：卡片的副标题。
  # elements：卡片的内容部分，通常是一个包含多个元素的列表，表示卡片的实际显示内容。
  # color：卡片的颜色模板，默认为 "blue"。
  # max_attempts：最大重试次数，默认为外部定义的 retry_times。
  # """
  
  attempt <- 1
  api <- "{domain}/message/v4/batch_send/"
  url <- with(config_, stringr::str_glue(api))

  if(length(open_ids) == 1) open_ids <- list(open_ids)
  #如果 open_ids 只有一个值，则将其转换为列表格式，确保支持同时向多个用户发送消息

  body <- list(
    union_ids = open_ids, #union_ids：接收卡片消息的用户 ID 列表
    msg_type = "interactive",#msg_type：指定消息类型为 "interactive"，表示这是一条交互式消息
    card = list(
      # 卡片头
      header = list(
        template = color,
        title = list(
          tag = "plain_text",
          content = title
        ),
        subtitle = list(
          tag = "plain_text",
          content = subtitle
        )
      ),
      # 卡片内容
      elements = elements
    )) |>
    jsonlite::toJSON(auto_unbox = TRUE)

  repeat{
    response <- httr::POST(url, config_$req_headers, body = body)
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("send_card_to_user() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in send_card_to_user(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  return(response)
}

# 上传图片,返回key
upload_img <- function(img_path, max_attempts = retry_times){
  # """
  # 这段 R 代码定义了一个函数 upload_img，用于上传图片到某个服务器，并返回图片的 image_key
  # img_path：上传的图片文件路径。
  # max_attempts：最大重试次数，默认为外部定义的 retry_times
  # """
  attempt <- 1
  api <- "{domain}/im/v1/images"
  url <- with(config_, stringr::str_glue(api))
  body <- list(image_type = "message", image = upload_file(img_path))
  #image_type：指定上传的图片类型，这里设定为 "message"，意味着图片将用作消息的一部分
  #image：通过 upload_file(img_path) 加载图片文件，upload_file 是一个帮助函数，
  #可能用于读取文件并以适当的方式将其包含在请求中

  repeat{
    response <- httr::POST(url, config_$req_headers, body = body, encode = "multipart")
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("upload_img() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in upload_img(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  img_key <-
    content(response) |>
    pluck("data", "image_key")

  return(img_key)
}


# Document API -----------------------------------------------------------------

# 创建云文档，返回文档ID/标题/url
create_doc <- function(folder, title, max_attempts = retry_times) {
  # """
  # 这段代码定义了一个函数 create_doc，用于在指定文件夹中创建文档并返回文档的相关信息（如 ID、标题和 URL）
  # folder：指定文档要存储的文件夹的唯一标识符（token）。
  # title：新文档的标题。
  # max_attempts：最大重试次数，默认为外部定义的 retry_times，用于在请求失败时控制重试次数。
  # """
  
  attempt <- 1
  api = "{domain}/docx/v1/documents/"
  url <- with(config_, stringr::str_glue(api))
  body <- list(folder_token = folder, title = title)
  #folder_token：文件夹的唯一标识符，用于指定文档要创建在哪个文件夹内
  #title：文档的标题

  repeat{
    response <- httr::POST(url, config_$req_headers, body = body, encode = "json")
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("create_doc() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in create_doc(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  doc_id <- pluck(content(response), "data", "document", "document_id")
  #doc_id：从响应的内容中提取文档的唯一标识符（document_id）
  doc_title <- pluck(content(response), "data", "document", "title")
  #doc_title：从响应的内容中提取文档的标题
  doc_url <- stringr::str_glue("https://wrpnn3mat2.feishu.cn/docx/{doc_id}")
  #doc_url：构造文档的 URL，使用 doc_id 来形成完整的文档链接
  
  return(list(id = doc_id, title = doc_title, url = doc_url))
}

# 获取文档内容块,返回response对象
get_doc_blocks <- function(doc_id, max_attempts = retry_times){
  # """
  # 这段代码定义了一个函数 get_doc_blocks，用于获取文档的块信息（如文档内容的不同部分或结构）
  # 返回response
  # """
  attempt <- 1
  api <-  "{domain}/docx/v1/documents/{doc_id}/blocks"
  url <- with(config_, stringr::str_glue(api))

  repeat{
    response <- httr::GET(url, config_$req_headers)
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("get_doc_blocks() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in get_doc_blocks(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  return(response)
}

# 清空文档
delt_doc_blocks <- function(doc_id, max_attempts = retry_times){
  attempt <- 1
  api <- "{domain}/docx/v1/documents/{doc_id}/blocks/{doc_id}/children/batch_delete"
  url <- with(config_, stringr::str_glue(api))

  resp <- get_doc_blocks(doc_id)
  # 使用 get_doc_blocks 函数获取文档块信息。这个函数返回文档中各个块的结构信息

  items <-
    content(resp) |>
    purrr::pluck("data", "items")
  # 使用 purrr::pluck 从响应中提取 items，即文档中的块列表

  if(length(items) == 1) return(0) # 原本就空

  childrens <- purrr::pluck(items[[1]], "children")
  #从文档块中的第一个元素 items[[1]] 中提取出 children，即该块下的子内容列表

  body <- list(start_index = 0, end_index = length(childrens))
  #构造请求体 body，指定要删除的子块的范围。这里设置了 start_index = 0 和 
  #end_index = length(childrens)，即删除所有子块

  repeat{
    response <- httr::DELETE(url, config_$req_headers, body = body, encode = "json")
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("delt_doc_blocks() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in delt_doc_blocks(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  return(response)
}

# 创建text_run类型block并写入内容
# 说明文档：https://open.feishu.cn/document/server-docs/docs/docs/docx-v1/document-block/create
create_text_run_block <- function(doc_id, block_type, block_name, content, index, block_id = NULL, max_attempts = retry_times){
  attempt <- 1
  if(is.null(block_id)) block_id <- doc_id
  api <- "{domain}/docx/v1/documents/{doc_id}/blocks/{block_id}/children"
  url <- with(config_, stringr::str_glue(api))

  expr <- "list(
    index = {index},
    children = list(
      list(
        block_type = {block_type},
        {block_name} = list(
          elements = list(
            list(
              text_run = list(
                content = '{content}'
              )
            )
          ),
          style = NULL
        )
      )
    )
  )"

  body_expr <- stringr::str_glue(expr)

  body <-
    eval(parse(text = body_expr)) |>
    jsonlite::toJSON(auto_unbox = TRUE)


  repeat{
    response <- httr::POST(url, config_$req_headers, body = body)
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("create_text_run_block() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in create_text_run_block(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  return(response)
}

# 创建block并写入纯文本
text_block <- function(doc_id, content, block_id = NULL, index = -1){
  resp <- create_text_run_block(doc_id = doc_id,
                                block_id = block_id,
                                block_type = 2,
                                block_name = "text",
                                content = content,
                                index = index)
}

# 创建block并写入H标题
heading_block <- function(doc_id, h, content, index = -1){

  if(h > 5) stop("The maximum H heading is 5")

  resp <- create_text_run_block(doc_id = doc_id,
                                block_type = 2+h,
                                block_name = paste0("heading",h),
                                content = content,
                                index = index)
}

# 创建image类型block,返回block_id
create_image_block <- function(doc_id, index, parent_block_id = NULL, max_attempts = retry_times){
  attempt <- 1
  if(is.null(parent_block_id)) parent_block_id <- doc_id
  api <- "{domain}/docx/v1/documents/{doc_id}/blocks/{parent_block_id}/children"
  url <- with(config_, stringr::str_glue(api))
  body <-
    list(
      index = index,
      children = list(
        list(block_type = 27,
             image = list(token = "")))) |>
    jsonlite::toJSON(auto_unbox = TRUE)

  repeat{
    response <- httr::POST(url, config_$req_headers, body = body)
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("create_image_block() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in create_image_block(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  block_id <-
    content(response) |>
    pluck("data", "children") |>
    map_vec(pluck("block_id"))

  return(block_id)
}

# 上传图片素材到指定parent_block_id,返回file_token
upload_image_to_block <- function(parent_block_id, image_file, max_attempts = retry_times){
  attempt <- 1
  size <- file.info(image_file)$size
  api <-  "{domain}/drive/v1/medias/upload_all"
  url <-  with(config_, stringr::str_glue(api))
  body <- list(
    file_name = image_file,
    parent_type = "docx_image",
    parent_node = parent_block_id,
    size = as.character(size),
    file = upload_file(image_file))

  repeat{
    response <- POST(url, config_$req_headers, body = body, encode = "multipart")
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("upload_image_to_block() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in upload_image_to_block(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  file_token <- content(response) |> pluck("data", "file_token")

  return(file_token)
}

# 更新block以显示图片素材
update_image_block <- function(doc_id, block_id, file_token, max_attempts = retry_times){
  attempt <- 1
  api <- "{domain}/docx/v1/documents/{doc_id}/blocks/{block_id}"
  url <- with(config_, stringr::str_glue(api))
  body <- list(replace_image = list(token = file_token))

  repeat{
    response <- PATCH(url, config_$req_headers, body = body, encode = "json")
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("update_image_block() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in update_image_block(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  return(response)
}

# 单张图片插入文档
# 组合调用函数：创建图片block、上传素材到图片block、更新显示图片block
img_block <- function(doc_id, image_file, index=-1){
  block_id <- create_image_block(doc_id, index)
  file_token <- upload_image_to_block(block_id, image_file)
  update_image_block(doc_id, block_id, file_token)
}

# 创建网格block
grid_block <- function(doc_id, n_col, index, max_attempts = retry_times){
  attempt <- 1
  api <- "{domain}/docx/v1/documents/{doc_id}/blocks/{doc_id}/children"
  url <- with(config_, stringr::str_glue(api))
  body <- list(
    index = index,
    children = list(
      list(block_type = 24,
           grid = list(
             column_size = n_col))))

  repeat{
    response <- httr::POST(url, config_$req_headers, body = body, encode = "json")
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("grid_block() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in grid_block(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  child <-
    content(response) |>
    pluck("data", "children") |>
    map(pluck("children")) |>
    unlist()

  return(child)
}

# 多张图片插入文档
# 组合调用函数，创建网格block、网格内创建图片block、上传素材到图片block、更新显示图片block
img_grid_block <- function(doc_id, image_files, index = -1){
  n_col <- length(image_files)

  grid_block_ids <- grid_block(doc_id, n_col, index)

  image_block_ids <-
    grid_block_ids |>
    map(~ create_image_block(doc_id, index, .)) |>
    unlist()

  file_tokens <-
    map2(image_files,
         image_block_ids,
         ~ upload_image_to_block(image_file = .x,
                                 parent_block_id = .y)) |>
    unlist()

  walk2(image_block_ids,
        file_tokens,
        ~ update_image_block(doc_id = doc_id,
                             block_id = .x,
                             file_token = .y))
}

# 插入分割线
hline <- function(doc_id, block_id = NULL, index = -1, max_attempts = retry_times){
  attempt <- 1
  if(is.null(block_id)) block_id <- doc_id
  api <- "{domain}/docx/v1/documents/{doc_id}/blocks/{block_id}/children"
  url <- with(config_, stringr::str_glue(api))

  body <- list(
    index = index,
    children = list(
      list(block_type = 22,
           divider = list())))

  repeat{
    response <- httr::POST(url, config_$req_headers, body = body, encode = "json")
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("hline() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in hline(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}
}

# 插入高亮块
highlight_block <- function(doc_id, block_id = NULL, back_col = 2, bord_col = 2, text_col = NA, emj = "bulb", index = -1, max_attempts = retry_times){
  attempt <- 1
  if(is.null(block_id)) block_id <- doc_id
  api <- "{domain}/docx/v1/documents/{doc_id}/blocks/{block_id}/children"
  url <- with(config_, stringr::str_glue(api))
  body <- list(
    index = index,
    children = list(
      list(block_type = 19,
           callout = list(background_color = back_col,
                          border_color = bord_col,
                          text_color = text_col,
                          emoji_id = emj))))

  repeat{
    response <- httr::POST(url, config_$req_headers, body = body, encode = "json")
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("highlight_block() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in highlight_block(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  items <- content(response) |> pluck("data", "children")
  block_id <- items[[1]]$block_id
  return(block_id)
}

# 提取元素块内的文本
extract_item_text <- function(item, dlt_title = TRUE){
  block_type <- item |> pluck("block_type")

  # extract title
  if(block_type == 1 & !dlt_title){
    content <-
      item |>
      pluck("page", "elements") %>%
      .[[1]] |>
      pluck("text_run", "content")

    return(content)
  }

  # extract heading
  if(block_type %in% 3:11){
    headings <- paste0("heading", 1:9)
    content <-
      headings |>
      map(~ pluck(item, .x)) |>
      keep(~ !is.null(.x)) %>%
      .[[1]] |>
      pluck("elements") %>%
      .[[1]] |>
      pluck("text_run", "content")
    return(content)
  }

  # extract text
  if(block_type == 2){
    content <-
      item |>
      pluck("text", "elements") %>%
      .[[1]] |>
      pluck("text_run", "content")
    return(content)
  }

  return(NULL)
}

# 提取云文档内的所有文本行
extract_doc_text <- function(doc_id, clean_null = TRUE, dlt_title = TRUE){
  resp <- get_doc_blocks(doc_id)

  items <-
    resp |>
    content() |>
    pluck("data", "items")

  content <-
    items |>
    map(extract_item_text, dlt_title)

  if(clean_null) content <- content |> keep(~ !is.null(.x))

  return(content)
}

# Spreadsheet API --------------------------------------------------------------

# 创建电子表格, 返回表格ID/标题/url
create_spreadsheet <- function(folder, title, max_attempts = retry_times) {
  attempt <- 1
  api <-  "{domain}/sheets/v3/spreadsheets"
  url <- with(config_, stringr::str_glue(api))
  body <- list(folder_token = folder, title = title)

  repeat{
    response <- httr::POST(url, config_$req_headers, body = body, encode = "json")
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("create_spreadsheet() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in create_spreadsheet(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  spreadsheet_token <- pluck(content(response), "data", "spreadsheet", "spreadsheet_token")
  title <- pluck(content(response), "data", "spreadsheet", "title")
  url <- stringr::str_glue("https://wrpnn3mat2.feishu.cn/sheets/{spreadsheet_token}")

  return(list(id = spreadsheet_token, title = title, url = url))
}

# 创建电子表格sheet, 返回子表id/标题/索引
add_sheet <- function(spreadsheetToken, title, index = 0, max_attempts = retry_times, wiki = FALSE){
  attempt <- 1
  if(wiki) spreadsheetToken <- trans_wiki_token(spreadsheetToken)
  api <- "{domain}/sheets/v2/spreadsheets/{spreadsheetToken}/sheets_batch_update"
  url <- with(config_, stringr::str_glue(api))
  body <- list(
    requests = list(
      list(
        addSheet = list(
          properties = list(
            title = title,
            index = index)))))

  repeat{
    response <- httr::POST(url, config_$req_headers, body = body, encode = "json")
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("add_sheet() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in add_sheet(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  plk <-
    content(response) |>
    pluck("data", "replies") |>
    map(pluck("addSheet"))

  sheetId = pluck(plk[[1]], "properties", "sheetId")
  title = pluck(plk[[1]], "properties", "title")
  index = pluck(plk[[1]], "properties", "index")

  return(list(id = sheetId, title = title, index = index))
}

# 读取电子表格指定范围数据, 返回列表结构 [["A1", "B1"], ["A2", "B2"], ...]
get_range <- function(spreadsheetToken, sheetId, range, valueRenderOption = "ToString", dateTimeRenderOption = "FormattedString", user_id_type = "union_id", max_attempts = retry_times, wiki = FALSE){
  attempt <- 1
  if(wiki) spreadsheetToken <- trans_wiki_token(spreadsheetToken)
  api <- "{domain}/sheets/v2/spreadsheets/{spreadsheetToken}/values/{sheetId}!{range}?valueRenderOption={valueRenderOption}&dateTimeRenderOption={dateTimeRenderOption}"
  url <- with(config_, stringr::str_glue(api))

  repeat{
    response <- httr::GET(url, config_$req_headers)
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("get_range() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in get_range(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  values <- content(response) |> pluck("data", "valueRange", "values")

  return(values)
}

# 读取电子表格指定范围数据, 返回dataframe结构, colname=TRUE时默认将第一行作为字段名,cleanNULL=TRUE时，默认清洗所有空行
get_range_to_df <- function(spreadsheetToken, sheetId, range, colname = FALSE, cleanNULL = TRUE, wiki = FALSE){

  res <- get_range(spreadsheetToken, sheetId, range, wiki = wiki)

  df <-
    res %>%
    do.call(rbind, .) %>%
    as.tibble()

  if(cleanNULL) {
    df <-
      df %>%
      filter(rowSums(. == "NULL") != ncol(.)) %>%
      filter(rowSums(. == "") != ncol(.))
  }

  if(colname) {
    df <-
      df %>%
      slice(-1) %>%
      setNames(unlist(df[1, ]))
  }

  # unnest
  df_unnested <- tryCatch({
    df %>%
      unnest(cols = everything())
  },
  error = function(e) {
    message("Warning: for this error “",
            e$message,
            "”Cast all data to strings")
    df %>%
      mutate(across(everything(), as.character)) %>%
      unnest(cols = everything())
  })

  return(df_unnested)
}

# 向电子表格指定范围写入数据，以列表结构入参
write_range <- function(val_ls, spreadsheetToken, sheetId, range, max_attempts = retry_times, wiki = FALSE){
  attempt <- 1
  if(wiki) spreadsheetToken <- trans_wiki_token(spreadsheetToken)
  api <- "{domain}/sheets/v2/spreadsheets/{spreadsheetToken}/values"
  url <- with(config_, stringr::str_glue(api))
  body <-
    list(
      valueRange = list(
        range = paste0(sheetId, "!", range),
        values = val_ls))

  repeat{
    response <- httr::PUT(url, body = body, config_$req_headers, encode = "json")
    if (status_code(response) %in% retry_statu_codes && attempt < max_attempts) {
      message(paste0("write_range() received ", status_code(response), " Retrying..."))
      Sys.sleep(2^attempt)
      attempt <- attempt + 1
    } else {break}
  }

  if(status_code(response) != 200){
    stop("Failed in write_range(), after multiple attempts. Status code: ", status_code(response), "\n",
         "Response content: \n", content(response))}

  return(response)
}

# 将dataframe数据框转换为入参格式并写入
write_df_to_range <- function(df, spreadsheetToken, sheetId, range, colname = FALSE, wiki = FALSE) {

  row_to_ls <- \(...) list(...) |> unname() |> as.list()

  val_ls <- pmap(df, row_to_ls)

  if(colname){
    val_ls <- c(list(as.list(names(df))), val_ls)
  }

  res <- write_range(val_ls, spreadsheetToken, sheetId, range, wiki = wiki)
  params <- content(res)

  if(params$code == 0) {
    updateRange <- pluck(params, "data", "updatedRange")
    updatedRows <- pluck(params, "data", "updatedRows")
    message(stringr::str_glue("write_df_to_range() success: updateRange {updateRange}, updateRows {updatedRows}"))
  }else{
    code <- pluck(params, "code")
    msg <- pluck(params, "msg")
    message(stringr::str_glue("write_df_to_range() failed: code {code}, msg {msg}"))
  }
  return(res)
}

# 伪清空指定range
clean_range <- function(spreadsheetToken, sheetId, range, wiki = FALSE){
  # 将电子表格英文索引转换为数字索引
  col_index <- \(col_str) {
    column_str <- toupper(col_str)
    num <- 0
    for (char in strsplit(column_str, "")[[1]]) {
      num <- num * 26 + (utf8ToInt(char) - utf8ToInt("A")) + 1
    }
    return(num)
  }

  # 计算range大小
  calculate_range <- \(range_str) {
    range_parts <- strsplit(range_str, ":")[[1]]
    start_cell <- range_parts[1]
    end_cell <- range_parts[2]
    start_col <- col_index(substr(start_cell, 1, regexpr("[0-9]", start_cell) - 1))
    end_col <- col_index(substr(end_cell, 1, regexpr("[0-9]", end_cell) - 1))

    num_rows <- as.numeric(sub("\\D+", "", end_cell)) - as.numeric(sub("\\D+", "", start_cell)) + 1
    num_cols <- end_col - start_col + 1

    return(c(num_rows, num_cols))
  }

  shape_n <- calculate_range(range)

  empty_mat <-
    matrix("", nrow = shape_n[1], ncol = shape_n[2])

  empty_vals <-
    lapply(1:nrow(empty_mat), \(i) {
      as.list(unname(empty_mat[i, ]))
    })

  res <- write_range(empty_vals, spreadsheetToken, sheetId, range, wiki = wiki)
  params <- content(res)
  if(params$code == 0) {
    updateRange <- pluck(params, "data", "updatedRange")
    updatedRows <- pluck(params, "data", "updatedRows")
    message(stringr::str_glue("clean_range() success: updateRange {updateRange}, updateRows {updatedRows}"))
  }else{
    code <- pluck(params, "code")
    msg <- pluck(params, "msg")
    message(stringr::str_glue("clean_range() failed: code {code}, msg {msg}"))
  }
  return(res)
}

# 纵向分割range,用于解决上传长度限制问题
split_range <- function(range, size = 5000){
  # 拆解range,计算长度
  range_parts <- strsplit(range, ":")[[1]]

  extr_col <- \(str) gsub("[^A-Za-z]", "", str)
  extr_row <- \(str) as.numeric(sub("\\D+", "", str))

  left_col <- extr_col(range_parts[1])
  left_row <- extr_row(range_parts[1])
  right_col <- extr_col(range_parts[2])
  right_row <- extr_row(range_parts[2])

  num_rows <- right_row - left_row + 1

  # 分割range
  split_intervals <- \(left_n, right_n, cut_size) {
    intervals <- list()
    start <- left_n

    while (start <= right_n) {
      end <- min(start + cut_size - 1, right_n)
      intervals <- c(intervals, list(list(left = start, right = end)))
      start <- end + 1
    }

    return(intervals)
  }

  # 重组range
  res <-
    split_intervals(left_row, right_row, size) %>%
    map(~{paste0(left_col, .x$left, ":", right_col, .x$right)}) %>%
    unlist()

  return(res)
}

# 分页伪清空长range
clean_longer_range <- function(spreadsheetToken, sheetId, range, cut_size = 5000, wiki = FALSE){
  sub_ranges <- split_range(range)
  sub_ranges %>%
    walk(~ clean_range(spreadsheetToken, sheetId, .x))
}

# 分页写入长数据框
write_ldf_to_range <- function(df, spreadsheetToken, sheetId, range, cut_size = 5000, colname = TRUE, wiki = FALSE){
  # 拆解range
  range_parts <- strsplit(range, ":")[[1]]

  extr_col <- \(str) gsub("[^A-Za-z]", "", str)
  extr_row <- \(str) as.numeric(sub("\\D+", "", str))

  left_col <- extr_col(range_parts[1])
  left_row <- extr_row(range_parts[1])
  right_col <- extr_col(range_parts[2])
  right_row <- extr_row(range_parts[2])

  # 拆分dataframe
  split_dfs <-
    df %>%
    split(ceiling(seq(nrow(df)) / cut_size))

  if(colname){
    # 首行写入字段名
    colname_row <- list(as.list(names(df)))
    colname_range <- paste0(left_col, left_row, ":", right_col, left_row)
    write_range(colname_row, spreadsheetToken, sheetId, colname_range, wiki = wiki)
    # 生成数据分页range
    all_range <-  paste0(left_col, left_row + 1, ":", right_col, nrow(df) + 1)
    sub_ranges <- split_range(range = all_range, size = cut_size)
    # 分页写入
    walk2(split_dfs,
          sub_ranges,
          ~ write_df_to_range(.x, spreadsheetToken, sheetId, .y, wiki = wiki))
  }else{
    all_range <- paste0(range_parts[1], ":", right_col, nrow(df))
    sub_ranges <- split_range(range = all_range, size = cut_size)

    walk2(split_dfs, sub_ranges,
          ~ write_df_to_range(.x, spreadsheetToken, sheetId, .y, wiki = wiki))
  }
}