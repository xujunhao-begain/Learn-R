#3.1 ggplot2 基础语法 
#3.1.1 ggplot2 概述
#ggplot2 是非常流行的 R 可视化包，最初是 Hadley Wickham 读博期间的作品。ggplot2 
#凭借图层化语法(图形是一层一层的图层叠加而成)、先进的绘图理念、优雅的语法代码、
#美观大方的生成图形，迅速走红。
#ggplot2 几乎是 R 语言的代名词，提起 R 语言，人们首先想到的是强大的可视化功能。
#未来我希望提起 R 语言，人们首先想到的是 tidyverse(将 ggplot2 扩展到整个数据科学流程)。
#ggplot2 绘图语法
#ggplot2 的绘图语法是从数据产生图形的一系列语法。 
#即选取整洁数据将其映射为几何对象(如点、线等)，几何对象具有美学特征
#(如坐标轴、颜色等)。若需要则对数据做统计变换，调整标度，可将结果投影到坐标系，
#再根据喜好选择主题。 
# ggplot 的语法包括 10 个部件: 
# 数据(data);
# 映射(mapping);
# 几何对象(geom);
# 标度(scale);
# 统计变换(stats);
# 坐标系(coord);
# 位置调整(Position adjustments);
# 分面(facet);
# 主题(theme);
# 输出(output)

#2.映射(mapping)
#函数 aes()是 ggplot2 中的映射函数, 所谓映射就是将数据集中的数据变量映射(关联)到
#相应的图形属性，也称为“美学映射”或“美学”。
#映射:指明了变量与图形所见元素之间的联系，告诉 ggplot 图形元素想要关联哪个变量数据
#最常用的映射(美学)如下所示。 
# x:x轴
# y:y轴
# color:颜色
# size:大小
# shape:形状
# fill:填充
# alpha:透明度
#最需要的美学是 x 和 y，分别映射到变量 displ 和 hwy, 再将美学 color 映射到 drv，
#此时图形就有了坐标轴和网格线，color 美学在绘制几何对象前还体现不出来:
library(tidyverse)
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv))
#注意:映射不是直接为出现在图形中的颜色、外形、线型等设定特定值，
#而是建立数据中的变量与可见的 图形元素之间的联系，经常将图形的美学 color、size 
#等映射到数据集的分类变量，以实现不同分组用 不同的美学来区分。
#所以，若要为美学指定特定值，比如 color = "red"，这部分内容是不能放在映射 aes()中的。

#3.几何对象(geometric) 
#每个图形都是采用不同的视觉对象来表达数据，称为“几何对象”。 
#我们通常用不同类型的“几何对象”从不同角度来表达数据，如散点图、平滑曲线、拆线
#图、条形图、箱线图等。
#ggplot2 提供了 50 余种“几何对象”，均以 geom_xxxx()的方式命名，常用的有以下几种。
# geom_point():散点图。
# geom_line():折线图。
# geom_smooth():光滑(拟合)曲线。
# geom_bar()/geom_col():条形图。
# geom_histogram():直方图。
# geom_density():概率密度图。
# geom_boxplot():箱线图。
# geom_abline()/geom_hline()/geom_vline():参考直线。
#要绘制几何对象，添加图层即可。
#以下先来绘制散点图，为了简洁，此处省略前文已知的 函数参数名:
ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point()
#不同的几何对象支持的美学会有些不同，美学映射也可以放在几何对象中，
#此时上面的代码可改写为:
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv))
#前面提到，为图形美学设置特定值也是可以的，但不能放在映射 aes()中。
#例如设置散点图中点的颜色，代码如下:
ggplot(mpg, aes(displ, hwy)) +
  geom_point(color = "blue")

#再添加一个几何对象(光滑曲线)，color 映射的位置不同，所得的结果 就不一样。
#下面通过设置不同类型的光滑曲线以实现更好的可视化效果:
#带分组光滑曲线的散点图 
ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  geom_smooth()

#带全局光滑曲线的散点图
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth()
#为什么会出现这种不同呢?这就涉及 ggplot2 关于“全局”与“局部”的约定: 
#ggplot()中的数据和映射是全局的，可供所有几何对象共用;
#而位于“几何对象”中的数据和映射是局部的，只供该几何对象使用;
#“几何对象”优先使用局部的数据和映射，局部没有则用全局的。

#4.关于分组美学(group)
#在前例中，用 aes(color = drv)将颜色映射到分类变量 drv，实际上就是实现了一种 分组，
#对不同 drv 值的数据，按不同颜色分别绘图。
#但是对于下面这种情况，根据 2001—2017 年我国各地经济统计数据集 ecostats，
#绘制人均 GDP 与年份之间的折线图，如果不区分各个地区，仅显示每个年份都对应的人均
#GDP 值，代码如下:
load("data/ecostats.rda")
ecostats
ggplot(ecostats, aes(Year, gdpPercap)) +
geom_line()
#这个图形显然不是我们想要的，图中应该能区分不同省份，这就需要显式地映射分组美学，
#可以使用aes(group = Region)实现:
ggplot(ecostats, aes(Year, gdpPercap)) +
  geom_line(aes(group = Region), alpha = 0.2) +
  geom_smooth(se = FALSE, size = 1.2)

#3.1.3 标度
#通常 ggplot2 会自动根据输入变量选择最优的坐标刻度方案，若要手动设置或调整，就需要
#用到标度函数 scale_<MAPPING>_<KIND>()。
#标度函数控制几何对象中的标度映射:不只是 x、y 轴，还有 color、fill、shape 和 size 
#产生的图例。它们是数据中的连续或分类变量的可视化表示，因为需要关联到标度，所以
#要用到映射。
#常用的标度函数如下所示
# scale_*_continuous():*为 x 或 y。 
# scale_*_discrete():*为 x 或 y。 
# scale_x_date()。
# scale_x_datetime()。
# scale_*_log10(), scale_*_sqrt(), scale_*_reverse():* 为 x 或 y。 
# scale_*_gradient(), scale_*_gradient2():* 为 color、fill 等。
# scales 包提供了很多现成的设置刻度标签风格的函数。

#1.修改坐标轴刻度及标签
#用 scale_*_continuous()函数修改连续变量坐标轴的刻度和标签:
# 参数 breaks 设置各个刻度的位置;
# 参数 labels 设置各个刻度对应的标签。
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  scale_y_continuous(breaks = seq(15, 40, by = 10),
                     labels = c("一五","二五","三五"))

#用 scale_*_discrete()函数修改离散变量坐标轴的标签: 
ggplot(mpg, aes(x = drv)) +
  geom_bar() + # 条形图
  scale_x_discrete(labels = c("4" = "四驱", "f" = "前驱", "r" = "后驱"))
  
#用 scale_x_date()设置日期刻度，用参数 date_breaks 设置刻度间隔，用 date_labels 
#设置标签的日期格式。借助 scales 包中的函数设置特殊格式，比如百分数函 数(percent)、
#科学记数法函数(scientific)、美元格式函数(dollar)等。
economics

ggplot(tail(economics, 45), aes(date, uempmed / 100)) +
  geom_line() +
  scale_x_date(date_breaks = "6 months", date_labels = "%b%Y") +
  scale_y_continuous(labels = scales::percent)

#2.修改坐标轴标签、图例名及图例位置
#用 labs()函数的参数 x、y，或者函数 xlab()、ylab()，设置 x 轴标签、y 轴标签，
#前面已学过 color 美学，则可以在 labs()函数中使用参数 color 修改颜色的图例名。
#图例位置是在 theme 图层通过参数 legend.position 设置，
#可选取值有“none”“left” “right”“bottom”“top”。
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv)) +
  labs(x = "引擎大小 (L)", y = "高速燃油率 (mpg)", color = "驱动类型") + 
  # 或者 # xlab("引擎大小 (L)") + ylab("高速燃油率 (mpg)")
  theme(legend.position = "top")

#3.设置坐标轴范围
#用 coord_cartesian()函数的参数 xlim 和 ylim, 或者用 xlim()和 ylim()函数，可以
#设置x轴和y轴的范围:
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv)) +
  coord_cartesian(xlim = c(5, 7), ylim = c(10, 30)) 
  # 或者 xlim(5, 7) + ylim(10, 30)

#4.变换坐标轴
#先变换数据再绘图，比如经过对数变换之后，坐标刻度也会进行相应的变换，这会使图形不好理解。
#ggplot2 提供的坐标变换函数 scale_x_log10()等可以变换坐标系，能够在视觉效果相同的情况下，
#继续使用原始数据的坐标刻度:
load("data/gapminder.rda")
p = ggplot(gapminder, aes(gdpPercap, lifeExp)) +
  geom_point() +
  geom_smooth()
p + scale_x_log10(labels = scales::dollar)

p + scale_x_continuous(labels = scales::dollar)

#5.设置图形标题
#用 labs()函数的参数 title、subtitle 和 caption 设置标题、副标题、脚注标题(默
#认右下角)，代码如下:
p = ggplot(mpg, aes(displ, hwy)) +
    geom_point(aes(color = drv)) + geom_smooth(se = FALSE) +
      labs(title = "燃油效率随引擎大小的变化图",
           subtitle = "两座车 (跑车) 因重量小而符合预期", 
           caption = "数据来自fueleconomy.gov")

p
#一部分人习惯图形标题位于顶部左端，如果想改成顶部居中，需要添加 theme 图层专门
p + theme(plot.title = element_text(hjust = 0.5), 
          # 标题居中
          plot.subtitle = element_text(hjust = 0.5))
          
#6.设置 fill 和 color 的颜色
# 数据的某个维度信息可以通过颜色来展示，颜色直接影响图形的美感。我们可以直接使用
# 颜色值来设置颜色，但是更建议使用 RColorBrewer(调色板)或 colorspace 包。
# (1)离散变量
# manual:直接指定分组使用的颜色。
# hue:通过改变色调(hue)、饱和度(chroma)、亮度(luminosity)来调整颜色。  brewer:使用 ColorBrewer 的颜色。
# grey:使用不同程度的灰色。
# 用 scale_*_manual()手动设置颜色，并修改图例及其标签: 
ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  scale_color_manual("驱动方式", # 修改图例名
                     values = c("red", "blue", "green"), 
                     # breaks = c("4", "f", "r"),
                     labels = c("四驱", "前驱", "后驱"))
  
# 用 scale_*_brewer()调用调色板中的颜色:
ggplot(mpg, aes(x = class, fill = class)) +
  geom_bar() +
  scale_fill_brewer(palette = "Dark2") # 使用Dark2调色版

#使用 RColorBrewer::display.brewer.all()函数查看所有可用的调色板;
#使用 hcl_palettes::hcl_palettes(plot = TRUE)函数查看所有可用的颜色空间。

#(2)连续变量
# gradient:设置二色渐变色。 
# gradient2:设置三色渐变色。
# distiller:使用 ColorBrewer 的颜色。
# identity:使用 color 变量对应的颜色，对离散型和连续型都有效。

#用 scale_color_gradient()设置二色渐变色: 
ggplot(mpg, aes(displ, hwy, color = hwy)) +
  geom_point() +
  scale_color_gradient(low = "green", high = "red")

#用scale_*_distiller()调用调色板中的颜色:调用调色板中的颜色:
ggplot(mpg, aes(displ, hwy, color = hwy)) +
  geom_point()  +
  scale_color_distiller(palette = "Set1")

#7.添加文字标注
#ggrepel 包提供了 geom_label_repel()和 geom_text_repel()函数，为图形添加文字标注。
#首先要准备好带标记点的数据，然后增加文字标注的图层，我们需要提供标记点数据，
#以及要标注的文字给 label 美学，若处理的是来自数据的变量，则需要用映射。
library(ggrepel)
best_in_class = mpg %>% # 选取每种车型hwy值最大的样本 group_by(class) %>%
  slice_max(hwy, n = 1)

ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_label_repel(data = best_in_class, aes(label = model))

#若要在图形某坐标位置添加文本注释，则用 annotate()函数，我们需要提供添加文本的
#中心坐标位置和要添加的文字内容:
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  annotate(geom = "text", x = 6, y = 40,
  label = "引擎越大\n燃油效率越高!", size = 4, color = "red")


ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  stat_smooth(method = "lm",
              formula = y ~ splines::bs(x, 3),
              se = FALSE) # 不绘制置信区间

#2.坐标系(coordinate)
#ggplot2 默认坐标系是直角坐标系将 coord_cartesian()，常用的坐标系操作还有以下几种。
#coord_flip():坐标轴翻转，即将 x 轴与 y 轴互换，比如绘制水平条形图。
#coord_fixed():参数 ratio=y/x。
#coord_polar():转化为极坐标系，比如将条形图转为极坐标系即为饼图。
#coord_trans():彻底的坐标变换，不同于 scale_x_log10()等。
#coord_map()和 coord_quickmap():可与 geom_polygon()连用，控制地图的坐 标投影。
#coord_sf():与 geom_sf()连用，用于控制地图的坐标投影。

#翻转坐标轴，从竖直图转换成水平图，代码如下:
ggplot(mpg, aes(class, hwy)) +
  geom_boxplot() + # 箱线图
  coord_flip() # 从竖直图变成水平图
  
#直角坐标下的条形图，转化为极坐标下的风玫瑰图，代码如下:
ggplot(mpg, aes(class, fill = drv)) +
  geom_bar() +
  coord_polar()
  
#3.位置调整(position adjustments)
#通过调用位置调整函数来调整某些图形元素的实际位置，例如条形图中的条形位置调整，
#示例如下:
# position_stack():竖直堆叠
# position_fill():竖直(百分比)堆叠，按比例放缩并保证条形的总高度为 1。 
# position_dodge(), position_dodge2():水平堆叠。

ggplot(mpg, aes(class, fill = drv)) +
geom_bar(position = position_dodge(preserve = "single"))
# geom_bar(position = "dodge")

#散点图中的散点位置调整，可使用以下函数。
# position_nudge():将散点移动固定的偏移量。
# position_jitter():给每个散点增加一点随机噪声，形成抖散图。
# position_jitterdodge():增加一点随机噪声并躲避组内的点，特别用于箱线图和散点图。
ggplot(mpg, aes(displ, hwy)) +
  geom_point(position = "jitter") # 避免有散点重叠

#有时候需要将多个图形排布在画板中，此时借助 patchwork 包更方便。
library(patchwork)
p1 = ggplot(mpg, aes(displ, hwy)) +
  geom_point()
p2 = ggplot(mpg, aes(drv, displ)) +
  geom_boxplot()
p3 = ggplot(mpg, aes(drv)) +
  geom_bar()
p1 | (p2 / p3)



#3.1.5 分面、主题、输出
#1.分面(facet)
#利用分类变量将图形分为若干个“面”(子图)，即对数据分组再分别绘图，该过程称为“分面”
#(1)facet_wrap() 
#封装分面要先生成一维的面板系列，再封装到二维中
#分面形式:~分类变量(关于一个分类变量平面)，~分类变量 1 + 分类变量 2(关于两 个分类变量平面)。
#scales 参数用于设置是否共用坐标刻度，"fixed"(默认)表示共用，"free"表示 不共用，
#也可以用 free_x 和 free_y 单独设置。
#参数 nrow 和 ncol 可设置子图的放置方式。

#一个分类变量分面
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  facet_wrap(~ drv, scales = "free")

#两个分类变量分面
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  facet_wrap(~ drv + cyl)

#(2)facet_grid()
#网格分面可生成二维的面板网格，面板的行与列通过分面变量定义。 
#分面形式:行分类变量 ~ 列分类变量
#网格分面
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  facet_grid(drv ~ cyl)

#2.主题(theme)
#你可以为图形选择不同风格的主题(外观)，ggplot2 提供了 8 套可选主题，如下所示。
# theme_bw()
# theme_light()
# theme_classic()
# theme_gray()(默认) 
# theme_linedraw()
# theme_dark()
# theme_minimal()
# theme_void()
#使用或修改主题，只需要添加主题图层 theme_bw()即可: 
ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  theme_bw()
#如果想使用更多的主题，还可以用 ggthemes 包，其中包含一些顶级期刊专用的绘图主题; 
#当然也可以用 theme()函数定制自己的主题。

#3.输出(output) 
#用ggsave()函数将当前图形保存为想要格式的图形文件，如png, pdf等:
ggsave("my_plot.pdf", width = 8, height = 6, dpi = 300)

# 参数 width 和 height 通常只设置其中一个，另一个自动匹配，以保持原图形宽高比。 
# 最后，再补充一点关于图形中使用中文字体导出到 pdf 等图形文件出现乱码问题的解决办
# 法。
# 之所以出现中文乱码是因为 R 环境只载入了“sans (Arial)”“serif (Times New Roman)”“mono (Courier New)”
# 三种英文字体，没有中文字体可用。
# 
# 解决办法就是从系统字体中载入中文字体，此时用 showtext 包(依赖 sysfonts 包)更简单一些。
# font_paths():查看系统字体路径，Windows 系统默认的路径是 C:\Windows\Fonts。
# font_files():查看系统自带的所有字体文件。
# font_add():从系统字体中载入字体，需提供 family 参数和字体路径。
# 载入字体后，再执行一下 showtext_auto()函数(即自动启用/关闭功能)，就可以使用该字体了。

# ggpplot2 中各种设置主题、文本相关的函数包括*_text()、annotate()等，
# 它们都提供 了 family 参数，设定为和 font_add()中一致的 family 名字即可。

library(showtext)
font_add("heiti", "simhei.ttf")
font_add("kaiti", "simkai.ttf")
showtext_auto()
ggplot(mpg, aes(displ, hwy, color = drv)) +
geom_point() +
theme(axis.title = element_text(family = "heiti"),
      plot.title = element_text(family = "kaiti")) + 
      xlab("发动机排量(L)") +
      ylab("高速里程数(mpg)") + 
      ggtitle("汽车发动机排量与高速里程数") + 
      annotate("text", 5, 35, family = "kaiti", size = 8,
                label = "设置中文字体", color = "red") 

ggsave("images/font_example.pdf", width = 7, height = 4)


#3.2 ggplot2 图形示例
#俗话说，“一图胜千言”，数据可视化能够真实、准确、全面地展示数据信息，
#发现数据中隐含的关系和模式。
#Nathan Yau 将数据可视化的过程总结为如下 4 个思考。 
# 你拥有什么样的数据?
# 你想要表达什么样的数据信息?
# 你会什么样的数据可视化方法?
# 你能从图表中获得什么样的数据信息? 
# 上述思索需要你对数据可视化的图形种类有所了解，本节将图形分为类别比较图、数据关
# 系图、数据分布图、时间序列图、局部整体图、地理空间图和动态交互图。
# 下面将对各类图形 进行概述，选择其中常用的、有代表性的图形进行实例展示，
# 还有一些常用的统计图、探索变量间关系的图，将在第 4 章和第 5 章中展示。
# 另外，ggpubr 包和 ggsci 包提供了很多函数，可以轻松绘制适用于期刊论文发表的图形。
# 读者针对自己的数据进行绘图时，建议首先根据展示目的选择想要绘制的图形，再查阅相关资料，完成相应图形的绘制。
# 《R 语言数据可视化之美:专业图表绘制指南》一书将图形分为类别比较图、数据关系图、 
# 数据分布图、时间序列图、局部整体图。本节沿用这种思路，以方便读者根据图形名称搜索绘图资料。

#3.2.1 类别比较图 
#类别比较图，通常用于展示和比较分类变量或分类变量组合的频数。
#基于表示位置和长度的视觉元素的不同，产生了多种类别比较图，
#两个分类变量的交叉频数可以用热图展示，根据两个分类变量的各水平值组合确定交叉网格，
#其上的频数(或其他数值)对应到颜色深度。邻接矩阵、混淆矩阵和相关系数矩阵也可以用
#热图来可视化展示。
#对 mpg 数据集按车型和驱动方式统计频数，并绘制热图，需要注意别漏下 0 频数:
#此外，ComplexHeatmap 包可绘制更复杂的热图，例如带层次聚类的热图。
df = mpg %>%
  mutate(across(c(class, drv), as.factor)) %>%
  count(class, drv, .drop = FALSE)

df

df %>%
  ggplot(aes(class, drv)) +
  geom_tile(aes(fill = n)) +
  geom_text(aes(label = n)) +
  scale_fill_gradient(low = "white", high = "darkred")

# 3.2.2 数据关系图
# 数据关系图如图主要包括以下类型
# 数据相关性图:展示两个或多个变量之间的关系，比如散点图、气泡图、曲面图等。 
# 数据流向图:展示两个或多个状态或情形之间的流动量或关系强度，比如网络图等。

# 网络图
# 网络图可以可视化实体(个体/事物)间的内部关系，比如社会媒体网络、朋友网络、合作网络、疾病传播网络等。
# 可视化网络图的包有 igraph 以及 tidygraph + ggraph，当然还有更加强大的 visNetwork 包。
# 这里只给一个简单示例:16 个人之间的电话数据。用 visNetwork()函数 实现，需要准备好节点和边的数据。
# 节点数据包括 id(用于边数据)、label(用于图显示)、group(设置分组颜色)、value (权重，即关联节点的大小)等。
# 边数据包括 from(起点)、to(终点)、label(用于图显示)、value(权重，即关联 边的粗细)等。

#金字塔图
pops = read_csv("data/hljPops.csv") %>%
  mutate(Age = as_factor(Age)) %>%
  pivot_longer(-Age, names_to = "性别", values_to = "Pops") pops
  ggplot(pops, aes(x = Age, fill = 性别,y = ifelse(性别 == "男", -Pops, Pops))) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = abs, limits = c(-200,200)) + 
  xlab("年龄段") + 
  ylab("人口数(万)") +
  coord_flip()

  
#3.2.4 时间序列图
#时间序列图如图 3.43 所示，展示数据随时间的变化规律或者趋势。比如，折线图、面积图等。
#折线图与面积图如图 3.44 左图所示，折线图是按 x 从小到大对数据进行排序，
#再用直线依次连接各个散点， 用 geom_line()函数绘制。
#类似的 geom_path()可用于绘制路径图，不是按 x 排序，而是按数据原始顺序用直线依次连接各个散点。
#面积图是在折线图下方再做填充，用 geom_area()函数绘制，如图 3.44 右图所示。 
#绘制折线图和面积图的代码如下:
p1 = ggplot(economics, aes(date, uempmed)) +
geom_line(color = "red")
p2 = ggplot(economics, aes(date, uempmed)) +
geom_area(color = "red", fill = "steelblue")
p1 | p2


#3.2.5 局部整体图
#局部整体图如图 3.45 所示，展示部分与整体的关系，如饼图、树状图等
#这里提供一个绘制饼图的代码模板:
piedat = mpg %>% # 先准备绘制饼图的数据
  group_by(class) %>%
  summarize(n = n(), labels = str_c(round(100 * n / nrow(.), 2), "%"))

piedat

ggplot(piedat, aes(x = "", y = n, fill = class)) +
  geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start = 0) +
  geom_text(aes(label = labels),
  position = position_stack(vjust = 0.5)) +
  theme_void()
  

#3.2.6 地理空间图
#地理空间图是在地图上展示数据关系，即与地理位置信息联系起来绘图，地理位置通常是
#用经度、纬度表示。常见的地理空间图包括普通地图、等值区间地图、等位图、
#带散点/气泡/条 形/饼图/链接线的地图、流量地图、向量地图、道林地图等。
#现在的 GIS 类软件广泛使用简单要素(Simple Features)标准，主要是用二维几何图形
#对象 (点、线、多边形、点族、线族、多边形族等)表示地理矢量数据，
#还可以包含坐标参照系统和用于描述对象的属性(如名称、值、颜色等)。
#sf 包实现了将简单要素表示成 R 中的 data.frame，并提供了一系列处理此类数据的工
#具。在 sf 格式数据框中，属性要素是正常的列，几何要素(geometry)存放为列表列。
#geometry 列是最重要的列，它指定了每个地理区域的空间几何，每个元素都是一个多边形
#族，即包含一个或多个多边形的顶点的数据，它们能确定多边形区域的边界。
#有了 sf 格式的数据，就可以用 geom_sf()和 coord_sf()函数绘制地图，甚至无须设定
#任何参数和美学映射。


#3.2.7 动态交互图
#plotly 包能够在 ggplot2 的基础上生成动态可交互图形。只要对 ggplot2 绘制的图形
#对象嵌套一个 ggplotly()函数，则图形变成可交互状态。当鼠标移动到图形元素上时，
#将自动显示对应的数值。
library(plotly)
load("data/ecostats.rda")
ecostats = ecostats %>%
mutate(Area = case_when(
  Region %in% c("黑龙江","吉林","辽宁") ~ "东北",
  Region %in% c("北京","天津","河北","山西","内蒙古") ~ "华北", 
  Region %in% c("河南","湖北","湖南") ~ "华中",
  Region %in% c("广东","广西","海南") ~ "华南",
  Region %in% c("陕西","甘肃","宁夏","青海","新疆") ~ "西北", 
  Region %in% c("四川","贵州","云南","重庆","西藏") ~ "西南", TRUE ~ "华东"))

p = ecostats %>%
  filter(Year == 2017) %>%
  ggplot(aes(Consumption, Investment, color = Area)) +
  geom_point() +
  theme_bw()
  ggplotly(p)

# gganimate 包是基于 ggplot2 的动态可视化拓展包，能让图形元素随时间等逐帧变化起来，
# 所生成的动态图可导出为.gif 格式。
# 下面绘制一个动态散点图，反映不同地区在 2016 年投资情况与消费水平的变化:

library(gganimate)
ggplot(ecostats, aes(Consumption, Investment, size = Population)) +
  geom_point() +
  geom_point(aes(color = Area)) +
  scale_x_log10() +
  labs(title = "年份: {frame_time}", x = "消费水平", y = "投资") + 
  transition_time(Year)
anim_save("output/ecostats.gif") # 保存为gif文件



#3.3 统计建模技术
#3.3.1 整洁模型结果
# tidyverse 主张以“整洁的”数据框作为输入，但是 lm、nls、t.test、kmeans 等统计模型
# 的输出结果却是“不整洁的”列表。
# broom 包实现将模型输出结果转化为整洁的 tibble，且列名规范一致，方便后续取用。 
# 另外，tibble 与 tidyr 包中的 nest()、unnest()函数以及 purrr 包中的 map_*()系列
# 函数连用，非常便于批量建模和批量整合模型结果。
# broom 包主要提供以下 3 个函数。

# 1.tidy():模型系数估计及其统计量
# 返回结果 tibble 的每一行通常表达的都是具有明确含义的概念，如回归模型的一项、一
# 个统计检验、一个聚类或类。tibble 的各列包括以下内容。
# term:回归或模型中要估计的项。
# estimate:参数估计值。
# statistic:检验统计量。
# p.value:检验统计量的 p 值。
# conf.low、conf.high:estimate 的置信区间边界值。
# df:自由度。 

#2.glance():模型诊断信息
#返回一行的 tibble，各列是模型诊断信息。
#r.squared:R2。
#adj.r.suquared:根据自由度修正的 R2。 
#sigma:残差标准差估计值。
#AIC、BIC:信息准则。

#3.augment():增加预测值列、残差列等
#augment(model, data, newdata):若data参数缺失，则不包含原始数据;
#若设置 了 newdata 参数，则只针对新数据。
#返回结果 tibble 的每一行都对应原始数据或新数据的一行，新增加的列包括以下内容。 
#.fitted:预测值，与原始数据同量纲。
#.resid:残差(真实值减去预测值)。
#.cluster:聚类结果。
#接下来以线性回归模型整洁化结果为例进行演示，其他统计模型、假设检验、K 均值聚类
#等都是类似的。
library(broom)
model = lm(mpg ~ wt, data = mtcars)
model %>%
  tidy()
model %>%
  glance()
model %>%
  augment()

#有了这些模型信息，就可以方便地筛选数据或绘图，绘制线性回归偏差图的代码如下:
model %>% 
  augment() %>%
  ggplot(aes(x = wt, y = mpg)) +
  geom_point() +
  geom_line(aes(y = .fitted), color = "blue") +
  geom_segment(aes(xend = wt, yend = .fitted), color = "red")

#绘制线性回归残差图的代码如下:
model %>% 
  augment() %>%
  ggplot(aes(x = wt, y = .resid)) +
  geom_point() +
  geom_hline(yintercept = 0, color = "blue")


#3.3.2 辅助建模
#modelr 包提供了一系列辅助建模的函数，便于在 tidyverse 框架下辅助建模。 
# 1.resample_*():重抽样 
# 重抽样就是反复从数据集中抽取样本形成若干个数据集副本，用于统计推断或模型性能评
# 估。常用的重抽样方法有留出重抽样(Holdout)，自助重抽样(Bootstrap)、交叉验证重抽样
# (Cross Validation)、置换重抽样(Permutation)。
# resample(data, idx):根据整数向量 idx 从数据集 data 中重抽样。
# resample_partition(data, p):生成一个留出重抽样，即按概率 p 对数据集进行
# 划分，比如划分训练集和测试集。
# resample_bootstrap(data):生成一个 bootstrap 重抽样。
# bootstrap(data, n):生成 n 个 bootstrap 重抽样。
# crossv_kfold(data, k):生成 k 折交叉验证重抽样。
# crossv_loo(data):生成留一交叉验证重抽样。
# crossv_mc(data, n, test):按测试集占比 test，生成 n 对蒙特卡洛交叉验证。
# resample_permutation(data, columns):按列 columns 生成一个置换重抽样。
# permute(data, n, columns):按列 columns 生成 n 个置换重抽样。
#对这些重抽样结果做以下操作。
#为了避免低效操作数据，都保存原数据的指针。
#重抽样数据集都存放在返回结果的列表列，借助 purrr::map 函数便于批量建模。
#对每个重抽样数据集，应用 as.data.frame()/as_tibble()函数可转化成数据框，
#这样一来，数据可不经转化直接应用于模型函数。
#另外，rsample 包提供了创建各种重抽样的函数，可生成便于后续分析的数据对象，更适
#合与机器学习包 tidymodels 连用。

#2.模型性能度量函数
# rmse(model, data):均方根误差。
# mae(model, data):平均绝对误差。
# qae(model, data, probs):分位数绝对误差。 
# mape(model, data):平均绝对百分比误差。
# rsae(model, data):绝对误差相对和。
# mse(model, data):均方误差。
# rsquare(model, data):R2。

#3.生成模型数据的函数
# seq_range(x, n):根据向量 x 值范围生成等间隔序列。
# data_grid(data, f1, f2):生成唯一值的所有组合。
# model_matrix():model.matrix()的包装，用于生成模型(设计)矩阵，特别是
# 用于虚拟变量处理(参见 4.4.3 节)。 

#4.增加预测值列、残差列的函数
#add_predictions()函数 
library(modelr)
set.seed(123)
ex = resample_partition(mtcars, c(test = 0.3, train = 0.7))
mod = lm(mpg ~ wt, data = ex$train)
rmse(mod, ex$test)
mod = lm(mpg ~ wt + cyl + vs, data = mtcars)
data_grid(mtcars, wt = seq_range(wt, 10), cyl, vs) %>%
add_predictions(mod)

#add_ residuals()函数
mtcars[1:4,c(1,2,6,8)] %>%
  add_residuals(mod)
  resid

#最后，再看一个 10 折交叉验证建模的例子。实际上这属于机器学习范畴，但经常有人在
#统计建模时也这么做。
#我们通常将数据集划分为训练集(90%)和测试集(10%)，在训练集上训练一个模型，在测试
#集上评估模型效果。只这样做一轮的话，模型效果可能具有偶然性，对数据集利用得也不够
#充分。k 折交叉验证是克服该缺陷的更好做法，我们以图 3.51 所示的 10 折交叉验证为例进行详解。

#先将数据集随机分成 10 份，分别以其中 1 份为测试集，其余 9 份为训练集，由此组成 10 组数据。
#然后训练 10 次模型，评估 10 次模型效果，取其平均作为最终模型效果。
#下面对mtcars数据集，采用10折交叉验证法构建关于mpg ~ wt的线性回归模型，并根据 rmse 评估每个模型效果。
#先用 crossv_kfold()函数生成 10 折交叉验证的数据:
cv10 = crossv_kfold(mtcars, 10)
cv10
# 结果为 10 行嵌套数据框，这些数据框分别对应交叉组成的 10 组训练集(train)、测试集(test) 数据。
# 接着进行批量建模(详见 3.3.3 节)，与普通的修改列操作是一样的，即(用 map)计算 新列并赋值。
cv10 %>%
  mutate(models = map(train, ~ lm(mpg ~ wt, data = .x)),
         rmse = map2_dbl(models, test, rmse))

#如果要计算最终的平均模型效果，对 rmse 列作汇总均值即可，这里不再详述。



#3.3.3 批量建模
#有时候需要对数据做分组，批量地对每个分组建立同样的模型，并提取和使用批量的模型结果，
#这就是批量建模。
#批量建模通常是作为探索性数据分析的一种手段，批量建立简单模型以理解复杂的数据集。 
#批量建模的“笨方法”是手动写 for 循环实现，再手动提取、合并模型结果。
#本节要介绍的是 tidyverse 中的两种优雅而简洁的做法。
#用嵌套数据框 + purrr::map 实现。
#用 dplyr 包的 rowwise 技术，具有异曲同工之妙
#下面用 ecostats 数据集演示，整理自国家统计局网站，包含 2001—2017 年我国不同地区
#的人口、居民消费水平、人均 GDP 等

#1.利用嵌套数据框 + purrr::map 先来介绍一个概念:嵌套数据框(列表列)
load("data/ecostats.rda")
ecostats
#当我们想要对各地区的数据做重复操作，需要先对数据框用 group_nest()针对分组变量
#Region 做分组嵌套，就能得到嵌套数据框，每组数据作为数据框嵌套到列表列 data。
#嵌套数据框 的每一行是一个分组，表示一个地区的整个时间跨度内的所有观测，
#而不是某个单独时间点的观测

by_region = ecostats %>%
  group_nest(Region)

by_region
by_region$data[[1]] # 查看列表列的第1个元素的内容 
unnest(by_region, data) # 解除嵌套, 还原到原数据


#嵌套数据框与普通数据框的操作一样，比如用 filter()函数筛选行，用 mutate()函数修改列。
#这里对嵌套的 data 列，用 mutate()函数修改该列，增加一个模型列 model，
#以存放用该行的 data 数据拟合的线性回归模型，即分别对每个地区拟合人均消费水平对
#人均 GDP 的线性回归模型，并保存到 model 列。这就实现了批量建模:
by_region = by_region %>%
  mutate(model = map(data, ~ lm(Consumption ~ gdpPercap, .x)))
by_region
#继续用 mutate()函数修改列，借助 map_*函数从模型列、数据列计算均方根误差、R2、 
#斜率、p 值:
library(modelr)
by_region %>%
  mutate(rmse = map2_dbl(model, data, rmse),
         rsq = map2_dbl(model, data, rsquare),
         slope = map_dbl(model, ~ coef(.x)[[2]]),
         pval = map_dbl(model, ~ glance(.x)$p.value))

#也可以配合 broom 包的函数 tidy()、glance()、augment()批量、整洁地提取模型结果，
#这些结果仍是嵌套的列表列，若要完整地显示出来，需要借助 unnest()函数解除嵌套

#批量提取模型系数估计及其统计量，代码如下:
by_region %>%
  mutate(result = map(model, tidy)) %>%
  select(Region, result) %>%
  unnest(result)

#批量提取模型诊断信息，代码如下:
by_region %>%
  mutate(result = map(model, glance)) %>%
  select(Region, result) %>%
  unnest(result)

#批量增加预测值列、残差列等，代码如下:
by_region %>%
  mutate(result = map(model, augment)) %>%
  select(Region, result) %>%
  unnest(result)

#2.利用 dplyr 包的 rowwise 技术
#dplyr 包的 rowwise(按行方式)可以理解为一种特殊的分组:将每一行作为一组
#若对 ecostats 数据框用 nest_by()函数做嵌套就得到 rowwise 类型的嵌套数据框:
by_region = ecostats %>%
  nest_by(Region)
  by_region

#注意，这里多了Rowwise: Region信息
#一个地区的数据占一行，rowwise 式的逻辑，就是按行操作数据，正好适合逐行地对每个
#嵌套的数据框建模和提取模型信息。
#这些操作是与 mutate()和 summarise()函数连用来实现，前者会保持 rowwise 模式，
#但需要计算结果的行数保持不变;后者相当于对每行结果做汇总，结果行数可变(变多)，
#不再具有 rowwise 模式
by_region = by_region %>%
  mutate(model = list(lm(Consumption ~ gdpPercap, data)))
by_region

#下面结果与前文相同，故略过。
#然后直接用 mutate()函数修改列，从模型列、数据列计算均方根误差、R2、斜率、p 值: 
by_region %>%
  mutate(rmse = rmse(model, data),
         rsq = rsquare(model, data),
         slope = coef(model)[[2]],
         pval = glance(model)$p.value)

#也可以配合 broom 包的函数 tidy()、glance()、augment()批量、整洁地提取模型结果。
#批量提取模型系数估计及其统计量，代码如下:
by_region %>%
  summarise(tidy(model))
#批量提取模型诊断信息，代码如下:
by_region %>%
  summarise(glance(model))
#批量增加预测值列、残差列等，代码如下:
by_region %>%
  summarise(augment(model))
#rowwise 化方法的代码更简洁，但速度不如“嵌套数据框 + purrr::map”快。 

#3.(分组)滚动回归 
#金融时间序列数据分析中常用到滚动回归，这是滑窗迭代与批量建模的结合，即对数据框
#按时间窗口滑动，在各个滑动窗口批量地构建回归模型并提取模型结果。
#滚动回归借助 slider 包很容易实现。
#下面看一个更进一步的案例:分组滚动回归。 
#stocks 股票数据是整洁的长表，但这里要做股票之间的线性回归，先进行长表变宽表，
#再根据日期列计算一个 season 列用于分组:
library(lubridate)
library(slider)
load("data/stocks.rda")
df = stocks %>%
  pivot_wider(names_from = Stock, values_from = Close) %>%
  mutate(season = quarter(Date))
df

#如图 3.53 所示，通过绘图结果可以看出，Amazon 与 Google 股票是大致符合线性关系的:
df %>% 
  ggplot(aes(Amazon, Google)) +
  geom_line(color = "steelblue", size = 1.1)

#因此，我们认为对这两只股票做滚动线性回归是合理的。为了演示分组滚动回归，我们再
#加入分组操作逻辑，分别对每个季度做五步滚动线性回归，这当然也离不开 slide()滑窗迭代
df_roll = df %>%
  group_by(season) %>%
  mutate(models = slide(cur_data(), ~ lm(Google ~ Amazon, .x),
                        .before = 2, .after = 2, .complete = TRUE)) %>%
  ungroup()

df_roll


#(1)slide()函数的第 1 个参数 cur_data()是专门与 group_by()函数搭配使用的，代表