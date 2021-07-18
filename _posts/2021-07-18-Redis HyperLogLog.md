---
layout: post
title: Redis HyperLogLog
tags:
  - Redis
---

### HyperLogLog简介
[Redis HyperLogLog](https://redis.io/topics/data-types-intro)(以下简称HLL)实现了一种叫做“HyperLogLog”的算法，并以Redis数据结构的形式提供给开发者使用。HLL只做一件事情，即统计集合中不重复元素的个数（术语叫做集合基数）。  
集合基数的统计用Redis中的set数据结构和Java中的Set集合类都可以实现，但是由于它们都会实际存储集合元素——存储空间正比于集合基数，因此它们不适合集合基数比较大的场景。HLL使用“精度换空间”的权衡策略，实现了以12kB的常量存储空间开销，得到标准误（standard error）为0.81%的集合基数估计值，并且集合基数的上限可以达到2^64。HLL不存储集合元素，只存储一个反映已添加集合元素的状态，因此能够实现常量空间复杂度。  
Redis HLL在实现上没有引入新的数据结构，而是复用了string数据结构，即HLL底层是用string编码的。  


#### 使用场景举例
服务每天被多少个不重复的IP访问过？  
接口每月被多少个不重复的用户ID访问过？  
搜索每天接收到了多少个不重复的搜索词请求？  



### HyperLogLog命令
HLL的API非常简单，包括3条命令：  

command|作用
-|-
PFADD|往HLL“添加”元素
PFCOUNT|读取HLL当前集合基数
PFMERGE|合并两个或多个HLL


#### [PFADD](https://redis.io/commands/pfadd): 往HLL“添加”元素
PFADD key [element [element ...]] 
```bash
redis>  PFADD hll a b c d e f g
(integer) 1
redis>  PFCOUNT hll
(integer) 7
```
**返回值**  
Integer reply, specifically:  
　　1 if at least 1 HyperLogLog internal register was altered. 0 otherwise.  
**时间复杂度**  
　　O(1)时间复杂度  
PFADD命令执行时，如果key还不存在就会先创建一个空的HLL；然后把key后面的元素（如有）“添加”到HLL。HLL实际上不会存储PFADD命令“添加”进来的元素，而是对元素进行计算看是否需要更新内部寄存器状态（如果需要则更新寄存器并返回1，否则返回0）。所以，无法从HLL取出之前通过PFADD命令“添加”进去的元素。


#### [PFCOUNT](https://redis.io/commands/pfcount): 读取HLL当前集合基数
PFCOUNT key [key ...] 
```bash
redis>  PFADD hll foo bar zap
(integer) 1
redis>  PFADD hll zap zap zap
(integer) 0
redis>  PFADD hll foo bar
(integer) 0
redis>  PFCOUNT hll
(integer) 3
redis>  PFADD some-other-hll 1 2 3
(integer) 1
redis>  PFCOUNT hll some-other-hll
(integer) 6
```
**返回值**  
Integer reply, specifically:  
　　The approximated number of unique elements observed via PFADD.  
**时间复杂度**  
　　只传一个key时O(1)时间复杂度（内部可缓存，快），传N个key时O(N)时间复杂度（无法缓存，毫秒级级）。  
当只传1个key时，如果集合基数的缓存值有效就直接返回缓存的集合基数，否则计算集合基数并返回；当传多个key时，Redis内部先把这些key对应HLL合并成得到1个临时HLL，然后计算并返回这个HLL的集合基数。


#### [PFMERGE](https://redis.io/commands/pfmerge): 合并两个或多个HLL
PFMERGE destkey sourcekey [sourcekey ...] 
```bash
redis>  PFADD hll1 foo bar zap a
(integer) 1
redis>  PFADD hll2 a b c foo
(integer) 1
redis>  PFMERGE hll3 hll1 hll2
"OK"
redis>  PFCOUNT hll3
(integer) 6
```
**返回值**  
Simple string reply: The command just returns OK.  
**时间复杂度**  
　　合并N个HLL时O(N)时间复杂度  
把1个destkey和多个sourcekey合并成1个HLL并写到destkey中，命令执行完成时destkey的集合基数等于这些集合的并集的集合基数值。  


HLL内部用Redis string编码，因此支持GET和SET命令。在对HLL执行这2个命令时，Redis会进行相应的序列化和反序列化操作。
```bash
redis> PFADD hll a b c d e f g
(integer) 1
redis> get hll
"HYLL\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x80Fm\x80V\x0c\x80@\xe9\x80CQ\x848\x80P\xb1\x84I\x8c\x80Bm\x80BZ"
redis> 
```



### HyperLogLog原理
Redis HLL的全部理论来源是如下2篇文献：  
P. Flajolet, Éric Fusy, O. Gandouet, and F. Meunier. [Hyperloglog: The  analysis of a near-optimal cardinality estimation algorithm](http://algo.inria.fr/flajolet/Publications/FlFuGaMe07.pdf).  
Heule, Nunkesser, Hall: [HyperLogLog in Practice: Algorithmic  Engineering of a State of The Art Cardinality Estimation Algorithm](http://citeseerx.ist.psu.edu/viewdoc/download;jsessionid=30F1D3FD363452B76390182D2F5E58F0?doi=10.1.1.308.9527&rep=rep1&type=pdf).  
文献中严谨的推理过程比较晦涩难懂，这里简单介绍一下HLL最基本的思路。  


#### [抛硬币](http://antirez.com/news/75)
甲在抛一枚硬币，抛到反面就继续抛，抛到正面就停止从而完成一个回合，记下这个回合抛到的连续反面的次数。甲在进行多个回合后，把他在这些回合中抛到的连续反面次数的最大值告诉乙，让乙猜一下甲一共进行了多少个回合。  
如果甲抛到的连续反面次数的最大值是3，那么很可能甲只进行了很少几个回合；如果甲抛到的连续反面次数的最大值是13，那么很可能甲进行了很多个回合。因此，乙实际上可以根据甲提供的连续次数的最大值给出回合数的猜测值。  
显然乙依据这种猜测方法给出的猜测值可能会存在很大的误差，比如，甲运气比较好，在第一个回合就抛出了连续10次反面，并马上告诉乙，这时候乙会给出一个误差很大的猜测值。假如让甲同时抛10枚硬币，并用10张纸分别记录各个硬币的连续反面次数最大值，最后把这10张纸交给乙，这种情况下乙的猜测值就会准确很多。  
HLL算法的基本思路跟这个抛硬币例子基本相同。


#### [HLL算法基本思路](https://en.wikipedia.org/wiki/HyperLogLog)
**HLL算法基础**：  
- HLL算法基于这样的观察，对于一个由均匀分布的随机数构成的集合，可以先把这些随机数转化成二进制表示，然后计算每个二进制表示的前导0个数，找出这些二进制表示中前导0个数的最大值n，通过n可以估计这个集合的集合基数，近似等于2^n。
- HLL通过哈希函数把原始集合转化成由均匀分布的随机数构成的集合，从而可以使用上面的方法对原始集合的集合基数进行估算。
- HLL为了减小误差，把原始集合分割成多子集合，先对各个子集合应用上述算法，最后把所有子集合的结果通过调和平均数组合成对原始集合的集合基数估计值。  

**Add： “添加”元素操作**  
往HLL“添加”元素V的操作如下图所示：
![HLL Add Operation](/assets/image/20210718hll_add.svg)
step 1: 用哈希函数h把元素v转换成由特定bit数表示的值x；  
step 2: 将x的前b个bit构成的数加1得到j，用j定位到寄存器M[j]；  
step 3: 计算x从b+1开始往后的所有bit构成的二进制串w的前导0个数ρ(w);  
step 4: 比较ρ(w)和M[j]的大小,把大值赋给M[j]。  

**Count: 计算集合基数操作**  
计算HLL集合基数时,先计算m个寄存器集合基数的调和平均值,然后乘上一个修正系数得到整个HLL的基数集合。如下图所示:
![HLL Count Operation](/assets/image/20210718hll_count1_1.svg)
![HLL Count Operation](/assets/image/20210718hll_count1_2.svg)
![HLL Count Operation](/assets/image/20210718hll_count1_3.svg)
寄存器j计算得到的集合基数值为2^M[j],根据第一个公式可以得到m个寄存器的集合基数的调和平均值为mZ;假设HLL的集合基数为n,那么每个寄存器的平均集合基数为n/m,所以n=m^Z;另外,由于哈希碰撞,需要再用一个系数 α m来修正。最终得到的HLL集合基数值如上述第三个公式所示。
考虑到系数 α m中的积分在实际实现时处理起来不太方便,通常用如下公式来近似(m为寄存器个数):  
![HLL Count Operation](/assets/image/20210718hll_count2_1.svg)
当集合基数小于5/2m时,HLL原始算法得到的集合基数的误差会比较大,这时会切换到另一种叫做Linear Counting的算法以进一步减小误差。  
通过上述修正,HLL算法得到的集合基数的标准误为:  
![HLL Count Operation](/assets/image/20210718hll_count2_2.svg)

**Merge: 合并集合操作**  
合并2个HLL集合的操作,就是把下标相同的寄存器分别合并的过程:  
![HLL Count Operation](/assets/image/20210718hll_merge.svg)


#### [Redis HLL实现](https://github.com/redis/redis/blob/unstable/src/hyperloglog.c)
**Redis HLL工作步骤**:  
(1) 用哈希函数把"添加"到HLL的元素转化成64bits的二进制表示;  
(2) 低14bits用来定位寄存器,所以一共需要2^14个寄存器;  
(3) 高50bits用来计算第一个"1"出现的位置,可见取值范围为[1,51],所以寄存器只要6bits大小即可(2^6=64 > 51);  
(4) 如果(3)得到的值比(2)定位到的寄存器的当前值大,就用它更新(2)定位到的寄存器的值,否则不更新。  
[动画演示](http://content.research.neustar.biz/blog/hll.html)  
![动画演示](/assets/image/20210718hll_flash_show.png)

**集合基数的计算**: 把寄存器个数m=2^14以及各个寄存器的当前值M[j]代入到上面的公式,就可以得到当前集合基数的估计值E,同时可以计算得到标准误1.04/sqrt(m)=0.81%。  

**内存开销**: 每个寄存器6bits,一共有2^14个寄存器,因此内存开销为 [(6 * 2^14)bits] / [8 bits / byte] = 12KB。除了寄存器内存开销外,HLL还有一个16B的头部开销:  
```c
 * +------+---+-----+----------+
 * | HYLL | E | N/U | Cardin.  |
 * +------+---+-----+----------+
```
- 前面4个字节是模数"HYLL"
- E占用1个字节,表示编码类型,取值为HLL_DENSE(密集)或HLL_SPARSE(稀疏)
- N/U占用3个字节,保留字段
- Cardin.是一个64bits的以小端字节序存放的整数,用来缓存最近一次计算得到的集合基数,最高有效位用来标志缓存值是否仍有效

HLL头部后面是一个接一个的6bits寄存器,从每个字节的最低有效位到最高有效位逐个排列:  
```c
 * +--------+--------+--------+------//      //--+
 * |11000000|22221111|33333322|55444444 ....     |
 * +--------+--------+--------+------//      //--+
```

**内存开销的进一步优化: 稀疏编码**
上述由2^14个6bits寄存器构成的编码方式在Redis HLL的实现中叫做密集编码(对应头部字段E的值为HLL_DENSE),需要占用12KB。当集合基数比较小时(如小于3000),绝大部分寄存器的值都是0,对存储空间是不小的浪费。针对这种情况,Redis采用了一种称为稀疏编码(对应头部字段E的值为LL_SPARSE)的表示形式。   
个人理解,稀疏编码其实是密集编码的一种压缩表示。 稀疏编码定义了3种操作码:  

操作码|二进制格式|占用字节|含义
-|-|-|-
ZERO|00xxxxxx|1|有"xxxxxx(2)+1"个值为0的寄存器
XZERO|01xxxxxx yyyyyyyy|2|有"xxxxxxyyyyyyyy(2)+1"个值为0的寄存器
VAL|1vvvvvxx|1|有"xx(2)"个值为"vvvvv(2)+1"的寄存器

用这3种操作码作为"词汇",描述当前寄存器的取值情况。 例如:  
当HLL为空(即所有寄存器的值都是0)时,可以表示("描述")为: XZERO:16384,此时一共只需2个字节就可以表示2^14个寄存器的状态;  
当HLL在地址为1000,1020和1021这3个寄存器的值分别为2,3和3,其它寄存器的值都是0时,可以表示("描述")为:  
```c
XZERO:1000 (Registers 0-999 are set to 0)
VAL:2,1    (1 register set to value 2, that is register 1000)
ZERO:19    (Registers 1001-1019 set to 0)
VAL:3,2    (2 registers set to value 3, that is registers 1020,1021)
XZERO:15362 (Registers 1022-16383 set to 0)
```
此时只需占用7个字节就可以表示2^14个寄存器的状态。   
可见,在集合基数比较小的时候,大部分寄存器的值都是0,稀疏编码可以比密集编码节省大量空间开销。同时也可以看到,在稀疏编码中,读取和更新寄存器的值需要的时间开销比密集编码大。因此,Redis会根据预设的条件从稀疏编码和密集编码选取合适的编码方式,具体而言:  
- HLL创建时,用稀疏编码方式;
- 当HLL集合基数超过server.hll_sparse_max_bytes或者当前元素要表示的值超出VAL操作码的表示范围(超过32)时,自动切换为密集表示。



---


参考：  
An introduction to Redis data types and abstractions: https://redis.io/topics/data-types-intro  
HyperLogLog: https://en.wikipedia.org/wiki/HyperLogLog  
Redis HLL实现细节: http://antirez.com/news/75  
Redis HLL源码: https://github.com/redis/redis/blob/unstable/src/hyperloglog.c  
HLL算法原理直观演示: http://content.research.neustar.biz/blog/hll.html  


