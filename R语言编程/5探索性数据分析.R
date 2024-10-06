#传统的统计分析通常是先假设样本服从某种分布，然后将数据代入假设模型再做分析。但
#由于多数数据并不能满足假设的分布，因此，传统统计分析结果常常不能让人满意。
#而探索性数据分析(Exploratory Data Analysis, EDA)更注重数据的真实分布，
#通过可视化、 变换、建模来探索数据，发现数据中隐含的规律，从而得到启发找到适合
#数据的模型。
#探索性数据分析是一个迭代循环的过程，涉及以下步骤:
#拟定关于数据的问题;
#通过对数据做可视化、变换和建模得到问题答案;
#利用得到的结果，重新改进问题，并(或)拟定新的问题。
#近似地回答一个正确的问题(通常是模糊的问题)，要比精确地回答一个错误问题(通常是清晰的问题)， 要好得多。
#在探索性数据分析的开始阶段，你应该随意地研究你所能想到的各种想法。有些想法将得
#到成功的结果，有些想法将走进死胡同。随着探索的推进，你将到达那些包含有效信息的位置，
#深入研究并得到你想要的结果。
#探索性数据分析通常包括数据清洗、数据描述与汇总、数据变换、探索变量间的关系等。
#希望读者能够通过探索性数据分析培养对数据的直觉。
#数据清洗、特征工程属于机器学习中的数据预处理环节，R 机器学习框架 tidymodels 下 
#的 recipes 包，以及 mlr3verse 下的 mlr3pipelines 包都能更系统方便地实现，
#但也更抽象，本节暂且不用它们实现。


#5.1 数据清洗
#数据模型结果的好坏很大程度上依赖于数据质量，很多数据集存在数据缺失、数据格式不统一、
#数据错误等情况，这就需要做数据清洗。
#数据清洗通常包括缺失值处理、数据去重、异常值处理、逻辑错误检测、数据均衡检测、 
#处理不一致数据、相关性分析(剔除与问题不相关的冗余变量)、
#数据变换(标准/归一化、线性 化、正态化等)。
#数据清洗常常占据了数据挖掘或机器学习的 70%~80%的工作量。
#5.1.1 缺失值
#R 中的缺失值用 NA 表示，NA 是有值且占位的，只是该值是缺失值。NULL 表示空值，不知
#道是否有值且不占位。
#也要注意有的数据因人为记录的原因，可能会用特殊值或特殊符号代替缺失值，这样的值
#首先要替换成 NA，可用 naniar 包中的 replace_with_na()函数实现，例如:
replace_with_na(df, replace = list(x = 9999))
#按 R 的语法规则，NA 具有“传染性”，即有 NA 参与的计算，结果也是 NA:
mean(c(1,2,NA,4))
#所以很多 R 函数都带有参数 na.rm，用于设置在计算时是否移除 NA: 
mean(c(1,2,NA,4), na.rm = TRUE)
#本节主要介绍用 naniar 包探索缺失值，用 simputation 和 imputeTS 包插补缺失值。
#1.探索缺失值 
#(1)缺失模式
#缺失模式用于描述缺失值与观测变量间可能的关系。从缺失值的分布来讲，缺失值可以分
#为以下几种类型。
#完全随机缺失(MCAR):某变量缺失值的出现完全是随机事件，与该变量自身无关，
#也与其他变量无关。
#随机缺失(MAR):某变量出现缺失值的可能性，与该变量自身无关，但与某些变量有关。 
#非随机缺失(MNAR):某变量出现缺失值的可能性只与自身有关。
#若数据是 MCAR 或 MAR，则可以用相应的插补方法来处理缺失值;
#若数据是 MNAR，则 问题比较严重，需要去检查数据的收集过程并试着理解数据为什么会丢失。
#naniar 包开发版提供了 mcar_test()函数对数据进行 Little’s MCAR 检验: 
library(naniar)
mcar_test(airquality)
#在以上结果中，P 值 = 0.00142 < 0.05，因此拒绝原假设，故该数据不是 MCAR
#对于探索 MAR，可以通过函数 vis_miss()可视化整个数据框，以提供数据缺失的汇总信息:
vis_miss(airquality)
#可见，变量 Ozone 和 Solar.R 有最多的缺失值，其他变量基本没有缺失值。 
#(2)缺失值统计
#获取缺失数与缺失比
n_miss(airquality) # 缺失样本的个数
n_complete(airquality)  # 完整样本的个数 
prop_miss_case(airquality) # 缺失样本占比
prop_miss_var(airquality) # 缺失变量占比
 
#注:上述函数也接收向量，即判断数据框的某列。 
# 样本(行)缺失汇总
miss_case_summary(airquality) # 每行缺失情况排序 
#说明:例如第 5 行缺失 2 个，缺失比例为 33.3%。
miss_case_table(airquality) # 行缺失汇总表 

#说明:例如缺失 0 个值的行有 111 个，占比为 72.5%。 
#变量(列)缺失汇总
miss_var_summary(airquality) # 每个变量缺失情况排序
miss_var_table(airquality) # 变量缺失汇总表

#注 1:上述缺失汇总函数，还可以与 group_by()连用，用于探索分组缺失情况。 
#注 2:上述缺失汇总函数，都有对应的可视化函数，例如: gg_miss_var(airquality)
#(3)对比缺失与非缺失数据
#这里需要借助一个工具— 影子矩阵。该矩阵与数据集维数相同，用于标记各个数据是否
#缺失，若缺失则表示为 NA，若不缺失则表示为!NA。
#用函数 bind_shadow()将影子矩阵按列合并到数据集，就可以分组汇总或绘图，以对比
#缺失数据与非缺失数据，例如:
aq_shadow = bind_shadow(airquality)
aq_shadow
#根据 Ozone 是否缺失，计算 Solar.R 的均值、标准差、方差、最小值和最大值，代码 如下:
aq_shadow %>%
  group_by(Ozone_NA) %>%
  summarise(across("Solar.R",list(mean, sd, var, min, max), na.rm = TRUE))

#根据 Ozone 是否缺失，绘制温度的分布图，代码如下:
aq_shadow %>%
  ggplot(aes(Temp, color = Ozone_NA)) +
  geom_density()

#2.插补缺失值
#若样本数据足够，缺失样本比例较小，可以直接剔除包含 NA 的样本，代码如下:
na.omit(df)
#若想只剔除某些列包含 NA 的行，代码如下: 
drop_na(df, <tidy-select>)
#若想只剔除包含较多 NA 的行或列，代码如下:
# 删除缺失超过60%的行 
df %>%
  filter(pmap_lgl(., ~ mean(is.na(c(...))) < 0.6)) # 删除缺失超过60%的列
df %>%
  select(where(~ mean(is.na(.x)) < 0.6))
#(1)单重插补
#simputation 包提供了许多常用的单重插补方法，每种方法都具有相似且简单的接口，
#目前支持以下情形。
#基于模型插补(可选增加随机误差):可以使用线性回归、稳健线性回归、岭回归/弹性
#网回归/Lasso 回归、CART(决策树)、随机森林等模型。
#多变量插补:基于期望最大算法插补、缺失森林(迭代的随机森林插补)。
#投票插补(包括各种投票池设定):k近邻(基于gower距离)、顺序hotdeck1(LOCF、NOCB)、
  #随机 hotdeck、预测均值匹配。
#其他:(逐组)中位数插补(可选随机误差)、代理插补(复制另一个变量或使用简单变换来计
  #算插补值)、用训练好的模型进行插补。

#想要可视化查看插补效果，可以再结合 naniar 包。
#simputation 包提供了一种通用的插补语法:
#  impute_<模型>(dat, formula, [模型设定选项])
#返回结果是经过插补的 dat 数据框，formula 用于设定插补公式，其一般结构如下: 
#IMPUTED ~ MODEL_SPECIFICATION [| GROUPING]
#其中，IMPUTED 为要插补的变量，MODEL_SPECIFICATION 为模型对象，[| GROUPING] 为可选项，
#该可选项可设置分组变量，一旦设置将分别对每组数据进行评估模型和插补
#下面列出常用的一些插补方法及代码实现。
#用均值插补或中位数插补，适合连续变量，例如分组均值插补或中位数插补:
airquality %>%
  group_by(Month) %>%
  mutate(Ozone = naniar::impute_mean(Ozone))
impute_median(airquality, Ozone ~ Month)
#用众数插补，适合分类变量使用。由于 Base R 没有提供现成函数计算众数，可以用 rstatix 
#包中的 get_mode()函数计算每一列的众数替换该列的缺失值，若某列有多个众数，则选取第1个
#下面是对所选分类变量做众数插补的基本语法:
df %>%
  select(<tidy-select>) %>% # 选择要插补的分类变量列
  map_dfc(~ replace_na(.x, rstatix::get_mode(.x)[1]))

#用线性回归模型插补步骤如下:先根据非缺失数据，以插补变量为因变量，其他相关变
#量为自变量，拟合线性回归模型，进而计算预测值并作为缺失值的插补值。
impute_lm(airquality, Ozone ~ Solar.R + Wind + Temp,
          add_residual = "normal") # 添加随机误差
#用其他模型插补(需要相应的包)，用法完全类似，具体如下
#impute_rlm():用稳健线性回归模型插补
#impute_en():用正则化线性回归模型插补
#impute_knn():用k近邻模型插补，可设置邻居数参数k
#impute_cart():用决策树模型插补，可设置复杂度参数cp
#impute_rf():用随机森林模型插补，可设置复杂度参数cp
#impute_mf():用缺失森林模型插补
#impute_em():用期望最大算法插补
#下面以决策树算法插补为例，并可视化查看插补效果
library(simputation) # 单重插补 
airquality %>%
  bind_shadow() %>% 
    as.data.frame() %>%
    impute_cart(Ozone ~ Solar.R + Wind + Temp) %>%
    add_label_shadow() %>%
    ggplot(aes(Solar.R, Ozone, color = any_missing)) +
    geom_point() +
    theme(legend.position = "top")

#注意，simputation 包只支持 data.frame, 不支持 tibble，因此其中的 as.data. frame()不能省。
#另外，还有代理插补函数 impute_proxy()可以自定义插补公式，调用 VIM 包后端进行 
#hotdeck 插补 impute_shd()，请参阅对应的包文档。

#(2)多重插补 
#前面的插补是单重插补，就是只插补一次。而多重插补是插补多次，涉及以下内容:
#将缺失数据集复制几个副本
#对每个副本数据集进行缺失值插补
#对这些插补数据集进行评估整合得到最终完整数据集
#先用 mice 包的 mice()函数实现多重插补，代码如下:
#设置参数 m 生成几个数据集副本;maxit 设置在每个插补数据集上的最大迭代次数;
#method 设置插补方法，针对连续、二分类和多分类变量的默认方法分别是 pmm、logreg 和 polyreg， 
#更多插补方法以及更多参数可查阅帮助文档
#再用 complete()函数获取经多重插补并整合的完整数据: aq_dat = mice::complete(aq_imp)
#另外，mice 包还提供了函数 with()在每个插补数据集上进行建模分析，
#pool()函数用 于组合各个建模分析结果。具体使用方法请参阅 mice 包相关的文档。

#(3)插值法插补
#imputeTS 包实现了一系列插补和可视化时间序列数据的方法，包括插值法、时间序列分
#析算法等
#函数 na_interpolation()可实现插值法插补，其参数 option 用于设置插值算法，例
#如 linear(线性)、spline(样条)、stine(Stineman)。 下面用样条插值法插补自带数据 
#tsAirgap 的缺失值，并对比插补值与真实值:
#其他插补函数还有 na_kalman()(Kalman 光滑)、na_ma()(指数移动平均)、
#na_seadec() (季节分解)等，请参阅对应的包文档
library(mice) # 多重插补
aq_imp = mice(airquality, m = 5, maxit = 10, method = "pmm",
              seed = 1, print = FALSE) # 设置种子,不输出过程
library(imputeTS) # 插补时间序列
imp = na_interpolation(tsAirgap, option = "spline") 
ggplot_na_imputations(tsAirgap, imp, tsAirgapComplete)

#5.1.2 异常值
#异常值是指与其他值或其他观测相距较远的值或观测，即与其他数据点有显著差异的数据点。
#异常值会极大地影响模型的效果。
#数据预处理包括异常值的检测与处理(直接剔除或替换为 NA 再插补)。另外，异常值检测
#也可能是研究目的，例如识别数据造假、交易异常等。
#1.单变量的异常值 
#(1)标准差法
#若数据近似正态分布，则大约 68%的数据落在均值的 1 个标准差之内，大约 95%落在 2
#个标准差之内，而大约 99.7%落在 3 个标准差之内。如果数据点落在 3 倍标准差之外，
#则认为是异 常值。
#(2)百分位数法
#基于百分位数，所有落在 2.5 和 97.5 百分位数(也可以是其他百分位数)之外的数据都被
#认为是异常值
#(3)箱线图法
#箱线图的主要应用之一就是识别异常值。以数据的上下四分位数(Q1 和 Q3)为界画一个
#矩形盒子(中间 50%的数据落在盒内)，盒长为 IQR = Q3 − Q1，默认盒须不超过盒长的 1.5 倍， 
#之外的点认为是异常值。
#自编函数实现上述 3 种识别异常值的方法，代码如下: 

# univ_outliers = function(x, method = "boxplot", k = NULL,
#                          coef = NULL, lp = NULL, up = NULL) {
# switch(method,
#    "sd" = {
#      if(is.null(k)) k = 3
#      mu = mean(x, na.rm = TRUE)
#      sd = sd(x, na.rm = TRUE)
#      LL = mu - k * sd
#      UL = mu + k * sd},
#    "boxplot" = {
#      if(is.null(coef)) coef = 1.5
#      Q1 = quantile(x, 0.25, na.rm = TRUE)
#      Q3 = quantile(x, 0.75, na.rm = TRUE)
#      iqr = Q3 - Q1
#      coef = NULL, lp = NULL, up = NULL) 


# 选择LOF值最大的5个索引, 认为是异常样本 order(lofs, decreasing = TRUE)[1:5]

#(2)基于聚类算法
#通过把数据聚成类，可以将那些不属于任何一类的数据作为异常值。
#DMwR2 包提供了 outliers.ranking()函数，基于层次聚类来计算异常值的概率及排名，
#具体是根据聚合层次聚类过程的各个样本的合并路径来获得排名。
rlt = outliers.ranking(iris[,1:4])

#我们也可以借助其他聚类算法包(dbscan 和 stats)做聚类分析，再进一步筛选出异常值:
#基于密度的聚类 DBSCAN，如果对象在稠密区域紧密相连，则被分组到一类;那些不会
#被分到任何一类的对象就是异常值;
#基于 k-means 聚类，围绕最近的聚类中心，将数据分成 k 组，再计算每个样本到聚类
#中心的距离(或相似性)，并选择距离最大的若干样本作为异常值。

#(3)基于模型的异常值 在对回归模型做模型诊断时会做强影响分析:
#通常回归模型具有一定的稳定性，若加入和移出某个样本对模型有巨大影响，则该样本是
#应该剔除的异常值。
#度量这种强影响的指标如下所示。
#Cook’s 距离:cooks.distance(model)。
#Leverage 值:hatvalues(model)。
#或者用 influence.measures(model)直接计算包括二者在内的 4 个强影响度量值
#另外，car 包提供了 Bonferroni 异常值检验函数 outlierTest(model)，支持线性回归、
#广义线性回归、线性混合模型，使用方法如下所示
mod = lm(mpg ~ wt, mtcars)
car::outlierTest(mod)

#结果表明，mtcars数据集中行名为Fiat 128的样本是异常值。 
#(4)随机森林法检测异常值
#相当于是单变量标准差法异常检测的多变量扩展。单变量标准差法是根据偏离全局均值多
#少判定异常值，而随机森林法是基于随机森林模型预测值计算的条件偏离(异常值)得分判定 异常值。
#变量 j 的第 i 个观测值 xij 的异常值得分如下:

#其中，predij 为第 j 个随机森林模型对 xij 的“袋外”预测值，该随机森林模型的均方根误差
#为 rmsej。若|sij|大于某设定阈值 L，则判断为异常值。这样识别出来的异常值，可以用基于
#非异常值数据预测的均值替换。
#每个数值变量都基于其他变量做随机森林回归，若观测值与“袋外”预测值的标准化绝对

#偏差大于“袋外”预测值的 RMSE 的 3 倍，则认为该观测值是异常值。
#这样识别出来的异常值， 可以用非异常值预测的均值替换。
#该方法用 outForest 包中的 outForest()函数实现，基本格式为: 
outForest(data, formula, replace, ...)
#data 为数据框。其中 formula 用于设置模型公式，默认为.~.，表示用右侧所有变量检测
#左侧所有数值变量。replace 用于设置如何替换异常值，可选"pmm""predictions""NA" "no"，
#插补值是基于 missRanger::missRaner()生成的预测值。其他参数可设置保留多少 异常值，
#控制随机森林的复杂度1等，详细信息请查阅包文档。
#代码示例如下:
library(outForest)
plot(out, what = "scores") # 绘制各变量异常值得分图 结果如图 5.6 所示
#用 Data(out)可以获取替换异常值之后的数据。
#rstatix 包提供了 mahalanobis_distance()函数可以计算多变量的马氏距离，进而标记基于
#马氏距离的异常值;anomalize 包可以检验时间序列的异常值;outliers 包提供了
#可用来提速的随机森林复杂度参数如 num.trees、mtry、sample.fraction、max.depth、min.node.size。 
# 用iris数据随机生成若干异常值
irisWithOut = generateOutliers(iris, p = 0.02, seed = 123) 
# 检测除Sepal.Length外数值变量异常值, 异常值数设为3
out = outForest(irisWithOut, . - Sepal.Length ~ .,
              max_n_outliers = 3, verbose = 0) outliers(out) 
# 查看异常值及相关信息

#5.2 特征工程
#自变量通常称为特征，特征工程(Feature Engineering)就是发现或构建对因变量有明显影响的特征，
#具体来说是将原始特征转化成更方便表达问题本质的特征的过程，将这些特征运用到预测模型
#中能提高对不可见数据的模型预测精度。
#5.2.1 特征缩放
#因为不同数值型特征的数据量纲可能相差多个数量级，这对很多数据模型会有很大影响， 
#所以有必要做归一化处理，就是将列或行对齐并将方向转为一致(把负向指标变成正向指标)。
#1.标准化
#标准化也称为 z 标准化，将数据变成均值为 0，标准差为 1:
scale(x) # 标准化 
scale(x, scale = FALSE) # 中心化: 减去均值
#其中，μ 为均值，σ 为标准差。z 值反映了该值偏离均值的标准差的倍数。
#注意:中心化后，0 就代表均值，更方便模型解释。

#2.归一化
#归一化是将数据线性放缩到[0,1]，一般还需要同时考虑指标一致化，
#将正向指标(值越大越好)和负向指标(值越小越好)都变成正向
rescale = function(x, type = "pos", a = 0, b = 1) {
  rng = range(x, na.rm = TRUE)
  switch (type,
          "pos" = (b - a) * (x - rng[1]) / (rng[2] - rng[1]) + a,
          "neg" = (b - a) * (rng[2] - x) / (rng[2] - rng[1]) + a)
}

as_tibble(iris) %>% # 将所有数值列归一化到[0,100] 
  mutate(across(where(is.numeric), rescale, b = 100))

#3.行规范化
#行规范化常用于文本数据或聚类算法，用于保证每行具有单位范数，即每行的向量“长度” 相同。
#想象一下，在 m 个特征的情况下，每行数据都是 m 维空间中的一个点，做行规范化能让
#这些点都落在单位球面上(即任意点到原点的距离均为 1)。
#行规范化一般采用 L2 范数:
pmap_dfr(~ c(...) / norm(c(...), "2"))

#4.数据平滑
#若数据噪声太多，通常就需要做数据平滑。最简单的数据平滑方法是移动平均，即用一定
#宽度的小窗口(比如五点平滑，用前两点/自身/后两点，共五点平均值代替自身因变量值)
#滑过曲线，把曲线的毛刺尖峰抹掉，这能在一定程度上去掉噪声还原原本曲线
#窗口宽度越大，平滑的效果越明显。
library(slider)
library(patchwork)
p1 = economics %>%
  ggplot(aes(date, uempmed)) +
  geom_line()
p2 = economics %>% # 做五点移动平均
  mutate(uempmed = slide_dbl(uempmed, mean, .before = 2, .after = 2)) %>%
  ggplot(aes(date, uempmed)) +
  geom_line()
p1 | p2

#另外，自带的 lowess()函数实现了局部加权多项式回归平滑。其他平滑方法还有指数平
#滑、滤波、光滑样条等


#5.2.2 特征变换
#1.非线性特征
#对于数值特征 x1、x2 等，我们可以创建更多的多项式项特征，例如 x1^2, x1 x2, x2^2， 
#这相当于是用自变量的更高阶泰勒公式去逼近因变量。
#在 4.4.3 节关于多元线性回归的实例中，我们已经介绍了如何借助 I()、poly()和 mpoly() 
#生成多项式项以及加入回归模型公式。
#这里再给出一种基于 recipes 包的实现，整体上按照是管道流进行操作。
#recipe():准备数据和模型变量
#step_poly():通过特征工程步构建单变量的多项式特征，参数 degree 可设置多项式次数，
#默认是生成正交多项式特征，若要生成原始特征，需要设置raw = TRUE
#prep():用数据估计特征工程步参数
#bake():默认应用到新数据，new_data = NULL 表示将特征工程应用到原数据
library(tidymodels)
recipe(hwy ~ displ + cty, data = mpg) %>%
  step_poly(all_predictors(), degree = 2, options = list(raw = TRUE)) %>%
  prep() %>%
  bake(new_data = NULL)
#也可以构建其他非线性特征以及样条特征、广义加法模型特征等。另外，文本数据有专用
#的文本特征(词袋、TF-IDF 等)

#2.正态性变换
#对数变换或幂变换
#对于方差逐渐变大的异方差的时间序列数据或右偏分布的数据，可以尝试做对数变换或开
#平方变换，以稳定方差和变成正态分布:
#以King Country的房价数据为例，对右偏分布的数据做对数变换后变成近似正态分布，代
#码如下:
df = mlr3data::kc_housing
p1 = ggplot(df, aes(price)) +
  geom_histogram()
p2 = ggplot(df, aes(log10(price))) +
  geom_histogram()
p1 | p2

#对数变换特别有用，因为具有可解释性:对数值的变化是原始尺度上的相对变化(百分比)。
#若使用以 10 为底的对数，则对数刻度上的值每增加 1 对应原始刻度上的值乘以 10。 
#注意，原始数据若存在零或负值，则不能取对数或开根号，解决办法是做平移，具体公式
#Box-Cox 变换是更神奇的正态性变换，用最大似然估计选择最优的  值，让非负的非正态
#数据变成正态数据
#若数据包含 0 或负数，则 Box-Cox 变换不再适用，可以改用相同原理的 Yeo-Johnson 变换:
#用 bestNormalize 包中的 boxcox()和 yeojohnson()函数，可以实现这两种变换及其逆变换，
#代码如下:
library(bestNormalize)
x = rgamma(100, 1, 1)
yj_obj = yeojohnson(x)
yj_obj$lambda # 最优lambda

p = predict(yj_obj) # 变换 
x2 = predict(yj_obj, newdata = p, inverse = TRUE) # 逆变换

#3.连续变量离散化
#在统计和机器学习中，有时需要将连续变量转化为离散变量，称为连续变量离散化或分箱，
#该方法常用于银行风控建模，特别是基于线性回归或 Logistic 回归模型进行建模
#分箱的好处如下
#使结果更便于分析和解释。比如，年龄从中年到老年，患高血压比例总体增加 25%，而
# 年龄每增加一岁，患高血压比例不一定有显著变化。
#将自变量与因变量间非线性的潜在的关系，转化为简单的线性关系，即简化模型。
#当然，分箱也可能带来问题，例如简化的模型关系可能与潜在的模型关系不一致(甚至可能是错误的模型关系)，
#删除数据中的细微差别，切分点可能没有实际意义。
#rbin 包提供了简单的分箱方法，如下所示
#rbin_manual()函数用于自定义分箱，手动指定切分点(左闭右开)
#rbin_equal_length()函数用于等宽分箱
#rbin_equal_freq()函数用于等频分箱
#rbin_quantiles()函数用于分位数分箱
#rbin_winsorize()函数用于缩尾分箱，不受异常值影响
#这些函数返回分箱结果的汇总统计以及 WOE、熵和信息值指标，用 rbin_create()函数
#可以进一步创建虚拟变量，代码如下。
library(rbin)
df = readxl::read_xlsx("data/hyper.xlsx")
bins = df %>%
  rbin_equal_length(hyper, age, bins = 3)
rbin_create(df, age, bins) %>% 
  head(3)

#其他基于模型的分箱方法还有基于 k-means 聚类、决策树、ROC 曲线、广义可加模型和
#最大秩统计量等的分箱方法
#另外，分类特征在用于回归建模或机器学习模型之前，经常需要做重新编码，即转化虚拟
#变量(参见 4.4.3 节)、效应编码等

#5.2.3 特征降维
#有时数据集可能包含过多特征，甚至是冗余特征，我们可以用降维技术进压缩特征，但这
#样通常会降低模型性能
#最常用的特征降维方法是主成分分析(PCA)，该方法利用协方差矩阵的特征值分解原理， 
#实现多个特征向少量综合特征(称为主成分)的转化，每个主成分都是多个原始特征的线性组
#合，且各个主成分之间互不相关，第一主成分用于解释数据变异(方差)最大的，第二主成分
#用于解释数据变异(方差)是次大的，依此类推
#若将 n 个特征转化为 n 个主成分，则会保留原始数据 100%的信息，但这就失去了降维的
#意义。所以一般是只选择前若干个主成分，一般原则是选择保留 85%以上信息的主成分
#用 recipes 包实现特征降维，关键步骤是特征工程步骤 step_pca(), 参数 threshold 
#设置保留信息的阈值，或者用参数 num_comp 设置保留主成分个数。
#以 iris 为例，对于所关注的 4 个数值型特征只提取前两个主成分就足以保留 85%以上的
#原始数据信息
recipe(~ ., data = iris) %>%
  step_normalize(all_numeric()) %>%
  step_pca(all_numeric(), threshold = 0.85) %>%
  prep() %>%
  bake(new_data = NULL)
#其他特征降维的方法，还有核主成分分析、独立成分分析(ICA)、多维尺度等。 

#5.3 探索变量间的关系
#数据中的变量值得关注，主要包括变量自身的变化(取常值的变量毫无价值)，以及变量与
#变量之间的协变化。描述统计相当于是探索单个变量自身的变化。比如，连续变量可以用
#均值等汇总统计量、 直方图、箱线图探索其分布;离散变量可以用频率表、条形图等探索
#其分布。
#探索性数据分析的另一项重要内容就是探索变量间的关系或者叫作探索协变化。协变化是
#两个或多个变量的值以一种相关的方式一起变化。识别出协变化的最好方式是将两个或多
#个变 量的关系可视化，当然也要区分变量是分类变量还是连续变量。
#5.3.1 两个分类变量
#探索两个分类变量的常用方法如下
#可视化:复式条形图、堆叠条形图
#描述统计量:交叉表(参见 4.1.3 节)
#Cramer’s V 统计量:rstatix::cramer_v()
#假设检验:检验两个比例的差、卡方独立性检验
#用可视化方法探索分析的代码如下:
titanic = read_rds("data/titanic.rds")
titanic %>%
  ggplot(aes(Pclass, fill = Survived)) +
  geom_bar(position = "dodge")

#用 Cramer’s V 检验法探索分析的代码如下: 
library(rstatix)
tbl = table(titanic$Pclass, titanic$Survived) 
cramer_v(tbl) # Cramer'V检验
# 用比例检验法探索分析的代码如下:
prop_test(tbl) # 比例检验
# 用卡方检验法探索分析的代码如下:
chisq_test(tbl)
# Cramer’V 统计量是修正版本的系数，一般法则是
# 0.3 ，代表很少或没有相关性;
# 0.3≤≤0.7代表有弱相关性;
# 0.7代表有强相关性

#5.3.2 分类变量与连续变量
# 探索分类变量与连续变量的常用方法如下
# 可视化:按分类变量分组的箱线图、直方图、概率密度曲线
# 描述统计:按分类变量分组汇总
# 比较均值的假设检验:t 检验、方差分析、Wilcoxon 秩和检验等
#用可视化方法探索分析并生成概率密度曲线的代码如下:
mpg %>%
  ggplot(aes(displ, color = drv)) +
    geom_density() # 概率密度曲线

#用描述统计法探索分析并进行分组汇总的代码如下:
mpg %>%
  group_by(drv) %>%
  get_summary_stats(displ, type = "five_number") # 五数汇总

#用方差分析法探索分析的代码如下:
mpg %>%
  anova_test(displ ~ drv)

#5.3.3 两个连续变量
#探索两个连续变量的常用方法如下。
#可视化:散点图(或加光滑曲线)、折线图，3 个连续变量可用气泡图。 
#线性相关系数:协方差能反映两个变量的影响关系，公式如下:

#用 rstatix 包计算相关系数矩阵，并去掉重复值，再按相关系数大小进行排序，代码如下:
iris[-5] %>%
  cor_mat() %>% # 相关系数矩阵
  replace_triangle(by = NA) %>% # 将下三角替换为NA cor_gather() %>% # 宽变长
  arrange(- abs(cor)) # 按绝对值降序排列
#注意:统计相关并不代表因果相关，线性不相关也可能具有非线性关系!
#GGally 包提供的 ggpair()函数可用于绘制散点图矩阵，非常便于可视化探索因变量与
#多个自变量之间的相关关系，代码如下:
library(GGally)
ggpairs(iris, columns = names(iris))

# 实际中，经常需要从许多自变量中筛选对因变量有显著影响的自变量，相关系数是一种方法，
# 另一种更系统的方法是机器学习中的特征选择。另外，correlationfunnel 包能够快速探索
# 自变量(特别是大量分类变量)对因变量的相关性影响大小，并绘制“相关漏斗图”进行 可视化
# 最后，我们还可以通过构建线性回归或广义线性回归模型，查看回归系数是否显著，并借此
# 探索自变量(无论是连续还是分类)对因变量的影响