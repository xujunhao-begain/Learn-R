#2021 年，商业科学公司创始人及数据科学专家 Matt Dancho(也是 tidyquant、timtk、modeltime 
#等包的贡献者)发表了一篇博文:“R is for Research, Python is for Production”提出了以下观点。
#对于做研究来说，R 在可视化、数据分析、生成分析报告以及用 shiny 制作 MVP 级应用等
#方面拥有卓越的性能。从概念(想法)到执行(代码)，R 用户完成这些任务往往能够比 Python 
#用户快 3~5 倍，从而使研究工作的效率很高。
#R 用在研究方面的优势体现在“文档沟通”，它是 tidyverse 整个数据科学流程的环节之 一。
#本章将主要围绕以下内容展开:
#1.可重复研究
#可重复研究是指将数据分析结果，以及更普遍的科学洞见，与数据和软件代码一起公布， 
#以便他人可以验证这些发现并在此基础上继续发展。
#可重复研究的优势如下。
#实现了可重复性的项目或论文，更便于与其他研究者和决策者交流研究结果，让他们可
#以快速、轻松地重现、验证、评估相关结果，并追溯结果是如何得出的。
#自己完成一篇论文并投稿到期刊，时隔几个月后重新修改并提交时，避免自己忘记所有
#的代码与分析过程是如何协同的。
#可重复研究的主要工具是R Markdown1，已嵌入RStudio中，为数据科学提供统一的编写
#框架，能够将代码、结果和文字叙述结合起来，是完全可改写的，并且支持几十种输出格式， 
#包括 html、pdf、word、ppt 等。
#可重复研究的另一工具是用于版本控制的 Git，这对于协作和跟踪代码与分析的“改动”至
#关重要
#2.网页交互
#Shiny 包可让你轻松创建丰富的交互式 Web 应用程序。Shiny 允许你使用 R 进行工作并通 
#过 Web 浏览器展示，以便任何人都可以使用。Shiny 可以轻松制作出可用于交互教学、交
#互数据报表等精巧的 Web 应用程序。
#3.开发R包
#R 项目已经能较好地组织某个项目相关的代码、数据等，更好、更易用的组织方式是开发
#成 R 包，同时也便于把你的代码分享给别人用。
#Jupyter Notebook是Python用户常用的可协作框架，也支持R，缺点是存储为JSON文件，
#不便于用Git跟 踪“改动”。
#6.1 R Markdown
#6.1.1 Markdown 简介
#Markdown 是一种可以使用普通文本编辑器编写的轻量化标记语言，通过简单的标记语法， 
#它可以使普通文本内容具有一定的格式。
#Typora 是一款好用的 Markdown 编辑器，Markdown 文件扩展名为.md，可导出 html、 
#word、pdf、latex 等格式的文件。
#Markdown 语法
#Markdown 就是为方便读写而设计的，非常简单易学。下面以对照的方式介绍最常用的 
#Markdown 语法。
#标题
#无序列表
#有序列表
#引用与文字
#下划线文本、高亮文本、下标、上标

#若要设置字体字号颜色，可以用 HTML 语法，如下所示
#<font color = red size = 5> 红色放大文字 </font>
#其他常用的 HTML 语法还包括用空行分段，用&emsp;缩进一个汉字，在输出控制符号时
#需要添加转义符号\，用---可以生成分割线。 
#数学公式，支持 Latex 语法
#高亮显示代码块
#插入图片(需提供本地图片的相对路径或完整路径，或网络图片的网址): 
#![图片描述](xxx.png){width = 80%}
#或者改用 HTML 代码:
#<img src="xxx.png" alt="图片描述" style="zoom:80%;"/> 
#若需要让图片居中显示，可以套一个<center>...</center>;若要添加图标题，一种
#简单的做法是，在图片下面增加一行文字:
#<center><b>图1</b> 标题文字</center>  插入超链接
#[超链接描述](超链接网址)
#绘制表格
#交叉引用
#脚注

#6.1.2 R Markdown 基础
#R Markdown 的主要开创者和发扬光大者是谢益辉。R Markdown 除了具备一般的 Markdown 
#语法功能之外，最关键的是用户可以在 R Markdown 中插入代码块，并能运行代码，且将
#代码运 行结果显示出来。
#使用 R Markdown 能够让用户只需关注内容创作，基于现成模板再加入少量自己的设置， 
#就可以自动化地制作以下文档:
#数据分析报告和文档(rmarkdown 包、officedown 包); 
#期刊论文(rticles 包);
#书籍(bookdown 包);
#个人简历(pagedown 包);
#个人博客网站(blogdown 包); 
#幻灯片(xaringan 包);
#交互报表(flexdashboard 包)。 
#使用 R Markdown 能够解决的痛点1如下。
#在用R或者其他数据分析工具时，经常需要在Word里写结论，在脚本里写代码， 在图表区
#生成图，将它们复制粘贴到一起后，还要担心格式问题。那么有没有什么自动化的方法呢?
#我的工作经常需要产出数据报告，如何创作一篇参数化、可复用的文档模板， 从此可以在
#更新数据的同时同步结论和图表?
#如何确保分析过程和结论是可重复的，别人是否能用同样的数据得到和我相同的结论?
#我不了解网页开发，如何在报告中插入可交互的图表和网页元素?
#R Markdown 文件是后缀名为.Rmd 的纯文本文件，.Rmd 文件的编译过程如图 6.11 所示
#当.Rmd 文件提交给 knitr 后，将执行代码块并创建一个新的包含代码和运行结果的 Markdown 
#文件(.md 格式)，再被 Pandoc 处理生成最终的输出文件。
#R Markdown 示例
#先看一个简单的 R Markdown 实例，需要先安装 rmarkdown 包。在 RStudio 中，依次单击 
#New File→R Markdown...，进入.Rmd 文件创建向导，如图 6.12 所示
#ioslides_presentation:ioslides幻灯片(html)
#slidy_presentation:slidy幻灯片(html)
#输出格式后面，还有很多可用的其他选项，如下所示
#toc_float:true:浮动目录
#number_sections:true:添加标题编号
#code_folding:hide:代码折叠
#fig_width:7, fig_height:6:固定图片宽和高
#fig_caption:true:添加图片标题
#df_print:kable:数据框输出表格样式
#highlight:tango:设置语法高亮
#theme:united:设置主题
#keep_md:true:保存中间.md文档
#citation_package:natbib:Latex参考文献格式用natbib宏包
#reference_docx:"template.docx":自定义word模板
#pdf_document 涉及 Latex 相关的选项将放在 6.2 节，这里再简单介绍一下如何使用自定
#义 word 模板。
#先创建一个输出到 Word 文档的.Rmd，在原始模板增加新的格式(内容随意)，比如三级标题、
#参考文献等，然后通过Knit to Word功能生成Word文档，打开所生成的文件可以继续在 
#Word 中进行修改，例如增加样式、修改格式等(内容随意)
#在.Rmd 的 yaml 中设置输出格式: output:
#通过上述代码则可以使用该参考模板(template.docx)，并在编译 Word 文档时，读取模板
#中的样式并将其应用到新文档中
#目前，R 与 Office 深度交互已有 officeverse 系列包，具体如下
#officer 包:用 R 生成 Word/PowerPoint
#officedown 包:用 R Markdown 与 Word 或 PowerPoint 进行沟通
#flextable 包:定制精美表格
#mschart 包:根据数据绘制 Office 风格图形
#rvg 包:生成可修改的矢量图
#更多细节可参阅 officeverse 文档。更多的 YAML 设置方法可参阅相关书籍或包文档
#另外， yaml 的设置还可以借助 ymlthis 包，完成图形交互界面

#2.代码块
#第 8~10、18~20、26~28 行是代码块，位于```{r}和```之间，表示 R 语言代码块
#(快 捷键:Windows 系统用 Ctrl + Alt + I;Mac 系统用 Cmd + Option + I)。
#reticulate 包也支持 Python 代码，还支持 Shell、SQL、Stan、C/Fortran、C++、 Julia、
#JavaScript/CSS 以及 SAS、Stata 等代码，但有些需要配置相应的开发环境。
#1 可选语法高亮有:“default”“tango”“pygments”“kate”“monochrome”“espresso”
#“zenburn”“haddock”“textmate”。
#2 可选主题有:“default”“cerulean”“journal”“flatly”“readable”“spacelab”“united”“cosmo”“lumen”“paper”
#“sandstone” “simplex”“yeti”。
word_document:
  reference_docx: "template.docx"

#语言名后面跟着的词语是该代码块的命名，可在导航栏按名字浏览代码块，让代码生成的
#图形有意义地命名，避免在缓存中重复计算。
#代码块命名之后用逗号隔开的是块选项，用来控制代码和运行结果的输出方式。常用的块
#选项(只写非默认情形)如下所示
#eval = FALSE:只显示代码，不运行代码
#echo = FALSE:不显示代码，只显示运行结果
#include = FALSE:运行代码，不显示代码和运行结果
#tidy = TRUE:整洁代码格式
#message = FALSE:不输出提示信息，例如包的载入信息
#warning = FALSE:不输出警告
#error = TRUE:忽略错误，继续编译文档
#collapse = TRUE:把代码块结果放在一个文本块
#cache = TRUE:缓存运行结果，能加速后续再编译
#其他选项如下所示
#results = "hide":隐藏输出结果。
#fig.width、fig.height、fig.align、fig.cap:设置输出图形的宽和高(英寸)、对齐、标题
#out.width 和 out.height:设置输出图形的宽和高(百分比)
#例如，设置代码块不输出代码本身、消息、警告，只输出运行结果:
#这些块选项虽然可以在每个代码块局部设置，但更建议优先进行全局设置，比如针对示例
#中的第 8~10 行，进行如下设置:
#这相当于让全局所有代码块都“不显示代码，只显示运行结果”，有特殊需要的代码块再进
#行局部设置。
#另外，R Markdown相比Jupyter Notebook的一个主要优势是Markdown支持行内代码，即
#在文字叙述中间使用R代码，基本格式是'r ...'，例如:渲染后，上述回归系数将变成具体数值。
3.插入图片、表格
对于可以用 R 代码绘制的图形，直接在代码块绘制即可。 插入图片不仅可以使用前面介绍的 Markdown 语法，也可以使用 knitr:: include_
graphics()函数法，如下所示。
另外，RStudio 从 1.4 版本开始，提供了可视化 Markdown 编辑器，如图 6.14 所示，单 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```
6.1 R Markdown 239
```{r echo = FALSE, message = FALSE, warning = FALSE} # 具体代码
```
mdl = lm(mpg ~ disp, mtcars)
b = mdl$coefficients
上面回归方程的斜率为`r b[2]`, 完整的回归方程为`r mpg = b[1] + b[2] * disp`。
```{r, echo=FALSE， out.width="50%", fig.cap="图标题", fig.align="center"} knitr::include_graphics("xxx.png")
```

240 6 文档沟通
击编辑窗口右上角的 Visual 按钮可切换过去。
图 6.14 启用可视化 Markdown 编辑器
这就相当于是 Markdown 编辑器，以菜单操作的方式实现各种 Markdown 语法。单击“插 入图片”按钮，浏览找到图片即可完成插入，插入图片下方可以调整图片大小。
插入简单表格可以用前文介绍的 Markdown 语法，也可以切换到可视化 Markdown 编辑器， 单击“插入表格”按钮，类似 word 中的插入表格操作。
对于现成的数据框或矩阵，可以用 knitr::kable()函数生成简单的表格，参数 align 用于设置各列对齐方式，digits 用于设置小数位数，col.names 用于设置新列名，caption 用于设置表标题:
  knitr::kable(mtcars[1:3,1:7], align = "lccrr", digits = 2,
               Markdown 语法的表格代码的渲染效果(因模板而异)如表 6.1 所示。
               col.names = str_c("x", 1:7), caption = "部分iris数据")
x1
x2
x3
x4
x5
x6
x7
Mazda RX4 Mazda RX4 Wag Datsun 710
6.1.3 表格输出
表 6.1 21.0 6
21.0 6 22.8 4
部分 iris 数据 160 110
160 110 108 93
3.90 2.62 3.90 2.88 3.85 2.32
16.46 17.02 18.61
有十几个包致力于通过 R 语言编程做出更加精美的表格，其中较优秀的几个如下所示。
 kableExtra 包:knitr::kable()的扩展，支持管道，可生成复杂精美的 html 或
LaTeX 表格。
 huxtable 包:支持更全面的输出格式，特别是 Latex 输出，拥有丰富的自定义功能。
 flextable 包:从 R Markdown 创建用于报告或出版的 html、pdf、Word、
PowerPoint 等文件中的表格。
 gt 包:由 RStudio 出品，用整洁语法组合不同的表格组件并创建表格，暂不支持 Latex
和 pdf 输出格式。
 DT 包:多与 Shiny 配合，将数据表渲染成 HTML。
 reactable 包:基于 React-Table 库的交互表格。
这几个包的操作和功能是类似的，都是通过相应函数精细控制，比如单元格背景、边框、 对齐方式、颜色、数字格式等。下面用 huxtable 包演示两种常用的制表。
(1)导出三线表到 Word 文件
通过更擅长与 Office 交互的 flextable 包实现，这里只演示几个功能:增加标题、带合
异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权

并列的题头行、文字对齐、颜色、加粗、合并单元格、高亮文字。
library(flextable)         # word, ppt
若只运行到 save_as_docx()之前，则在 Viewer 窗口显示结果表格。最终写入 Word 的 效果如图 6.15 所示。
6.1 R Markdown 241
iris[1:5,] %>%
  flextable() %>%
  set_caption("定制表格示例") %>%
  add_header_row(colwidths = c(2, 2, 1), values = c("Sepal", "Petal", "")) %>% align(align = "center", part = "all") %>%
  color(color = "red", part = "header") %>%
  bold(bold = TRUE, part = "header") %>%
  merge_v(j = 3:4) %>%
  highlight(i = ~ Sepal.Length < 5, j = 1, color = "yellow") %>% save_as_docx(path = "output/threelinetable.docx")
(2)将统计模型结果整理成模型结果汇总表 期刊论文经常要求将统计模型结果以规范格式 的表格展示，以最常用的回归分析结果表为例， huxtable 包中的 huxreg()函数可以实现此类表
格，但更好用的是 modelsummary 包。 modelsummary 包基于 broom 和 broom.mixed 整洁模型结果，可与上述 4 个表格包连用，制作精 美的可定制统计模型结果表格，支持各种常见输出
图 6.15
自动生成三线表
格式。
模型汇总表通常是希望直接用到论文中，这就需要 pdf 格式或 latex 代码，用
modelsummary()函数，可接受多个模型对象的 list, 选择相应的参数定制想要的表格，这里 只演示修改参数名、标记显著性星号、小数位数、表标题、不输出部分统计量，更多参数设置 请查阅帮助。
若上述定制已能满足要求，可以设置参数output = "file.tex"等，可将表格直接导出 到文件;否则，可以设置输出到其他表格对象，比如 output = "huxtable"，则得到 huxtable 表格对象，这就相当于转到 huxtable 包，继续做相应的美化修改，再导出到文件。
df = read_csv("data/Guerry.csv")
 先用 modelsummary()定制回归分析结果表，将表导出为 huxtable 对象并做一些美 化:增加带合并的表头行、设置第 4 行(Literacy 所在行)字体颜色，设置第 5 行(Priests 所在行)背景色;再导出到 pdf(对于中文文件存在编码问题)。
library(modelsummary)
导出到 pdf 的表格效果如图 6.16 所示。 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
models = list(
  "OLS" = lm(Donations ~ Literacy + Clergy, data = df),
  "Poisson" = glm(Donations ~ Literacy + Commerce, family = poisson, data = df))
cm = c("(Intercept)" = "Constant", "Literacy" = "Literacy (%)",
       "Clergy" = "Priests/capita")
cap = "Regression Tables with moelsummary"
library(huxtable)          # pdf
modelsummary(models, output = "huxtable", coef_map = cm,
             stars = TRUE, fmt = "%.2f",
             title = cap, gof_omit = 'IC|Log|Adj') %>% # 转到 huxtable set_text_color(row = 4, col = 1:ncol(.), value = "red") %>% set_background_color(row = 6, col = 1:ncol(.), value = "lightblue") %>% quick_pdf(file = "output/tablepdf.pdf")
  
  242 6 文档沟通
图 6.16 将回归结果表导出到 pdf 效果
 若要将表格导出到 latex 源代码，需要设置 output = "latex"，并在 kableExtra 下美化，再用 save_kable()保存到.tex 文件，代码如下:
  library(kableExtra)      # latex
导出到.tex 的 latex 代码效果如图 6.17 所示。
图 6.17 导出到 latex 文件的效果
注意:从回归模型对象到 latex 代码的结果表，也可以用 stargazer 包或 gtsummary 包实现。另外，
bruceR 包支持很多统计模型建模与输出结果表。
最后，R Markdown 的可重复报告，通常是先建立分析模版，然后再通过自动加载数据的方式，
自动化生成分析报告。比如，想要只更换数据集就能生成同样格式的分析结果报告，操作如下。
modelsummary(models, output = "latex", coef_map = cm,
             stars = TRUE, fmt = "%.2f",
             title = cap, gof_omit = 'IC|Log|Adj') %>%
  add_header_above(c(" " = 1, "Donations" = 2)) %>%
  row_spec(3, color = "red") %>%
  row_spec(5, background = "lightblue") %>%
  save_kable("output/modeltable.tex")
# 转到 kableExtra
异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权

 先准备一份可重复使用的报告模板:可重复报告.Rmd，在其 yaml 中设置传递数据集的 参数 name(将用来传递数据集名字)，name 可在标题中直接使用，正文中要获取该名字 的数据集，可以用`df = get(params$name)`:
  ---
  6.2 R 与 Latex 交互 243
title: "数据概览:`r name`" author: "张敬信"
date: "`r Sys.Date()`" params:
  name: "input your data name"
output: html_document
---
  ## 输出数据概要
  ```{r}
df = get(params$name)
summary(df)
```
 接着，只需要让“可重复报告.Rmd”在若干个数据集名字构成的字符向量上，重复应用 函数 render()(渲染)即可，只批量地生成结果报告不需要返回结果, 适合用 walk():
  library(rmarkdown)
注意:你也可以直接在 .Rmd 中使用当前内存变量。
6.2 R 与 Latex 交互
Latex 是高质量的专业排版系统，具有强大的数学公式排版功能，非常适合生成高印刷质 量的科技和数学类文档。Latex 需要编写代码再编译成 pdf，缺点是不像 Word“所见即所得”。 Latex 现在已广泛应用于书籍、期刊论文、毕业论文、学术报告、简历等排版。
对于大多数普通用户来说，只专注于使用现成的 Latex 模板即可，模板已包含了全部的文 档格式，只需要替换成相应的内容。
R Markdown 就是将 Latex 排版融入进来:Rmd -> md -> tex -> pdf，最终输出 pdf 文档1，顺 便解决了“插入代码块，并能运行代码，将代码运行结果显示出来”的问题。
6.2.1 Latex 开发环境
Latex 的主流开发环境是 TexLive(2021 版安装包已达 4.1GB)，编辑器可以选用 Texwork、TexStudio、VScode 等。
对于 R 用户，强烈建议使用谢益辉专为 R Markdown 开发的，超轻量级的 Latex 环境— TinyTex + RStudio。
TinyTex 只保留了编译 Latex 的核心组件以及少量常用宏包，大小只有 200 多 MB。对于使 用过程中缺少的宏包，可根据需要自动下载安装。
为了更方便地在 R 环境中使用 Latex，谢益辉还开发了 tinytex 包，该包提供了各种方便操 作 Latex 的函数。
1R Markdown输出pdf文档的另一条路线是pagedown包:Rmd->md->html->pdf。 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
names = c("iris", "mtcars", "CO2")
purrr::walk(names,
            ~ render("Reproducible.Rmd", params = list(name = .x), output_file = paste0(.x, "分析报告.html")))

244 6 文档沟通
1.安装 TinyTex
建议先从 https://yihui.org/tinytex/TinyTeX.zip 下载到本地(比如 D 盘根目录)，再用命令从 本地安装。
注意，下述命令都是在 Console 窗口执行。 library(tinytex)
参数 pkg 指定 zip 文件路径，还有参数 dir 可以设置安装路径，安装成功后可通过以下 命令查看:
  2.基本使用
 修改国内镜像源
因为用的时候，不可避免需要下载宏包，所以先修改为国内镜像源，比如改为清华大学的 镜像源，命令如下:
  tinytex:::install_prebuilt(pkg = "D:/TinyTeX.zip") # tinytex::uninstall_tinytex() # 卸载TinyTex
tinytex_root() # 查看安装路径
tl_pkgs() # 查看已安装宏包
tlmgr_repo(url = "http://mirrors.tuna.tsinghua.edu.cn/CTAN/")
 简单测试
在RStudio中新建Text File，输入Latex代码，
保存的时候，后缀名用.tex，即保存为 Latex 文件，如 图 6.18 所示。
单击Compile PDF按钮，启动编译。英文tex文 档一般用 pdflatex 编译，中文 tex 文档特别是涉及使用 系统自带中文字体的情况，需要用 xelatex 编译。在 Tools -> Global Options -> Sweave可修改该默认编译 方式。
因为缺少支持中文的宏包 ctex, 所以会报错，可 以通过以下命令解析报错日志文件:
  parse_packages("test.log")
会告诉缺少的宏包名，则安装它:
  tlmgr_install("ctex")
图 6.18
在 RStudio 中编写 Latex 文件
等待安装完成再重新编译即可。若缺少宏包较多，你可能需要这样反复操作很多次。因此 更建议直接用命令编译(系统会自动下载安装所有缺少的宏包):
  xelatex("test.tex")
编译成功，将在当前路径下，生成 test.pdf。有时候编译不成功，可能是缺少宏包，也 可能是因为系统缺少字体，需要手动下载再安装。
至此，你已经成功搭建了 Latex 开发环境，该环境完全可以取代 TexLive，也能编译.Rmd 到 pdf 文档。
6.2.2 Latex 嵌入 Rmd
Latex 模板可以直接在 TinyTex + RStudio 开发环境使用，但是要嵌入 Rmd 模板需要做一定
异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权

的移植工作，对于大多数用户来说，会使用别人移植好的模板就够了。
1.用 Latex 输入数学公式
配置了上述环境，Rmd 文档就可以使用 Latex 代码输入数学公式，还能编译成 pdf 和 html 等格式。
行内数学公式用$...$，行间数学公式用$$...$$. 看一个多行数学公式的例子: $$
  bnh
a fxdx 2fx fx
h n1
 2  f a f b  h 
f x  i
k1
另外，mathpix 软件支持对数学公式进行截图，甚至对整页 PDF 进行截图，还可以将相关 内容转换成 Latex 代码。
2.Latex 选项
一些控制 Latex 编译的选项可以在 yaml 中进行设置，例如: output:
  6.2 R 与 Latex 交互 245
\begin{aligned}
\int_a^b f(x) \mathrm{d}x & \approx \sum_{k=1}^n \frac{h}{2} [f(x_{i-1}) + f(x_i)] \\
\end{aligned}
$$
  & = \frac{h}{2} [f(a) + f(b)] + h \sum_{k=1}^{n-1} f(x_i)
i1 i k1
pdf_document:
  latex_engine: xelatex
citation_package: natbib
keep_tex: true
includes:
  in_header: preamble.tex
before_body: doc-prefix.tex
after_body: doc-suffix.tex
template: quarterly-report.tex
fontsize: 11pt
geometry: margin=1in
上述命令分别用于设置编译引擎、参考文献风格宏包、保存中间.tex 文档、在篇头/正文前/ 正文后包含 tex 文件、使用自定义模板、字体大小、页面布局页边距。
6.2.3 期刊论文、幻灯片、书籍模板
下面介绍一些常用模板及其使用方法。
1.期刊论文模板
安装rticles包后，在新建R Markdown时选择From Template，则多出很多可用的期刊 模板，如图 6.19 所示。
这里列出的几乎都是英文期刊模板，其中 CTEX documents 是支持中文的期刊模板。这些模 板都是简单的示例，内容就是讲解怎么使用，根据实际需求修改调试即可。
2.幻灯片模板 (1)xaringan 包
该包由谢益辉开发，安装后再从 From Template 选择模板时，有两种类型。 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权

246 6 文档沟通
图 6.19 从期刊模板新建 Latex 文档
 Ninja Presentation:英文幻灯片。
 Ninja Presentation (Simplified Chinese):中文幻灯片。
基本与普通 Rmd 一样的语法，采用“---”换页，更多语法可参阅模板内容和官方教程。
单击 Knit 按钮可编译成 HTML，也可以为 RStudio 安装 Infinite Moon Reader(无限月读)插 件，在 Viewer 窗口实时预览幻灯片(保存则自动编译)。
另外，xaringanthemer 包提供了更多主题，xaringanExtra 包提供了更多的扩展功能。 其他生成HTML幻灯片的方式，还包括新建Rmd，选择Presentation -> HTML (ioslides)/HTML (Slidy)。
(2)PPT 模板
新建 Rmd，选择 Presentation -> PowerPoint，或者从 From Template 中选择 officedown 包提
供的 Advanced PowerPoint Presentation 模板。
还可以使用 Office 自带的 PPT 模板，作为自定义模板: output:
  单击 Knit -> Knit to PowerPoint 可启动编译，并等待生成 PPT。 (3)R Beamer 模板
Beamer 是 Latex 下的一类幻灯片模板，R Markdown 已将其移植过来。新建 Rmd，选择 Presentation -> PDF (Beamer)，即可开始使用。
Beamer 在 Beamer 主题矩阵页有大量的主题可选，在 yaml 中设置主题名即可使用。注意， 原始 R Beamer 模板只支持英文，要想使用中文，需要修改编译引擎为 xelatex，并加载 ctex 宏包， 修改方式如下所示:
  output:
  单击 Knit -> Knit to PDF(Beamer)可启动编译，等待生成 PDF。 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
powerpoint_presentation:
  reference_doc: my-styles.pptx
beamer_presentation:
  latex_engine: xelatex
theme: "Madrid"
colortheme: "dolphin"
fonttheme: "structurebold"
header-includes:
  - \usepackage{ctex}

3.书籍模板
纯 Latex 格式的书籍模板可以在 Latex 开发环境下运行，但不能包含并运行程序代码。谢益 辉开发的 bookdown 包是 R Markdown 向书籍模板的扩展，使 Rmd 可以支持章节结构、公式图 表、自动编号、交叉引用、参考文献等适用于书籍编写的功能。
谢益辉在 GitHub 提供了中英文的最小 bookdown 书籍示例模板。  bookdown-demo:英文书籍。
 bookdown-chinese:中文书籍。
 bookdownplus 包:更多的 bookdown 书籍模板。
另外，Elegantbook 是邓东升和黄晨成开发的格式非常精美的 Latex 书籍模板，黄湘云和叶 飞将其移植到 ElegantBookdown，本书的原始书稿就是基于此模板编写，特此表示感谢!
  下载 Bookdown 书籍模板解压，源文件是在一个 R 项目中管理，打开 bookdown-demo. Rproj 可统一管理所有文件，如图 6.20 所示。
图 6.20 bookdown 书籍模板源文件
书籍与期刊论文没有本质上的区别，只是因为书籍结构更庞大，而被拆分成更多的文件， 当然也涉及相互的串联。
(1)文件结构 书籍一般包含多章，每章是一个Rmd文件(必须UTF-8编码)，每章章头是一级标题:# 章
  名;因为 index.Rmd 里面包含部分 yaml，所以总是第 1 个出现，其他的默认按文件名顺序，当 然也可以在 yaml 中定义顺序:
  rmd_files:
  在定义章节时，可以同时定义其交叉引用: ## 节标题 {#sec1}
  ...
\@{#sec1}
  6.2 R 与 Latex 交互 247
  - "index.Rmd"
  - "01-intro.Rmd"
  - "02-basic.Rmd"
  异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
  
  248 6 文档沟通
  章节是默认编号的，若不体现编号，则需要按以下方式设置# Preface {-}。
  另外，bookdown 包括的文件类型及用途如下:.yml 文件用于设置 yaml;.tex 文件都是需要 在正文前加入的设置和定义 Latex 相关的内容;.bib 是参考文献;相关的数据、脚本、图片都可 以分别放在一个文件夹中。
  (2)交叉引用
  bookdown 包也提供了图、表、公式的交叉引用(非 Latex 中的交叉引用)，目前支持编译成
  html、pdf、Word 格式，需要在 yaml 中按以下方式设置:
    output:
    bookdown::html_document2: default
  bookdown::pdf_document2: default
  bookdown::word_document2: default
  图、表交叉引用需要在相应的图、表代码块起名，再用\@ref()引用名字。例如
  plot(cars)
  ```
  见表\@ref(tab:mtcars):
    ```{r mtcars, echo=FALSE}
  knitr::kable(mtcars[1:5, 1:5], caption = "汽车数据") ```
  数学公式需要用 Latex 语法生成带编号的公式，同时对公式起名，再用\@ref()引用。例如
  \begin{equation}
  \bar{X} = \frac{\sum_{i=1}^n X_i}{n} (\#eq:mean) \end{equation}
                                        由式\@ref(eq:mean)可得，...
                                        使用脚注需要先在标脚注的文字处标记“^[脚注名]”，再另起一段以“^[脚注名]:”开头并 在后面补充脚注内容。例如:
                                          R Markdown 支持 bib 参考文献，所有参考文献放一起作为.bib 文件，比如: @Book{zhaopeng2021,
                                            year = {2021},
                                            edition = {1},
                                            note = {},
                                          }
                                        然后在正文里使用[@zhaopeng2021]引用该文献。Zotero 软件可以很方便地管理参考文 献，将文献批量导出到一个.bib 文件中。
                                        (3)环境与中文
                                        bookdown 提供了定理类环境:theorem、lemma、corollary、proposition、definition、example、
                                        exercise 等，其交叉引用与引用公式类似，需用到相应的缩写 thm、lem、cor、prp、def、exm、 exr。例如:
                                          如图\@ref(fig:cars-plot)所示:
                                          ```{r cars-plot, fig.cap="汽车散点图", echo=FALSE}
                                        R markdown ^[ft1] 是文档沟通的利器，目前已发展出了很多的生态。 ^[ft1]: R markdown由谢益辉开发。
                                        title = {现代统计图形},
                                        author = {赵鹏, 谢益辉, 黄湘云}, publisher = {人民邮电出版社}, address = {北京},
                                        ::: {.theorem #weakconv name="弱若收敛定理"} $\xi_n$依分布收敛到$\xi$，当且仅当对任意$\mathbb R$上的一元实值连续函数$f(\cdot)$ 都有
                                          $$
                                            E f(\xi_n) \to E f(\xi), \quad n \to \infty
                                          $$
                                            :::
                                            异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                          
                                          然后这样引用:
                                            由定理\@ref(thm: weekconv) 得......
                                          中文书籍除了需要如前文所述设置 xelatex 引擎和中文字体之外，图、表、章节标题、定理 类关键字也要改成中文:
                                            language:
                                            (4)编译成书
                                          bookdown 可以编译成 HTML、WORD、PDF、Epub 等书籍格式。
                                          单击右上窗口的 Build -> Build Book -> bookdown::pdf_book 启动编译，其他可选的格式还有
                                          All Formats、bookdown::git_book、bookdown::epub_book。
                                          若要导出到 Word，需要在_output.yml 文件的 yaml 代码部分增加以下内容:
                                            bookdown::word_document2:
                                            toc: true
                                          此时会在 Build Book 下拉菜单出现 bookdown::word_document2 选项。
                                          另外，bookdown 还提供了 publish_book()函数让你很方便地将书籍发布到网上进行分享。 很多 R 语言爱好者都热爱分享自己用 bookdown 创作的书籍，bookdown 网站也是寻找 R 语言书 的好网站。
                                          最后，再简单介绍一下正在快速兴起的新一代文档沟通工具— Quarto。Quarto 是 RStudio 推出的支持多种语言的下一代 R markdown, 包括几十个新的特性和功能，同时能够渲染大多数 现有的 Rmd 文件而不需要修改。Quarto 的安装与基本使用，可参阅 Quarto 官网的相关资料。
                                          Quarto 的主要特性包括:
                                            6.3 R 与 Git 版本控制 249
                                          label:
                                            fig: "图 " tab: "表 " thm: "定理"
                                          ui:
                                            edit: "编辑"
                                          chapter_name: ["第 ", " 章"]
                                             
                                          
                                          6.3
                                          6.3.1
                                          它是建立在 Pandoc 上的开源科技出版系统;
                                          支持用 Python、R、Julia 和 Observable 创建动态内容;
                                          可以用纯文本 markdown 或 Jupyter 笔记本的形式编写文档;
                                          以 HTML、PDF、MS Word、ePub 等格式发布高质量的文章、报告、简报、网站、博客 和书籍;
                                          支持用 markdown 进行科学创作，包括公式、文献引用、交叉引用、图形面板、插图编 号、高级布局等。
                                          R 与 Git 版本控制 Git 版本控制
                                          数据科学家通常是独立工作并与其他人共享随时间变化的文件、数据和代码。版本控制是 一个框架和过程，用于跟踪对文件、数据或代码所做的修改，其好处是你可以将文件恢复到以 前的任何修改或时间点，你可以在同一个材料上与多人并行工作。
                                          版本控制可以作为一种备份的方式，但真正发挥作用是在合作项目中。项目一般由多人协
                                          异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                          
                                          250 6 文档沟通
                                          同，并涉及一系列常见步骤，例如:  下载/收集数据;
                                           清洗/变换数据;
                                           分析和可视化数据;
                                           生成精美的结果报告。 这些任务相互重叠或相互依赖，复杂的合作项目需要预先考虑如何设置，以便每个人都能
                                          将自己的贡献无缝衔接到项目的整体结构中，而不会耽误其他团队成员的进程。有了版本控制，
                                          如果你所做的修改破坏了某些东西，很容易通过提交时间线恢复到较早的工作版本。
                                          Git 和 GitHub 是常用的基于云服务的版本控制工具，能够准确控制文件“版本”。这些版本 是你工作过程的快照，有唯一的标识符和简短的提交信息，让你能够在任何时间点恢复这些更 改。Git 对特定用户的特定修改提供了更精细的控制，使版本控制成为一个非常强大的工具。
                                          Git 和 GitHub 有什么区别?
                                             Git 是版本控制软件，安装在你的计算机上，有相关的命令用来与版本控制的文件互动;
                                           GitHub 是与 Git 对接的网站，允许我们将文件作为仓库进行存储、访问、共享;同时 GitHub
                                          也是目前全球最大的代码托管网站，里面有着世界各地程序员分享的海量程序代码。
                                          注意:在国内访问 GitHub 容易失败，可以换成 gitee(码云)访问，gitee 可称为 GitHub 的国内汉化版， 所有操作几乎是一样的。
                                          6.3.2 RStudio 与 Git/GitHub 交互
                                          1.安装并配置 Git
                                          到 GitHub 官网注册账号。
                                          到 Git 镜像站下载对应系统版本的 Git 软件并安装，在安装过程中，所有选项保持默认即可。 重启 RStudio 会自动检测并关联到 Git。
                                           配置 Git(只需配置一次)
                                          可以通过 Git Bash 操作，更简单的方法是用 usethis 包:
                                            library(usethis)
                                          use_git_config(user.name = "zhjx19", user.email = "zhjx_19@163.com")
                                          其中用户名和 Email 建议用 GitHub 注册的用户名和 Email。  用 SSH 连接 GitHub(只需配置一次)
                                          使用 SSH 协议可以连接和验证远程服务器和服务。用 SSH 密钥，就不必在每次 RStudio 与 GitHub 交互时提供一遍 用户名和密码。在将代码上传到 GitHub 时，就需要用 SSH。
                                          在 RStudio 中，依次单击 Tools -> Global Options -> Git/SVN，单击 Create RSA Key，弹出窗口如图 6.21 所示， 单击 Create，完成后再点击 View Public key。
                                          复制图 6.21 所示的所有 key 码，然后转到 GitHub，依 次单击头像 -> Settings -> SSH and GPG keys -> New SSH key。如图 6.22 所示，将复制的内容粘贴到 Key 框，单击
                                          “Add SSH key”，若验证成功则会显示图 6.23 所示的界面。
                                          创建并查看 RSA Key
                                          图 6.21 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                          
                                          图 6.22 GitHub 添加 RSA Key
                                          图 6.23 添加成功
                                          2.创建仓库
                                           创建 GitHub 远程仓库
                                          登录GitHub网站，在个人主页单击Repositories -> New，创建一个新仓库(Repository)，
                                          比如起名为“test-demo”，选择 Public(公共仓库)，勾选下面的 Add a README file，单击 Create repository，则成功创建了 test-demo 仓库。
                                          提示:你也可以 fork 别人的公共仓库到自己名下使用。  克隆仓库到本地
                                          进入 GitHub 仓库页面，单击 Code 按钮(如图 6.24 所示)，单击“复制”按钮复制 HTTPS 或者 SSH(更推荐)下的仓库地址备用。
                                          图 6.24 复制 GitHub 仓库地址
                                          在 RStudio 中，依次单击 Creat Project -> Version Control -> Git。如图 6.25 所示，在 Repository
                                          异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                          6.3 R 与 Git 版本控制 251
                                          
                                          异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                          
                                          通常每个团队成员都分别创建自己的分支，这些分支都来自主分支。
                                          负责分支项目的成员的一般工作流程如下。
                                          (1)暂存(Staged) 做一些工作:文件新建/修改/删除。为了对这些变化进行版本控制，需要对这些工作进行暂
                                          存(stage)，以便相关操作能被 Git 版本化。
                                          例如，创建 data 文件夹，放入 5 个学生成绩的 xlsx 文件，新建 R 脚本 read_datas.R，脚本
                                          的内容是批量读取这些数据文件。
                                          所有新增加或修改过的文件都会在 Git 窗口显示出来，添加之前 Status 按钮是黄色的，勾选
                                          Staged 下面的选框，Status 按钮变成绿色则完成添加，如图 6.27 所示。
                                          图 6.27 Staged:暂存修改
                                          (2)提交(Commit) 填写简洁的描述性的提交信息，如果你想回到过去查看不同版本的东西，这些信息是可看
                                          的，为了方便回看，请添加一些有用的信息。
                                          在 Git 窗口中，单击 Commit 按钮，弹出 Review Changes 窗口，在 Commit Message 窗口中
                                          填写提交信息，如图 6.28 所示。
                                          图 6.28 Commit:提交
                                          单击 Commit 进行提交，等待完成。 (3)提交(Push)到“Collect_Datas”分支
                                          准备好本地提交的修改后，就可以将其推送到 GitHub 远程云仓库。记住，你可以随心所欲 地提交，并在一天结束时推送，或在每次提交时推送，时间戳标识符是随着提交信息添加的， 而不是随着推送添加的。
                                          单击 Push 按钮提交到“Collect_Datas”分支，等待完成(若 GitHub 网络有问题，则不能提 交上去)。提交成功后，在 GitHub 仓库页面，多了一条 Compare & pull request，如图 6.29 所示。
                                          4.拉回请求(pull request) 版本控制的下一步是将刚才项目成员的工作从“Collect_Datas”分支转移到主分支(main)，
                                          异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                          6.3 R 与 Git 版本控制 253
                                          
                                          254 6 文档沟通 这就要用到“拉取请求”。
                                          图 6.29 Push 步:提交并查看
                                          拉回请求是一种在合并到仓库之前提出和讨论修改意见的工具，检查是否有冲突(比如大 家可能在同一个文件上工作)，然后将这些修改合并(merge)到主分支。也可以删除
                                          “Collect_Datas”分支，再创建一个分支来处理下一个任务，如此反复。
                                          单开 Compare & pull request 按钮，可以填写一些额外的描述、评论，关于该拉回请求正在
                                          做什么以及为什么，并为审查者(项目合作者)添加标签、重要事件等。这些都有助于跟踪哪 些工作已经完成，哪些尚未完成。
                                          然后单击 Create pull request 按钮，我们期望看到“This branch has no conflicts with the base branch(本分支与基础分支没有冲突)”，这意味着我们的主分支可以很容易地将这项新工作 合并进来!若有合并冲突则需要尝试解决它。
                                          继续单击 Merge pull request 按钮，等待出现“Pull request was successfully merged and closed (拉回请求被成功合并和关闭)”!
                                            注意:拉取请求的另一种常见用途是，分叉(fork)别人的仓库副本，对别人的代码做出改进，申请提交 合并。
                                          5. 项目工作流
                                          项目流程中的下一项工作(比如探索性数据分析)由另一位项目成员乙负责，他首先需要 将成员甲合并的改动拉回(pull)主仓库，保持更新到最新状态。这有两种方法。
                                           git fetch 是比较安全的做法，因为它从仓库中下载任何远程内容，但不更新本地仓库状 态。它只是保留一份远程内容的副本，让任何当前的工作保持原样。为了完全整合新的 内容，需要在 fetch 之后进行合并(merge)。
                                           Pull:拉回(单击 Git 窗口的 Pull 按钮)。该操作将下载远程内容，然后立即将内容与本 地状态合并，但如果你有未完成的工作，这将产生合并冲突，但不用担心，这些可以被 修复。
                                          然后，如同成员甲一样，成员乙要新建自己的分支，然后执行文件新建/修改/删除，再暂存、 提交、推送、拉回请求、合并到主分支。
                                          当然，成员甲如果需要对一些数据进行快速修改，也可以拉回(Pull)成员乙的分支，进行 修改(提交)，并在成员乙合并到主分支之前，将其合并到乙的分支。
                                          整个工作流大致如图 6.30 所示。 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                          
                                          图 6.30 Git 版本控制一般工作流程
                                          Git 版本控制的上述操作流程最大的好处就是可以撤销错误，单击 Git 窗口的 History 按钮打
                                          开历史窗口，如图 6.31 所示。
                                          图 6.31 查看 Git 提交历史
                                          该窗口列出了每个提交，单击查看具体提交内容，包括 SHA(唯一的 ID)、作者、日期、 父级和提交的修改。浏览找到发生错误之前的提交，记下SHA，在Git窗口单击More -> Shell 打开命令行窗口，执行以下命令:
                                            git checkout <SHA> <filename>
                                            就能回滚到错误发生之前的文件(并覆盖文件版本)，更多 Git 撤销操作以及 Git 命令行指 令，可参阅知乎“李刚”的专栏“Super Git”。
                                          另外，可以用 usethis::edit_git_ignore()函数访问或创建.gitignore 文件，其 中包含的任何文件扩展名或特定文件都意味着 Git 会忽略它。因为有些文件，比如临时文件、日 志文件、带有私人信息的 .Rprofile 文件，是不需要或不能向云端提交的。
                                          异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                          6.3 R 与 Git 版本控制 255
                                          
                                          256 6 文档沟通 6.4 R Shiny
                                          Shiny 包可以轻松从 R 直接构建交互式 Web 应用，可以在网页上托管独立 app，也可以将其 嵌入 R Markdown 文档或用于构建 dashboards(仪表盘)。还可以使用 CSS 主题、htmlwidgets(网 页部件)和 JavaScript 操作扩展 Shiny app。
                                          Shiny 主要是为数据科学家设计的，可以让大家在没有 HTML、CSS 或 JavaScript 知识储备 的情况下创建相当复杂的 Shiny app。
                                          Shiny 扩展了基于 R 的分析，通过将 R 代码和数据包装成一个额外的互动层，以更好地进 行可视化、分析、输出等。这提供了一种强大的方式，使任何用户(甚至是非 R 用户)都可以 与数据进行互动、探索和理解数据。
                                          那么，什么情况下需要构建 Shiny app 呢?比如，开发并设计辅助教学工具，让学生交互 式探索统计学方法或模型;设计动态数据分析报表或仪表盘，以交互式的结果呈现数据分析 结果。
                                          6.4.1 Shiny 基本语法
                                          首先，在 RStudio 中创建一个 Shiny app，单击 New File -> Shiny Web App，打开创建 R shiny
                                          窗口，如图 6.32 所示。
                                          图 6.32 创建 R shiny
                                          选择路径并输入 app 名字，单击 Create 按钮，则可以在该路径下创建同名的文件夹，里面 有一个 app.R 文件。
                                          该文件就是一个简单的 Shiny app 的模板，单击 Run App 按钮或用 Ctrl + Shift + Enter 运行， 则生成 app，单击 Open in Browser 可在浏览器打开。
                                          1.Shiny app 基本结构
                                          每个Shiny app的app.R都具有同样的结构，其结构由三部分构成:ui(用户界面)、server (服务器)和 shinyApp()(接受 ui 和 server 对象，并运行 app)。
                                          library(shiny)
                                          # 定义UI
                                          ui = fluidPage(
                                            ... )
                                          # 定义server逻辑
                                          server = function(input, output) {
                                            ... }
                                          # 运行app
                                          shinyApp(ui = ui, server = server)
                                          异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                          
                                          Shiny设计将Web app的前端和后端组件分开。ui代表“用户界面”，定义了用户看到并与 之交互的前端控件，如图、表、滑块、按钮等。Server 负责后端逻辑，接收用户输入，并使用这 些输入来定义应该发生什么样的数据转换，以及将什么传回前端以供用户查看和交互。
                                          (1)ui(前端)
                                          ui定义了用户与Shiny app交互时所能看到的东西。在定义ui之前，你可以根据需要加载
                                          其他包、读入数据、定义函数等。 一般来说，ui 用来设置以下内容:
                                             用户界面的布局，为输入和输出安排位置;
                                           输入控件，允许用户向 server 发送命令;
                                           来自 server 的输出。
                                          关于页面布局，先用 fluidPage()函数创建整体页面布局，常用的两种布局如下。
                                           侧边面板+主面板:用titlePanel()函数创建标题面板，用sidebarLayout()函数 创建带侧边栏的布局，其内又常包括侧边面板 sidebarPanel()和主面板
                                          mainPanel，主面板内还可以继续用 tabPanel()函数创建标签面板。
                                           直接按行列布局:用fluidRow()函数控制若干控件属于一行，一行的宽度是12个单
                                          位，其内再用 column()函数划分列宽，再将输入或输出置于其中1。
                                          Shiny 提供了一系列内置的控件，每个控件都用同名的函数创建。例如，actionButton
                                          函数创建动作按钮，sliderInput 函数创建滑动条。 下面实例展示页面布局以及常用控件，若想了解更多的控件，请参阅 Shiny Widgets Gallery
                                          网站。
                                          library(shiny)
                                          column(3,
                                                 6.4 R Shiny 257
                                                 # 定义UI
                                                 ui = fluidPage(
                                                   titlePanel("常用控件"), fluidRow(
                                                     column(3, h3("按钮"), # actionButton("action", "点击"), br(), br(), submitButton("提交")),
                                                            column(3, h3("单选框"),
                                                                   checkboxInput("checkbox", "选项A", value = TRUE)),
                                                            checkboxGroupInput("checkGroup", h3("多选框"),
                                                                               choices = list("选项1" = 1, "选项2" = 2, "选项3" = 3), selected = 1)),
                                                     column(3, dateInput("date", h3("输入日期"), value = "2021-01-01"))), fluidRow(
                                                       column(3, dateRangeInput("dates", h3("日期范围"))), column(3, fileInput("file", h3("文件输入"))), column(3, h3("帮助文本"),
                                                                                                                                                        helpText("注: 帮助文本不是真正的部件, 但提供了一种", "易于实现的方式为其他部件添加文本.")),
                                                       column(3, numericInput("num", h3("输入数值"), value = 1))), fluidRow(
                                                         column(3, radioButtons("radio", h3("单选按钮"),
                                                                                choices = list("选项1" = 1, "选项2" = 2,
                                                                                               "选项3" = 3), selected = 1)), column(3, selectInput("select", h3("下拉选择"),
                                                                                                                                                 1 mainPanel 主面板中可以用与 HTML5 标签一致的函数控制文本格式，比如 h3()代表三级标题，br()代表空一行， strong()代表加粗，em()代表强调斜体，code()代表代码格式等。
                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                 
                                                                                                                                                 258 6 文档沟通
                                                                                                                                                 choices = list("选项1" = 1, "选项2" = 2, "选项3" = 3), selected = 1)),
                                                         column(3, sliderInput("slider1", h3("滑动条"),
                                                                               min = 0, max = 100, value = 50),
                                                                sliderInput("slider2", "",
                                                                            min = 0, max = 100, value = c(25, 75))),
                                                         column(3, textInput("text", h3("文本输入"), value = "输入文本..."))) )
                                                 # 定义server逻辑: 空白逻辑是app对控件的输入什么都不做, 不产生任何输出 server = function(input, output) {}
                                                 # 运行app
                                                 shinyApp(ui = ui, server = server)
                                                 运行该 Shiny app 得到 app 界面如图 6.33 所示，读者可以对照前面的代码来看。
                                                 图 6.33 Shiny 常用控件面板
                                                 实际上，一个 Shiny app 不可能用到所有这些输入控件，需要用哪些控件取决于 app 想要与 用户做怎样的交互，以及怎么交互。
                                                 (2)server(后端)
                                                 用户通过键盘/鼠标操作 ui 上的输入控件，就会改变输入，后端 server 一旦接收到一组新的
                                                 输入，就立马解读输入，对数据进行处理，并创建输出，再将输出送回 ui，用户就会看到交互 的结果。
                                                 ui 很简单，因为面向每个用户的都是相同的用户界面;真正复杂的是设计 server()，因 为所有的后端处理、响应计算、交互逻辑都在里面完成。
                                                 server()函数有 3 个参数:input、output、session，它们是在会话开始时由 Shiny 创建的，连接到一个特定的会话。一般只关心前两个参数即可。
                                                 ui 和 server 是分开设计的，这就需要把它们中的输入、输出联系起来。通过一个简单的“问 候 app”来看:
                                                   library(shiny)
                                                 server = function(input, output, session) {
                                                   output$greeting = renderText({
                                                     ui = fluidPage(
                                                       textInput("name", "请输入您的姓名:"), textOutput("greeting")
                                                     )
                                                     异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                     
                                                     paste0("您好 ", input$name, "!") })
                                                 }
                                                 shinyApp(ui = ui, server = server)
                                                 运行结果非常简单，如图 6.34 所示。  关于输入 input
                                                 input 是类似列表的对象，在 ui 中定义输入时，都需 要提供一个该输入的ID，该ID将会内化为与input同名的 一个成分，同时将接收到的用户输入作为该成分的内容。
                                                 图 6.34
                                                 简单的 Shiny 姓名交互
                                                 比如，textInput("name", "请输入您的姓名:")
                                                 定义了一个 ID 为“name”的文本输入，则 input 对象自动生成一个名为“name”的成分— input$name，它将接收用户交互时输入的文本作为其内容。
                                                  关于输出 output
                                                 output 是类似列表的对象，在 ui 中定义输出时，提供一个该输出的 ID，该 ID 将会内化为
                                                 与 output 同名的一个成分，将用来存放随后渲染输出函数生成的输出。 比如，textOutput("greeting")定义了一个 ID 为“greeting”的文本输出，则 output
                                                 对象自动生成一个同名的成分— output$greeting，随后被赋值为 renderText()生成的输出。 在 ui 中用“定义输出函数”定义的每一个某类型的输出，都在 server()中有一个对应的
                                                 “渲染输出函数”来生成该类型的输出。
                                                 在本例中，在 ui 中用“定义输出函数”textOutput("greeting")定义了一个文本输出，
                                                 其 ID 为“greeting”，则在 server()中就有一个与它对应的“渲染输出函数”renderText() 来生成文本输出，再赋值给 output 中与 ID 同名的成分。
                                                 注意:rendText()函数中的一对{ }用于将多行代码打包成一个整体。
                                                 Shiny 支持渲染多种类型的输出对象，常用的“ui 定义输出函数”，与 server()中相对
                                                 6.4 R Shiny 259
                                                 应的“渲染输出”函数，如表 6.2 所示。
                                                 表 6.2 Shiny 输出对象
                                                 ui 定义输出函数
                                                 server 渲染输出函数
                                                 输出对象
                                                 DT::dataTableOutput
                                                 imageOutput
                                                 plotOutput
                                                 plotly::plotlyOutput
                                                 tableOutput
                                                 textOutput
                                                 verbatimTextOutput
                                                 uiOutput
                                                 DT::renderDataTable
                                                 renderImage
                                                 renderPlot
                                                 plotly::renderPlotly
                                                 renderTable
                                                 renderText
                                                 renderText
                                                 renderUI
                                                 数据表 图片(文件链接) R图形
                                                 交互R图形
                                                 表格
                                                 文本
                                                 固定宽度文本
                                                 Shiny 标签或 HTML 网页
                                                 6.4.2 响应表达式 我们熟悉的编程是命令式编程:你发出一个具体的命令，计算机就会立即执行。但这不适
                                                 用于 Shiny app。以刚才的问候 app 为例，server()中的核心代码如下: 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                 
                                                 260 6 文档沟通
                                                 output$greeting = renderText({
                                                   这不是简单地把“您好”与姓名拼接再发送给 output$greeting，虽然你只发出一次指 令，但是 Shiny 在用户每次更新 input$name 的时候都会执行这个动作!
                                                     代码并没有告诉 Shiny 创建字符串并将其发送给浏览器，而是告知 Shiny 如果需要，它 可以如何创建字符串。至于何时(甚至是否)运行该代码，则由 Shiny 决定。决定何时执行代 码是 Shiny 的责任，而不是你的责任。把你的 app 看作为 Shiny 提供配方，而不是给它命令。
                                                   这是一种声明式编程，优势之一是它允许app非常懒惰:一个Shiny App将只做输出控 件所需的最小量的工作。
                                                   注意:这也造成了 Shiny 代码不再是从上到下的顺序执行，所以，要理清 Shiny 代码的执行顺序，更 重要的是在自己开发Shiny app时，绘制响应图是非常有必要的!
                                                     当Shiny app交互时，控件的输入一旦发生改变，Shiny就要做出响应:重新计算、生 成输出、发送给 ui，这就对 app 运行效率要求很高，所以就非常需要避免不必要的重复计算。 Shiny 有一种非常重要的机制，叫作响应表达式，就是专用于此的。
                                                   响应表达式与函数类似，是使用控件输入完成相应计算并返回值的 R 表达式。每当控件更 改时，响应式表达式都会更新返回值。响应表达式比函数更聪明，主要表现在以下方面:
                                                      响应表达式在首次运行时会保存其结果;
                                                    下次调用响应式表达式时，它将检查保存的值是否已过期(即其依赖的控件输入是否已更改);
                                                    若该值已过期，则响应对象将重新计算它(然后保存新结果);
                                                    如果该值是最新的，则响应表达式将返回保存的值，而不进行任何计算(从而提高 app
                                                                                     运行效率)。
                                                   用 reactive()函数创建响应表达式，响应表达式通常由多行代码构成，所以需要用大括
                                                   号括起来。使用响应表达式的返回结果，类似调用无参数函数。
                                                   在 Shiny app 的制作中，要尽可能地把交互计算提取出来，作为响应表达式。下面看一
                                                   个将 Shiny 用于交互教学设计的例子— 演示中心极限定理。
                                                   定理 6.1
                                                   设 X1, ..., Xn 为任意期望为，方差为  2 (有限)分布的抽样，则当 n 足够大时， X  1 X i 近似服从
                                                   paste0("您好 ", input$name, "!") })
                                                 2
                                                 N  ,  。 n 
                                                 n n i1
                                                 (1)设计想要做哪些交互、怎么交互
                                                  让用户有几种分布可以选择，通过下拉选项输入。
                                                  让用户可以改变随机变量个数，通过滑动条输入。
                                                  让用户可以改变每个随机变量数据量，通过滑动条输入。  对样本均值数据绘制直方图，通过图形输出。
                                                  让用户可以改变直方图的条形数，通过滑动条输入。
                                                 (2)绘制响应图 响应图是描述输入和输出的连接方式的一种图形，绘制响应图(草图)是制作或理解他人
                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                 
                                                 Shiny app的好用工具，本例的响应图如图6.35所示。
                                                 图 6.35 设计响应图
                                                 (3)定义 ui 传统的用户界面分两部分，侧边栏放置输入控件，主面板输出直方图。 ui = fluidPage(
                                                   最后，将它们组装到 app.R, 注意需要加载 ggplot2 包。运行 App, 结果界面如图 6.36 所示。
                                                   异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                   6.4 R Shiny 261
                                                   titlePanel("演示中心极限定理"), sidebarLayout(position = "right", # 放到右侧
                                                                                         sidebarPanel( selectInput("distr", "分布:",
                                                                                                                   c("均匀", "二项", "泊松", "指数")), sliderInput("samples", "随机变量数:", 1, 100, 10, step = 1), sliderInput("nsim", "模拟样本量:", 1000, 10000, 1000, step = 100), sliderInput("bins", "条形数", min = 10, max = 100, value = 50), helpText("说明:从下拉选项选择分布, 并用滑动条选择
随机变量数和模拟样本量.")), mainPanel(plotOutput("plot")))
                                                 )
                                                 (4)定义 server()
                                                 根据响应图的要求，我们需要实现从输入到生成 X 的样本数据，并放入响应表达式。实际
                                                 上这与自定义函数基本是一样的，除了把“函数”外形以及参数多一步从 input 取出来。
                                                 从 input 取出 3 个输入:samples(随机变量个数)、nsim(模拟样本数)、distr(分 布)，利用 switch()函数根据分布名生成随机数，并一次全部生成再分配给各个随机变量(矩 阵)，对矩阵中的元素按行取平均值得到样本均值的样本，再定义成数据框以便用于 ggplot
                                                 绘图。
                                                 响应表达式命名为 Xbar，故在 renderPlot()函数中使用时用的是 Xbar()。 server = function(input, output) {
                                                 }) }
                                        Xbar = reactive({
                                          n = input$samples # 随机变量个数 m = input$nsim # 模拟样本量 xs = switch(input$distr,
                                          "均匀" = runif(m * n, 0, 1), "二项" = rbinom(m * n, 10, 0.3), "泊松" = rpois(m * n, 5),
                                          "指数" = rexp(m * n), 1)
                                        data.frame(x = rowMeans(matrix(xs, ncol = n)))
                                        })
  output$plot = renderPlot({
    ggplot(Xbar(), aes(x)) +
      geom_histogram(alpha = 0.2, bins = input$bins,
                     fill = "steelblue", color = "black")
    
    262 6 文档沟通
    图 6.36 中心极限定理 Shiny app 效果 6.4.3 案例:探索性数据展板
    Shiny 常用的场景是设计动态数据分析报表或仪表盘，给他人以交互式的结果呈现。最后 再看一个用 Shiny 制作探索性数据展板的案例。
    以交互探索 ecostats 数据为例，该数据整理自国家统计局网站，包含各个省、自治区、 直辖市 2001—2017 年的电力消费、固定资产投资、居民消费水平、人口数、人均 GDP 等数据。
    我们设计以下交互需求:
       让用户选择地区，并通过下拉选项输入;
     对该地区人均 GDP 绘制折线图，并通过图形输出;
     通过表格输出该地区的数据子集，并将数据导出到文件，以数据表输出。
    ui 用户界面布局如下:首先选用侧边栏+主面板，在侧边栏采用下拉选项输入地区;其次把 主面板所选地区的人均 GDP 图形和数据表设计为可通过标签切换的两个页面。
    server()交互逻辑:将从用户输入的地区到筛选出该地区的数据放入响应表达式，应用于 随后的渲染输出图形和渲染输出数据表。
    另外，为了增加图形的可交互性(移动鼠标可以显示当前数据)，我们需要使用 plotly 包 的 plotlyOutput 对象;为了增加数据表的可交互性(换页显示、可导出到文件)，我们需要 使用 DT 包的 dataTableOutput 对象。
    完整的 Shiny app 代码如下:
      # 载入数据
      load("data/ecostats.rda")
    countries = unique(ecostats$Region) # 用户界面
    ui = fluidPage(
      titlePanel("交互探索 ecostats 数据"), sidebarLayout( # 侧边栏带下拉选项选择地区
        sidebarPanel(
          selectInput("name", "选择地区:", choices = countries,
                      selected = "黑龙江")),
        mainPanel( # 主面板带图形和数据表的切换标签
          tabsetPanel(
            tabPanel("人均GDP图", plotly::plotlyOutput("eco_plot")), tabPanel("数据表", DT::dataTableOutput("eco_data"))))
      ) )
    异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
    
    6.4 R Shiny 263
    # 定义服务器逻辑: 绘制折线图、创建数据表 server = function(input, output) {
    selected = reactive({
      ecostats %>%
        filter(Region == input$name)
    })
    # 绘制折线图
    output$eco_plot = plotly::renderPlotly({
      p = ggplot(selected(), aes(Year, gdpPercap)) + geom_line(color = "red", size = 1.2) +
        labs(title = paste0(input$name, "人均GDP变化趋势"),
             x = "年份", y = "人均GDP")
      plotly::ggplotly(p) # 渲染plotly对象 })
      # 创建数据表
      output$eco_data = DT::renderDataTable({
        DT::datatable(selected(), extensions = "Buttons", caption = paste0(input$name, "数据"),
                      options = list(dom = "Bfrtip",
                                     运行该 app，默认显示预期寿命图界面，如图 6.37 和图 6.38 所示，单击“数据表”可切换 到“数据表”标签页面。
                                     图 6.37 数据展板 Shiny app 交互图形页
                                     图 6.38 数据展板 Shiny app 数据交互页
                                     有了该 Shiny app，用户可以很方便地选择地区，查看该地区的人均 GDP 变化趋势图并能在
      }) }
      # 运行app
      shinyApp(ui = ui, server = server)
      buttons = c("copy", "csv", "excel", "pdf", "print")))
      异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
      
      264 6 文档沟通
      图上交互，还能将该地区的数据导出到文件。 最后，关于如何分享做好的 Shiny app。
       以 R 脚本分享，这是最简单的方法，但需要用户有配置好的 R 和 Shiny 环境，且知道如 何运行它。
       以网页形式分享，用户只要联网用浏览器就能交互使用它，但是这需要托管到云服务器， RStudio提供了shinyapps.io(免费受限)，还有Shiny的配套服务器程序Shiny Server， 但是只能部署在支持 Ubuntu 和 CentOS/RHEL 的 Linux 服务器。
      6.5 开发R包
      在编程中，我们提倡将实现一个功能自定义为一个函数，这样就可以方便自己和他人重复 使用;将完成每一项工作，组织在一个 R 项目方便统一管理，里面包含一系列好用的自定义函 数;如果再进一步，想让你的 R 项目变成通用的工作流，可以方便自己和他人解决同类问题， 就是将R项目变成R包。
      R 包将代码、数据、文档和测试捆绑在一起，便于自己复用且很容易与他人分享，同时也 为 R 社区的发展作出贡献。
      Hadley 等人开发的 devtools 系列包，可以说让如今的 R 包开发变得非常简单和自动化， 其理念就是让开发包的整个工作流程尽可能地用相应函数自动化实现，让人们把时间花在思考 究竟想让包实现什么功能，而不是思考包的结构。
      R 包有五种形态:源码、捆绑、二进制、已安装、载入内存。前三种形态是开发和发布 R 包所涉及的，后两种形态是大家已经熟悉的安装包和加载包。
      本节开发 R 包的完整流程主要参阅了 Hadley 编写的 R Packages，以及 Cosima meyer 的博客 文章“Hovo to write your own R package and publish it on CRAN”。
      6.5.1 准备开发环境
      安装专为开发 R 包而打造的 devtools 包，会同步安装 usethis 包(自动化设置包和项 目)、roxygen2 包(为各个函数提供文档)、testthat 包(进行单元测试)等。
      Windows 系统从源码构建 R 包所需的工具集，称为 Rtools，需要从 CRAN 下载相应版本并 按默认选项安装，然后重启 R，并执行以下命令，检查 Rtools 是否安装成功:
        devtools::has_devel() # 或者Sys.which("make")
      注意:对于 Mac 系统，需要先安装 Xcode 命令行工具，并注册为苹果开发者。
      6.5.2 编写R包工作流
      假设你有开发一个新包的想法，首先是为它寻找和挑选一个合适的包名，available 包可 以为你提供灵感并检查名字是否可用。
      我一直有为常用的数学建模算法开发一个 R 包的想法，让做数学建模的高校学生、教师能 够不再依赖 MATLAB(体积庞大、非开源免费、部分用户还被禁用)。当然，这是一个长期的巨 大工程，那么，就让我以此为契机开始打造它吧!
        我为该包起名为 mathmodels。
      异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
      
      1.创建R包
      我们希望所创建的包包含 Git 版本控制，并且能在远程 GitHub 仓库同步(相当于发布在 GitHub)。
      不知道是不是 RStudio 的 bug，在 RStudio 依次单击 New Project -> New Directory -> R Package，从窗口输入包名、路径，勾选 Create a git，创建 R 包，Git 窗口部分按钮(更新 Origin、 Pull、Push)是灰色，无法与远程仓库很好地建立连接。从 Git Shell 命令行用 Git 指令做相应操 作是可以的，但毕竟不够友好。
      咱们采用另一种对读者更友好的做法，先在 GitHub 建立远程同包名的仓库，再在本地新建 带 Git 版本控制的同包名的 R 项目。
      接着，从该 R 项目开始创建 R 包: library(devtools)
      create_package(getwd()) # 从当前路径创建R包
      有个是否重写mathmodels.Rproj的选择，选择1则重新生成mathmodels.Rproj文件(覆盖)。 这样就在本地创建了一个初始的源码 R 包结构，如图 6.39 所示。
      先来认识一下这些构成 R 包的文件。
       .gitignore 和.Rbuildignore:包含 Git 或 R 包构建时应该忽略的文件。
       DESCRIPTION:关于包的元数据。
       NAMESPACE:声明你的包对用户输
      出的函数和从其他包导入的外部函 数，后续执行 document()进行文 档化时，将重新生成并覆盖该文件。
       R:包含所有自定义的函数。
       mathmodels.Rproj:R 项目文件。
      其中需要编辑并改写的文件，都将用 devtools::document()自动生成。
      图 6.39
      R 包的源码文件
      至此，初步的开发 R 包的框架已经搭建完成，并且已经与远程仓库建立连接，后续任何更 新都能很容易提交到 GitHub 仓库(提交步骤:Staged -> Commit -> Push)。
      2.添加函数
      R 包最核心的部分就是自定义的函数，其余都是配套的使用说明、保证函数可运行的依赖 和数据集等。R 文件夹包含了所有的自定义函数，每个函数都保存为一个同名的.R 文件。
      现在来写我们的第一个函数:用 AHP()实现层次分析法。
      R 包中的自定义函数，本质上与普通的自定义函数并没有不同，只是额外需要注意:
         增加函数注释信息，将用于生成函数帮助;
       调用其他包中的函数时，用包名前缀，不加载包;
       永远不要使用 library()或 require(), 永远不要使用 source()。
      执行下面语句，在 R 文件夹中自动创建并打开 AHP.R: use_r("AHP")
      将调试通过的函数代码放进来:
        AHP <- function(A) {
          rlt <- eigen(A)
          Lmax <- Re(rlt$values[1])   # Maximum eigenvalue
          6.5 开发R包 265
          异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
          
          266 6 文档沟通
          # Weight vector
          W <- Re(rlt$vectors[,1]) / sum(Re(rlt$vectors[,1]))
          # Consistency index
          n <- nrow(A)
          CI <- (Lmax - n) / (n - 1)
          # Consistency ratio
          # Saaty's random Consistency indexes
          RI <- c(0,0,0.58,0.90,1.12,1.24,1.32,1.41,1.45,1.49,1.51)
          CR <- CI / RI[n]
          list(W = W, CR = CR, Lmax = Lmax, CI = CI)
        }
      把光标放在函数体内，单击 Code -> Insert roxygen skeleton，自动插入函数注释信息模板。 我们为本函数编写的注释信息如下:
        #' @title AHP: Analytic Hierarchy Process
        #' @description AHP is a multi-criteria decision analysis method developed
        #' by Saaty, which can also be used to
        #' determine indicator weights.
        #' @param A a numeric matrix, i.e. pairwise comparison matrix
        #' @return a list object that contains: W (Weight vector), CR (Consistency ratio),
        #' Lmax (Maximum eigenvalue), CI (Consistency index)
        #' @export
        #' @examples
        #' A = matrix(c(1,   1/2, 4, 3,   3,
        #' 2,   1,   7, 5,   5,
        #' 1/4, 1/7, 1, 1/2, 1/3,
        #' 1/3, 1/5, 2, 1,   1,
        #' 1/3, 1/5, 3, 1,   1), byrow = TRUE, nrow = 5)
        #' AHP(A)
        每行注释都以#'开头，@引导的关键词包括标题、描述、参数、返回值、工作示例，这些关 键词后边分别填写相应内容。
      有了上述帮助信息，就可以执行文档化，代码如下:
        document()
      此时将自动生成函数帮助，实际上是调用roxygen2包生成man/AHP.Rd，该文件在RStudio Help 窗口显示就如我们平时用“?函数名”查看帮助所看到的一样，如图 6.40 所示。
      图 6.40 文档化后的函数帮助页面
      如果是新包，建议加上@export 以导出函数，这样做文档化时会自动将该函数添加到 NAMESPACE 文件。导出的函数也是给安装你的包的用户所使用的函数。若不加@export 则不 导出函数，这样的函数叫作内部函数，只供包里的其他函数使用。
      3.编辑元数据
      每个包都必须有一个 DESCRIPTION 文件，它用来存放关于你的包的重要元数据，DESCRIPTION
      异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
      
      文件也是一个 R 包的决定性特征，RStudio 和 devtools 认为任何包含 DESCRIPTION 的目录都是 一个包。
      打开 DESCRIPTION 文件，包名、编码等部分信息是自动生成的，包括可编辑标题(单行文 字)、版本号、作者、描述(一段文字)、网址等信息，导入、许可等信息更建议通过命令添加。
      Package: mathmodels
      6.5 开发R包 267
      Title: Implement Common Mathematical Modeling Algorithms with R
      Version: 0.0.1
      Authors@R: # 多个作者用c()合并
        person(given = "Jingxin",
               family = "Zhang",
               role = c("aut", "cre", "cph"), # 作者,维护者,版权人,还有"ctb"贡献者
               email = "zhjx_19@hrbcu.edu.cn")
      Description: Mathematical modeling algorithms are classified as evaluation,
      optimization, prediction, dynamics, graph theory, statistics,
      intelligence, etc. This package is dedicated to implementing various
      common mathematical modeling algorithms with R.
      License: AGPL (>= 3)
      URL: https://github.com/zhjx19/mathmodels
      BugReports: https://github.com/zhjx19/mathmodels/issues
      Encoding: UTF-8
      LazyData: true
      Roxygen: list(markdown = TRUE)
      RoxygenNote: 7.1.1
      Imports:
        deSolve
       版本号
      通常是三位:大版本.小版本.补丁版本，按数值大小递进，开发版本一般从 9000 开始:0.0.1.9000。
       依赖包
      Imports 下所列的包是必须存在，这样你的包才能工作，当别人安装你的包时，也会自动安
      装这些包;
      Suggests 下所列的包是建议包(比如案例数据集、运行测试、用于 Vignette 等)，不会随
      你的包自动安装，所以在使用之前通常需要检查这些建议包是否存在:
        if (requireNamespace("pkg", quietly = TRUE)) {
          推荐大家用命令方式添加依赖包或建议包:
            @importFrom dplyr "%>%"从某包导入单个函数或符号。 Depends 是要求最低的 R 版本。
           选择许可
          这里用命令方式选择比较流行的 GPL-31开源许可: use_agpl3_license()
           LazyData 为 true 确保加载包时自动惰性加载(使用时才载入内存)内部数据集。 4.使用数据集
          在你的包中包含数据集有 3 种主要方式，这取决于你想用它做什么以及谁能够使用它。
          1 GPL 许可规定任何将代码以捆绑形式发布的人必须以与 GPL 兼容的方式对整个捆绑进行许可。此外，任何分发代码的 修改版本(衍生作品)的人也必须提供源代码。GPL-3 比 GPL-2 更严格一些，关闭了一些旧的漏洞。
          pkg::f() }
      use_package("deSolve") # 还有参数min_version指定最低版本 use_package("deSolve", "Suggests")
      异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
      
      268 6 文档沟通
       外部使用
      如果你想存储二进制数据并使其对用户可用，就把它以 .rda 格式放在 data/中，这种方式适
      合放示例数据集。
      先把数据集读入当前变量，比如读入企鹅数据集 penguins，代码如下: use_data(penguins) # 参数compress可设置压缩格式 内部数据集就像函数一样需要做文档化，把数据集的名称文档化并将其保存在 R/中。先创
      建数据集，代码如下:
        use_r("penguins")
      再编辑该数据集的注释信息，注释信息将用于生成该数据集的帮助:
        #' @title Size measurements for adult foraging penguins near Palmer Station, Antarctica
        #' @description Includes measurements for penguin species, island in Palmer Archipelago, #' size (flipper length, body mass, bill dimensions), and sex.
        #' @docType data
        #' @usage data(penguins)
        #' @format A tibble with 344 rows and 8 variables:
        #' \describe{
        #'   \item{species}{a factor denoting penguin species}
        #'   \item{island}{a factor denoting island in Palmer Archipelago, Antarctica}
        #'   \item{bill_length_mm}{a number denoting bill length (millimeters)}
        #'   \item{bill_depth_mm}{a number denoting bill depth (millimeters)}
        #'   \item{flipper_length_mm}{an integer denoting flipper length (millimeters)}
        #'   \item{body_mass_g}{an integer denoting body mass (grams)}
        #'   \item{sex}{a factor denoting penguin sex (female, male)}
        #'   \item{year}{an integer denoting the study year (2007, 2008, or 2009)}
        #' }
        #' @references This dataset referenced from the palmerpenguins package.
        #' @keywords datasets
        #' @examples
        #' data(penguins)
        #' head(penguins)
        "penguins"
      在关键词引导下，编辑数据集标题、描述、变量说明、来源、示例等信息。还有@source 是你自己获得数据的来源，通常是一个 url{}. 注意，永远不要@export 一个数据集。
      有了上述帮助信息，就可以执行文档化(查看其帮助略):
        document()
       内部使用
      如果你想存储处理过的数据，但不向用户提供，就把它以.rda 格式放在 R/中，这种方式
      适合放函数需要的数据。
      同样的操作，除了设置 internal 参数为 TRUE: use_data(penguins, internal = TRUE)
       原始数据 如果你想展示加载/处理原始数据的例子，就把原始数据文件放在inst/extdata中，安装包时，
      inst/中的所有文件(和文件夹)都会被上移一级目录(去掉 inst/)。
      要引用 inst/extdata 中的数据文件(无论是否安装)，代码如下: system.file("extdata", "mtcars.csv", package = "readr", mustWork = TRUE)
      参数mustWork = TRUE保证若文件不存在，不是返回空字符串而是报错。
      另外，通常你的数据集是你搜集的原始数据经过处理的版本，Hadley 建议额外将原始数据 和处理过程的代码放入 data-raw/，这只是便于将来更新或重现数据。在捆绑 R 包时，原始数据
      异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
      
      和处理过程的代码是不需要的，所以需要添加到.Rbuildignore。这个步骤不必手动执行，use_ data_raw()能帮你自动完成。
      5.单元测试
      测试是开发 R 包的重要部分，可以确保代码更稳健，能成功地实现相关的功能。 测试的一般原则是，设想函数在可能遇到的各种情况下，是否都能得到预期的结果。策略
      之一是每当你遇到一个 bug，就为它写一个测试，以检查将来是否会出现这种情况。 虽然通过执行 load_all()模拟加载包，可以在控制台做一些函数测试，但更好的做法是
      采用 testthat 包提供的单元测试，这是一种正式的自动化测试。具体操作如下所示。 先初始化包的单元测试:
        use_testthat()
      它将 Suggests:testthat 添加到 DESCRIPTION, 创建目录 tests/testthat/，并 添加脚本 tests/testthat.R。然而，真正的测试还是要靠自己来编写!
        先打开或创建针对某函数的测试文件:
        use_test("AHP")
      测试文件是由若干个 test_that()构成，第一个参数是对测试的描述，测试内容是大 括号括起来的代码块，一般是比较函数返回值与期望值是否(近似)相等、是否符合类型等， 比如:
        test_that("AHP weights and type", {
          然后，执行测试(若测试结果全为 PASS，则表示通过测试): test()
          如果单元测试没问题，再执行R CMD check检测: check()
          执行该命令可能需要一些时间，并在控制台中产生一个输出，输出是关于潜在错误、警告、 注意的具体反馈，我们希望三者都是 0。
          通过检测的 R 源码包已经可以在自己的计算机上安装使用了:
            按照标准的步骤(Staged -> Commit -> Push)把包的相关文件推送到 GitHub 远程仓库，就 是成功发布到 GitHub，别人也已经可以从 GitHub 安装和使用你的 R 包。
          6.5.3 发布到CRAN
          如果想让你的包在 R 社区分享，则需要把它提交到 CRAN，这比发布在 GitHub 上要做更多 的工作。
           选择一个三位版本号:大版本.小版本.补丁。
           检测是否符合 CRAN 政策，在至少两种操作系统执行 R CMD check，并准备 cran-
            6.5 开发R包 269
          A = matrix(c(1,   1/2,
                       2,   1), byrow = TRUE, nrow = 2)
          rlt = AHP(A)
          expect_equal(rlt$W, c(0.3333, 0.6667), tolerance = 0.001)
          expect_type(rlt, "list")
        })
      install() # 安装包 library(mathmodels)
      # some code
      异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
      
      270 6 文档沟通
      comments.md 文件加以说明。
       编写 README.md 和 NEWS.md。
       用 devtools::build()从源码包创建捆绑包 tar.gz 格式。
       向 CRAN 提交包。
       通过更新版本号为下一个版本做准备。
       发布新的版本。
      但上述操作是值得的，因为只有发布到 CRAN，广大 R 用户才能更容易发现和使用你的 R 包。 CRAN 政策除了对基本的规范流程有要求之外，还有一些其他注意事项。
       包的维护者的 E-mail(长期)可用，CRAN 要确保能联系到维护者。
       必须在 DESCRIPTION 中明确指出版权人，若包含外部源代码必须兼容许可。
       要求你的包在至少两个操作系统平台上通过 R CMD check 检测，建议也在 R 开发版本上
      通过 R CMD check 检测。
       禁止替用户做外部修改，例如不要写到文件系统、改变选项、安装包、退出 R、通过互
      联网发送信息、打开外部软件等。
       不要过于频繁地提交更新，建议最多每 1~2 个月提交一次新版本。
      1.CRAN 检测
      在多个操作系统做R CMD check都要保证错误项、警告项、注意项的数量为0，但新包第一 次提交必有一个注意项，提醒 CRAN 这是一个新的提交。这无法消除，可在 cran-comments.md 中 注明这是第一次提交。
      rhub 包可以帮助你在多个操作系统做 R CMD check，还能自动生成检测结果的描述，并用 于生成 cran-comments.md。
      第一次使用 rhub, 需要先验证你的 E-mail 地址: library(rhub)
      validate_email("zhjx_19@hrbcu.edu.cn")
      这将向你的该邮箱发送一个 token 码，在提示中输入将绑定你的 E-mail。 在多个操作系统上对你的 R 包执行 R CMD check，只需运行以下代码: results = check_for_cran()
      检测过程会有一点漫长，你的 E-mail 会陆续收到 3 个邮件，其中的链接详细反馈了测试在 3 个不同操作系统上的表现。将检测结果赋值可以方便地查看检测的概述结果，如图 6.41 所示:
        results$cran_summary()
      再生成 cran-comments.md，稍加修改就能使用: use_cran_comments() # usethis包
      2.编写 README、NEWS
      若你的包发布在 GitHub，则有必要编写 README.md。它是包的主页和欢迎页，介绍如何 简单使用这个包。执行以下命令则生成并打开 README.Rmd 模板，编辑相应内容即可。
      use_readme_rmd()
      NEWS 文件在每次更新包的版本时，用来描述了自上一版本以来的变化，执行以下命令， 则自动生成并打开 NEWS.md，按 markdown 语法无序列表语法编辑内容即可。
      use_news_md()
      异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
      
      图 6.41 CRAN 检测结果汇总
      3.捆绑包与提交
      源码包需要 build 为捆绑包(tar.gz)，才能往 CRAN 提交，执行以下命令:
        build()
      结果如图 6.42 所示。
      图 6.42 从源码包到捆绑包
      有了 mathmodels_0.0.1.tar.gz 和 cran-comments.md，终于可以向 CRAN 提交了。
      打开图 6.43 所示的提交包页面，按要求提交即可。
      图 6.43 CRAN 提交包页面
      提交后，你会收到一封邮件，是确认你的提交，然后就是等待。如果是一个新的包，CRAN 还会运行一些额外的测试，可能比提交包的更新版本要花更多的时间(4~5 天)。
      直到 CRAN 回复你，可能会反馈一些潜在的问题，你必须在重新提交包之前解决这些问题 (并增加一点版本号)。当然，你也可能非常幸运，你的包立即被接受。
      在包被 CRAN 接受后，它将被建立在每个平台上。这有可能会发现更多的错误。等待 48 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
      6.5 开发R包 271
      
      272 6 文档沟通
      小时，直到所有包的检查都运行完毕，然后进入你的包页面，单击“CRAN checks”下的“包
      results”，检查相关问题，若有必要就得提交一个更新版本的补丁包。 6.5.4 推广包(可选)
      为了更好地宣传和推广你的包，可以采用以下方式。  通过编写 vignettes(小册子)
      相当于通过博客文章描述你的包所要解决的问题，然后向用户展示如何解决该问题。执行 以下命令:
        use_vignette("Evaluation-Algorithm") # 或_, 不能用空格
      这将自动创建 vignettes/Evaluation-Algorithm.Rmd，向 DESCRIPTION 添加必要的依赖项(将 knitr 添加到 Suggests 和 VignetteBuilder 字段)。接着，按照标准的 R Markdown 格式，编写 Vignette 内容即可。
       建立网站
      只要你已经遵照上述流程处理，那么在 GitHub 仓库里就会有一个 R 包结构，借助 pkgdown
      包，只需要运行以下命令:
        pkgdown::build_site()
      就能自动把你的包渲染成一个网站，该网站遵循你的包结构，有一个基于 README 文件的 登录页面，一个 vignette 折叠页面，以及基于 man/文件夹内容的函数引用页面，还有一个专门 的 NEWS.md 页面。它甚至包括一个侧边栏，上面有 GitHub 仓库的链接、作者的名字等。此外， 你还可以进行以下操作。
       为你的包设计六边形 logo(目前非常流行)，可以参考 hexSticker 包和相关网站。
       为你的包制作 cheatsheet，RStudio 有提供相关模板。