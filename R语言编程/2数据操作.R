# 前面章节已涵盖了 R 语言的基本语法，特别是让读者训练了向量化编程思维
# (同时操作一系列数据)、函数式编程思维(采用自定义函数解决问题+泛函式循环迭代)。
# R 语言更多的是与数据打交道，本章正式进入 tidyverse 系列，全面讲解用“管道流、
# 整洁流”操作数据的基本语法，包括数据读写、数据连接、数据重塑，以及各种数据操作。
# 本章最核心的目的是训练读者的数据思维，那么什么是数据思维?

# 我认为最关键的三点如下所示。
# (1)将向量化编程思维和函数式编程思维，纳入数据框或更高级的数据结构中。 
# 比如，向量化编程能同时操作一个向量的数据，我们将其转变成在数据框中操作一列的数据
# 或 者同时操作数据框的多列，甚至分别操作数据框每个分组的多列;
# 将函数式编程转变成为想实现的操作自定义函数(或使用现成函数)，
# 再依次应用到数据框的多个列上，以修改列或进行汇总。
# (2)将复杂数据操作分解为若干基本数据操作。 
# 复杂数据操作都可以分解为若干简单的基本数据操作:数据连接、数据重塑(长宽变换/拆
# 分合并列)、排序行、选择列、修改列、分组汇总等。一旦完成问题的梳理和分解，
# 又熟悉每个基本的数据操作，用“管道流”依次对数据做操作即可。
# (3)接受数据分解的操作思维。 比如，想对数据框进行分组，分别对每组数据做操作，
# 整体来看这是不容易想透的复杂事情，实际上只需通过 group_by()分组，然后把你要对一
# 组数据做的操作进行实现;再比如，用 across()同时操作多列，实际上只需把对一列数据要
# 做的操作进行实现。这就是数据分解的操作思维，这些函数会帮你“分解+分别操作+合并结果”，
# 你只需要关心分别操作的部分，它 就变成一件简单的事情。
# 很多从 C 语言等转到 R 语言的编程新手，总习惯于使用 for 循环逐个元素操作、
# 每个计算 都得“眼见为实”，这都是训练数据思维的大忌，是最应该首先摒弃的恶习。

# 2.1 tidyverse 简介与管道 
# 2.1.1 tidyverse 包简介
# tidyverse包是Hadley Wickham及团队的集大成之作，是专为数据科学而开发的一系列包的合集。
# tidyverse 包基于整洁数据，提供了一致的底层设计哲学、语法、数据结构
# 
# tidyverse 用“现代的”“优雅的”方式，以管道式、泛函式编程技术实现了数据科学的整个流程
# 数据导入、数据清洗、数据操作、数据可视化、数据建模、可重现与交互报告。
# tidyverse 操作数据的优雅，就体现在以下方面:
# 每一步要“做什么”，就写“做什么”，用管道依次做下去，并得到最终结果。
# 代码读起来，就像是在读文字叙述一样，顺畅自然，毫无滞涩。
# 
# 在 tidyverse 包的引领下，近年来涌现出一系列具体研究领域的 tidy* 风格的包:
# tidymodels(统计与机器学习)、mlr3verse(机器学习)、rstatix(应用统计)、
# tidybayes (贝叶斯模型)、tidyquant(金融)、fpp3 和 timetk(时间序列)、
# quanteda(文本挖掘)、tidygraph(网络图)、sf(空间数据分析)、tidybulk(生物信息)、
# sparklyr(大数据)等。 
# 
# tidyverse 与 data.table
# tidyverse 操作数据语法优雅、容易上手，但效率与主打高效的 data.table 包不可同
# 日而语，处理几 GB 甚至十几 GB 的数据，就需要用 data.table。
# 但 data.table 的语法高度抽象、不容易上手。
# 本书不对 data.table 做过多展开，只讲一下基本使用。
# 另一种不错的方案是使用专门的转化包:有不少包尝试在底层用 data.table， 
# 在上层用 tidyverse 语法包装(转化)，如 dtplyr、tidyfst 等。

# 2.1.2 管道操作
# 1.什么是管道操作
# magrittr 包引入了管道操作，能够通过管道将数据从一个函数传给另一个函数，从而用若
# 干函数构成的管道依次变换你的数据。
# 例如，对数据集 mtcars，先按分类变量 cyl 分组，再对连续变量 mpg 做分组并汇总计算
# 均值:
library(tidyverse)
mtcars %>%
  group_by(cyl) %>%
  summarise(mpg_avg = mean(mpg))
#管道运算符“%>%”(Windows 快捷键:Shift + Ctrl + M;Mac 快捷键:Cmd + Shift + M)的 
#意思是:将左边的运算结果，以输入的方式传给右边函数。把若干个函数通过管道链接起来，
#叫作管道(pipeline)。
x %>% f() %>% g() # 等同于g(f(x))
#对该管道示例应该这样理解:依次对数据进行若干操作，先对 x 进行 f 操作, 接着对结果 
#进行g操作。
#管道也支持base R函数，例如:
month.abb %>% # 内置月份名缩写字符向量 
sample(6) %>%
tolower() %>%
str_c(collapse = "|")
#注意:R 4.1 增加了同样功能的管道运算符“|>”。、
#使用管道的好处是:
#避免使用过多的中间变量;
#程序可读性大大增强。

#管道操作的过程，其代码读起来就是对原数据集依次进行一系列操作的过程。
#而非管道操作，其代码读起来与操作的过程是相反的，比如同样实现上例，
#非管道操作的代码如下:
#str_c(tolower(sample(month.abb, 6)), collapse="|")

# 2.常用管道操作
# (1)管道默认将数据传给下一个函数的第 1 个参数，且该参数可以省略
#这种机制使得管道代码看起来就是:从数据开始，依次用函数对数据施加一系列的操作
#(变换数据)，各个函数都直接从非数据参数开始写即可，而不用再额外操心数据的事情，
#数据会自己沿管道向前“流动”。正是这种管道操作，使得 tidyverse 能够优雅地操作数据。
#因此，tidyverse 中的函数都设计为将数据作为第 1 个参数，自定义的函数也建议这样做。
# (2)数据可以在下一个函数中使用多次
# 数据经过管道默认传递给函数的第 1 个参数(通常直接省略);若在非第 1 个参数处使用该 
# 数据，必须用“.”代替(绝对不能省略)，这使管道作用更加强大和灵活。
# 下面看一些具体实例:
# 数据传递给plot第一个参数作为绘图数据(.省略), 
# 同时用于拼接成字符串给main参数用于图形标题
c(1, 3, 4, 5) %>%
  plot(main = str_c(., collapse=",")) 

# 数据传递给第二个参数data
mtcars %>% 
  plot(mpg ~ disp, data = .) # 选择列
iris %>% 
  .$Species # 选择Species列内容
iris %>% 
  pull(Species) # 同上
iris %>% 
  .[1:3] # 选择1-3列子集
 

#再来看一个更复杂的例子— 分组批量建模，代码如下:
# mtcars %>%
#   group_split(cyl) %>%
#   map(~ lm(mpg ~ wt, data = .x))
# group_split()是将数据框 mtcars 根据其 cyl 列(包含 3 个水平的分类变量)进行分组，
# 得到包含3个成分的列表;列表接着传递给map(.x, .f)的第一个参数(直接省略)，
# ~ lm(mpg ~ wt, data = .x)是第二个参数，即“.f”，该参数使用了purrr风格公式写法。
# 整体来看，实现的是分组建模:将数据框根据分类变量分组，再用 map 循环机制依次对每
# 组数据建立线性回归模型。
# 建议进行区分:“.”用于管道操作中代替数据;“.x”用于 purrr 风格公式(匿名函数)。 

#2.2 数据读写
# 2.3 数据连接
# 一个项目的数据通常都是用若干数据表分别存放的，它们之间通过“键”连接在 一起，根据
# 数据分析的需要，通过键匹配进行数据连接。
# 例如，纽约机场航班数据的关系结构
# 比如，想要考察天气状况对航班的影响，就需要先将数据表 flights 和 weather 根据其键
# 值匹配并连接成一个新数据表。
# 键列(可以不止 1 列)能够唯一识别自己或他人的数据表的每一个观测(或样本)。
# 要判断 某(些)列是否是键列，可以先用count()计数，若没有“n > 1”的情况出现，
# 则可判定其 为键列:

planes %>%
  count(tailnum) %>%
  filter(n > 1)

weather %>%
  count(year, month, day, hour, origin) %>%
  filter(n > 1)

# 2.3.1 合并行与合并列
# 合并数据框最基本的方法如下所示。
#合并行:在下方堆叠新行，根据列名匹配列，注意列名要相同，否则会作为新列(用 NA
#填充)。
#合并列:在右侧拼接新列，根据位置匹配行，数据框的行数必须相同。
#合并行和合并列分别用 dplyr 包中的 bind_rows()和 bind_cols()函数实现。 
bind_rows(
sample_n(iris, 2), # 随机抽取2个样本(行)
sample_n(iris, 2),
sample_n(iris, 2)
)

one = mtcars[1:4, 1:3]
two = mtcars[1:4, 4:5]
bind_cols(one, two)

#利用 purrr 包中 map_dfr()和 map_dfc()的函数可以在批量读入或生成数据的同时合并行
#和合并列。
#还有add_row(.data, ..., .before, .after)函数可以根据索引位置插入行。 
#另外，受到 SQL 的 INSERT、UPDATE 和 DELETE 函数的启发，dplyr 包还提供了以下 6
#个函数，可实现根据另一个数据框来修改某数据框中的行。
# rows_insert(x, y, by):插入新行(类似 INSERT)。默认情况下，y 中的键值必
# 须不存在于 x 中。
# rows_append():与 rows_insert()类似，但是忽略键值。
# rows_update():更改现有的行(类似 UPDATE)。y 中的键值必须是唯一的，而且默
# 认情况下，y 中的键值必须存在于 x 中。
# rows_patch():与 rows_update()类似，但是只覆盖 NA 值。
# rows_upsert():根据 y 中的键值是否已经存在于 x 中，对 x 进行插入或更新。
# rows_delete():删除行(类似DELETE)。默认情况下，y中的键值必须存在于x中。

# 2.3.2 根据值匹配合并数据框
# 只介绍最常用的六种合并:左连接、右连接、全连接、内连接、半连接、反连接，
# 前四种连接又称为修改连接，后两种连接又称为过滤连接。
# 这六种连接对应六个接口一致的函数，其基本格式为:
# left_join(x, y, by)
# right_join(x, y, by)
# full_join(x, y, by)
# inner_join(x, y, by)
# semi_join(x, y, by)
# anti_join(x, y, by)
#下面以 dplyr 包自带的两个小数据集进行演示: 
band = band_members
band
instrument = band_instruments
instrument
#1.左连接:left_join()
# 外连接至少保留一个数据表中的所有观测，分为左连接、右连接、全连接，其中最常用的 
# 是左连接:保留 x 的所有行，合并匹配的 y 中的列
band %>%
  left_join(instrument, by = "name")

#若两个表中的键列列名不同，用 by = c("name1" = "name2");
#若根据多个键列匹配，用 by =c("name1", "name2")。

#2.右连接:right_join()
#保留 y 的所有行，合并匹配的 x 中的列
band %>%
  right_join(instrument, by = "name")

#3.全连接:full_join()
#保留 x 和 y 中的所有行，合并匹配的列
band %>%
  full_join(instrument, by = "name")

# 前面讨论的都是连接两个数据表的情况，若要连接多个数据表，可以将连接两个数据表的
# 函数结合 purrr 包中的 reduce()使用即可。
# 比如 achieves 文件夹有 3 个 Excel 文件，
# 需要批量读取它们，再依次做全连接 (做其他连接也是类似的)。
# reduce()函数可以实现先将前两个表做全连接，再将结 果表与第三个表做全连接
# (更多表就依次这样做下去)，代码如下:
files = list.files("data/achieves/", pattern = "xlsx", full.names = TRUE)
map(files, read_xlsx) %>%
  reduce(full_join, by = "人名") # 读入并依次做全连接

# 若还是上述数据，但是分布在一个工作簿的多个工作表中
# 此时就需要批量读取并依次做全连接，代码如下所示:
# 批量读取并做全连接
path = "data/3-5月业绩.xlsx" 
map(excel_sheets(path),~ read_xlsx(path, sheet = .x)) %>%
  reduce(full_join, by = "人名") # 读入并依次做全连接

# 2.3.3 集合运算 
# 集合运算有时候很有用，都是针对所有行通过比较变量的值来实现。
# 这就需要数据表的 x和 y 具有相同的变量，并将观测看成是集合中的元素:
intersect(x, y) # 返回x和y共同包含的观测
union(x, y) # 返回x和y 中所有的(唯一)观测
setdiff(x, y) # 返回在x中但不在y中的观测
setequal(x, y) # 判断集合x和y是否相等

# 2.4 数据重塑
# 2.4.1 什么是整洁的数据
# 采用 Hadley 的表述，脏的、不整洁的数据往往具有如下特点: 
# 首行(列名)是值，不是变量名;
# 多个变量放在一列;
# 变量既放在行也放在列;

#让数据变整洁的关键是，要学会区分变量、观测、值。 

#2.4.2 宽表变长表
# 宽表的特点是:表比较宽，本来该是“值”的，却出现在“变量(名)”中。
# 这就需要把它放到“值”中，这就需要新起个列名并把相关数据存为一列，
# 这就是所谓的宽表变长表。
# 用 tidyr 包的 pivot_longer()函数可实现宽表变长表，其基本格式为: 
# pivot_longer(data, cols, names_to, values_to, values_drop_na, ...)
# data:要重塑的数据框。
# cols:用选择列语法选择要变形的列。 
# names_to:为存放变形列的列名中的“值”，指定新列名。 
# values_to:为存放变形列中的“值”，指定新列名。 
# values_drop_na:是否忽略变形列中的 NA。 
# 若变形列的列名除了“值”外，还包含前缀、变量名+分隔符、正则表达式分组捕获模式，
# 则可以借助参数 names_prefix、names_sep、names_pattern 来提取出“值”。 
#1.值列中只包含一个变量的值
#这也是最简单的情形，以年度 GDP 数据为例，要变形的值列中只包含一个变量 GDP 的值。
df = read_csv("data/分省年度GDP.csv") 
df

#要变形的列是除了“地区”列之外的列。
#变量(名)中的 2019 年、2018 年等是年份的值，需要作为 1 列“值”来存放，新创建
#一个列，并命名为“年份”。
#2019 年、2018 年等列中的值，属于同一个变量 GDP，新创建一个 GDP 列来存放:

df %>%
  pivot_longer(-地区, names_to = "年份", values_to = "GDP")

pivot_longer(everything(), names_to = c("队员", ".value"), 
             names_pattern = "(.*\\d)(.*)")

# 2.4.3 长表变宽表
# 长表的特点是:表比较长。有时候需要将分类变量的若干水平值，变成变量(列名)，
# 这就是长表变宽表，它与宽表变长表正好相反(二者互逆)。
# 用 tidyr 包中的 pivot_wider()函数来实现长表变宽表，其基本格式为: 
# pivot_wider(data, id_cols, names_from, values_from, values_fill, ...)
# data:要重塑的数据框。
# id_cols:唯一识别观测的列，默认是除 names_from 和 values_from 指定列之外的列。
# names_from:指定列名来自哪个变量列。
# values_from:指定列“值”来自哪个变量列。
# values_fill:若表变宽后单元格值缺失，要设置用何值填充。
# 另外，还有若干帮助修复列名的参数:names_prefix、names_sep、names_glue。
#最简单的情形是，只有一个列名列和一个值列，比如 animals 数据集，如下所示:
load("data/animals.rda")
animals

#用 names_from 指定列名来自哪个变量，用 values_from 指定 “值” 来自哪个变量: 
animals %>%
  pivot_wider(names_from = Type, values_from = Heads, values_fill = 0)

#还可以有多个列名列或多个值列，比如 us_rent_income 数据集有两个值列: 
us_rent_income

us_rent_income %>%
  pivot_wider(names_from = variable, values_from = c(estimate, moe))

# 长表变宽表时，经常会遇到两个问题:
# 长表变宽表正常会压缩行，为什么行数没变; 
# 值不能被唯一识别，输出将包含列表列。
# 比如，现有以下数据:
  df = tibble(
    x = 1:6,
    y = c("A","A","B","B","C","C"),
    z = c(2.13,3.65,1.88,2.30,6.55,4.21))
df
#想让 y 列提供变量名，z 列提供值，做长表变宽表，但是得到的结果并不令人满意。 
df %>%
  pivot_wider(names_from = y, values_from = z)

# 这就是前面说到的第一个问题，本来该压缩成 2 行，但是由于 x 列的存在，无法压缩，
# 只 能填充 NA，这并不是你想要的效果。所以，在长表变宽表时要注意，
# 不能带着类似 x 列这种唯一识别各行的 ID 列。
# 那去掉 x 列，重新做长表变宽表，但是又遇到了前面说的第二个问题: 
df = df[-1]
df %>%
  pivot_wider(names_from = y, values_from = z)
# 值不能唯一识别，结果变成了列表列1，同样不是想要的结果。
# 这里的值唯一识别，指的是各分组(A 组、B 组、C 组)组内元素必须要能唯一识别。
# 咱们 来增加一个各组的唯一识别列，如下所示:

df = df %>%
  group_by(y) %>%
  mutate(n = row_number())
df

#这才是能够长表变宽表的标准数据，此时再来做长表变宽表:
df %>%
  pivot_wider(names_from = y, values_from = z)

# 这次得到的是想要的结果，新增加的列 n 若不想要，删除该列即可。
# 回头再看一下，所谓的各组内值唯一识别，比如 A 组有两个数 2.13 和 3.65，
# 给了它们唯一 识别:n = 1 和 n = 2(当然 1 和 2 可以换成其他两个不同的值)，
# 这样就知道谁作为第一个样本 (行)，谁作为第二个样本(行)。否则 A 组的两个数无法区分，
# 就只能放到一个列表里了，这时就会产生前面的错误结果和警告。 
# 最后再看一个特殊的实例:整理不规则通讯录。 
contacts = tribble( ~field, ~value,
                    "姓名", "张三",
                    "公司", "百度",
                    "姓名", "李四",
                    "公司", "腾讯",
                    "Email", "Lisi@163.com", "姓名", "王五")
contacts = contacts %>%
  mutate(ID = cumsum(field == "姓名"))
contacts

contacts %>%
  pivot_wider(names_from = field, values_from = value)

#2.4.4 拆分列与合并列
# 拆分列与合并列也是正好相反(二者互逆)。
# 用 separate()函数来拆分列，其基本语法为: 
# separate(data, col, into, sep, ...)
# col:要拆分的列。 
# into:拆开的新列。
# sep:指定根据什么分隔符拆分。 

table3
table3 %>%
  separate(rate, into = c("cases", "population"), sep = "/", convert = TRUE) 
  # 同时转化为数值型

#separate_rows()函数可对不定长的列进行分列，并按行堆叠放置:
df = tibble(Class = c("1班", "2班"),
              Name = c("张三，李四，王五", "赵六，钱七"))
df

df1 = df %>%
  separate_rows(Name, sep = "，") 
df1

df1 %>%
  group_by(Class) %>%
  summarise(Name = str_c(Name, collapse = "，"))

#另外，extract()函数可以利用正则表达式的分组捕获功能，直接从一列中提取出多组信 息，并生成多个列。例如，处理本节开始的不整洁数据，代码如下所示:

dt
dt %>%
  extract(observation, into = c("site", "surveyor"),regex = "(.*)\\((.*)\\)")

#用unite()函数来合并列，其基本语法为:
# unite(data, col, ..., sep, remove) 
# col:新列名。
# ...:整洁地选择要合并的列。
# sep:指定合并各列添加的分隔符。
# remove:是否删除旧例。

table5
table5 %>%
  unite(new, century, year, sep = "")

#最后看一个综合示例:重塑“世界银行”(world_bank)的人口数据。
world_bank_pop
#先从最显然的入手:年份跨过了多个列，应该使用宽表变长表:
pop2 = world_bank_pop %>%
  pivot_longer(`2000`:`2017`, names_to = "year", values_to = "value")
pop2

#再来考察 indicator 变量:
pop2 %>%
  count(indicator)

#这里，SP.POP.GROW 为人口增长率，SP.POP.TOTL 为总人口，SP.URB.GRW 
#为城镇人口增长率，SP.URB.TOTL 为城镇总人口(只是城市的)。
#将该列值拆分为两个变量:area(URB, POP)和 variable(GROW, TOTL):
#最后，再将分类变量 variable 的水平值变为列名(长表变宽表)，就完成了数据重塑:

pop2 = world_bank_pop %>%
  pivot_longer(`2000`:`2017`, names_to = "year", values_to = "value")
pop2

pop2 %>%
  count(indicator)

pop3 = pop2 %>%
  separate(indicator, c(NA, "area", "variable"), sep = "\\.")
pop3

pop3 %>%
  pivot_wider(names_from = variable, values_from = value)

#2.4.5 方形化
# 方形化(Rectangling)是将一个深度嵌套的列表(通常来自 JSON 或 XML)驯服成一个具
# 有整齐的行和列的数据集。主要通过组合使用以下函数实现。
# unnest_longer():提取列表列的每个元，再按行存放(横向展开)。
# unnest_wider():提取列表列的每个元，再按列存放(纵向展开)。
# unnest_auto():提取列表列的每个元，猜测按行或按列存放。
# hoist():类似 unnest_wider()函数，但只取出选择的组件，且可以深入多个层。
# 以权力游戏角色数据集 got_chars 为例，它是一个长度为 30 的列表，里面又嵌套了很
# 多列表。一种处理技巧是，先把它创建成 tibble 以方便后续操作:
library(repurrrsive) # 使用got_chars数据集
chars = tibble(char = got_chars)
chars

#chars 是嵌套列表列，每个元素又是长度为 18 的列表，先横向展开它们:
chars1 = chars %>%
  unnest_wider(char)
chars1


"Ironb~ "In ~ ""
""      "In ~ ""
"Ironb~ "In ~ ""
""      ""    "In ~ FALSE <chr ~ <chr [~
                                         "Norvo~ "In ~ ""    TRUE  <chr ~ <chr [~
                                                                                  ## #   mother <chr>, spouse <chr>, allegiances <list>, books <list>,
                                                                                  ## #   povBooks <list>, tvSeries <list>, playedBy <list>
                                                                                  生成一个表，以匹配人物角色和他们的昵称，name 直接选择列，昵称来自列表列 titles, 纵向展开它:
                                                                                  chars1 %>%
                                                                                  select(name, title = titles) %>%
                                                                                  unnest_longer(title)
                                                                                TRUE  <chr ~ <chr [~
                                                                                                     TRUE  <chr ~ <chr [~
                                                                                                                          TRUE  <chr ~ <chr [~
                                                                                                                                               ## # A tibble: 60 x 2
                                                                                                                                               ## name
                                                                                                                                               ##   <chr>
                                                                                                                                               ## 1 Theon Greyjoy
                                                                                                                                               title
                                                                                                                                             <chr>
                                                                                                                                               Prince of Winterfell
                                                                                                                                             Captain of Sea Bitch
                                                                                                                                             Lord of the Iron Islands (by law of the green la~
                                                                                                                                                                         ## 2 Theon Greyjoy
                                                                                                                                                                         ## 3 Theon Greyjoy
                                                                                                                                                                         ## 4 Tyrion Lannister  Acting Hand of the King (former)
                                                                                                                                                                         ## 5 Tyrion Lannister  Master of Coin (former)
                                                                                                                                                                         ## 6 Victarion Greyjoy Lord Captain of the Iron Fleet
                                                                                                                                                                         ## # ... with 54 more rows
                                                                                                                                                                         或者改用 hoist()函数直接从内层提取想要的列，再对列表列 title 做纵向展开: chars %>%
                                                                                                                                                                         hoist(char, name = "name", title = "titles") %>%
                                                                                                                                                                         异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                       
                                                                                                                                                                       unnest_longer(title)
                                                                                                                                                                       ## # A tibble: 60 x 3
                                                                                                                                                                       ## name
                                                                                                                                                                       ##   <chr>
                                                                                                                                                                       ## 1 Theon Greyjoy
                                                                                                                                                                       char
                                                                                                                                                                       <list>
                                                                                                                                                                         <named list~
                                                                                                                                                                         <named list~
                                                                                                                                                                         title
                                                                                                                                                                       <chr>
                                                                                                                                                                         Prince of Winterfell
                                                                                                                                                                       Captain of Sea Bitch
                                                                                                                                                                       Lord of the Iron Islands (by law of~ <named list~
                                                                                                                                                                                                   <named list~
                                                                                                                                                                                                   <named list~
                                                                                                                                                                                                   <named list~
                                                                                                                                                                                                   另外，还有 tibblify 包专门用于将嵌套列表转化为 tibble 数据框。 2.5 基本数据操作
                                                                                                                                                                                                 用 dplyr 包实现各种数据操作，通常的数据操作无论多么复杂，往往都可以分解为若干基 本数据操作步骤的组合。
                                                                                                                                                                                                 共有 5 种基本数据操作:
                                                                                                                                                                                                    select()— 选择列;
                                                                                                                                                                                                  filter()/slice()— 筛选行;
                                                                                                                                                                                                  arrange()— 对行排序;
                                                                                                                                                                                                  mutate()— 修改列/创建新列;
                                                                                                                                                                                                  summarize()— 汇总。
                                                                                                                                                                                                 这些函数都可以与 group_by()— 分组函数连用，以改变数据操作的作用域(作用在整 个数据框，还是分别作用在数据框的每个分组)。
                                                                                                                                                                                                 这些函数组合使用就足以完成各种数据操作，它们的相同之处是:
                                                                                                                                                                                                    第 1 个参数是数据框，方便管道操作;
                                                                                                                                                                                                  根据列名访问数据框的列，且列名不用加引号;  返回结果是一个新数据框，不改变原数据框。
                                                                                                                                                                                                 通过把函数组合使用，可以方便地实现“将多个简单操作，依次用管道连接，并实现复杂 的数据操作”。
                                                                                                                                                                                                 另外，若要同时对所选择的多列数据应用函数，还可以使用强大的 across()函数，它支 持各种选择列语法，搭配 mutate()和 summarise()函数使用，能同时修改或汇总多列数据， 非常高效。类似地，dplyr 包提供了 if_any()和 if_all()函数，搭配 filter()函数使用 可以达到根据多列的值筛选行的目的。
                                                                                                                                                                                                 2.5.1 选择列
                                                                                                                                                                                                 选择列包括对数据框做选择列、调整列序和重命名列。 下面以虚拟的学生成绩数据来演示，包含随机生成的 20 个 NA:
                                                                                                                                                                                                   df = read_xlsx("data/ExamDatas_NAs.xlsx")
                                                                                                                                                                                                 ## 2 Theon Greyjoy
                                                                                                                                                                                                 ## 3 Theon Greyjoy
                                                                                                                                                                                                 ## 4 Tyrion Lannister  Acting Hand of the King (former)
                                                                                                                                                                                                 ## 5 Tyrion Lannister  Master of Coin (former)
                                                                                                                                                                                                 ## 6 Victarion Greyjoy Lord Captain of the Iron Fleet
                                                                                                                                                                                                 ## # ... with 54 more rows
                                                                                                                                                                                                 2.5 基本数据操作 89
                                                                                                                                                                                                 df
                                                                                                                                                                                                 ## # A tibble: 50 x 8
                                                                                                                                                                                                 ##   class name   sex
                                                                                                                                                                                                 ## <chr> <chr> <chr> ##1六1班何娜 女
                                                                                                                                                                                                 ## 2六1班黄才菊女 ## 3六1班陈芳妹女
                                                                                                                                                                                                 chinese  math english moral science
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   87 95 79
                                                                                                                                                                                                 92 77 87
                                                                                                                                                                                                 79 75 66
                                                                                                                                                                                                 9 10 NA 9 9 10
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 90 2 数据操作
                                                                                                                                                                                                 ## 4六1班陈学勤男
                                                                                                                                                                                                 ## 5六1班陈祝贞女
                                                                                                                                                                                                 ## 6六1班何小薇女
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 1.选择列语法 (1)用列名或索引选择列
                                                                                                                                                                                                 df %>%
                                                                                                                                                                                                   select(name, sex, math)
                                                                                                                                                                                                 ## # A tibble: 50 x 3
                                                                                                                                                                                                 ##   name   sex    math
                                                                                                                                                                                                 ##   <chr>  <chr> <dbl>
                                                                                                                                                                                                 ## 1何娜 女 92
                                                                                                                                                                                                 ## 2黄才菊女 77
                                                                                                                                                                                                 ## 3陈芳妹女 87
                                                                                                                                                                                                 ## 4陈学勤男 79
                                                                                                                                                                                                 ## 5陈祝贞女 79
                                                                                                                                                                                                 ## 6何小薇女 73
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 NA    79
                                                                                                                                                                                                 76    79
                                                                                                                                                                                                 83    73
                                                                                                                                                                                                 66     9      10
                                                                                                                                                                                                 67     8      10
                                                                                                                                                                                                 65     8       9
                                                                                                                                                                                                 # 或者select(2, 3, 5)
                                                                                                                                                                                                 (2)借助运算符选择列
                                                                                                                                                                                                  用“:”选择连续的若干列。
                                                                                                                                                                                                  用“!”选择变量集合的余集(反选)。
                                                                                                                                                                                                  用“&”和“|”选择变量集合的交集或并集。  用 c()合并多个选择。
                                                                                                                                                                                                 (3)借助选择助手函数  选择指定列
                                                                                                                                                                                                  everything():选择所有列。
                                                                                                                                                                                                  last_col():选择最后一列，可以带参数，例如last_col(5)选择倒数第6列。  选择列名匹配的列
                                                                                                                                                                                                  starts_with():得到以某前缀开头的列名。  ends_with():得到以某后缀结尾的列名。
                                                                                                                                                                                                  contains():得到包含某字符串的列名。
                                                                                                                                                                                                  matches():匹配正则表达式的列名。
                                                                                                                                                                                                  num_range():匹配数值范围的列名，如num_range("x",1:3)匹配x1、x2和x3。  结合函数选择列
                                                                                                                                                                                                  where():把一个函数应用到所有列，选择返回结果为TRUE的列，比如可以与
                                                                                                                                                                                                 is.numeric 等函数连用。
                                                                                                                                                                                                 2.选择列的示例
                                                                                                                                                                                                 df %>%
                                                                                                                                                                                                   select(starts_with("m"))
                                                                                                                                                                                                 ## # A tibble: 50 x 2
                                                                                                                                                                                                 ## math moral
                                                                                                                                                                                                 ##   <dbl> <dbl>
                                                                                                                                                                                                 ##1 92 9
                                                                                                                                                                                                 ##2 77 NA
                                                                                                                                                                                                 ##3 87 9
                                                                                                                                                                                                 ##4 79 9
                                                                                                                                                                                                 ##5 79 8
                                                                                                                                                                                                 ##6 73 8
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 df %>%
                                                                                                                                                                                                   select(ends_with("e"))
                                                                                                                                                                                                 ## # A tibble: 50 x 3
                                                                                                                                                                                                 ## 3六1班 陈芳妹 87
                                                                                                                                                                                                 ## 4六1班 陈学勤 79
                                                                                                                                                                                                 ## 5六1班 陈祝贞 79
                                                                                                                                                                                                 ## 6六1班 何小薇 73
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 9 9 8 8
                                                                                                                                                                                                 87      10
                                                                                                                                                                                                 95       9
                                                                                                                                                                                                 79      10
                                                                                                                                                                                                 NA      10
                                                                                                                                                                                                 76      10
                                                                                                                                                                                                 83       9
                                                                                                                                                                                                 2.5 基本数据操作 91
                                                                                                                                                                                                 ## name
                                                                                                                                                                                                 ## <chr>
                                                                                                                                                                                                 ## 1何娜
                                                                                                                                                                                                 ## 2 黄才菊
                                                                                                                                                                                                 ## 3 陈芳妹
                                                                                                                                                                                                 ## 4 陈学勤
                                                                                                                                                                                                 ## 5 陈祝贞
                                                                                                                                                                                                 ## 6 何小薇
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 df %>%
                                                                                                                                                                                                   select(contains("a"))
                                                                                                                                                                                                 ## # A tibble: 50 x 4
                                                                                                                                                                                                 ##   class name    math moral
                                                                                                                                                                                                 ##   <chr> <chr>  <dbl> <dbl>
                                                                                                                                                                                                 ## 1六1班何娜 92 9
                                                                                                                                                                                                 ## 2六1班 黄才菊 77 NA
                                                                                                                                                                                                 chinese science
                                                                                                                                                                                                 <dbl>   <dbl>
                                                                                                                                                                                                   根据正则表达式匹配选择列:
                                                                                                                                                                                                   df %>%
                                                                                                                                                                                                   select(matches("m.*a"))
                                                                                                                                                                                                 ## # A tibble: 50 x 2
                                                                                                                                                                                                 ## math moral
                                                                                                                                                                                                 ##   <dbl> <dbl>
                                                                                                                                                                                                 ##1 92 9
                                                                                                                                                                                                 ##2 77 NA
                                                                                                                                                                                                 ##3 87 9
                                                                                                                                                                                                 ##4 79 9
                                                                                                                                                                                                 ##5 79 8
                                                                                                                                                                                                 ##6 73 8
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 根据条件(逻辑判断)选择列，例如选择所有数值型的列:
                                                                                                                                                                                                   df %>%
                                                                                                                                                                                                   select(where(is.numeric))
                                                                                                                                                                                                 ## # A tibble: 50 x 5
                                                                                                                                                                                                 也可以自定义返回 TRUE 或 FALSE 的判断函数，支持 purrr 风格的公式写法。例如，选 择列值之和大于 3000 的列:
                                                                                                                                                                                                   df[, 4:8] %>%
                                                                                                                                                                                                   select(where(~ sum(.x, na.rm = TRUE) > 3000))
                                                                                                                                                                                                 ## # A tibble: 50 x 2
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##1
                                                                                                                                                                                                 ##2
                                                                                                                                                                                                 ##3
                                                                                                                                                                                                 ##4
                                                                                                                                                                                                 ##5
                                                                                                                                                                                                 ##6
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 chinese  math english moral science
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   87    92
                                                                                                                                                                                                 95    77
                                                                                                                                                                                                 79    87
                                                                                                                                                                                                 NA    79
                                                                                                                                                                                                 76    79
                                                                                                                                                                                                 83    73
                                                                                                                                                                                                 <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   ##
                                                                                                                                                                                                   ##
                                                                                                                                                                                                   ##1 87 92 ##2 95 77 ##3 79 87
                                                                                                                                                                                                   chinese  math
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   79
                                                                                                                                                                                                 75
                                                                                                                                                                                                 66
                                                                                                                                                                                                 66
                                                                                                                                                                                                 67
                                                                                                                                                                                                 65
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 NA       9
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 8      10
                                                                                                                                                                                                 8       9
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 92 2 数据操作
                                                                                                                                                                                                 ##4 NA 79
                                                                                                                                                                                                 ##5 76 79
                                                                                                                                                                                                 ##6 83 73
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 再比如，结合 n_distinct()选择唯一值数目小于 10 的列: df %>%
                                                                                                                                                                                                   select(where(~ n_distinct(.x) < 10))
                                                                                                                                                                                                 ## # A tibble: 50 x 4
                                                                                                                                                                                                 ##   class sex   moral science
                                                                                                                                                                                                 ##   <chr> <chr> <dbl>   <dbl>
                                                                                                                                                                                                 ## 1六1班女
                                                                                                                                                                                                 ## 2六1班女
                                                                                                                                                                                                 ## 3六1班女
                                                                                                                                                                                                 ## 4六1班男
                                                                                                                                                                                                 ## 5六1班女
                                                                                                                                                                                                 ## 6六1班女
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 ## 1六1班女
                                                                                                                                                                                                 ## 2六1班女
                                                                                                                                                                                                 ## 3六1班女
                                                                                                                                                                                                 ## 4六1班男
                                                                                                                                                                                                 ## 5六1班女
                                                                                                                                                                                                 ## 6六1班女
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 92六1班女 77六1班女 87六1班女 79六1班男 79六1班女 73六1班女
                                                                                                                                                                                                 79     9
                                                                                                                                                                                                 75    NA
                                                                                                                                                                                                 66     9
                                                                                                                                                                                                 66     9
                                                                                                                                                                                                 67     8
                                                                                                                                                                                                 65     8
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 NA       9
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 8      10
                                                                                                                                                                                                 8       9
                                                                                                                                                                                                 3.用“-”删除列 df %>%
                                                                                                                                                                                                   select(-c(name, chinese, science)) # 或者select(-ends_with("e"))
                                                                                                                                                                                                 ## # A tibble: 50 x 5
                                                                                                                                                                                                 ##   class sex    math english moral
                                                                                                                                                                                                 ##   <chr> <chr> <dbl>
                                                                                                                                                                                                 df %>%
                                                                                                                                                                                                   select(math, everything(), -ends_with("e"))
                                                                                                                                                                                                 ## # A tibble: 50 x 5
                                                                                                                                                                                                 注意:-ends_with()要放在 everything()后面，否则删除的列又全回来了。 4.调整列的顺序
                                                                                                                                                                                                 列根据被选择的顺序排列:
                                                                                                                                                                                                   df %>%
                                                                                                                                                                                                   select(ends_with("e"), math, name, class, sex)
                                                                                                                                                                                                 ## # A tibble: 50 x 6
                                                                                                                                                                                                 ##   name   chinese science  math class sex
                                                                                                                                                                                                 ##   <chr>    <dbl>   <dbl> <dbl> <chr> <chr>
                                                                                                                                                                                                 92六1班女 77六1班女 87六1班女 79六1班男 79六1班女 73六1班女
                                                                                                                                                                                                 92
                                                                                                                                                                                                 77
                                                                                                                                                                                                 87
                                                                                                                                                                                                 79
                                                                                                                                                                                                 79
                                                                                                                                                                                                 73
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   79     9
                                                                                                                                                                                                 75    NA
                                                                                                                                                                                                 66     9
                                                                                                                                                                                                 66     9
                                                                                                                                                                                                 67     8
                                                                                                                                                                                                 65     8
                                                                                                                                                                                                 ## ##
                                                                                                                                                                                                 ## 1
                                                                                                                                                                                                 ## 2
                                                                                                                                                                                                 ## 3
                                                                                                                                                                                                 ## 4
                                                                                                                                                                                                 ## 5
                                                                                                                                                                                                 ## 6
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 math class sex
                                                                                                                                                                                                 <dbl> <chr> <chr>
                                                                                                                                                                                                   english moral
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   ## 1何娜
                                                                                                                                                                                                   ## 2 黄才菊
                                                                                                                                                                                                   ## 3 陈芳妹
                                                                                                                                                                                                   ## 4 陈学勤
                                                                                                                                                                                                   ## 5 陈祝贞
                                                                                                                                                                                                   ## 6 何小薇
                                                                                                                                                                                                   ## # ... with 44 more rows
                                                                                                                                                                                                   87 10 959 79 10 NA 10 76 10 839
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 ## # A tibble: 50 x 8
                                                                                                                                                                                                 ##    math class name   sex
                                                                                                                                                                                                 ##   <dbl> <chr> <chr>  <chr>   <dbl>
                                                                                                                                                                                                 ##1 92六1班何娜 女 87
                                                                                                                                                                                                 ##2 77六1班 黄才菊 女 95
                                                                                                                                                                                                 ##3 87六1班 陈芳妹 女 79
                                                                                                                                                                                                 ##4 79六1班 陈学勤 男 NA
                                                                                                                                                                                                 ##5 79六1班 陈祝贞 女 76
                                                                                                                                                                                                 ##6 73六1班 何小薇 女 83
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 ## class name
                                                                                                                                                                                                 ##   <chr> <chr>
                                                                                                                                                                                                 ## 1六1班何娜
                                                                                                                                                                                                 ## 2六1班 黄才菊
                                                                                                                                                                                                 ## 3六1班 陈芳妹
                                                                                                                                                                                                 ## 4六1班 陈学勤
                                                                                                                                                                                                 ## 5六1班 陈祝贞
                                                                                                                                                                                                 ## 6六1班 何小薇
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 chinese english moral science
                                                                                                                                                                                                 <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   用 relocate()函数将选择的列移到某列之前或之后，基本语法为: relocate(.data, ..., .before, .after)
                                                                                                                                                                                                 例如，将数值列移到 name 列的后面: ## # A tibble: 50 x 8
                                                                                                                                                                                                   chinese  math english moral science sex
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   87    92
                                                                                                                                                                                                 95    77
                                                                                                                                                                                                 <dbl> <dbl>   <dbl> <chr>
                                                                                                                                                                                                   79    87
                                                                                                                                                                                                 NA    79
                                                                                                                                                                                                 76    79
                                                                                                                                                                                                 83    73
                                                                                                                                                                                                 79
                                                                                                                                                                                                 75
                                                                                                                                                                                                 66
                                                                                                                                                                                                 66
                                                                                                                                                                                                 67
                                                                                                                                                                                                 65
                                                                                                                                                                                                 9 10女 NA 9女 9 10女 9 10男 8 10女 89女
                                                                                                                                                                                                 5.重命名列
                                                                                                                                                                                                 用 set_names()函数为所有列设置新列名:
                                                                                                                                                                                                   ## # A tibble: 50 x 8
                                                                                                                                                                                                   ## 班级姓名 性别 语文数学英语品德科学
                                                                                                                                                                                                   ## <chr> <chr> <chr> <dbl> <dbl> <dbl> <dbl> <dbl>
                                                                                                                                                                                                   9    10
                                                                                                                                                                                                 NA     9
                                                                                                                                                                                                 9    10
                                                                                                                                                                                                 9    10
                                                                                                                                                                                                 8    10
                                                                                                                                                                                                 8     9
                                                                                                                                                                                                 rename()函数只修改部分列名，格式为:新名 = 旧名。
                                                                                                                                                                                                 ##1六1班何娜 女 ##2六1班黄才菊女 ##3六1班陈芳妹女 ##4六1班陈学勤男 ##5六1班陈祝贞女 ##6六1班何小薇女
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 79
                                                                                                                                                                                                 75
                                                                                                                                                                                                 66
                                                                                                                                                                                                 66
                                                                                                                                                                                                 67
                                                                                                                                                                                                 65
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 NA       9
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 8      10
                                                                                                                                                                                                 8       9
                                                                                                                                                                                                 2.5 基本数据操作 93
                                                                                                                                                                                                 df %>%
                                                                                                                                                                                                   relocate(where(is.numeric), .after = name)
                                                                                                                                                                                                 df %>%
                                                                                                                                                                                                   set_names("班级", "姓名", "性别", "语文",
                                                                                                                                                                                                             "数学", "英语", "品德", "科学")
                                                                                                                                                                                                 df %>%
                                                                                                                                                                                                   rename(数学 = math, 科学 = science)
                                                                                                                                                                                                 ## # A tibble: 50 x 8
                                                                                                                                                                                                 ##   class name   sex
                                                                                                                                                                                                 ## <chr> <chr> <chr> ##1六1班何娜 女 ##2六1班黄才菊女 ##3六1班陈芳妹女 ##4六1班陈学勤男 ##5六1班陈祝贞女 ##6六1班何小薇女
                                                                                                                                                                                                 chinese 数学 english moral 科学
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 87    92    79
                                                                                                                                                                                                 95    77    75
                                                                                                                                                                                                 79    87    66
                                                                                                                                                                                                 NA    79    66
                                                                                                                                                                                                 76    79    67
                                                                                                                                                                                                 83    73    65
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   87    92
                                                                                                                                                                                                 95    77
                                                                                                                                                                                                 79    87
                                                                                                                                                                                                 NA    79
                                                                                                                                                                                                 76    79
                                                                                                                                                                                                 83    73
                                                                                                                                                                                                 <dbl> <dbl> <dbl>
                                                                                                                                                                                                   异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 79
                                                                                                                                                                                                 75
                                                                                                                                                                                                 66
                                                                                                                                                                                                 66
                                                                                                                                                                                                 67
                                                                                                                                                                                                 65
                                                                                                                                                                                                 9    10
                                                                                                                                                                                                 NA     9
                                                                                                                                                                                                 9    10
                                                                                                                                                                                                 9    10
                                                                                                                                                                                                 8    10
                                                                                                                                                                                                 8     9
                                                                                                                                                                                                 还有更强大的rename_with(.data, .fn, .cols)函数，参数“.cols”支持用选择 列语法选择要重命名的列，“.fn”是对所选列重命名的函数，将原列名的字符向量变成新列名 的字符向量。比如，将包含“m”的列名，都拼接上前缀“new_”:
                                                                                                                                                                                                   
                                                                                                                                                                                                   94 2 数据操作
                                                                                                                                                                                                 还有更强大的rename_with(.data, .fn, .cols)函数，参数“.col”支持用选择列 语法选择要重命名的列，“.fn”是对所选列重命名的函数，将原列名的字符向量变成新列名的 字符向量。比如，将包含“m”的列名，都拼接上前缀“new_”:
                                                                                                                                                                                                   df %>%
                                                                                                                                                                                                   rename_with(~ paste0("new_", .x), matches("m"))
                                                                                                                                                                                                 ## # A tibble: 50 x 8
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##2六1班黄才菊女 ##3六1班陈芳妹女 ##4六1班陈学勤男 ##5六1班陈祝贞女 ##6六1班何小薇女
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 6.强大的 across()函数
                                                                                                                                                                                                 class new_name sex
                                                                                                                                                                                                 chinese new_math english new_moral science
                                                                                                                                                                                                 <chr> <chr> <chr> 1六1班何娜 女
                                                                                                                                                                                                 <dbl>    <dbl>   <dbl>
                                                                                                                                                                                                   87       92      79
                                                                                                                                                                                                 <dbl>   <dbl>
                                                                                                                                                                                                   9      10
                                                                                                                                                                                                 NA       9
                                                                                                                                                                                                 9 10 9 10 8 10 8 9
                                                                                                                                                                                                 95       77
                                                                                                                                                                                                 79       87
                                                                                                                                                                                                 NA       79
                                                                                                                                                                                                 76       79
                                                                                                                                                                                                 83       73
                                                                                                                                                                                                 75 66 66 67 65
                                                                                                                                                                                                 函数 across()恰如其名，让零个/一个/多个函数穿过所选择的列，即同时对所选择的多列 应用若干函数，基本格式如下:
                                                                                                                                                                                                   across(.cols = everything(), .fns = NULL, ..., .names)
                                                                                                                                                                                                  .cols 为根据选择列语法选定的列范围。
                                                                                                                                                                                                  .fns 为应用到选定列上的函数1，它可以是以下类型。
                                                                                                                                                                                                  NULL:不对列作变换。
                                                                                                                                                                                                  一个函数，如 mean。 一个purrr风格的匿名函数，如~ .X * 10。  多个函数或匿名函数构成的列表。
                                                                                                                                                                                                  .names 用来设置输出列的列名样式，默认为{col}_{fn}。若想保留旧列，则需要设 置该参数，否则将使用原列名，即计算的新列将替换旧列。
                                                                                                                                                                                                 across()支持各种选择列语法，与 mutate()和 summarise()连用，可以同时修改/(多 种)汇总多列效果。
                                                                                                                                                                                                 across()也能与 group_by()、count()和 distinct()函数连用，此时“.fns”为 NULL，只起到选择列的作用。
                                                                                                                                                                                                 across()函数的引入，使我们可以弃用那些限定列范围的后缀:_all、_if、_at。  across(everything(), .fns):在所有列范围内，代替后缀_all。
                                                                                                                                                                                                  across(where(), .fns):在满足条件的列范围内，代替后缀_if。
                                                                                                                                                                                                  across(.cols, .fns):在给定的列范围内，代替后缀_at。
                                                                                                                                                                                                 across 函数的作用机制如图 2.20 所示，它包含了分解思维，即想要同时修改多列，只需 要选出多列，并把对一列数据做的操作写成函数，剩下的交给 across()就行了。
                                                                                                                                                                                                 1 在这些函数内部可以使用 cur_column()和 cur_group()函数以访问当前列和分组键值。 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 2.5.2 修改列
                                                                                                                                                                                                 mutate(new_col = 5)
                                                                                                                                                                                                 ## # A tibble: 50 x 9
                                                                                                                                                                                                 ##   class name   sex
                                                                                                                                                                                                 ## <chr> <chr> <chr> ##1六1班何娜 女 ##2六1班黄才菊女 ##3六1班陈芳妹女 ##4六1班陈学勤男 ##5六1班陈祝贞女 ##6六1班何小薇女
                                                                                                                                                                                                 chinese  math english moral science new_col
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 正常是为长度等于行数的向量赋值:
                                                                                                                                                                                                   df %>%
                                                                                                                                                                                                   mutate(new_col = 1:n())
                                                                                                                                                                                                 ## # A tibble: 50 x 9
                                                                                                                                                                                                 ##   class name   sex
                                                                                                                                                                                                 ## <chr> <chr> <chr> ##1六1班何娜 女 ##2六1班黄才菊女 ##3六1班陈芳妹女 ##4六1班陈学勤男 ##5六1班陈祝贞女 ##6六1班何小薇女
                                                                                                                                                                                                 chinese  math english moral science new_col
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 图 2.20 across()函数示意图
                                                                                                                                                                                                 修改列即修改数据框的列，并计算新列。
                                                                                                                                                                                                 1.创建新列
                                                                                                                                                                                                 用 dplyr 包中的 mutate()函数创建或修改列，返回原数据框并增加新列，默认加在最后 一列，参数.before 和.after 可以设置新列的位置。若改用 transmute()函数则只返回增 加的新列。
                                                                                                                                                                                                 若只给新列 1 个值，则循环使用并得到值相同的一列: df %>%
                                                                                                                                                                                                   <dbl> <dbl>
                                                                                                                                                                                                   87    92
                                                                                                                                                                                                 95    77
                                                                                                                                                                                                 79    87
                                                                                                                                                                                                 NA    79
                                                                                                                                                                                                 76    79
                                                                                                                                                                                                 83    73
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   <dbl>   <dbl>
                                                                                                                                                                                                   10       5
                                                                                                                                                                                                 9       5
                                                                                                                                                                                                 10 5 10 5 10 5
                                                                                                                                                                                                 9 5
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   87    92
                                                                                                                                                                                                 95    77
                                                                                                                                                                                                 79    87
                                                                                                                                                                                                 NA    79
                                                                                                                                                                                                 76    79
                                                                                                                                                                                                 83    73
                                                                                                                                                                                                 <dbl> <dbl>   <dbl>   <int>
                                                                                                                                                                                                   注意:n()函数返回当前分组的样本数, 未分组则为总行数。
                                                                                                                                                                                                 2.计算新列
                                                                                                                                                                                                 用数据框的现有列计算新列，若要修改当前列，只需要赋值给原列名。
                                                                                                                                                                                                 df %>%
                                                                                                                                                                                                   mutate(total = chinese + math + english + moral + science)
                                                                                                                                                                                                 ## # A tibble: 50 x 9
                                                                                                                                                                                                 ##   class name   sex   chinese  math english moral science total
                                                                                                                                                                                                 ##   <chr> <chr>  <chr>   <dbl> <dbl>   <dbl> <dbl>   <dbl> <dbl>
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 79
                                                                                                                                                                                                 75
                                                                                                                                                                                                 66
                                                                                                                                                                                                 66
                                                                                                                                                                                                 67
                                                                                                                                                                                                 65
                                                                                                                                                                                                 9 NA 9 9 8 8
                                                                                                                                                                                                 79
                                                                                                                                                                                                 75
                                                                                                                                                                                                 66
                                                                                                                                                                                                 66
                                                                                                                                                                                                 67
                                                                                                                                                                                                 65
                                                                                                                                                                                                 9      10       1
                                                                                                                                                                                                 NA       9       2
                                                                                                                                                                                                 9      10       3
                                                                                                                                                                                                 9      10       4
                                                                                                                                                                                                 8      10       5
                                                                                                                                                                                                 8       9       6
                                                                                                                                                                                                 2.5 基本数据操作 95
                                                                                                                                                                                                 
                                                                                                                                                                                                 96 2 数据操作 ##1六1班何娜女
                                                                                                                                                                                                 ##2六1班黄才菊女 ##3六1班陈芳妹女 ##4六1班陈学勤男 ##5六1班陈祝贞女 ##6六1班何小薇女
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 87    92
                                                                                                                                                                                                 95    77
                                                                                                                                                                                                 79    87
                                                                                                                                                                                                 NA    79
                                                                                                                                                                                                 76    79
                                                                                                                                                                                                 83    73
                                                                                                                                                                                                 799 75 NA 669 669 678 658
                                                                                                                                                                                                 10 277 9NA 10 251 10 NA 10 240 9 238
                                                                                                                                                                                                 注意:不能用 sum()函数，它会将整个列的内容都加起来，类似的还有 mean()函数。
                                                                                                                                                                                                 在同一个 mutate()函数中可以同时创建或计算多个列，它们是从前往后依次计算，所以 可以使用前面新创建的列，例如:
                                                                                                                                                                                                    计算 df 中 math 列的中位数;
                                                                                                                                                                                                  创建标记 math 是否大于中位数的逻辑值列;
                                                                                                                                                                                                  用 as.numeric()将 TRUE/FALSE 转化为 1/0。
                                                                                                                                                                                                 df %>%
                                                                                                                                                                                                   ## # A tibble: 50 x 10
                                                                                                                                                                                                   ##   class name   sex
                                                                                                                                                                                                   ## <chr> <chr> <chr> ##1六1班何娜女 ##2六1班黄才菊女 ##3六1班陈芳妹女 ##4六1班陈学勤男 ##5六1班陈祝贞女 ##6六1班何小薇女
                                                                                                                                                                                                   med label
                                                                                                                                                                                                 <dbl> <dbl> <dbl>
                                                                                                                                                                                                   10    73     1
                                                                                                                                                                                                 9    73     1
                                                                                                                                                                                                 10    73     1
                                                                                                                                                                                                 10    73     1
                                                                                                                                                                                                 10    73     1
                                                                                                                                                                                                 9    73     0
                                                                                                                                                                                                 mutate(med = median(math, na.rm = TRUE),
                                                                                                                                                                                                        label = math > med,
                                                                                                                                                                                                        label = as.numeric(label))
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 3.修改多列
                                                                                                                                                                                                 ##1六1班何娜女87 92
                                                                                                                                                                                                 <chr> <chr>
                                                                                                                                                                                                   9     10
                                                                                                                                                                                                 ## 2六1班 黄才菊 女
                                                                                                                                                                                                 ## 3六1班 陈芳妹 女
                                                                                                                                                                                                 ## 4六1班 陈学勤 男
                                                                                                                                                                                                 ## 5六1班 陈祝贞 女
                                                                                                                                                                                                 ## 6六1班 何小薇 女
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 79
                                                                                                                                                                                                 75      <NA>  9
                                                                                                                                                                                                 66      9     10
                                                                                                                                                                                                 66      9     10
                                                                                                                                                                                                 67      8     10
                                                                                                                                                                                                 65      8     9
                                                                                                                                                                                                 (2)把函数应用到满足条件的列 对所有数值列做归一化: rescale = function(x) {
                                                                                                                                                                                                   chinese  math english moral science
                                                                                                                                                                                                   <dbl> <dbl>
                                                                                                                                                                                                     87    92
                                                                                                                                                                                                   95    77
                                                                                                                                                                                                   79    87
                                                                                                                                                                                                   NA    79
                                                                                                                                                                                                   76    79
                                                                                                                                                                                                   83    73
                                                                                                                                                                                                   <dbl> <dbl>
                                                                                                                                                                                                     79     9
                                                                                                                                                                                                   75    NA
                                                                                                                                                                                                   669 669 678 65 8
                                                                                                                                                                                                   结合 across()函数和选择列语法可以把函数应用到多列，从而实现同时修改多列。 (1)把函数应用到所有列
                                                                                                                                                                                                   将所有列转化为字符型:
                                                                                                                                                                                                     df %>%
                                                                                                                                                                                                     mutate(across(everything(), as.character))
                                                                                                                                                                                                   ## # A tibble: 50 x 8
                                                                                                                                                                                                   ##   class name   sex   chinese math  english moral science
                                                                                                                                                                                                   ##   <chr> <chr>  <chr> <chr>   <chr> <chr>
                                                                                                                                                                                                   95      77
                                                                                                                                                                                                   79      87
                                                                                                                                                                                                   <NA>    79
                                                                                                                                                                                                   76      79
                                                                                                                                                                                                   83      73
                                                                                                                                                                                                   rng = range(x, na.rm = TRUE)
                                                                                                                                                                                                   (x - rng[1]) / (rng[2] - rng[1])
                                                                                                                                                                                                 }
                                                                                                                                                                                                 df %>%
                                                                                                                                                                                                   mutate(across(where(is.numeric), rescale))
                                                                                                                                                                                                 ## # A tibble: 50 x 8
                                                                                                                                                                                                 ## class name sex chinese math english moral science ## <chr> <chr> <chr> <dbl> <dbl> <dbl> <dbl> <dbl> ## 1六1班何娜 女 0.843 0.974 1 0.875 1
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 ## 2六1班 黄才菊 女
                                                                                                                                                                                                 ## 3六1班 陈芳妹 女
                                                                                                                                                                                                 ## 4六1班 陈学勤 男
                                                                                                                                                                                                 ## 5六1班 陈祝贞 女
                                                                                                                                                                                                 ## 6六1班 何小薇 女
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 (3)把函数应用到指定的列
                                                                                                                                                                                                 1 0.776
                                                                                                                                                                                                 0.926 NA       0.833
                                                                                                                                                                                                 0.759  0.875   1
                                                                                                                                                                                                 0.759  0.875   1
                                                                                                                                                                                                 0.778  0.75    1
                                                                                                                                                                                                 0.741  0.75    0.833
                                                                                                                                                                                                 0.686 0.908
                                                                                                                                                                                                 NA     0.803
                                                                                                                                                                                                 0.627 0.803
                                                                                                                                                                                                 0.765 0.724
                                                                                                                                                                                                 将 iris 中列名包含 length 和 width 的列的测量单位从厘米变成毫米:
                                                                                                                                                                                                   as_tibble(iris) %>%
                                                                                                                                                                                                   mutate(across(contains("Length") | contains("Width"), ~ .x * 10))
                                                                                                                                                                                                 ## # A tibble: 150 x 5
                                                                                                                                                                                                 ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
                                                                                                                                                                                                 2.5 基本数据操作 97
                                                                                                                                                                                                 ##          <dbl>       <dbl>        <dbl>
                                                                                                                                                                                                 ## 1           51          35           14
                                                                                                                                                                                                 ## 2           49          30           14
                                                                                                                                                                                                 ## 3           47          32           13
                                                                                                                                                                                                 ## 4           46          31           15
                                                                                                                                                                                                 ## 5           50          36           14
                                                                                                                                                                                                 ## 6           54          39           17
                                                                                                                                                                                                 ## # ... with 144 more rows
                                                                                                                                                                                                 4.替换 NA (1)replace_na()函数
                                                                                                                                                                                                 <dbl> <fct>
                                                                                                                                                                                                   2 setosa
                                                                                                                                                                                                 2 setosa
                                                                                                                                                                                                 2 setosa
                                                                                                                                                                                                 2 setosa
                                                                                                                                                                                                 2 setosa
                                                                                                                                                                                                 4 setosa
                                                                                                                                                                                                 实现用某个值替换一列中的所有 NA 值，该函数接受一个命名列表，其成分为“列名 = 替 换值”。
                                                                                                                                                                                                 替换具体的列的缺失值，代码如下:
                                                                                                                                                                                                   starwars %>%
                                                                                                                                                                                                   ## # A tibble: 87 x 14
                                                                                                                                                                                                   ##   name  height  mass hair_color skin_color eye_color birth_year sex
                                                                                                                                                                                                   replace_na(list(hair_color = "UNKNOWN",
                                                                                                                                                                                                                   height = round(mean(.$height, na.rm = TRUE))))
                                                                                                                                                                                                 ##   <chr>  <dbl> <dbl> <chr>
                                                                                                                                                                                                 <chr>      <chr>          <dbl> <chr>
                                                                                                                                                                                                   fair       blue            19   male
                                                                                                                                                                                                 gold       yellow         112   none
                                                                                                                                                                                                 white, bl~ red             33   none
                                                                                                                                                                                                 ## 1 Luke~
                                                                                                                                                                                                 ## 2 C-3PO
                                                                                                                                                                                                 ## 3 R2-D2
                                                                                                                                                                                                 ## 4 Dart~
                                                                                                                                                                                                 ## 5 Leia~
                                                                                                                                                                                                 ## 6 Owen~
                                                                                                                                                                                                 ## # ... with 81 more rows, and 6 more variables: gender <chr>,
                                                                                                                                                                                                 ## #   homeworld <chr>, species <chr>, films <list>, vehicles <list>,
                                                                                                                                                                                                 ## #   starships <list>
                                                                                                                                                                                                 所有浮点列的缺失值用其均值替换(结果略)，代码如下:
                                                                                                                                                                                                   starwars %>%
                                                                                                                                                                                                   mutate(across(where(is.double), ~ replace_na(.x, mean(.x, na.rm = TRUE))))
                                                                                                                                                                                                 (2)fill()函数
                                                                                                                                                                                                 用前一个(或后一个)非缺失值填充 NA。有些表在记录时，会省略与上一条记录相同的内
                                                                                                                                                                                                 172    77 blond
                                                                                                                                                                                                 167    75 UNKNOWN
                                                                                                                                                                                                 96    32 UNKNOWN
                                                                                                                                                                                                 202   136 none
                                                                                                                                                                                                 150    49 brown
                                                                                                                                                                                                 178   120 brown, gr~ light
                                                                                                                                                                                                 容，例如:
                                                                                                                                                                                                   load("data/gap_data.rda")
                                                                                                                                                                                                 knitr::kable(gap_data, align="c")
                                                                                                                                                                                                 得到的结果如表 2.4 所示。
                                                                                                                                                                                                 表 2.4
                                                                                                                                                                                                 Bilpin A. longiforlia
                                                                                                                                                                                                 待填充数据
                                                                                                                                                                                                 white light
                                                                                                                                                                                                 yellow
                                                                                                                                                                                                 brown
                                                                                                                                                                                                 blue
                                                                                                                                                                                                 41.9 male
                                                                                                                                                                                                 19   fema~
                                                                                                                                                                                                   52   male
                                                                                                                                                                                                 site
                                                                                                                                                                                                 species
                                                                                                                                                                                                 sample_num
                                                                                                                                                                                                 bees_present
                                                                                                                                                                                                 1 TRUE
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 98 2 数据操作
                                                                                                                                                                                                 NA NA NA NA NA Grose Vale NA
                                                                                                                                                                                                 NA 2 TRUE
                                                                                                                                                                                                 NA 3 TRUE A. elongata 1 TRUE NA 2 FALSE NA 3 TRUE
                                                                                                                                                                                                 A. terminalis 1 FALSE NA 2 FALSE NA NA 2 TRUE
                                                                                                                                                                                                 tidyr 包中的 fill()函数适合处理这种结构的缺失值, 默认是向下填充，即用上一个非 缺失值填充:
                                                                                                                                                                                                   gap_data %>%
                                                                                                                                                                                                   fill(site, species)
                                                                                                                                                                                                 ## # A tibble: 9 x 4
                                                                                                                                                                                                 ##   site   species
                                                                                                                                                                                                 ##   <chr>  <chr>
                                                                                                                                                                                                 ## 1 Bilpin A. longiforlia
                                                                                                                                                                                                 ## 2 Bilpin A. longiforlia
                                                                                                                                                                                                 ## 3 Bilpin A. longiforlia
                                                                                                                                                                                                 ## 4 Bilpin A. elongata
                                                                                                                                                                                                 ## 5 Bilpin A. elongata
                                                                                                                                                                                                 ## 6 Bilpin A. elongata
                                                                                                                                                                                                 ## # ... with 3 more rows
                                                                                                                                                                                                 5.重新编码
                                                                                                                                                                                                 sample_num bees_present
                                                                                                                                                                                                 <dbl> <lgl>
                                                                                                                                                                                                   1 TRUE
                                                                                                                                                                                                 2 TRUE
                                                                                                                                                                                                 3 TRUE
                                                                                                                                                                                                 1 TRUE
                                                                                                                                                                                                 2 FALSE
                                                                                                                                                                                                 3 TRUE
                                                                                                                                                                                                 现实中，经常需要对列中的值进行重新编码。
                                                                                                                                                                                                 (1)两类别情形:if_else()函数
                                                                                                                                                                                                 用 if_else()函数做二分支判断进而重新编码:
                                                                                                                                                                                                   df %>%
                                                                                                                                                                                                   mutate(sex = if_else(sex == "男", "M", "F"))
                                                                                                                                                                                                 ## # A tibble: 50 x 8
                                                                                                                                                                                                 ##   class name   sex
                                                                                                                                                                                                 ##   <chr> <chr>  <chr>
                                                                                                                                                                                                 ## 1六1班何娜F
                                                                                                                                                                                                 chinese  math english moral science
                                                                                                                                                                                                 <dbl> <dbl>   <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   87 92 79 9 10
                                                                                                                                                                                                 ## 2六1班 黄才菊F
                                                                                                                                                                                                 ## 3六1班 陈芳妹F
                                                                                                                                                                                                 ## 4六1班 陈学勤M
                                                                                                                                                                                                 ## 5六1班 陈祝贞F
                                                                                                                                                                                                 ## 6六1班 何小薇F
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 95    77
                                                                                                                                                                                                 79    87
                                                                                                                                                                                                 NA    79
                                                                                                                                                                                                 76    79
                                                                                                                                                                                                 83    73
                                                                                                                                                                                                 75    NA       9
                                                                                                                                                                                                 66     9      10
                                                                                                                                                                                                 66     9      10
                                                                                                                                                                                                 67     8      10
                                                                                                                                                                                                 65     8       9
                                                                                                                                                                                                 (2)多类别情形:case_when()函数
                                                                                                                                                                                                 用 case_when()函数做多分支判断进而重新编码，避免使用很多 if_else()嵌套: df %>%
                                                                                                                                                                                                   mutate(math = case_when(math >= 75 ~ "High",
                                                                                                                                                                                                                           math >= 60 ~ "Middle",
                                                                                                                                                                                                                           TRUE       ~ "Low"))
                                                                                                                                                                                                 ## # A tibble: 50 x 8
                                                                                                                                                                                                 ##   class name   sex
                                                                                                                                                                                                 ## <chr> <chr> <chr> ## 1六1班何娜 女 ##2六1班黄才菊女 ##3六1班陈芳妹女 ##4六1班陈学勤男 ##5六1班陈祝贞女 ##6六1班何小薇女
                                                                                                                                                                                                 chinese math
                                                                                                                                                                                                 <dbl> <chr>
                                                                                                                                                                                                   87 High
                                                                                                                                                                                                 95 High
                                                                                                                                                                                                 79 High
                                                                                                                                                                                                 NA High
                                                                                                                                                                                                 76 High
                                                                                                                                                                                                 83 Middle
                                                                                                                                                                                                 english moral science
                                                                                                                                                                                                 <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   ## # ... with 44 more rows
                                                                                                                                                                                                   异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 79
                                                                                                                                                                                                 75
                                                                                                                                                                                                 66
                                                                                                                                                                                                 66
                                                                                                                                                                                                 67
                                                                                                                                                                                                 65
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 NA       9
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 8      10
                                                                                                                                                                                                 8       9
                                                                                                                                                                                                 
                                                                                                                                                                                                 case_when()中用的是公式形式:
                                                                                                                                                                                                    左边是返回 TRUE 或 FALSE 的表达式或函数;
                                                                                                                                                                                                  右边是若左边表达式为 TRUE，则重新编码的值，也可以是表达式或函数;
                                                                                                                                                                                                  每个分支条件将从上到下计算，并接受第一个 TRUE 条件;
                                                                                                                                                                                                  最后一个分支直接用 TRUE 表示若其他条件都不为 TRUE 时怎么做。
                                                                                                                                                                                                 (3)更强大的重新编码函数
                                                                                                                                                                                                 基于 tidyverse 设计哲学，sjmisc 包实现了对变量做数据变换，如重新编码、二分或分
                                                                                                                                                                                                 组变量、设置与替换缺失值等。sjmisc 包也支持标签化数据，这对操作 SPSS 或 Stata 数据集 特别有用。
                                                                                                                                                                                                 重新编码函数 rec()，可以将变量的旧值重新编码为新值，基本格式为: rec(x, rec, append, ...)
                                                                                                                                                                                                  x:为数据框(或向量)。
                                                                                                                                                                                                  append:默认为 TRUE，则返回包含重编码新列的数据框;若 FALSE，则只返回重编
                                                                                                                                                                                                 码的新列。
                                                                                                                                                                                                  rec:设置重编码模式，即哪些旧值被哪些新值取代，具体如下。
                                                                                                                                                                                                 重编码对:每个重编码对用“;”隔开，例如rec="1=1; 2=4; 3=2; 4=3"。  多值:把多个旧值(逗号分隔)重编码为一个新值，例如 rec="1,2=1; 3,4=2"。 值范围:用冒号表示值范围，例如rec="1:4=1; 5:8=2"。
                                                                                                                                                                                                  数值型值范围:带小数部分的数值向量，值范围内的所有值将被重新编码，例 如rec="1:2.5=1; 2.6:3=2"1
                                                                                                                                                                                                  min 和 max:最小值和最大值分别用 min 和 max 表示，例如 rec = "min:4=1; 5:max=2"(min和max也可以作为新值，如5:7=max, 表示将5~7编码为max(x))。  else:所有未设定的其他值都用 else 表示，例如 rec="3=1; 1=2; else=3"。  copy:else可以结合copy一起使用，表示所有未设定的其他值保持原样(从 原数值copy)，例如rec="3=1; 1=2; else=copy"。
                                                                                                                                                                                                  NAs:NA既可以作为旧值，也可以作为新值，例如rec="NA=1; 3:5=NA"。  rev:设置反转值顺序。
                                                                                                                                                                                                  非捕获值:不匹配的值将设置为 NA, 除非使用 else 和 copy。
                                                                                                                                                                                                 library(sjmisc)
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## math_r <character>
                                                                                                                                                                                                 ## # total N=50 valid N=50 mean=3.28 sd=1.26 ##
                                                                                                                                                                                                 ##Value | N|Raw%|Valid%|Cum.%
                                                                                                                                                                                                 ## -------------------------------------- ##-Inf |3|6.00| 6.00| 6
                                                                                                                                                                                                 2.5 基本数据操作 99
                                                                                                                                                                                                 df %>%
                                                                                                                                                                                                   rec(math, rec = "min:59=不及格; 60:74=中; 75:85=良; 85:max=优",
                                                                                                                                                                                                       append = FALSE) %>%
                                                                                                                                                                                                   frq() # 频率表
                                                                                                                                                                                                 ##不及格| 14 | 28.00 |
                                                                                                                                                                                                 28.00 |     34
                                                                                                                                                                                                 20.00 |     54
                                                                                                                                                                                                 24.00 |     78
                                                                                                                                                                                                 22.00 |    100
                                                                                                                                                                                                 ## 良 ## 优 ## 中
                                                                                                                                                                                                 | 10 | 20.00 |
                                                                                                                                                                                                   | 12 | 24.00 |
                                                                                                                                                                                                   | 11 | 22.00 |
                                                                                                                                                                                                   1 注意，对于介于 2.5 和 2.6 之间的值(如 2.55)，因未包含在值范围内将不被重新编码。 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 100 2 数据操作
                                                                                                                                                                                                 ## <NA> | 0 | 0.00 | <NA> | <NA>
                                                                                                                                                                                                 注意:新值的值标签可以在重新编码时一起设置，只需要在每个重编码对后接上中括号标签。 2.5.3 筛选行
                                                                                                                                                                                                 筛选行，即按行选择数据子集，包括过滤行、对行切片、删除行。 先创建一个包含重复行的数据框:
                                                                                                                                                                                                   set.seed(123)
                                                                                                                                                                                                 1.用 filter()函数根据条件筛选行
                                                                                                                                                                                                 提供筛选条件给 filter()函数则返回满足该条件的行。筛选条件本质上是用长度同行数 的逻辑向量，通常是直接用能返回这种逻辑向量的列表达式。
                                                                                                                                                                                                 df_dup %>%
                                                                                                                                                                                                   filter(sex == "男", math > 80)
                                                                                                                                                                                                 ## # A tibble: 8 x 8
                                                                                                                                                                                                 ##   class name   sex
                                                                                                                                                                                                 ##   <chr> <chr>  <chr>
                                                                                                                                                                                                 ## 1六2班 陈华健 男
                                                                                                                                                                                                 ## 2六2班 陈华健 男
                                                                                                                                                                                                 ## 3六4班<NA>男
                                                                                                                                                                                                 ## 4六2班 陈华健 男
                                                                                                                                                                                                 ## 5六4班 李小龄 男
                                                                                                                                                                                                 ## 6六4班 李小龄 男
                                                                                                                                                                                                 ## # ... with 2 more rows
                                                                                                                                                                                                 df_dup = df %>%
                                                                                                                                                                                                   slice_sample(n = 60, replace = TRUE)
                                                                                                                                                                                                 ## # A tibble: 11 x 8
                                                                                                                                                                                                 ##   class name   sex
                                                                                                                                                                                                 ## <chr> <chr> <chr> ##1六4班周婵 女
                                                                                                                                                                                                 chinese  math english moral science
                                                                                                                                                                                                 ## 2六1班陈芳妹女 ##3六5班陆曼 女 ##4六5班陆曼 女
                                                                                                                                                                                                 ## 5六2班徐雅琦女 ##6六5班陆曼 女
                                                                                                                                                                                                 ## # ... with 5 more rows
                                                                                                                                                                                                 df_dup %>%
                                                                                                                                                                                                   92 79 88
                                                                                                                                                                                                 88 92 88
                                                                                                                                                                                                 94 87 84
                                                                                                                                                                                                 84 86 84
                                                                                                                                                                                                 77 66 69
                                                                                                                                                                                                 69 72 69
                                                                                                                                                                                                 10 9 9 10 8 10
                                                                                                                                                                                                 8 10 NA 9 8 10
                                                                                                                                                                                                 ## # A tibble: 15 x 8
                                                                                                                                                                                                 chinese  math english moral science
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   92    84
                                                                                                                                                                                                 92    84
                                                                                                                                                                                                 84    85
                                                                                                                                                                                                 92    84
                                                                                                                                                                                                 90    87
                                                                                                                                                                                                 90    87
                                                                                                                                                                                                 <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   <dbl> <dbl>
                                                                                                                                                                                                   <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   70
                                                                                                                                                                                                 70
                                                                                                                                                                                                 52
                                                                                                                                                                                                 70
                                                                                                                                                                                                 69
                                                                                                                                                                                                 69
                                                                                                                                                                                                 9 10 9 10 9 8 9 10
                                                                                                                                                                                                 10 10 10 10
                                                                                                                                                                                                 注意:对多个条件之间用“,”隔开，相当于 and。 df_dup %>%
                                                                                                                                                                                                   filter(sex == "女", (is.na(english) | math > 80))
                                                                                                                                                                                                 filter(between(math, 70, 80))
                                                                                                                                                                                                 # 闭区间
                                                                                                                                                                                                 chinese math english moral science
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##2六5班容唐女 83 71 56 9 7
                                                                                                                                                                                                 class name   sex
                                                                                                                                                                                                 <chr> <chr> <chr> 1六2班杨远芸女
                                                                                                                                                                                                 <dbl> <dbl>   <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   93    80      68     9      10
                                                                                                                                                                                                 ## 3六4班关小孟男
                                                                                                                                                                                                 ## 4六1班陈祝贞女
                                                                                                                                                                                                 ## 5六1班陈欣越男
                                                                                                                                                                                                 ##6六1班雷旺男 NA 80 68 8 9 ## # ... with 9 more rows
                                                                                                                                                                                                 2.在限定列范围内根据条件筛选行
                                                                                                                                                                                                 dplyr 1.0.4提供了函数if_any()和if_all()，基本格式为:
                                                                                                                                                                                                    if_any(.cols, .fns, ...) 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 84    78
                                                                                                                                                                                                 76    79
                                                                                                                                                                                                 57    80
                                                                                                                                                                                                 49     8       5
                                                                                                                                                                                                 67     8      10
                                                                                                                                                                                                 60     9       9
                                                                                                                                                                                                 
                                                                                                                                                                                                  if_all(.cols, .fns, ...)
                                                                                                                                                                                                 if_any 和 if_all 的作用机制如图 2.21 所示，其操作逻辑类似 across(), 只是返回的
                                                                                                                                                                                                 是关于行的逻辑向量(长度同行数)，用于根据多列的值筛选行:
                                                                                                                                                                                                   在.cols 所选择的列范围内，分别对每一列应用函数.fns 做判断，得到多个逻辑向量;
                                                                                                                                                                                                 if_all()是对这些逻辑向量依次取&，if_any()是对这些逻辑向量依次取|，最终得到一个逻 辑向量并将其用于 filter()筛选行。
                                                                                                                                                                                                 注意:对多个逻辑向量做&或|时，是做向量化运算，相当于是对位于同行的逻辑值取&或|，换句话说，相当于 将函数.fns 依次作用在所选列的每一行元素上，得到的判断结果，取&或|，再作为是否筛选该行的依据。
                                                                                                                                                                                                 图 2.21 if_any 和 if_all 函数筛选行示意图
                                                                                                                                                                                                 (1)限定列范围内，筛选“所有值都满足某条件的行”
                                                                                                                                                                                                 选出第 4~6 列范围内，所有值都大于 75 的行:
                                                                                                                                                                                                   df %>%
                                                                                                                                                                                                   filter(if_all(4:6, ~ .x > 75))
                                                                                                                                                                                                 ## # A tibble: 3 x 8
                                                                                                                                                                                                 ##   class name   sex
                                                                                                                                                                                                 ## <chr> <chr> <chr> ##1六1班何娜 女 ##2六4班周婵 女
                                                                                                                                                                                                 ## 3六5班符苡榕女
                                                                                                                                                                                                 chinese  math english moral science
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   87 92 85
                                                                                                                                                                                                 92 94 89
                                                                                                                                                                                                 79 77 76
                                                                                                                                                                                                 9 10 10 9 9 NA
                                                                                                                                                                                                 ## # A tibble: 38 x 8
                                                                                                                                                                                                 ##   class name   sex
                                                                                                                                                                                                 ## <chr> <chr> <chr>
                                                                                                                                                                                                 ## 1六4班周婵 女 92
                                                                                                                                                                                                 ## 2六2班杨远芸女 93
                                                                                                                                                                                                 ## 3六2班陈华健男 92
                                                                                                                                                                                                 ## 4六1班陈芳妹女 79
                                                                                                                                                                                                 ##5六5班陆曼女 88 84 69 8 10
                                                                                                                                                                                                 选出所有列范围内，所有值都不是 NA 的行: df_dup %>%
                                                                                                                                                                                                   filter(if_all(everything(), ~ !is.na(.x)))
                                                                                                                                                                                                 chinese  math english moral science
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   94
                                                                                                                                                                                                 <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   80 84 87
                                                                                                                                                                                                 ## 6六5班胡玉洁女 74 61 52 9 ## # ... with 32 more rows
                                                                                                                                                                                                 (2)限定列范围内，筛选“存在值满足某条件的行”
                                                                                                                                                                                                 选出所有列范围内，存在值包含“bl”的行，代码如下:
                                                                                                                                                                                                   starwars %>%
                                                                                                                                                                                                   filter(if_any(everything(), ~ str_detect(.x, "bl")))
                                                                                                                                                                                                 6
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 77 68 70 66
                                                                                                                                                                                                 10       9
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 2.5 基本数据操作 101
                                                                                                                                                                                                 ## # A tibble: 47 x 14
                                                                                                                                                                                                 ##   name  height  mass hair_color skin_color eye_color birth_year sex
                                                                                                                                                                                                 ##   <chr>  <int> <dbl> <chr>      <chr>      <chr>          <dbl> <chr>
                                                                                                                                                                                                 
                                                                                                                                                                                                 102 2 数据操作
                                                                                                                                                                                                 ##1 Luke~ 172
                                                                                                                                                                                                 ##2 R2-D2 96
                                                                                                                                                                                                 ##3 Owen~ 178
                                                                                                                                                                                                 ##4 Beru~ 165
                                                                                                                                                                                                 ##5 Bigg~ 183
                                                                                                                                                                                                 ##6 Obi-~ 182
                                                                                                                                                                                                 ## # ... with 41 more rows, and 6 more variables: gender <chr>,
                                                                                                                                                                                                 ### homeworld <chr>, species <chr>, films <list>, vehicles <list>,
                                                                                                                                                                                                 ### starships <list>
                                                                                                                                                                                                 选出数值列范围内，存在值大于 90 的行: df %>%
                                                                                                                                                                                                   filter(if_any(where(is.numeric), ~ .x > 90))
                                                                                                                                                                                                 ## # A tibble: 8 x 8
                                                                                                                                                                                                 ##   class name   sex
                                                                                                                                                                                                 ## <chr> <chr> <chr> ##1六1班何娜 女 ##2六1班黄才菊女 ##3六2班黄祖娜女 ##4六2班徐雅琦女 ##5六2班陈华健男 ##6六2班杨远芸女
                                                                                                                                                                                                 ## # ... with 2 more rows
                                                                                                                                                                                                 77 blond
                                                                                                                                                                                                 fair       blue
                                                                                                                                                                                                 white, bl~ red
                                                                                                                                                                                                 light      blue
                                                                                                                                                                                                 light      blue
                                                                                                                                                                                                 light      brown
                                                                                                                                                                                                 fair       blue-gray
                                                                                                                                                                                                 19 male
                                                                                                                                                                                                 33 none
                                                                                                                                                                                                 52 male
                                                                                                                                                                                                 47 fema~
                                                                                                                                                                                                   24 male
                                                                                                                                                                                                 57 male
                                                                                                                                                                                                 32 <NA>
                                                                                                                                                                                                   120 brown, gr~
                                                                                                                                                                                                   75 brown
                                                                                                                                                                                                 84 black
                                                                                                                                                                                                 77 auburn, w~
                                                                                                                                                                                                   从字符列范围内，选择包含(存在)NA 的行: df_dup %>%
                                                                                                                                                                                                   filter(if_any(where(is.character), is.na))
                                                                                                                                                                                                 chinese  math english moral science
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   87    92
                                                                                                                                                                                                 95    77
                                                                                                                                                                                                 94 88 92 86
                                                                                                                                                                                                 92 84
                                                                                                                                                                                                 93 80
                                                                                                                                                                                                 <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   79
                                                                                                                                                                                                 75
                                                                                                                                                                                                 75
                                                                                                                                                                                                 72
                                                                                                                                                                                                 70
                                                                                                                                                                                                 68
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 NA       9
                                                                                                                                                                                                 10      10
                                                                                                                                                                                                 NA       9
                                                                                                                                                                                                 9 10 9 10
                                                                                                                                                                                                 ## # A tibble: 3 x 8
                                                                                                                                                                                                 ##   class name   sex   chinese  math english moral science
                                                                                                                                                                                                 ## <chr> <chr> <chr> <dbl> <dbl> <dbl> <dbl> <dbl> ##1六4班<NA>男 84 85 52 9 8 ## 2 <NA> 徐达政 男 90 86 72 9 10 ## 3六5班符芳盈<NA> 58 85 48 9 10
                                                                                                                                                                                                 另一种思路:pmap_lgl()是对数据框逐行迭代，返回长度同行数的逻辑值向量，正好适 合配合 filter()筛选行。filter()函数的第一个参数是由多列范围构成的数据框;第 2 个参 数是对多列范围内的每行的值向量构造一个可返回逻辑值的判断函数，并将该逻辑值作为是否 筛选该行的依据。
                                                                                                                                                                                                 例如，筛选出语文、数学、英语三科成绩中恰有两科成绩不及格(分数 < 60)的行: df %>%
                                                                                                                                                                                                   filter(pmap_lgl(.[4:6], ~ sum(c(...) < 60) == 2))
                                                                                                                                                                                                 ## # A tibble: 5 × 8
                                                                                                                                                                                                 ##   class name   sex   chinese  math english moral science
                                                                                                                                                                                                 ## <chr> <chr> <chr> <dbl> <dbl> <dbl> <dbl> <dbl> ##1六2班黄菲女 90 41 40 6 7
                                                                                                                                                                                                 ## 2六2班李永升男 ## 3六3班陈逾革男 ## 4六4班梁少盈女 ## 5六5班符芳盈NA
                                                                                                                                                                                                 66    54
                                                                                                                                                                                                 47    24
                                                                                                                                                                                                 90    55
                                                                                                                                                                                                 58 85
                                                                                                                                                                                                 36     8      10
                                                                                                                                                                                                 67     2       5
                                                                                                                                                                                                 52     8       9
                                                                                                                                                                                                 48 9 10
                                                                                                                                                                                                 3.对行进行切片:slice_*()函数
                                                                                                                                                                                                 slice 就是对行切片的意思，该系列函数的共同参数如下。
                                                                                                                                                                                                  n:用来指定要选择的行数。
                                                                                                                                                                                                  prop:用来指定选择的行比例。
                                                                                                                                                                                                 slice(df, 3:7)
                                                                                                                                                                                                 slice_head(df, n, prop)
                                                                                                                                                                                                 slice_tail(df, n, prop)
                                                                                                                                                                                                 slice_min(df, order_by, n, prop)
                                                                                                                                                                                                 slice_max(df, order_by, n, prop)
                                                                                                                                                                                                 # 选择3~7行
                                                                                                                                                                                                 # 从前面开始选择若干行
                                                                                                                                                                                                 # 从后面开始选择若干行
                                                                                                                                                                                                 # 根据order_by选择最小的若干行 # 根据order_by选择最大的若干行
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 slice_sample(df, n, prop)
                                                                                                                                                                                                 选择 math 列值排在前 5 的行: df %>%
                                                                                                                                                                                                   slice_max(math, n = 5)
                                                                                                                                                                                                 ## # A tibble: 5 x 8
                                                                                                                                                                                                 ##   class name   sex   chinese  math english moral science
                                                                                                                                                                                                 ##1六4班周婵女 92 ## 2六4班陈丽丽女 87 ##3六1班何娜女 87 ## 4六5班符苡榕女 85 ## 5六2班黄祖娜女 94
                                                                                                                                                                                                 4.删除行 (1)删除重复行
                                                                                                                                                                                                 94 93 92 89 88
                                                                                                                                                                                                 77 NA 79 76 75
                                                                                                                                                                                                 10       9
                                                                                                                                                                                                 8       6
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      NA
                                                                                                                                                                                                 10      10
                                                                                                                                                                                                 用 dplyr 包中的 distinct()函数删除重复行(只保留第 1 个，删除其余)。 df_dup %>%
                                                                                                                                                                                                   distinct()
                                                                                                                                                                                                 ## # A tibble: 35 x 8
                                                                                                                                                                                                 ##   class name   sex   chinese  math english moral science
                                                                                                                                                                                                 2.5 基本数据操作 103
                                                                                                                                                                                                 # 随机选择若干行
                                                                                                                                                                                                 ##   <chr> <chr>  <chr>   <dbl> <dbl>
                                                                                                                                                                                                 <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   ## <chr> <chr> <chr> <dbl> <dbl> ##1六4班周婵女 92 94
                                                                                                                                                                                                   <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   ## 2六2班杨远芸女
                                                                                                                                                                                                   ## 3六2班陈华健男
                                                                                                                                                                                                   ## 4六1班陈芳妹女 ##5六5班陆曼女 88 84 ## 6六5班胡玉洁女 74 61 ## # ... with 29 more rows
                                                                                                                                                                                                   也可以只根据某些列判定重复行:
                                                                                                                                                                                                   df_dup %>%
                                                                                                                                                                                                   77 68 70 66
                                                                                                                                                                                                 69 52
                                                                                                                                                                                                 10       9
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 8 10 9 6
                                                                                                                                                                                                 93    80
                                                                                                                                                                                                 92    84
                                                                                                                                                                                                 79    87
                                                                                                                                                                                                 distinct(sex, math, .keep_all = TRUE) # 只根据 sex 和 math 判定重复
                                                                                                                                                                                                 ## # A tibble: 32 x 8
                                                                                                                                                                                                 ##   class name   sex   chinese  math english moral science
                                                                                                                                                                                                 ##   <chr> <chr>  <chr>   <dbl> <dbl>
                                                                                                                                                                                                 <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   ##1六4班周婵女 92
                                                                                                                                                                                                   94 80 84 87
                                                                                                                                                                                                 84 61
                                                                                                                                                                                                 77 68 70 66
                                                                                                                                                                                                 69 52
                                                                                                                                                                                                 10       9
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 8 10 9 6
                                                                                                                                                                                                 ## 2六2班杨远芸女
                                                                                                                                                                                                 ## 3六2班陈华健男
                                                                                                                                                                                                 ## 4六1班陈芳妹女 ##5六5班陆曼女 88 ## 6六5班胡玉洁女 74 ## # ... with 26 more rows
                                                                                                                                                                                                 93 92 79
                                                                                                                                                                                                 注意:默认只返回选择的列，若要返回所有列，则需要设置参数“.keep_all = TRUE”。
                                                                                                                                                                                                 (2)删除包含 NA 的行
                                                                                                                                                                                                 用 tidyr 包中的 drop_na()函数删除所有包含 NA 的行:
                                                                                                                                                                                                   df_dup %>%
                                                                                                                                                                                                   drop_na()
                                                                                                                                                                                                 ## # A tibble: 38 x 8
                                                                                                                                                                                                 ##   class name   sex   chinese  math english moral science
                                                                                                                                                                                                 ##   <chr> <chr>  <chr>   <dbl> <dbl>
                                                                                                                                                                                                 <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   ##1六4班周婵女 92
                                                                                                                                                                                                   94 80 84 87
                                                                                                                                                                                                 84 61
                                                                                                                                                                                                 77 68 70 66
                                                                                                                                                                                                 69 52
                                                                                                                                                                                                 10       9
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 8 10 9 6
                                                                                                                                                                                                 ## 2六2班杨远芸女
                                                                                                                                                                                                 ## 3六2班陈华健男
                                                                                                                                                                                                 ## 4六1班陈芳妹女 ##5六5班陆曼女 88 ## 6六5班胡玉洁女 74 ## # ... with 32 more rows
                                                                                                                                                                                                 93 92 79
                                                                                                                                                                                                 也可以只删除某些列包含 NA 的行: 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 104 2 数据操作 df_dup %>%
                                                                                                                                                                                                   drop_na(sex:math)
                                                                                                                                                                                                 ## # A tibble: 50 x 8 ## class name sex ## <chr> <chr> <chr> ##1六4班周婵 女
                                                                                                                                                                                                 chinese  math english moral science
                                                                                                                                                                                                 ## 2六2班杨远芸女
                                                                                                                                                                                                 ## 3六2班陈华健男
                                                                                                                                                                                                 ## 4六1班陈芳妹女 ##5六5班陆曼 女
                                                                                                                                                                                                 ## 6六5班胡玉洁女
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 92 93 92 79
                                                                                                                                                                                                 88 74
                                                                                                                                                                                                 94 80 84 87
                                                                                                                                                                                                 84 61
                                                                                                                                                                                                 77 68 70 66
                                                                                                                                                                                                 69 52
                                                                                                                                                                                                 10       9
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 8 10 9 6
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   若要删除某些列都是 NA 的行，借助 if_all()函数也很容易实现: df_dup %>%
                                                                                                                                                                                                   filter(!if_all(where(is.numeric), is.na))
                                                                                                                                                                                                 2.5.4 对行排序
                                                                                                                                                                                                 用 dplyr 包中的 arrange()函数对行排序，默认是按递增进行排序。
                                                                                                                                                                                                 df_dup %>%
                                                                                                                                                                                                   arrange(math, sex)
                                                                                                                                                                                                 ## # A tibble: 60 x 8
                                                                                                                                                                                                 ##   class name   sex
                                                                                                                                                                                                 ##   <chr> <chr>  <chr>
                                                                                                                                                                                                 ## 1六3班 邹嘉伟 男
                                                                                                                                                                                                 chinese  math english moral science
                                                                                                                                                                                                 <dbl> <dbl>   <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   ## 2六3班 刘虹均 男
                                                                                                                                                                                                   ## 3六3班 刘虹均 男
                                                                                                                                                                                                   ## 4六3班 黄凯丽 女
                                                                                                                                                                                                   ## 5六3班 黄凯丽 女
                                                                                                                                                                                                   ## 6六3班 黄凯丽 女
                                                                                                                                                                                                   ## # ... with 54 more rows
                                                                                                                                                                                                   67    18      62
                                                                                                                                                                                                 72    23      74
                                                                                                                                                                                                 72    23      74
                                                                                                                                                                                                 70    23      61
                                                                                                                                                                                                 70    23      61
                                                                                                                                                                                                 70    23      61
                                                                                                                                                                                                 8      NA
                                                                                                                                                                                                 3       6
                                                                                                                                                                                                 3       6
                                                                                                                                                                                                 4       4
                                                                                                                                                                                                 4       4
                                                                                                                                                                                                 4       4
                                                                                                                                                                                                 若要按递减进行排序，嵌套一个 desc()函数或在变量名前加负号即可: df_dup %>%
                                                                                                                                                                                                   arrange(-math)
                                                                                                                                                                                                 ## # A tibble: 60 x 8
                                                                                                                                                                                                 ##   class name   sex
                                                                                                                                                                                                 ## <chr> <chr> <chr> ##1六4班周婵 女 ##2六4班陈丽丽女 ##3六5班符苡榕女 ##4六5班符苡榕女 ##5六1班陈芳妹女 ##6六4班李小龄男
                                                                                                                                                                                                 # 同desc(math), 递减排序 chinese math english moral science
                                                                                                                                                                                                 ## # ... with 54 more rows
                                                                                                                                                                                                 2.5.5 分组操作
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   92    94
                                                                                                                                                                                                 87    93
                                                                                                                                                                                                 85    89
                                                                                                                                                                                                 85    89
                                                                                                                                                                                                 79    87
                                                                                                                                                                                                 90    87
                                                                                                                                                                                                 <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   77
                                                                                                                                                                                                 NA
                                                                                                                                                                                                 76
                                                                                                                                                                                                 76
                                                                                                                                                                                                 66
                                                                                                                                                                                                 69
                                                                                                                                                                                                 10       9
                                                                                                                                                                                                 8       6
                                                                                                                                                                                                 9      NA
                                                                                                                                                                                                 9      NA
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 10 10
                                                                                                                                                                                                 对未分组的数据框，一些操作(如 mutate()函数)是在所有行上执行。相当于把整个数 据框视为一个分组，所有行都属于它。
                                                                                                                                                                                                 若数据框被分组，则这些操作是分别在每个分组上独立执行。可以认为是，将数据框拆分 为更小的多个数据框。在每个更小的数据框上执行操作，最后再将结果合并回来。
                                                                                                                                                                                                 1.创建分组
                                                                                                                                                                                                 用 group_by()函数创建分组，只是对数据框增加了分组信息(可以用 group_keys() 查看)，并不是真的将数据分割为多个数据框。
                                                                                                                                                                                                 df_grp = df %>%
                                                                                                                                                                                                   异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 group_by(sex)
                                                                                                                                                                                                 df_grp
                                                                                                                                                                                                 ## # A tibble: 50 x 8
                                                                                                                                                                                                 ## # Groups:   sex [3]
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##6六1班何小薇女
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 class name   sex
                                                                                                                                                                                                 <chr> <chr> <chr> 1六1班何娜 女
                                                                                                                                                                                                 2 六 1 班 黄才菊 女
                                                                                                                                                                                                 3 六 1 班 陈芳妹 女
                                                                                                                                                                                                 4 六 1 班 陈学勤 男
                                                                                                                                                                                                 5 六 1 班 陈祝贞 女
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   87    92
                                                                                                                                                                                                 95    77
                                                                                                                                                                                                 79    87
                                                                                                                                                                                                 NA    79
                                                                                                                                                                                                 76    79
                                                                                                                                                                                                 83    73
                                                                                                                                                                                                 <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   访问或查看分组情况:
                                                                                                                                                                                                   chinese  math english moral science
                                                                                                                                                                                                 79
                                                                                                                                                                                                 75
                                                                                                                                                                                                 66
                                                                                                                                                                                                 66
                                                                                                                                                                                                 67
                                                                                                                                                                                                 65
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 NA       9
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 8      10
                                                                                                                                                                                                 8       9
                                                                                                                                                                                                 2.5 基本数据操作 105
                                                                                                                                                                                                 group_keys(df_grp) # 分组键值(唯一识别分组)
                                                                                                                                                                                                 group_indices(df_grp)
                                                                                                                                                                                                 group_rows(df_grp)
                                                                                                                                                                                                 ungroup(df_grp)
                                                                                                                                                                                                 # 查看每一行属于哪一分组 # 查看每一组包含哪些行 # 解除分组
                                                                                                                                                                                                 其他分组函数如下所示:
                                                                                                                                                                                                    真正将数据框分割为多个分组，要使用 group_split()函数，该函数返回列表，列表
                                                                                                                                                                                                 的每个成分是一个分组数据框;
                                                                                                                                                                                                  group_nest()函数是将数据框分组(group_by)，再进行嵌套(nest)，一步到位地
                                                                                                                                                                                                 生成嵌套式数据框，该函数常用于批量建模。
                                                                                                                                                                                                 iris %>%
                                                                                                                                                                                                   group_nest(Species)
                                                                                                                                                                                                 ## # A tibble: 3 x 2
                                                                                                                                                                                                 ##   Species                  data
                                                                                                                                                                                                 ##   <fct>      <list<tibble[,4]>>
                                                                                                                                                                                                 ## 1 setosa
                                                                                                                                                                                                 ## 2 versicolor
                                                                                                                                                                                                 ## 3 virginica
                                                                                                                                                                                                 [50 x 4]
                                                                                                                                                                                                 [50 x 4]
                                                                                                                                                                                                 [50 x 4]
                                                                                                                                                                                                  purrr 风格的分组迭代:将函数.f 依次应用到分组数据框(即.data)的每个分组上。  group_map(.data, .f, ...):返回列表。
                                                                                                                                                                                                  group_walk(.data, .f, ...):只做操作，不返回值。
                                                                                                                                                                                                  group_modify(.data, .f, ...):返回修改后的分组数据框。
                                                                                                                                                                                                 iris %>%
                                                                                                                                                                                                   group_by(Species) %>%
                                                                                                                                                                                                   group_map(~ head(.x, 2)) # 提取每组的前两个观测
                                                                                                                                                                                                 ## [[1]]
                                                                                                                                                                                                 ## # A tibble: 2 x 4
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## 1
                                                                                                                                                                                                 ## 2
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## [[2]]
                                                                                                                                                                                                 ## # A tibble: 2 x 4
                                                                                                                                                                                                 ## ## ## 1 ## 2
                                                                                                                                                                                                 <dbl>       <dbl>
                                                                                                                                                                                                   6.3         3.3
                                                                                                                                                                                                 5.8         2.7
                                                                                                                                                                                                 <dbl>       <dbl>
                                                                                                                                                                                                   6           2.5
                                                                                                                                                                                                 5.1         1.9
                                                                                                                                                                                                 Sepal.Length Sepal.Width Petal.Length Petal.Width
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## 1
                                                                                                                                                                                                 ## 2
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## [[3]]
                                                                                                                                                                                                 ## # A tibble: 2 x 4
                                                                                                                                                                                                 <dbl>       <dbl>
                                                                                                                                                                                                   5.1         3.5
                                                                                                                                                                                                 4.9         3
                                                                                                                                                                                                 <dbl>       <dbl>
                                                                                                                                                                                                   1.4         0.2
                                                                                                                                                                                                 1.4         0.2
                                                                                                                                                                                                 Sepal.Length Sepal.Width Petal.Length Petal.Width
                                                                                                                                                                                                 <dbl>       <dbl>
                                                                                                                                                                                                   7           3.2
                                                                                                                                                                                                 6.4         3.2
                                                                                                                                                                                                 Sepal.Length Sepal.Width Petal.Length Petal.Width
                                                                                                                                                                                                 <dbl>       <dbl>
                                                                                                                                                                                                   4.7         1.4
                                                                                                                                                                                                 4.5         1.5
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 106 2 数据操作
                                                                                                                                                                                                 2.分组修改
                                                                                                                                                                                                 分组是一种强大的数据思维，当你想分组并分别对每组数据进行操作时，应该优先采用 “group_by + mutate”，而不是“分割数据 + 循环迭代”。
                                                                                                                                                                                                 这里仍是数据分解的思维:一旦要对数据框分组，你只需要考虑对一个分组(子数据框)做 的操作怎么实现，剩下的事情(如“分组 + 合并结果”)，“group_by + mutate”会帮你完成。
                                                                                                                                                                                                 例如，对如下的股票数据，分别计算每只股票的收盘价与前一天的差价。
                                                                                                                                                                                                 load("data/stocks.rda")
                                                                                                                                                                                                 stocks
                                                                                                                                                                                                 ## # A tibble: 753 x 3
                                                                                                                                                                                                 ##    Date       Stock  Close
                                                                                                                                                                                                 ##    <date>     <chr>  <dbl>
                                                                                                                                                                                                 ##  1 2017-01-03 Google  786.
                                                                                                                                                                                                 ##  2 2017-01-03 Amazon  754.
                                                                                                                                                                                                 ##  3 2017-01-03 Apple   116.
                                                                                                                                                                                                 ##  4 2017-01-04 Google  787.
                                                                                                                                                                                                 ##  5 2017-01-04 Amazon  757.
                                                                                                                                                                                                 ##  6 2017-01-04 Apple   116.
                                                                                                                                                                                                 ## # ... with 747 more rows
                                                                                                                                                                                                 只要对 Stock 进行分组，对一只股票怎么计算收盘价与前一天的差价，就可以按相同的方式 编写代码:
                                                                                                                                                                                                   stocks %>%
                                                                                                                                                                                                   group_by(Stock) %>%
                                                                                                                                                                                                   mutate(delta = Close - lag(Close))
                                                                                                                                                                                                 ## # A tibble: 753 x 4
                                                                                                                                                                                                 ## # Groups:
                                                                                                                                                                                                 ## Date
                                                                                                                                                                                                 ##    <date>
                                                                                                                                                                                                 ##  1 2017-01-03 Google  786. NA
                                                                                                                                                                                                 ##  2 2017-01-03 Amazon  754. NA
                                                                                                                                                                                                 ##  3 2017-01-03 Apple   116. NA
                                                                                                                                                                                                 ##  4 2017-01-04 Google  787.  0.760
                                                                                                                                                                                                 ##  5 2017-01-04 Amazon  757.  3.51
                                                                                                                                                                                                 ##  6 2017-01-04 Apple   116. -0.130
                                                                                                                                                                                                 ## # ... with 747 more rows
                                                                                                                                                                                                 3.分组筛选
                                                                                                                                                                                                 filter()是根据条件筛选数据框的行，与 group_by()连用，就是分别对每个分组， 根据条件筛选行，再将结果合并到一起返回。
                                                                                                                                                                                                 这里仍是数据分解的思维:一旦对数据框分组，你只需要考虑对一个分组(子数据框) 如何构造条件筛选行，至于剩下的事情—“分组+合并结果”，“group_by + filter” 会帮你完成。
                                                                                                                                                                                                 例如，筛选每只股票涨幅超过 4%的观测:
                                                                                                                                                                                                   stocks %>%
                                                                                                                                                                                                   group_by(Stock) %>%
                                                                                                                                                                                                   filter((Close - lag(Close)) / lag(Close) > 0.04)
                                                                                                                                                                                                 ## # A tibble: 4 × 3
                                                                                                                                                                                                 Stock [3]
                                                                                                                                                                                                 Stock  Close  delta
                                                                                                                                                                                                 <chr>  <dbl>  <dbl>
                                                                                                                                                                                                   ## # Groups:
                                                                                                                                                                                                   ## Date
                                                                                                                                                                                                   ##   <date>
                                                                                                                                                                                                   ## 1 2017-02-01 Apple   129.
                                                                                                                                                                                                   ## 2 2017-08-02 Apple   157.
                                                                                                                                                                                                   ## 3 2017-10-27 Google 1019.
                                                                                                                                                                                                   ## 4 2017-10-27 Amazon 1101.
                                                                                                                                                                                                   比较推荐的写法是先用 mutate 计算出新列(涨幅列)，再构造筛选条件: stocks %>%
                                                                                                                                                                                                   Stock [3]
                                                                                                                                                                                                 Stock  Close
                                                                                                                                                                                                 <chr>  <dbl>
                                                                                                                                                                                                   异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 group_by(Stock) %>%
                                                                                                                                                                                                   mutate(Gains = (Close - lag(Close)) / lag(Close)) %>%
                                                                                                                                                                                                   filter(Gains > 0.04)
                                                                                                                                                                                                 另外，group_by 也可以与 slice_*连用，按分组切片的方式筛选行。例如，筛选每 只股票的收盘价位于从高到低排序的前两名的收盘价:
                                                                                                                                                                                                   stocks %>%
                                                                                                                                                                                                   group_by(Stock) %>%
                                                                                                                                                                                                   slice_max(Close, n = 2)
                                                                                                                                                                                                 ## # A tibble: 6 × 3
                                                                                                                                                                                                 2.5 基本数据操作 107
                                                                                                                                                                                                 ## # Groups:
                                                                                                                                                                                                 ## Date
                                                                                                                                                                                                 ##   <date>
                                                                                                                                                                                                 ## 1 2017-11-27 Amazon 1196.
                                                                                                                                                                                                 ## 2 2017-11-28 Amazon 1194.
                                                                                                                                                                                                 ## 3 2017-12-18 Apple   176.
                                                                                                                                                                                                 ## 4 2017-11-08 Apple   176.
                                                                                                                                                                                                 ## 5 2017-12-18 Google 1077.
                                                                                                                                                                                                 ## 6 2017-12-19 Google 1071.
                                                                                                                                                                                                 4.分组汇总
                                                                                                                                                                                                 分组汇总，相当于 Excel 的透视表功能。 对数据框做分组最主要的目的就是做分组汇总，汇总就是以某种方式组合行，可以用 dplyr
                                                                                                                                                                                                 包中的 summarise()函数实现，结果只保留分组列的唯一值和新创建的汇总列。 请读者区分以下两种情况。
                                                                                                                                                                                                  group_by + summarise:分组汇总，其结果是“有几个分组就有几个观测”。
                                                                                                                                                                                                  group_by + mutate:分组修改，其结果是“原来有几个样本就有几个观测”。 (1)summarise()函数
                                                                                                                                                                                                 可以与很多自带或自定义的汇总函数连用，常用的汇总函数有以下几种。  中心化:mean()、median()。
                                                                                                                                                                                                  分散程度:sd()、IQR()、mad()。
                                                                                                                                                                                                  范围:min()、max()、quantile()。
                                                                                                                                                                                                  位置:first()、last()、nth()。  计数:n()、n_distinct()。
                                                                                                                                                                                                  逻辑运算:any()、all()。
                                                                                                                                                                                                 df %>%
                                                                                                                                                                                                   group_by(sex) %>%
                                                                                                                                                                                                   summarise(n = n(),
                                                                                                                                                                                                             math_avg = mean(math, na.rm = TRUE),
                                                                                                                                                                                                             math_med = median(math))
                                                                                                                                                                                                 ## # A tibble: 3 x 4
                                                                                                                                                                                                 Stock [3]
                                                                                                                                                                                                 Stock  Close
                                                                                                                                                                                                 <chr>  <dbl>
                                                                                                                                                                                                   ## ## ## ## ##
                                                                                                                                                                                                   器或判断条件选择多列，还能在这些列上执行多个函数，只需要将它们放入一个列表即可。
                                                                                                                                                                                                 (2)对某些列做汇总
                                                                                                                                                                                                 df %>%
                                                                                                                                                                                                   group_by(class, sex) %>%
                                                                                                                                                                                                   summarise(across(contains("h"), mean, na.rm = TRUE))
                                                                                                                                                                                                 ## # A tibble: 12 x 5
                                                                                                                                                                                                 ## # Groups:   class [6]
                                                                                                                                                                                                 sex       n math_avg math_med
                                                                                                                                                                                                 <dbl>    <dbl>
                                                                                                                                                                                                   64.6       NA
                                                                                                                                                                                                 70.8       NA
                                                                                                                                                                                                 <chr> <int> 1男 24 2女 25 3<NA> 1
                                                                                                                                                                                                 85 85
                                                                                                                                                                                                 函数 summarise()配合 across()可以对所选择的列做汇总。好处是可以借助辅助选择
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 108 2 数据操作
                                                                                                                                                                                                 ## class sex
                                                                                                                                                                                                 ##   <chr> <chr>
                                                                                                                                                                                                 ## 1六1班男
                                                                                                                                                                                                 ## 2六1班女
                                                                                                                                                                                                 ## 3六2班男
                                                                                                                                                                                                 ## 4六2班女
                                                                                                                                                                                                 ## 5六3班男
                                                                                                                                                                                                 ## 6六3班女
                                                                                                                                                                                                 ## # ... with 6 more rows
                                                                                                                                                                                                 (4)对满足条件的列做多种汇总
                                                                                                                                                                                                 ## # ## # ## #
                                                                                                                                                                                                 english_mean <dbl>, english_min <dbl>, moral_sum <dbl>,
                                                                                                                                                                                                 moral_mean <dbl>, moral_min <dbl>, science_sum <dbl>,
                                                                                                                                                                                                 science_mean <dbl>, science_min <dbl>
                                                                                                                                                                                                   chinese  math english moral science
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   57    79.7
                                                                                                                                                                                                 80.7  77.2
                                                                                                                                                                                                 75.4  68.8
                                                                                                                                                                                                 92.2  73.8
                                                                                                                                                                                                 66    30.4
                                                                                                                                                                                                 68.4  49.2
                                                                                                                                                                                                 <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   64.7  8.67    9.33
                                                                                                                                                                                                 67.4  8.33    9.57
                                                                                                                                                                                                 42.6  8.8     9.25
                                                                                                                                                                                                 63.8  8.33    9
                                                                                                                                                                                                 67.6  4.6     4.75
                                                                                                                                                                                                 67.8  6.25    7.2
                                                                                                                                                                                                 df_grp = df %>%
                                                                                                                                                                                                   group_by(class) %>%
                                                                                                                                                                                                   summarise(across(where(is.numeric),
                                                                                                                                                                                                                    list(sum=sum, mean=mean, min=min), na.rm = TRUE))
                                                                                                                                                                                                 ## # A tibble: 6 x 16
                                                                                                                                                                                                 df_grp
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 class chinese_sum chinese_mean chinese_min math_sum math_mean
                                                                                                                                                                                                 <chr> <dbl> 1六1班 622 2六2班 746 3六3班 606 4六4班 850 5六5班 726
                                                                                                                                                                                                 <dbl>       <dbl>    <dbl>     <dbl>
                                                                                                                                                                                                   77.8          57      702      78
                                                                                                                                                                                                 82.9          66      570      71.2
                                                                                                                                                                                                 67.3          44      349      38.8
                                                                                                                                                                                                 85            72      771      77.1
                                                                                                                                                                                                 72.6          58      720      72
                                                                                                                                                                                                 ## 6 <NA>           90
                                                                                                                                                                                                 ## # ... with 10 more variables: math_min <dbl>, english_sum <dbl>,
                                                                                                                                                                                                 90 90 86 86
                                                                                                                                                                                                 ## class Vars
                                                                                                                                                                                                 ## <chr> <chr>
                                                                                                                                                                                                 ## 1六1班chinese
                                                                                                                                                                                                 ## 2六1班math
                                                                                                                                                                                                 ## 3六1班english
                                                                                                                                                                                                 ## 4六1班moral
                                                                                                                                                                                                 ## 5六1班science
                                                                                                                                                                                                 ## 6六2班chinese
                                                                                                                                                                                                 ## # ... with 24 more rows
                                                                                                                                                                                                 (5)支持多返回值的汇总函数
                                                                                                                                                                                                 summarise()函数以前只支持一个返回值的汇总函数，如 sum、mean 等。现在也支持多
                                                                                                                                                                                                 返回值(返回向量值、甚至是数据框)的汇总函数，如 range()、quantile()等。 qs = c(0.25, 0.5, 0.75)
                                                                                                                                                                                                 df_q = df %>%
                                                                                                                                                                                                   group_by(sex) %>%
                                                                                                                                                                                                   summarise(math_qs = quantile(math, qs, na.rm = TRUE), q = qs)
                                                                                                                                                                                                 df_q
                                                                                                                                                                                                 ## # A tibble: 9 x 3
                                                                                                                                                                                                 ## # Groups:   sex [3]
                                                                                                                                                                                                 ##   sex   math_qs     q
                                                                                                                                                                                                 如果数据的可读性不好，可以通过宽表变长表来改善:
                                                                                                                                                                                                   df_grp %>%
                                                                                                                                                                                                   pivot_longer(-class, names_to = c("Vars", ".value"), names_sep = "_")
                                                                                                                                                                                                 ## # A tibble: 30 x 5
                                                                                                                                                                                                 sum  mean   min
                                                                                                                                                                                                 <dbl> <dbl> <dbl>
                                                                                                                                                                                                   622 77.8     57
                                                                                                                                                                                                 702 78       55
                                                                                                                                                                                                 666 66.6     54
                                                                                                                                                                                                 76 8.44 8
                                                                                                                                                                                                 959.5 9 746 82.9 66
                                                                                                                                                                                                 ## <chr> ## 1男
                                                                                                                                                                                                 ## 2男
                                                                                                                                                                                                 ## 3男
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   57.5  0.25
                                                                                                                                                                                                 69    0.5
                                                                                                                                                                                                 80    0.75
                                                                                                                                                                                                 55    0.25
                                                                                                                                                                                                 73    0.5
                                                                                                                                                                                                 86.5  0.75
                                                                                                                                                                                                 ## 4女
                                                                                                                                                                                                 ## 5女
                                                                                                                                                                                                 ## 6女
                                                                                                                                                                                                 ## # ... with 3 more rows
                                                                                                                                                                                                 如果数据的可读性不好，可以通过长表变宽表来改善:
                                                                                                                                                                                                   异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 2.5 基本数据操作 109
                                                                                                                                                                                                 df_q = df %>%
                                                                                                                                                                                                   group_by(sex) %>%
                                                                                                                                                                                                   summarise(math_qs = quantile(math, qs, na.rm = TRUE), q = qs)
                                                                                                                                                                                                 df_q
                                                                                                                                                                                                 ## # A tibble: 9 x 3
                                                                                                                                                                                                 ## # Groups:   sex [3]
                                                                                                                                                                                                 ##   sex   math_qs     q
                                                                                                                                                                                                 ##   <chr>   <dbl> <dbl>
                                                                                                                                                                                                 ## 1男
                                                                                                                                                                                                 ## 2男
                                                                                                                                                                                                 ## 3男
                                                                                                                                                                                                 ## 4女
                                                                                                                                                                                                 ## 5女
                                                                                                                                                                                                 ## 6女
                                                                                                                                                                                                 ## # ... with 3 more rows
                                                                                                                                                                                                 57.5  0.25
                                                                                                                                                                                                 69    0.5
                                                                                                                                                                                                 80    0.75
                                                                                                                                                                                                 55    0.25
                                                                                                                                                                                                 73    0.5
                                                                                                                                                                                                 86.5  0.75
                                                                                                                                                                                                 如果数据的可读性不好，可以通过宽表变长表来改善:
                                                                                                                                                                                                   df_q %>%
                                                                                                                                                                                                   pivot_wider(names_from = q, values_from = math_qs, names_prefix = "q_")
                                                                                                                                                                                                 ## # A tibble: 3 x 4
                                                                                                                                                                                                 ## # Groups: sex [3]
                                                                                                                                                                                                 ## sex q_0.25 q_0.5 q_0.75 ## <chr> <dbl> <dbl> <dbl> ## 1男 57.5 69 80 ##2女 55 73 86.5 ## 3 <NA> 85 85 85
                                                                                                                                                                                                 5.分组计数
                                                                                                                                                                                                 用 count()按分类变量 class 和 sex 进行分组，并按分组大小排序:
                                                                                                                                                                                                   df %>%
                                                                                                                                                                                                   count(class, sex, sort = TRUE)
                                                                                                                                                                                                 ## # A tibble: 12 x 3
                                                                                                                                                                                                 ## class sex n
                                                                                                                                                                                                 ## <chr> <chr> <int>
                                                                                                                                                                                                 ## 1六1班女 7
                                                                                                                                                                                                 ## 2六4班男 6
                                                                                                                                                                                                 ## 3六2班男 5
                                                                                                                                                                                                 ## 4六3班男 5
                                                                                                                                                                                                 ## 5六3班女 5
                                                                                                                                                                                                 ## 6六5班女 5
                                                                                                                                                                                                 ## # ... with 6 more rows
                                                                                                                                                                                                 对已分组的数据框，用 tally()函数进行计数:
                                                                                                                                                                                                   df %>%
                                                                                                                                                                                                   group_by(math_level = cut(math, breaks = c(0, 60, 75, 80, 100), right = FALSE)) %>%
                                                                                                                                                                                                   tally()
                                                                                                                                                                                                 ## # A tibble: 5 x 2
                                                                                                                                                                                                 ##   math_level     n
                                                                                                                                                                                                 ##   <fct>      <int>
                                                                                                                                                                                                 ## 1 [0,60)        14
                                                                                                                                                                                                 ## 2 [60,75)       11
                                                                                                                                                                                                 ## 3 [75,80)        5
                                                                                                                                                                                                 ## 4 [80,100)      17
                                                                                                                                                                                                 ## 5 <NA>           3
                                                                                                                                                                                                 注意:count()和 tally()函数都有参数 wt，可以设置加权计数。
                                                                                                                                                                                                 用 add_count()和 add_tally()函数可以为数据集增加一列按分组变量分组的计数:
                                                                                                                                                                                                   df %>%
                                                                                                                                                                                                   add_count(class, sex)
                                                                                                                                                                                                 ## # A tibble: 50 x 9
                                                                                                                                                                                                 ##   class name   sex   chinese  math english moral science     n
                                                                                                                                                                                                 ##   <chr> <chr>  <chr>   <dbl> <dbl>   <dbl> <dbl>   <dbl> <int>
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 110 2 数据操作 ##1六1班何娜 女
                                                                                                                                                                                                 ##2六1班黄才菊女 ##3六1班陈芳妹女 ##4六1班陈学勤男 ##5六1班陈祝贞女 ##6六1班何小薇女
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 2.6 其他数据操作 2.6.1 按行汇总
                                                                                                                                                                                                 87    92
                                                                                                                                                                                                 95    77
                                                                                                                                                                                                 79    87
                                                                                                                                                                                                 NA    79
                                                                                                                                                                                                 76    79
                                                                                                                                                                                                 83    73
                                                                                                                                                                                                 79     9
                                                                                                                                                                                                 75    NA
                                                                                                                                                                                                 66     9
                                                                                                                                                                                                 66     9
                                                                                                                                                                                                 67     8
                                                                                                                                                                                                 65     8
                                                                                                                                                                                                 10     7
                                                                                                                                                                                                 9     7
                                                                                                                                                                                                 10     7
                                                                                                                                                                                                 10     3
                                                                                                                                                                                                 10     7
                                                                                                                                                                                                 9     7
                                                                                                                                                                                                 通常的数据操作逻辑都是按列方式(colwise)，这使得按行汇总很困难。
                                                                                                                                                                                                 dplyr 包提供了 rowwise()函数为数据框创建行化逻辑(rowwise)，使用 rowwise() 后并不是真的改变了数据框，只是创建了行化逻辑的元信息，改变了数据框的操作逻辑:
                                                                                                                                                                                                   rf = df %>%
                                                                                                                                                                                                   ## # A tibble: 50 x 8
                                                                                                                                                                                                   ## # Rowwise:
                                                                                                                                                                                                   rowwise() rf
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##6六1班何小薇女
                                                                                                                                                                                                 ## # ... with 40 more rows rf %>%
                                                                                                                                                                                                 class name   sex
                                                                                                                                                                                                 <chr> <chr> <chr> 1六1班何娜 女 2六1班黄才菊女 3六1班陈芳妹女 4六1班陈学勤男 5六1班陈祝贞女
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   87    92
                                                                                                                                                                                                 95    77
                                                                                                                                                                                                 79    87
                                                                                                                                                                                                 NA    79
                                                                                                                                                                                                 76    79
                                                                                                                                                                                                 83    73
                                                                                                                                                                                                 <dbl> <dbl>   <dbl>
                                                                                                                                                                                                   ## # ... with 44 more rows
                                                                                                                                                                                                   ## # A tibble: 50 x 9
                                                                                                                                                                                                   ## # Rowwise:
                                                                                                                                                                                                   ##   class name   sex
                                                                                                                                                                                                   ## <chr> <chr> <chr> ##1六1班何娜 女 ##2六1班黄才菊女 ##3六1班陈芳妹女 ##4六1班陈学勤男 ##5六1班陈祝贞女 ##6六1班何小薇女
                                                                                                                                                                                                   chinese  math english moral science total
                                                                                                                                                                                                 chinese  math english moral science
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   87    92
                                                                                                                                                                                                 95    77
                                                                                                                                                                                                 79    87
                                                                                                                                                                                                 NA    79
                                                                                                                                                                                                 76    79
                                                                                                                                                                                                 83    73
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   <dbl> <dbl>
                                                                                                                                                                                                   10   258
                                                                                                                                                                                                 9   247
                                                                                                                                                                                                 10   232
                                                                                                                                                                                                 10    NA
                                                                                                                                                                                                 10   222
                                                                                                                                                                                                 9 221
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   87    92
                                                                                                                                                                                                 95    77
                                                                                                                                                                                                 79    87
                                                                                                                                                                                                 NA    79
                                                                                                                                                                                                 76    79
                                                                                                                                                                                                 83    73
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   <dbl> <dbl>
                                                                                                                                                                                                   10   277
                                                                                                                                                                                                 9    NA
                                                                                                                                                                                                 10   251
                                                                                                                                                                                                 10    NA
                                                                                                                                                                                                 10   240
                                                                                                                                                                                                 9 238
                                                                                                                                                                                                 79
                                                                                                                                                                                                 75
                                                                                                                                                                                                 66
                                                                                                                                                                                                 66
                                                                                                                                                                                                 67
                                                                                                                                                                                                 65
                                                                                                                                                                                                 9 NA 9 9 8 8
                                                                                                                                                                                                 函数 c_across()是为按行方式(rowwise)在选定的列范围汇总数据而设计的，它没有 提供.fns 参数，只能选择列。
                                                                                                                                                                                                 rf %>%
                                                                                                                                                                                                   mutate(total = sum(c_across(where(is.numeric))))
                                                                                                                                                                                                 79
                                                                                                                                                                                                 75
                                                                                                                                                                                                 66
                                                                                                                                                                                                 66
                                                                                                                                                                                                 67
                                                                                                                                                                                                 65
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 NA       9
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 9      10
                                                                                                                                                                                                 8      10
                                                                                                                                                                                                 8       9
                                                                                                                                                                                                 mutate(total = sum(chinese, math, english))
                                                                                                                                                                                                 ## # A tibble: 50 x 9
                                                                                                                                                                                                 ## # Rowwise:
                                                                                                                                                                                                 ##   class name   sex
                                                                                                                                                                                                 ## <chr> <chr> <chr> ##1六1班何娜 女 ##2六1班黄才菊女 ##3六1班陈芳妹女 ##4六1班陈学勤男 ##5六1班陈祝贞女 ##6六1班何小薇女
                                                                                                                                                                                                 chinese  math english moral science total
                                                                                                                                                                                                 79
                                                                                                                                                                                                 75
                                                                                                                                                                                                 66
                                                                                                                                                                                                 66
                                                                                                                                                                                                 67
                                                                                                                                                                                                 65
                                                                                                                                                                                                 9 NA 9 9 8 8
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 若只是做按行求和或均值，直接用 rowSums()或 rowMeans()函数速度更快(不需要“分
                                                                                                                                                                                                                                             异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                             2.6 其他数据操作 111 割—汇总—合并”)，这里经过行化后提供可以做更多的按行汇总的可能。
                                                                                                                                                                                                 df %>%
                                                                                                                                                                                                   mutate(total = rowSums(across(where(is.numeric))))
                                                                                                                                                                                                 ## # A tibble: 50 x 9
                                                                                                                                                                                                 ##   class name   sex
                                                                                                                                                                                                 ## <chr> <chr> <chr> ##1六1班何娜女 ##2六1班黄才菊女 ##3六1班陈芳妹女 ##4六1班陈学勤男 ##5六1班陈祝贞女 ##6六1班何小薇女
                                                                                                                                                                                                 chinese  math english moral science total
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   87    92
                                                                                                                                                                                                 95    77
                                                                                                                                                                                                 79    87
                                                                                                                                                                                                 NA    79
                                                                                                                                                                                                 76    79
                                                                                                                                                                                                 83    73
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   <dbl> <dbl>
                                                                                                                                                                                                   10   277
                                                                                                                                                                                                 9    NA
                                                                                                                                                                                                 10   251
                                                                                                                                                                                                 10    NA
                                                                                                                                                                                                 10   240
                                                                                                                                                                                                 9 238
                                                                                                                                                                                                 79
                                                                                                                                                                                                 75
                                                                                                                                                                                                 66
                                                                                                                                                                                                 66
                                                                                                                                                                                                 67
                                                                                                                                                                                                 65
                                                                                                                                                                                                 9 NA 9 9 8 8
                                                                                                                                                                                                 按行方式(rowwise)可以理解为一种特殊的分组，即每一行作为一组。为 rowwise()函数提供 行 ID，用 summarise()函数做汇总更能体会这一点。 要解除行化模式，可以使用 ungroup()函数。
                                                                                                                                                                                                 df %>%
                                                                                                                                                                                                   ## # A tibble: 50 x 2
                                                                                                                                                                                                   ## # Groups:   name [50]
                                                                                                                                                                                                   ## name total
                                                                                                                                                                                                   ##   <chr>  <dbl>
                                                                                                                                                                                                   ## 1何娜 277
                                                                                                                                                                                                   ## 2黄才菊 NA
                                                                                                                                                                                                   ## 3陈芳妹 251
                                                                                                                                                                                                   ## 4陈学勤 NA
                                                                                                                                                                                                   ## 5陈祝贞 240
                                                                                                                                                                                                   ## 6何小薇 238
                                                                                                                                                                                                   ## # ... with 44 more rows
                                                                                                                                                                                                   rowwise 行化操作的缺点是速度相对更慢，更建议用 1.6.2 节讲到的 pmap()函数逐行迭代。
                                                                                                                                                                                                 rowwise 行化更让人惊喜的是:它的逐行处理的逻辑和嵌套数据框可以更好地实现批量建 模，在 rowwise 行化模式下，批量建模就像计算新列一样自然。批量建模(参见 3.3.3 节)可 以用“嵌套数据框 + purrr::map_*()”实现，但这种 rowwise 技术，具有异曲同工之妙。
                                                                                                                                                                                                 逐行迭代除了 for 循环通常有四种做法，具体如下: iris[1:4] %>% # apply
                                                                                                                                                                                                   2.6.2 窗口函数
                                                                                                                                                                                                 汇总函数(如 sum()和 mean())接受 n 个输入，返回 1 个值。而窗口函数是汇总函数的 变体:接受 n 个输入，返回 n 个值。
                                                                                                                                                                                                 例如，cumsum()、cummean()、rank()、lead()、lag()等函数。 1.排名和排序函数
                                                                                                                                                                                                 共有 6 个排名函数，这里只介绍比较常用的 min_rank()函数，该函数可以实现从小到大
                                                                                                                                                                                                 排名(ties.method="min")，若要从大到小排名需要加“−”或嵌套一个 desc()函数。 df %>%
                                                                                                                                                                                                   rowwise(name) %>%
                                                                                                                                                                                                   summarise(total = sum(c_across(where(is.numeric))))
                                                                                                                                                                                                 mutate(avg = apply(., 1, mean))
                                                                                                                                                                                                 iris[1:4] %>% # rowwise (慢)
                                                                                                                                                                                                   rowwise() %>%
                                                                                                                                                                                                   mutate(avg = mean(c_across()))
                                                                                                                                                                                                 iris[1:4] %>%                         # pmap
                                                                                                                                                                                                   mutate(avg = pmap_dbl(., ~ mean(c(...))))
                                                                                                                                                                                                 iris[1:4] %>% # asplit(逐行分割) + map
                                                                                                                                                                                                   mutate(avg = map_dbl(asplit(., 1), mean))
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 112 2 数据操作
                                                                                                                                                                                                 mutate(ranks = min_rank(desc(-math))) %>%
                                                                                                                                                                                                   arrange(ranks)
                                                                                                                                                                                                 ## # A tibble: 50 x 9
                                                                                                                                                                                                 ##   class name   sex
                                                                                                                                                                                                 ## <chr> <chr> <chr> ##1六4班周婵 女
                                                                                                                                                                                                 chinese  math english moral science ranks
                                                                                                                                                                                                 ## 2六4班陈丽丽女 ##3六1班何娜 女
                                                                                                                                                                                                 ## 4六5班符苡榕女
                                                                                                                                                                                                 ## 5六2班黄祖娜女
                                                                                                                                                                                                 ## 6六1班陈芳妹女
                                                                                                                                                                                                 ## # ... with 44 more rows
                                                                                                                                                                                                 92
                                                                                                                                                                                                 87
                                                                                                                                                                                                 87
                                                                                                                                                                                                 85
                                                                                                                                                                                                 94
                                                                                                                                                                                                 79
                                                                                                                                                                                                 94
                                                                                                                                                                                                 93
                                                                                                                                                                                                 92
                                                                                                                                                                                                 89
                                                                                                                                                                                                 88
                                                                                                                                                                                                 87
                                                                                                                                                                                                 77
                                                                                                                                                                                                 NA
                                                                                                                                                                                                 79
                                                                                                                                                                                                 76
                                                                                                                                                                                                 75
                                                                                                                                                                                                 66
                                                                                                                                                                                                 10 8 9 9
                                                                                                                                                                                                 10 9
                                                                                                                                                                                                 library(lubridate)
                                                                                                                                                                                                 ## # A tibble: 4 x 4
                                                                                                                                                                                                 ## ##
                                                                                                                                                                                                 ## 1
                                                                                                                                                                                                 ## 2
                                                                                                                                                                                                 ## 3
                                                                                                                                                                                                 ## 4
                                                                                                                                                                                                 day        wday   sales balance sales_lag sales_delta
                                                                                                                                                                                                 <date>     <chr>  <dbl>   <dbl>     <dbl>       <dbl>
                                                                                                                                                                                                   2019-08-30星期五 2019-09-03星期二 2019-09-04星期三 2019-09-05星期四
                                                                                                                                                                                                 2      30        NA          NA
                                                                                                                                                                                                 6      25         2           4
                                                                                                                                                                                                 2     -40         6          -4
                                                                                                                                                                                                 3      30         2           1
                                                                                                                                                                                                 <dbl> <dbl>
                                                                                                                                                                                                   <dbl> <dbl>
                                                                                                                                                                                                   <dbl> <int>
                                                                                                                                                                                                   9     1
                                                                                                                                                                                                 6     2
                                                                                                                                                                                                 10     3
                                                                                                                                                                                                 NA 4 10 5 10 6
                                                                                                                                                                                                 2.移位函数
                                                                                                                                                                                                  lag()函数:取前一个值，数据整体右移一位，相当于将时间轴滞后一个单位。  lead()函数:取后一个值，数据整体左移一位，相当于将时间轴超前一个单位。
                                                                                                                                                                                                 dt = tibble(
                                                                                                                                                                                                   day = as_date("2019-08-30") + c(0,4:6),
                                                                                                                                                                                                   wday = weekdays(day),
                                                                                                                                                                                                   sales = c(2,6,2,3),
                                                                                                                                                                                                   balance = c(30, 25, -40, 30))
                                                                                                                                                                                                 dt
                                                                                                                                                                                                 sales balance
                                                                                                                                                                                                 <dbl>   <dbl>
                                                                                                                                                                                                   230 625 2 -40 330
                                                                                                                                                                                                 mutate(sales_lag = lag(sales), sales_delta = sales - lag(sales))
                                                                                                                                                                                                 ## # A tibble: 4 x 6
                                                                                                                                                                                                 ## ##
                                                                                                                                                                                                 ## 1
                                                                                                                                                                                                 ## 2
                                                                                                                                                                                                 ## 3
                                                                                                                                                                                                 ## 4 dt %>%
                                                                                                                                                                                                 day wday <date> <chr> 2019-08-30 星期五 2019-09-03 星期二 2019-09-04 星期三 2019-09-05 星期四
                                                                                                                                                                                                 注意:默认是根据行序移位，可用参数 order_by 设置根据某变量值大小顺序做移位。
                                                                                                                                                                                                 3.累计汇总
                                                                                                                                                                                                 base R已经提供了cumsum()、cummin()、cummax()和cumprod()函数。
                                                                                                                                                                                                 dplyr 包又提供了 cummean()、cumany()和 cumall()函数，后两者可与 filter()
                                                                                                                                                                                                 函数连用以选择行。
                                                                                                                                                                                                  cumany(x):用来选择遇到第一个满足条件之后的所有行。
                                                                                                                                                                                                  cumany(!x):用来选择遇到第一个不满足条件之后的所有行。  cumall(x):用来选择所有行直到遇到第一个不满足条件的行。  cumall(!x):用来选择所有行直到遇到第一个满足条件的行。
                                                                                                                                                                                                 x = c(1, 3, 5, 2, 2)
                                                                                                                                                                                                 ## [1] FALSE FALSE  TRUE  TRUE  TRUE
                                                                                                                                                                                                 cumany(x >= 5) # 从第一个出现x>=5选择后面所有值
                                                                                                                                                                                                 cumany(!x < 5) # 同上, 从第一个出现不满足x<5开始选择后面所有值
                                                                                                                                                                                                 cumall(x < 5) # 依次选择值直到第一个x<5不成立 cumall(!x >= 5) # 同上, 依次选择值直到第一个出现x>=5
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 ## [1]  TRUE  TRUE FALSE FALSE FALSE
                                                                                                                                                                                                 dt %>%
                                                                                                                                                                                                   filter(cumany(balance < 0)) # 选择第一次透支之后的所有行 ## # A tibble: 2 x 4
                                                                                                                                                                                                 2.6 其他数据操作 113
                                                                                                                                                                                                 ## ##
                                                                                                                                                                                                 ## 1
                                                                                                                                                                                                 ## 2
                                                                                                                                                                                                 day wday sales balance <date> <chr> <dbl> <dbl> 2019-09-04星期三 2 -40
                                                                                                                                                                                                 2019-09-05星期四 3 dt %>%
                                                                                                                                                                                                   30
                                                                                                                                                                                                 ## ##
                                                                                                                                                                                                 ## 1
                                                                                                                                                                                                 ## 2
                                                                                                                                                                                                 2.6.3
                                                                                                                                                                                                 day wday sales balance <date> <chr> <dbl> <dbl> 2019-08-30星期五 2 30 2019-09-03星期二 6 25
                                                                                                                                                                                                 滑窗迭代
                                                                                                                                                                                                 filter(cumall(!(balance < 0)))
                                                                                                                                                                                                 ## # A tibble: 2 x 4
                                                                                                                                                                                                 # 选择所有行直到第一次透支
                                                                                                                                                                                                 “窗口函数”这一术语来自 SQL，意味着逐窗口浏览数据，将某函数重复应用于数据的每个 “窗口”。窗口函数的典型应用包括滑动平均、累计和以及更复杂如滑动回归。
                                                                                                                                                                                                 slider 包提供了 slide_*()系列函数实现滑窗迭代，其基本格式为: slide_*(.x, .f, ..., .before, .after, .step, .complete)
                                                                                                                                                                                                 .x:为窗口所要滑过的向量。 .f:要应用于每个窗口的函数，支持 purrr 风格公式写法。 ...:用来传递 .f 的其他参数。
                                                                                                                                                                                                 .before 和.after:设置窗口范围当前元往
                                                                                                                                                                                                 前、往后几个元，可以取 Inf(即往前、往后所有元)。 .step:每次函数调用时，窗口往前移动的步长。 .complete:设置两端处是否保留不完整窗口，
                                                                                                                                                                                                 默认为 FALSE。 slider::slide_*()系列函数与 purrr::
                                                                                                                                                                                                   map_*()是类似的，只是将“逐元素迭代”换成了 “逐窗口迭代”。
                                                                                                                                                                                                 slide 滑窗迭代的作用机制如图 2.22 所示，其 逻辑是先利用窗口参数正确设计并生成滑动窗口，每 个滑动窗口是一个小向量，函数.f 是作用在一个小 向量上，通过后缀控制返回结果类型，返回结果通常作为 mutate 的一列。
                                                                                                                                                                                                 slide 滑窗迭代示意图 金融时间序列数据经常需要计算滑动平均值，比如计算 sales 的 3 日滑动平均:
                                                                                                                                                                                                   library(slider)
                                                                                                                                                                                                 ## # A tibble: 4 x 5
                                                                                                                                                                                                 dt %>%
                                                                                                                                                                                                   mutate(avg_3 = slide_dbl(sales, mean, .before = 1, .after = 1))
                                                                                                                                                                                                 ## ##
                                                                                                                                                                                                 ## 1
                                                                                                                                                                                                 ## 2
                                                                                                                                                                                                 ## 3
                                                                                                                                                                                                 ## 4
                                                                                                                                                                                                 day        wday   sales balance avg_3
                                                                                                                                                                                                 <date>     <chr>  <dbl>   <dbl> <dbl>
                                                                                                                                                                                                   2019-08-30星期五 2019-09-03 星期二 2019-09-04 星期三 2019-09-05 星期四
                                                                                                                                                                                                 2      30  4
                                                                                                                                                                                                 6      25  3.33
                                                                                                                                                                                                 2     -40  3.67
                                                                                                                                                                                                 3      30  2.5
                                                                                                                                                                                                 输出每个滑动窗口更便于理解该 3 日滑动平均值是如何计算的: 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 图 2.22
                                                                                                                                                                                                 
                                                                                                                                                                                                 114 2 数据操作
                                                                                                                                                                                                 slide(dt$sales, ~ .x, .before = 1, .after = 1)
                                                                                                                                                                                                 ## [[1]]
                                                                                                                                                                                                 ## [1] 2 6
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## [[2]]
                                                                                                                                                                                                 ## [1] 2 6 2
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## [[3]]
                                                                                                                                                                                                 ## [1] 6 2 3
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## [[4]]
                                                                                                                                                                                                 ## [1] 2 3
                                                                                                                                                                                                 细心的读者可能发现了:上面计算的并不是真正的 3 日滑动平均值，而是连续 3 个值的滑 动平均值。这是因为 slide()函数默认是以行索引来滑动，如果日期也是连续日期就没有问题。 但是若日期有跳跃，则结果可能不是你想要的。
                                                                                                                                                                                                 那么，怎么计算真正的 3 日滑动平均值呢?需要改用 slide_index()函数，并提供日期 索引，其基本格式为:
                                                                                                                                                                                                   slide_index(.x, .i, .f, ...)
                                                                                                                                                                                                 其中参数.i 用来传递索引向量，实现根据“.i 的当前元+其前/后若干元”创建相应的.x 的 滑动窗口。
                                                                                                                                                                                                 来看一下的连续 3 日滑动窗口与连续 3 值滑动窗口的区别: slide(dt$day, ~ .x, .before = 1, .after = 1)
                                                                                                                                                                                                 ## [[1]]
                                                                                                                                                                                                 ## [1] "2019-08-30" "2019-09-03"
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## [[2]]
                                                                                                                                                                                                 ## [1] "2019-08-30" "2019-09-03" "2019-09-04"
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## [[3]]
                                                                                                                                                                                                 ## [1] "2019-09-03" "2019-09-04" "2019-09-05"
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## [[4]]
                                                                                                                                                                                                 ## [1] "2019-09-04" "2019-09-05"
                                                                                                                                                                                                 slide_index(dt$day, dt$day, ~ .x, .before = 1, .after = 1)
                                                                                                                                                                                                 ## [[1]]
                                                                                                                                                                                                 ## [1] "2019-08-30"
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## [[2]]
                                                                                                                                                                                                 ## [1] "2019-09-03" "2019-09-04"
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## [[3]]
                                                                                                                                                                                                 ## [1] "2019-09-03" "2019-09-04" "2019-09-05"
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## [[4]]
                                                                                                                                                                                                 ## [1] "2019-09-04" "2019-09-05"
                                                                                                                                                                                                 最后，计算 sales 真正的 3 日滑动平均值: dt %>%
                                                                                                                                                                                                   mutate(avg_3 = slide_index_dbl(sales, day, mean, .before = 1, .after = 1))
                                                                                                                                                                                                 ## # A tibble: 4 x 5
                                                                                                                                                                                                 ## ##
                                                                                                                                                                                                 ## 1
                                                                                                                                                                                                 ## 2
                                                                                                                                                                                                 ## 3
                                                                                                                                                                                                 ## 4
                                                                                                                                                                                                 day        wday   sales balance avg_3
                                                                                                                                                                                                 <date>     <chr>  <dbl>   <dbl> <dbl>
                                                                                                                                                                                                   2019-08-30星期五 2019-09-03星期二 2019-09-04 星期三 2019-09-05 星期四
                                                                                                                                                                                                 2      30  2
                                                                                                                                                                                                 6      25  4
                                                                                                                                                                                                 2     -40  3.67
                                                                                                                                                                                                 3      30  2.5
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 2.6.4 整洁计算
                                                                                                                                                                                                 tidyverse 代码之所以这么整洁、优雅，并且访问列时只需要提供列名，不需要加引号， 也不需要加数据框环境 df$, 这是因为它内部采用了一套整洁计算(tidy evaluation)框架。
                                                                                                                                                                                                 如果我们也想自定义这样整洁、优雅的函数，也即在自定义函数中这样“整洁、优雅”地 传递参数，就需要掌握一些整洁计算的技术，具体如下。
                                                                                                                                                                                                 1.数据屏蔽与整洁选择 整洁计算的两种基本形式如下所示。
                                                                                                                                                                                                  数据屏蔽:使得可以不用带数据框(环境变量) 名字，就能使用数据框内的变量(数 据变量)，以便于在数据集内计算值。
                                                                                                                                                                                                  整洁选择:即各种选择列的语法，便于使用数据集中的列。 数据屏蔽内在的机制是先冻结表达式，然后注入函数，再恢复其计算。整洁计算已经为此
                                                                                                                                                                                                 做好了两种封装，如下所示。
                                                                                                                                                                                                  {{ }}(curly-curly 算符):若只是传递，可将“冻结+注入”合成一步。
                                                                                                                                                                                                  enquo()和!!(引用与反引用):不只是传递，而是在冻结和注入之间仍需要做额外
                                                                                                                                                                                                 操作。
                                                                                                                                                                                                 自定义函数时，想要像tidyverse那样整洁地传递变量名，需要用到{{ }},即用两个大括
                                                                                                                                                                                                 号将变量括起来:
                                                                                                                                                                                                   var_summary = function(data, var) {
                                                                                                                                                                                                     ## # A tibble: 3 x 3
                                                                                                                                                                                                     ##     cyl     n  mean
                                                                                                                                                                                                     ## ##1 ##2 ##3
                                                                                                                                                                                                     <dbl> <int> <dbl>
                                                                                                                                                                                                       4 6 8
                                                                                                                                                                                                     1126.7 7 19.7 1415.1
                                                                                                                                                                                                     若要传递多个整洁变量名，可以借助 across()函数传递一个整洁选择(tidy select): group_count = function(data, var) {
                                                                                                                                                                                                       ## # A tibble: 4 × 3
                                                                                                                                                                                                       ## # Groups:   vs [2]
                                                                                                                                                                                                       ##      vs    am     n
                                                                                                                                                                                                       2.6 其他数据操作 115
                                                                                                                                                                                                       data %>%
                                                                                                                                                                                                         summarise(n = n(), mean = mean({{var}}))
                                                                                                                                                                                                     }
                                                                                                                                                                                                     mtcars %>%
                                                                                                                                                                                                       group_by(cyl) %>%
                                                                                                                                                                                                       var_summary(mpg)
                                                                                                                                                                                                     data %>%
                                                                                                                                                                                                       group_by(across({{var}})) %>%
                                                                                                                                                                                                       summarise(n = n())
                                                                                                                                                                                                   }
                                                                                                                                                                                                 group_count(mtcars, c(cyl, am))
                                                                                                                                                                                                 ## ##1 ##2 ##3 ##4
                                                                                                                                                                                                 <dbl> <dbl> <int>
                                                                                                                                                                                                   0     0    12
                                                                                                                                                                                                 0     1     6
                                                                                                                                                                                                 1     0     7
                                                                                                                                                                                                 1     1     7
                                                                                                                                                                                                 若想用字符串形式传递变量名，在访问数据时需要借助.data[[var]]，这里的.data 相 当于代替数据集的代词:
                                                                                                                                                                                                   var_summary = function(data, var) {
                                                                                                                                                                                                   }
                                                                                                                                                                                                 data %>%
                                                                                                                                                                                                   summarise(n = n(), mean = mean(.data[[var]]))
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 116 2 数据操作
                                                                                                                                                                                                 mtcars %>%
                                                                                                                                                                                                   group_by(cyl) %>%
                                                                                                                                                                                                   var_summary("mpg")
                                                                                                                                                                                                 ## # A tibble: 3 x 3
                                                                                                                                                                                                 ##     cyl     n  mean
                                                                                                                                                                                                 ## ##1 ##2 ##3
                                                                                                                                                                                                 <dbl> <int> <dbl>
                                                                                                                                                                                                   names() %>%
                                                                                                                                                                                                   map(~ count(mtcars, .data[[.x]]))
                                                                                                                                                                                                 gear n 3 15 4 12
                                                                                                                                                                                                 4 6 8
                                                                                                                                                                                                 1126.7 7 19.7 1415.1
                                                                                                                                                                                                 该用法还可用于对列名向量做循环迭代，比如对因子型各列计算水平值频数:
                                                                                                                                                                                                   mtcars[,9:10] %>%
                                                                                                                                                                                                   ## [[1]]
                                                                                                                                                                                                   ##   am  n
                                                                                                                                                                                                   ## 1  0 19
                                                                                                                                                                                                   ## 2  1 13
                                                                                                                                                                                                   ##
                                                                                                                                                                                                   ## [[2]]
                                                                                                                                                                                                   ##
                                                                                                                                                                                                   ## 1
                                                                                                                                                                                                   ## 2
                                                                                                                                                                                                   ##3 55
                                                                                                                                                                                                   同样地，将整洁选择作为函数参数传递，也需要用到{{ }}: summarise_mean = function(data, vars) {
                                                                                                                                                                                                     ## # A tibble: 3 x 12
                                                                                                                                                                                                     ##     cyl     n   mpg  disp    hp  drat    wt  qsec    vs    am  gear
                                                                                                                                                                                                     data %>%
                                                                                                                                                                                                       summarise(n = n(), across({{vars}}, mean))
                                                                                                                                                                                                   }
                                                                                                                                                                                                 mtcars %>%
                                                                                                                                                                                                   group_by(cyl) %>%
                                                                                                                                                                                                   summarise_mean(where(is.numeric))
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## 1
                                                                                                                                                                                                 ## 2
                                                                                                                                                                                                 ## 3     8    14  15.1  353. 209.   3.23  4.00  16.8 0     0.143  3.29
                                                                                                                                                                                                 ## # ... with 1 more variable: carb <dbl>
                                                                                                                                                                                                 <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
                                                                                                                                                                                                   4    11  26.7  105.  82.6  4.07  2.29  19.1 0.909 0.727  4.09
                                                                                                                                                                                                 6     7  19.7  183. 122.   3.59  3.12  18.0 0.571 0.429  3.86
                                                                                                                                                                                                 若传递的参数是多个列名构成的字符向量，则需要借助函数 all_of()或 any_of()，具 体选用哪个取决于你的选择:
                                                                                                                                                                                                   vars = c("mpg", "vs")
                                                                                                                                                                                                 最后，再来看使用{{ }}或整洁选择同时修改列名的用法: my_summarise = function(data, mean_var, sd_var) {
                                                                                                                                                                                                   ## # A tibble: 3 x 3
                                                                                                                                                                                                   ##     cyl mean_mpg sd_disp
                                                                                                                                                                                                   mtcars %>% select(all_of(vars))
                                                                                                                                                                                                   mtcars %>% select(!all_of(vars))
                                                                                                                                                                                                   data %>%
                                                                                                                                                                                                     summarise("mean_{{mean_var}}" := mean({{mean_var}}),
                                                                                                                                                                                                               "sd_{{sd_var}}" := mean({{sd_var}}))
                                                                                                                                                                                                 }
                                                                                                                                                                                                 mtcars %>%
                                                                                                                                                                                                   group_by(cyl) %>%
                                                                                                                                                                                                   my_summarise(mpg, disp)
                                                                                                                                                                                                 ##   <dbl>
                                                                                                                                                                                                 ## 1     4
                                                                                                                                                                                                 ## 2     6
                                                                                                                                                                                                 ## 3     8
                                                                                                                                                                                                 <dbl>   <dbl>
                                                                                                                                                                                                   26.7    105.
                                                                                                                                                                                                 19.7    183.
                                                                                                                                                                                                 15.1    353.
                                                                                                                                                                                                 my_summarise = function(data, group_var, summarise_var) {
                                                                                                                                                                                                   data %>%
                                                                                                                                                                                                     group_by(across({{group_var}})) %>%
                                                                                                                                                                                                     异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                   
                                                                                                                                                                                                   summarise(across({{summarise_var}}, mean, .names = "mean_{.col}"))
                                                                                                                                                                                                 }
                                                                                                                                                                                                 mtcars %>%
                                                                                                                                                                                                   my_summarise(c(am, cyl), where(is.numeric))
                                                                                                                                                                                                 ## # A tibble: 6 x 11
                                                                                                                                                                                                 ## # Groups:   am [2]
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## 1     0
                                                                                                                                                                                                 ## 2     0
                                                                                                                                                                                                 ## 3     0
                                                                                                                                                                                                 ## 4     1
                                                                                                                                                                                                 ## 5     1
                                                                                                                                                                                                 ## 6     1
                                                                                                                                                                                                 ## # ... with 3 more variables: mean_vs <dbl>, mean_gear <dbl>,
                                                                                                                                                                                                 ## #   mean_carb <dbl>
                                                                                                                                                                                                 对于字符串列名，同时修改列名的方法如下所示:
                                                                                                                                                                                                   var_summary = function(data, var) {
                                                                                                                                                                                                     data %>%
                                                                                                                                                                                                       summarise(n = n(),
                                                                                                                                                                                                                 !!enquo(var) := mean(.data[[var]]))
                                                                                                                                                                                                   }
                                                                                                                                                                                                 mtcars %>%
                                                                                                                                                                                                   group_by(cyl) %>%
                                                                                                                                                                                                   var_summary("mpg")
                                                                                                                                                                                                 ## # A tibble: 3 x 3
                                                                                                                                                                                                 ##     cyl     n   mpg
                                                                                                                                                                                                 am   cyl mean_mpg mean_disp mean_hp mean_drat mean_wt mean_qsec
                                                                                                                                                                                                 <dbl> <dbl>    <dbl>
                                                                                                                                                                                                   4     22.9
                                                                                                                                                                                                 6     19.1
                                                                                                                                                                                                 8     15.0
                                                                                                                                                                                                 4     28.1
                                                                                                                                                                                                 6     20.6
                                                                                                                                                                                                 8     15.4
                                                                                                                                                                                                 <dbl>   <dbl>     <dbl>   <dbl>     <dbl>
                                                                                                                                                                                                   136.     84.7
                                                                                                                                                                                                 205.    115.
                                                                                                                                                                                                 358.    194.
                                                                                                                                                                                                 3.77    2.94      21.0
                                                                                                                                                                                                 3.42    3.39      19.2
                                                                                                                                                                                                 3.12    4.10      17.1
                                                                                                                                                                                                 4.18    2.04      18.4
                                                                                                                                                                                                 3.81    2.76      16.3
                                                                                                                                                                                                 3.88    3.37      14.6
                                                                                                                                                                                                 93.6    81.9
                                                                                                                                                                                                 155     132.
                                                                                                                                                                                                 326     300.
                                                                                                                                                                                                 2.6 其他数据操作 117
                                                                                                                                                                                                 ## ##1 ##2 ##3
                                                                                                                                                                                                 <dbl> <int> <dbl>
                                                                                                                                                                                                   4 6 8
                                                                                                                                                                                                 1126.7 7 19.7 1415.1
                                                                                                                                                                                                 var_summary = function(data, var) {
                                                                                                                                                                                                   data %>%
                                                                                                                                                                                                     summarise(n = n(),
                                                                                                                                                                                                               !!str_c("mean_", var) := mean(.data[[var]]))
                                                                                                                                                                                                 }
                                                                                                                                                                                                 mtcars %>%
                                                                                                                                                                                                   group_by(cyl) %>%
                                                                                                                                                                                                   var_summary("mpg")
                                                                                                                                                                                                 ## # A tibble: 3 x 3
                                                                                                                                                                                                 ##     cyl     n mean_mpg
                                                                                                                                                                                                 ## ## 1 ##2 ##3
                                                                                                                                                                                                 <dbl> <int>    <dbl>
                                                                                                                                                                                                   4 6 8
                                                                                                                                                                                                 11     26.7
                                                                                                                                                                                                 7     19.7
                                                                                                                                                                                                 14     15.1
                                                                                                                                                                                                 2.引用与反引用 引用与反引用将冻结和注入分成两步，在使用上更加灵活:
                                                                                                                                                                                                    用 enquo()让函数自动引用其参数;  用“!!”反引用该参数。
                                                                                                                                                                                                 以自定义计算分组均值函数为例:
                                                                                                                                                                                                   grouped_mean = function(data, summary_var, group_var) {
                                                                                                                                                                                                     summary_var = enquo(summary_var)
                                                                                                                                                                                                     group_var = enquo(group_var)
                                                                                                                                                                                                     data %>%
                                                                                                                                                                                                       group_by(!!group_var) %>%
                                                                                                                                                                                                       summarise(mean = mean(!!summary_var))
                                                                                                                                                                                                   }
                                                                                                                                                                                                 grouped_mean(mtcars, mpg, cyl)
                                                                                                                                                                                                 ## # A tibble: 3 x 2
                                                                                                                                                                                                 ## ## ##1 ##2 ##3
                                                                                                                                                                                                 cyl mean <dbl> <dbl> 426.7 619.7 815.1
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 118 2 数据操作
                                                                                                                                                                                                 要想修改结果列名，可借助 as_label()函数从引用中提取名字:
                                                                                                                                                                                                   grouped_mean = function(data, summary_var, group_var) {
                                                                                                                                                                                                     ## # A tibble: 3 x 2
                                                                                                                                                                                                     summary_var = enquo(summary_var)
                                                                                                                                                                                                     group_var = enquo(group_var)
                                                                                                                                                                                                     summary_nm = str_c("mean_", as_label(summary_var))
                                                                                                                                                                                                     group_nm = str_c("group_", as_label(group_var))
                                                                                                                                                                                                     data %>%
                                                                                                                                                                                                       group_by(!!group_nm := !!group_var) %>%
                                                                                                                                                                                                       summarise(!!summary_nm := mean(!!summary_var))
                                                                                                                                                                                                   }
                                                                                                                                                                                                 grouped_mean(mtcars, mpg, cyl)
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## 1
                                                                                                                                                                                                 ## 2
                                                                                                                                                                                                 ## 3
                                                                                                                                                                                                 group_cyl mean_mpg
                                                                                                                                                                                                 <dbl>    <dbl>
                                                                                                                                                                                                   4     26.7
                                                                                                                                                                                                 6     19.7
                                                                                                                                                                                                 8     15.1
                                                                                                                                                                                                 要传递多个参数可以用特殊参数“...”。比如，我们还想让计算分组均值的 group_var 可以是任意多个，这就需要改用“...”参数，为了更好地应付这种参数传递，我们特意将该参 数放在最后一个位置。另外，将其他函数参数都增加前缀“.”是一个好的做法，因为可以降低 其与“...”参数的冲突风险。
                                                                                                                                                                                                 grouped_mean = function(.data, .summary_var, ...) {
                                                                                                                                                                                                   ## # A tibble: 6 x 3
                                                                                                                                                                                                   ## # Groups:   cyl [3]
                                                                                                                                                                                                   summary_var = enquo(.summary_var)
                                                                                                                                                                                                   .data %>%
                                                                                                                                                                                                     group_by(...) %>%
                                                                                                                                                                                                     summarise(mean = mean(!!summary_var))
                                                                                                                                                                                                 }
                                                                                                                                                                                                 grouped_mean(mtcars, disp, cyl, am)
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ##
                                                                                                                                                                                                 ## 1     4
                                                                                                                                                                                                 ## 2     4
                                                                                                                                                                                                 ## 3     6
                                                                                                                                                                                                 ## 4     6
                                                                                                                                                                                                 ## 5     8
                                                                                                                                                                                                 ## 6     8
                                                                                                                                                                                                 cyl    am  mean
                                                                                                                                                                                                 <dbl> <dbl> <dbl>
                                                                                                                                                                                                   0 136.
                                                                                                                                                                                                 1  93.6
                                                                                                                                                                                                 0 205.
                                                                                                                                                                                                 1 155
                                                                                                                                                                                                 0 358.
                                                                                                                                                                                                 1 326
                                                                                                                                                                                                 “...”参数不需要做引用和反引用就能正确工作，但若要修改结果列名就不行了，仍需要 借助引用和反引用，但是要改用 enques()和“!!!”。
                                                                                                                                                                                                 grouped_mean = function(.data, .summary_var, ...) {
                                                                                                                                                                                                   ## # A tibble: 6 x 3
                                                                                                                                                                                                   ## # Groups:   groups_cyl [3]
                                                                                                                                                                                                   summary_var = enquo(.summary_var)
                                                                                                                                                                                                   group_vars = enquos(..., .named = TRUE)
                                                                                                                                                                                                   summary_nm = str_c("avg_", as_label(summary_var))
                                                                                                                                                                                                   names(group_vars) = str_c("groups_", names(group_vars))
                                                                                                                                                                                                   .data %>%
                                                                                                                                                                                                     group_by(!!!group_vars) %>%
                                                                                                                                                                                                     summarise(!!summary_nm := mean(!!summary_var))
                                                                                                                                                                                                 }
                                                                                                                                                                                                 grouped_mean(mtcars, disp, cyl, am)
                                                                                                                                                                                                 ## ## ##1 ##2 ##3 ##4 ##5 ##6
                                                                                                                                                                                                 groups_cyl groups_am avg_disp
                                                                                                                                                                                                 <dbl> 4 4 6 6 8 8
                                                                                                                                                                                                 <dbl> <dbl> 0136.
                                                                                                                                                                                                 193.6 0205. 1155 0358. 1326
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 另外，参数“...”也可以传递表达式: filter_fun = function(df, ...) {
                                                                                                                                                                                                   ##                mpg cyl  disp  hp drat    wt qsec vs am gear carb
                                                                                                                                                                                                   ## Porsche 914-2 26.0   4 120.3  91 4.43 2.140 16.7  0  1    5    2
                                                                                                                                                                                                   ## Lotus Europa  30.4   4  95.1 113 3.77 1.513 16.9  1  1    5    2
                                                                                                                                                                                                   最后，再来看一个自定义绘制散点图的模板函数:
                                                                                                                                                                                                     scatter_plot = function(df, x_var,y_var) {
                                                                                                                                                                                                       x_var = enquo(x_var)
                                                                                                                                                                                                       y_var = enquo(y_var)
                                                                                                                                                                                                       ggplot(data = df, aes(x = !!x_var, y = !!y_var)) +
                                                                                                                                                                                                         geom_point() +
                                                                                                                                                                                                         theme_bw() +
                                                                                                                                                                                                         theme(plot.title = element_text(lineheight = 1, face = "bold", hjust = 0.5)) +
                                                                                                                                                                                                         geom_smooth() +
                                                                                                                                                                                                         ggtitle(str_c(as_label(y_var), " vs. ", as_label(x_var)))
                                                                                                                                                                                                     }
                                                                                                                                                                                                     scatter_plot(mtcars, disp, hp)
                                                                                                                                                                                                     结果如图 2.23 所示。
                                                                                                                                                                                                     图 2.23 自定义绘制散点图 2.7 数据处理神器:data.table 包
                                                                                                                                                                                                     data.table 包是 data.frame 的高性能版本，不依赖其他包就能胜任各种数据操作，速 度超快，让个人计算机都能轻松处理几 GB 甚至十几 GB 的数据。data.table 的高性能来源 于内存管理(引用语法)、并行化和大量精细优化。
                                                                                                                                                                                                     2.7 数据处理神器:data.table 包 119
                                                                                                                                                                                                     filter(df, ...)
                                                                                                                                                                                                 }
                                                                                                                                                                                                 mtcars %>%
                                                                                                                                                                                                   filter_fun(mpg > 25 & disp > 90)
                                                                                                                                                                                                 但是，与 tidyverse 一次用一个函数做一件事， 通过管道依次连接，整洁地完成复杂事情的理念截然 不同，data.table 语法高度抽象、简洁、统一，如 图 2.24 所示。
                                                                                                                                                                                                 一句话概括 data.table 语法:用 i 选择行，用 j 操作列，根据 by 分组。
                                                                                                                                                                                                 图 2.24
                                                                                                                                                                                                 data.table 包的最简语法
                                                                                                                                                                                                 其中，j 表达式非常强大和灵活，可以选择、修改、汇总和计算新列，甚至可以接受任意表 达式。需要记住的关键一点是:只要返回的 list 元素是等长元素或长度为 1 的元素，那么每个 list 元素将转化为结果 data.table 的一列。
                                                                                                                                                                                                 data.table 高度抽象的语法无疑增加了学习成本，但它的高效性能和处理大数据能力， 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                 120 2 数据操作
                                                                                                                                                                                                 使得我们非常有必要学习它。当然，读者如果既想要 data.table 的高性能，又想要 tidyverse 的整洁语法，也可以借助一些衔接二者的中间包(如 dtplyr、tidyfst 等)实现。
                                                                                                                                                                                                 为了节省篇幅，本节将只展示代码以演示 data.table 语法，请尽量忽略输出结果。因为 有些复杂操作采用了同前文一样的数据，会得到同样的结果。
                                                                                                                                                                                                 2.7.1 通用语法
                                                                                                                                                                                                 创建 data.table 的代码如下所示:
                                                                                                                                                                                                   library(data.table)
                                                                                                                                                                                                 ## xy ## 1: 1 A ## 2: 2 B
                                                                                                                                                                                                 用 as.data.table()可将数据框、列表、矩阵等转化为 data.table;若只想按引用转 化，则使用 setDT()函数。
                                                                                                                                                                                                 1.引用语法
                                                                                                                                                                                                 高效计算的编程都支持引用语法，也叫浅复制。 浅复制1只是复制列指针向量(对应数据框的列)，而实际数据在内存中不做物理复制;而
                                                                                                                                                                                                 相对的概念— 深复制，则将整个数据复制到内存中的另一位置，深复制这种冗余的复制极大 地影响性能，特别是大数据的情形。
                                                                                                                                                                                                 data.table 使用“:=”运算符，做整列或部分列替换时都不做任何复制，因为“:=”运 算符是通过引用就地更新 data.table 的列。
                                                                                                                                                                                                 若想要复制数据而不想按引用处理(修改数据本身)，则使用DT2 = copy(DT1)。 2.键与索引
                                                                                                                                                                                                 data.table 支持设置键和索引，使得选择行和做数据连接更加方便快速。
                                                                                                                                                                                                  键:一级有序索引。
                                                                                                                                                                                                  索引:自动二级索引。
                                                                                                                                                                                                 二者的主要不同在于以下方面。
                                                                                                                                                                                                  使用键时，数据在内存中做物理上的重排序;而使用索引时，顺序只是保存为属性;
                                                                                                                                                                                                  键是显式定义的;索引可以手动创建，也可以在运行时创建(比如用 ==或 %in% 时);
                                                                                                                                                                                                  索引与参数 on 连用;键的使用是可选的，但为了可读性建议使用键。
                                                                                                                                                                                                 3.特殊符号
                                                                                                                                                                                                 data.table 提供了一些辅助操作的特殊符号，如下所示。
                                                                                                                                                                                                  .():代替 list()。
                                                                                                                                                                                                  := :按引用方式增加和修改列。
                                                                                                                                                                                                  .N :行数。
                                                                                                                                                                                                 1 引用语法，相当于是只有一个对象在内存放着，不做多余复制，用两个指针都指向该同一对象，无论操作哪个指针， 都是在修改该同一对象。
                                                                                                                                                                                                 dt = data.table(
                                                                                                                                                                                                   x = 1:2,
                                                                                                                                                                                                   y = c("A", "B"))
                                                                                                                                                                                                 dt
                                                                                                                                                                                                 setkey(dt, v1, v3) # 设置键 setindex(dt, v1, v3) # 设置索引
                                                                                                                                                                                                 异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                                                                                                 
                                                                                                                                                                                                  .SD:每个分组数据(除了 by 或 keyby 的列)。
                                                                                                                                                                                                  .SDcols:与.SD 连用，用来选择包含在.SD 中的列。
                                                                                                                                                                                                  .BY:包含所有 by 分组变量的 list
                                                                                                                                                                                                  .I : 整 数 向 量 seq_len(nrow(x)) ， 例 如 DT[, .I[which.max(somecol)],
                                                                                                                                                                                                                                          by=grp]。
                                                                                                                                                                                                  .GRP:分组索引，1 代表第 1 分组，2 代表第 2 分组......
                                                                                                                                                                                                  .NGRP:分组数。
                                                                                                                                                                                                  .EACHI:用于 by/keyby = .EACHI 表示根据 i 表达式的每一行分组。
                                                                                                                                                                                                 4.链式操作
                                                                                                                                                                                                 data.table 也有自己专用的管道操作，称为链式操作:
                                                                                                                                                                                                   DT[...][...][...] # 或者写开为 DT[
                                                                                                                                                                                                 ... ][
                                                                                                                                                                                                   2.7.2 数据读写
                                                                                                                                                                                                   函数 fread()和 fwrite()是 data.table 中最强大的函数之二。它们最大的优势，仍 是读取大数据时速度超快，且非常稳健，分隔符、列类型、行数都可以自动检测;它们非常通 用，可以处理不同的文件格式(但不能直接读取 Excel 文件)，还可以接受 URL 甚至是操作系统 指令。
                                                                                                                                                                                                   2.7 数据处理神器:data.table 包 121
                                                                                                                                                                                                   ... ][
                                                                                                                                                                                                     ... ]
                                                                                                                        1.读入数据 fread("DT.csv")
                                                                                                                        fread("DT.txt", sep = "\t")
                                                                                                                        # 选择部分行列读取
                                                                                                                        fread("DT.csv", select = c("V1", "V4")) fread("DT.csv", drop = "V4", nrows = 100) # 读取压缩文件
                                                                                                                        fread(cmd = "unzip -cq myfile.zip") fread("myfile.gz")
                                                                                                                        # 批量读取
                                                                                                                        c("DT.csv", "DT.csv") %>%
                                                                                                                          lapply(fread) %>%
                                                                                                                          rbindlist() # 多个数据框/列表按行合并
                                                                                                                        2.写出数据
                                                                                                                        fwrite(DT, "DT.csv")
                                                                                                                        fwrite(DT, "DT.csv", append = TRUE)
                                                                                                                        fwrite(DT, "DT.txt", sep = "\t")
                                                                                                                        # 追加内容
                                                                                                                        fwrite(setDT(list(0, list(1:5))), "DT2.csv") # 支持写出列表列 fwrite(DT, "myfile.csv.gz", compress = "gzip") # 写出到压缩文件
                                                                                                                        vroom 包提供了速度更快的文件读写函数:vroom()和 vroom_write()，感兴趣的读者 可以自行了解。
                                                                                                                        异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                        
                                                                                                                        122 2 数据操作 2.7.3 数据连接
                                                                                                                        data.table 提供了简单的按行合并函数。
                                                                                                                         rbind(DT1, DT2, ...):按行堆叠多个 data.table。
                                                                                                                         rbindlist(DT_list, idcol):堆叠多个 data.table 构成 list。
                                                                                                                        最常用的六种数据连接是左连接、右连接、内连接、全连接、半连接、反连接。
                                                                                                                        1.左连接
                                                                                                                        外连接至少保留一个数据表中的所有观测，分为左连接、右连接、全连接，其中最常用的 是左连接:保留 x 的所有行，合并匹配的 y 中的列。
                                                                                                                        若表x与y中匹配列的列名不同，可以用by.x = "c1", by.y = "c2"，若有多个匹配列，嵌套使用 c()即可。
                                                                                                                        上面代码提供了左连接的三种不同实现，为了易记性和可读性，更建议用第三种 merge()函数。 注意，只要加载了 data.table 包，程序将自动使用更快速的 data.table::merge()函数，而不是
                                                                                                                        base R中的merge()函数，尽管二者语法相同。 2.右连接
                                                                                                                        保留 y 中的所有行，合并匹配的 x 中的列: merge(x, y, all.y = TRUE, by = "v1")
                                                                                                                        3.内连接
                                                                                                                        内连接是保留两个数据表中所共有的观测:只保留 x 中与 y 匹配的行，合并匹配的 y 中的列:
                                                                                                                          merge(x, y, by = "v1")
                                                                                                                        4.全连接
                                                                                                                        保留 x 表中与 y 表相匹配的所有行，即根据在 y 表中匹配成功的部分来筛选 x 表中的行:
                                                                                                                          merge(x, y, all = TRUE, by = "v1")
                                                                                                                        5.半连接
                                                                                                                        删掉 x 表中与 y 表相匹配的所有行，即根据在 y 表中没有匹配成功的部分来筛选 x 表中的行:
                                                                                                                          x[y$v1, on = "v1", nomatch = 0]
                                                                                                                        6.反连接
                                                                                                                        根据不在 y 中，来筛选 x 中的行:
                                                                                                                          x[!y, on = "v1"]
                                                                                                                        7.集合运算
                                                                                                                        fintersect(x, y)
                                                                                                                        fsetdiff(x, y)
                                                                                                                        funion(x, y)
                                                                                                                        fsetequal(x, y)
                                                                                                                        y[x, on = "v1"] # 注意是以x为左表 y[x] # 若v1是键 merge(x, y, all.x = TRUE, by = "v1")
                                                                                                                        异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                        
                                                                                                                        2.7.4 数据重塑
                                                                                                                        1.宽表变长表
                                                                                                                        宽表的特点是表比较宽，本来该是“值”的，却出现在“变量(名)”中。这就需要给它变 到“值”中，新起个列名存为一列，这就是所谓的宽表变长表。
                                                                                                                         每一行只有 1 个观测的情形
                                                                                                                        参数 measure 是用整数向量指定要变形的列，也可以使用正则表达式 patterns("年$"), 也可以改用参数id指定不变形的列;若需要忽略缺失值，可以设置参数na.rm = TRUE。
                                                                                                                        基于 tidyr::pivot_longer()的实现如下: DT %>%
                                                                                                                          pivot_longer(-地区, names_to = "年份", values_to = "GDP") 两种语法基本相同，都是指定要变形的列，为存放变形列的列名中的“值”指定新列名，
                                                                                                                        为存放变形列中的“值”指定新列名。  每一行有多个观测的情形
                                                                                                                        load("data/family.rda")
                                                                                                                        DT = as.data.table(family) # family数据 DT %>%
                                                                                                                        melt(measure = patterns("^dob", "^gender"),
                                                                                                                             value = c("dob", "gender"), na.rm = TRUE)
                                                                                                                        2.长表变宽表
                                                                                                                        长表的特点是表比较长。有时候需要将分类变量的若干水平值变成变量(列名)，这就是长 表变宽表，它与宽表变长表正好相反(二者互逆)。
                                                                                                                         只有 1 个列名列和 1 个值列的情形
                                                                                                                        load("data/animals.rda")
                                                                                                                        DT = as.data.table(animals) # 农场动物数据 DT %>%
                                                                                                                        dcast(Year ~ Type, value = "Heads", fill = 0)
                                                                                                                        基于 tidyr::pivot_wider()的实现如下: DT %>%
                                                                                                                          pivot_wider(names_from = Type, values_from = Heads, values_fill = 0) dcast()函数的第 1 个参数是公式形式，~ 左边是不变的列，右边是“变量名”来源列，
                                                                                                                        参数 value 指定“值”的来源列。
                                                                                                                         有多个列名列和多个值列的情形
                                                                                                                        us_rent_income %>%
                                                                                                                          as.data.table() %>%
                                                                                                                          dcast(GEOID + NAME ~ variable, value = c("estimate", "moe"))
                                                                                                                        3.数据分割与合并
                                                                                                                        函数split(DT, by)可将data.table分割为list，然后就可以接map_*()函数实现逐 分组迭代。
                                                                                                                         拆分列
                                                                                                                        DT = as.data.table(table3)
                                                                                                                        # 将case列拆分为两列, 并删除原列
                                                                                                                        DT[, c("cases", "population") := tstrsplit(DT$rate, split = "/")][,
                                                                                                                                                                                          rate := NULL]
                                                                                                                        2.7 数据处理神器:data.table 包 123
                                                                                                                        DT = fread("data/分省年度GDP.csv", encoding = "UTF-8") DT %>%
                                                                                                                          melt(measure = 2:4, variable = "年份", value = "GDP")
                                                                                                                        异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                        
                                                                                                                        124 2 数据操作  合并列
                                                                                                                        DT = as.data.table(table5)
                                                                                                                        # 将century和year列合并为新列new, 并删除原列
                                                                                                                        DT[, new := paste0(century, year)][, c("century", "year") := NULL]
                                                                                                                        2.7.5 数据操作
                                                                                                                        1.选择行
                                                                                                                        用 i 表达式选择行。
                                                                                                                         根据索引
                                                                                                                         根据逻辑表达式
                                                                                                                        dt[v2 > 5]
                                                                                                                        dt[v4 %chin% c("A","C")]
                                                                                                                        dt[v1==1 & v4=="A"]
                                                                                                                         删除重复行 unique(dt)
                                                                                                                        # 比 %in% 更快
                                                                                                                        dt[3:4,] # 或dt[3:4] dt[!3:7,] # 反选, 或dt[-(3:7)]
                                                                                                                        unique(dt, by = c("v1","v4"))
                                                                                                                         删除包含 NA 的行 na.omit(dt, cols = 1:4)
                                                                                                                         行切片
                                                                                                                         其他
                                                                                                                        2.对行进行排序
                                                                                                                        若按引用对行进行重排序:
                                                                                                                          # 返回所有列
                                                                                                                          dt[sample(.N, 3)]
                                                                                                                        dt[sample(.N, .N * 0.5)]
                                                                                                                        dt[frankv(-v1, ties.method = "dense") < 2]
                                                                                                                        # 随机抽取3行
                                                                                                                        # 随机抽取50% 的行 # v1值最大的行
                                                                                                                        dt[v4 %like% "^B"]
                                                                                                                        dt[v2 %between% c(3,5)]
                                                                                                                        dt[between(v2, 3, 5, incbounds = FALSE)]
                                                                                                                        dt[v2 %inrange% list(-1:1, 1:3)]
                                                                                                                        dt[inrange(v2, -1:1, 1:3, incbounds = TRUE)]
                                                                                                                        # v4值以B开头
                                                                                                                        # 闭区间
                                                                                                                        # 开区间
                                                                                                                        # v2值属于多个区间的某个 # 同上
                                                                                                                        dt[order(v1)]
                                                                                                                        dt[order(-v1)]
                                                                                                                        dt[order(v1, -v2)]
                                                                                                                        # 默认按v1从小到大
                                                                                                                        # 按v1从大到小
                                                                                                                        # 按v1从小到大, v2从大到小
                                                                                                                        setorder(DT, V1, -V2)
                                                                                                                        data.table包还提供了函数fsort()和frank()，它们是Base R中sort()和rank()函数的快速版本。
                                                                                                                        3.操作列
                                                                                                                        用 j 表达式操作列。
                                                                                                                         选择一列或多列
                                                                                                                        # 根据索引 dt[[3]] dt[, 3]
                                                                                                                        # 根据列名 dt[, .(v3)]
                                                                                                                        # 或dt[["v3"]], dt$v3, 返回向量 # 或dt[, "v3"], 返回data.table
                                                                                                                        # 或dt[, list(v3)]
                                                                                                                        异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                                        
                                                                                                                        dt[, .(v2,v3,v4)]
                                                                                                                        dt[, v2:v4]
                                                                                                                        dt[, !c("v2","v3")] # 反选列
                                                                                                                         反引用列名
                                                                                                                        tidyverse 提供了丰富的选择列的辅助函数，而 data.table 需要通过字符串函数、正
                                                                                                                        则表达式构造出列名向量，再通过反引用选择相应的列。
                                                                                                                        cols = c("v2", "v3")
                                                                                                                        dt[, ..cols]
                                                                                                                        dt[, !..cols]
                                                                                                                        cols = paste0("v", 1:3)
                                                                                                                        dt[, ..cols]
                                                                                                                         调整列序
                                                                                                                         修改列名 setnames(DT, old, new)
                                                                                                                        # v1, v2, ...
                                                                                                                        2.7 数据处理神器:data.table 包 125
                                                                                                                        cols = union("v4", names(dt)) # v4列提到第1列
                                                                                                                        cols = grep("v", names(dt)) # 列名中包含"v" cols = grep("^(a)", names(dt)) # 列名以"a"开头
                                                                                                                        cols = grep("b$", names(dt))
                                                                                                                        cols = grep(".2", names(dt))
                                                                                                                        cols = grep("v1|X", names(dt))
                                                                                                                        # 列名以"b"结尾
                                                                                                                        # 正则匹配".2"的列 # v1或x
                                                                                                                        cols = rev(names(DT)) # 或其他列序 setcolorder(DT, cols)
                                                                                                                         修改因子水平
                                                                                                                        DT[, setattr(sex, "levels", c("M", "F"))]
                                                                                                                        tidyverse 是用 mutate()函数修改列，此时并不会修改原数据框，必须赋值才能看到结果 变化结果;data.table 修改列是用列赋值符号“:=”(不执行复制)，可以直接对原数据框修改。
                                                                                                                         修改或增加一列
                                                                                                                        注意，代码v3 = v2 + 1中的v2是原始的v2列，而不是前面新计算的v2列;若想使用新计算的列， 可以用以下语句:
                                                                                                                          dt[, c("v2", "v3") := .(temp <- log(v1), v3 = temp + 1)]
                                                                                                                         增加多列
                                                                                                                         同时修改多列
                                                                                                                        tidyverse 是借助 across()函数或_all、_if、_at 后缀选择并同时操作多列;而
                                                                                                                        data.table 选择并操作多列是借助 lapply()函数以及特殊符号。
                                                                                                                         .SD:每个分组数据(除了 by 或 keyby 的列)。
                                                                                                                         .SDcols:与.SD 连用，用来选择包含在.SD 中的列，支持索引、列名、连选、反选、
                                                                                                                        正则表达式和条件判断函数。
                                                                                                                        dt[, v1 := v1 ^ 2][]
                                                                                                                        dt[, v2 := log(v1)]
                                                                                                                        dt[, .(v2 = log(v1), v3 = v2 + 1)]
                                                                                                                        # 修改列, 加[]输出结果 # 增加新列
                                                                                                                        # 只保留新列
                                                                                                                        dt[, c("v6","v7") := .(sqrt(v1), "x")] # 或者 dt[, ':='(v6 = sqrt(v1),
                                                                                                                        v7 = "x")] # v7列的值全为x
                                                                                                   # 使用不带NA的考试成绩数据
                                                                                                   DT = readxl::read_xlsx("data/ExamDatas.xlsx") %>%
                                                                                                     as.data.table()
                                                                                                   异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                   
                                                                                                   126 2 数据操作
                                                                                                   # 把函数应用到所有列
                                                                                                   DT[, lapply(.SD, as.character)] # 把函数应用到满足条件的列
                                                                                                   DT[, lapply(.SD, rescale),
                                                                                                      # rescale()为自定义的归一化函数
                                                                                                      .SDcols = is.numeric]
                                                                                                   # 把函数应用到指定列
                                                                                                   DT = as.data.table(iris)
                                                                                                   DT[, .SD * 10, .SDcols = patterns("(Length)|(Width)")]
                                                                                                   注意，上述同时修改多列的代码，都是只保留新列，若要保留所有列，需要准备新列名 cols, 再在 j 表 达式中使用(cols):= ...
                                                                                                    删除列
                                                                                                   dt[, v1 := NULL]
                                                                                                   dt[, c("v2","v3") := NULL]
                                                                                                   cols = c("v2","v3")
                                                                                                   dt[, (cols) := NULL]
                                                                                                    重新编码
                                                                                                   # 一分支
                                                                                                   dt[v1 < 4, v1 := 0]
                                                                                                   # 二分支
                                                                                                   dt[, v1 := fifelse(v1 < 0, -v1, v1)] # 多分支
                                                                                                   dt[, v2 := fcase(v2 < 4, "low",
                                                                                                                    v2 < 7, "middle",
                                                                                                                    default = "high")]
                                                                                                    前移/后移运算
                                                                                                   shift(x, n = 1, fill = NA, type = "lag")
                                                                                                   shift(x, n = 1, fill = NA, type = "lead")
                                                                                                   2.7.6 分组操作
                                                                                                   用 by 表达式指定分组。
                                                                                                   # 注意, 不是 dt[, cols := NULL]
                                                                                                   # 1,2,3 -> NA,1,2
                                                                                                   # 1,2,3 -> 2,3,NA
                                                                                                   data.table 是根据 by 或 keyby 分组，区别是，keyby 会排序结果并创建键，使得我们 可以更快地访问子集。
                                                                                                   未分组数据框相当于把整个数据框作为 1 组，数据操作是在整个数据框上进行，若汇总则 得到的是 1 个结果。
                                                                                                   分组数据框相当于把整个数据框分成了 m 个数据框，数据操作是分别在每个数据框上进行， 若汇总则得到的是 m 个结果。
                                                                                                   # 使用带NA值的考试成绩数据
                                                                                                   DT = readxl::read_xlsx("data/ExamDatas_NAs.xlsx") %>%
                                                                                                     as.data.table()
                                                                                                    分组修改
                                                                                                   分别对每个分组进行操作(计算新列)，相当于 group_by+mutate:
                                                                                                     DT[, ':='(math.avg = mean(math,  na.rm = TRUE),
                                                                                                               math_med = median(math)),
                                                                                                        by = sex]
                                                                                                    未分组汇总
                                                                                                   DT[, .(math_avg = mean(math, na.rm = TRUE))]
                                                                                                   ##    math_avg
                                                                                                   ## 1: 68.04255
                                                                                                   异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权
                                                                                                   
                                                                                                    简单的分组汇总
                                                                                                   DT[, .(n = .N,
                                                                                                          math_avg = mean(math,  na.rm = TRUE),
                                                                                                          math_med = median(math)),
                                                                                                      by = sex]
                                                                                                   sex n math_avg math_med 1: 女25 70.78261 NA 2: 男24 64.56522 NA
                                                                                                   可以直接在 by 中使用判断条件或表达式，特别是根据整合单位的日期时间汇总: date = as.IDate("2021-01-01") + 1:50
                                                                                                   data.table 提供快速处理日期时间的 IDateTime 类，更多信息可查阅帮助文档。  对某些列做汇总
                                                                                                   DT[, lapply(.SD, mean), .SDcols = patterns("h"), by = .(class, sex)]
                                                                                                   # 或用by = c("class", "sex")  对所有列做汇总
                                                                                                   DT[, name := NULL][, lapply(.SD, mean, na.rm = TRUE),
                                                                                                                      by = .(class, sex)]
                                                                                                    对满足条件的列做汇总
                                                                                                   DT[, lapply(.SD, mean, na.rm = TRUE), by = class,
                                                                                                      .SDcols = is.numeric]
                                                                                                    分组计数
                                                                                                   DT = na.omit(DT)
                                                                                                   cut N (60,100] 5 (0,60]1
                                       (60,100] 5 (0,60]1
上述分组计数会忽略频数为 0 的分组，若要显示频数为 0 的分组可以用以下方法: DT[, Bin := cut(math, c(0, 60, 100))]
其中，函数 CJ()相当于 expand_grid()，可以生成所有两两组合(笛卡儿积)。  分组选择行
data.table 也提供了辅助函数:first()、last()、uniqueN()，比如提取每组的 first/nth 观测，可以使用以下方式:
  DT[, first(.SD), by = class]
2.7 数据处理神器:data.table 包 127
##
##
##
## 3: <NA>  1 85.00000       85
DT = data.table(date, a = 1:50)
DT[, mean(a), by = list(mon = month(date))] # 按月平均
DT[, .N, by = .(class, cut(math, c(0, 60, 100)))] %>%
  print(topn = 2)
##
##
##
## ---
## 8: 六5班
## 9:六5班
class 1: 六1班 2:六1班
DT[CJ(class = class, Bin = Bin, unique = TRUE),
   on = c("class","Bin"), .N, by = .EACHI]
DT[, .SD[3], by = class] # 每组第3个观测 DT[, tail(.SD, 2), by = class] # 每组后2个观测 # 选择每个班男生数学最高分的观测
DT[sex == "男", .SD[math == max(math)], by = class]
异步社区cloudcHCO8tlw0iz(15725519632) 专享 请尊重版权

128 2 数据操作
提示
本节是分别按 i、j、by 的顺序讲解语法，当你真正实践的时候，是把三者组合起来使用，即同时对 i 所选择的行，根据 by 分组，并做 j 操作。
在 data.table 中，人们习惯用 lapply()函数，换成 map()函数也是一样的效果，好处是 map()函 数支持函数的 purrr-风格公式写法。
拓展学习
读者如果想进一步了解 tidyverse 数据操作，建议大家去阅读 Hadley 编写的《R 数据科学》(R for Data Science)，Desi Quintans 编写的 Working in Tidyverse，Benjamin 编写的 Modern Data Science with R，王敏 杰编写的《数据科学中的 R 语言》，以及 dplyr 包、tidyr 包、slider 包文档及相关资源。 读者如果想进一步了解整洁计算，建议大家阅读 Lionel Henry 编写的 Tidy evaluation，以及 rlang 包文档 及相关资源。
读者如果想进一步了解 data.table 数据操作，建议大家阅读 data.table 包文档及相关资源。