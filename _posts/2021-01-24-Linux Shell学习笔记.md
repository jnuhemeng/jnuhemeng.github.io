---
layout: post
title: Linux Shell学习笔记
tags:
  - 开发工具
---

### 第二部分 命令之乐

#### 一、cat、head和tail命令
用cat命令读取多个文件和拼接：
```bash
#cat命令既可以从文件读取数据，也可以从stdin读取数据
cat file1.txt file2.txt #读取多个文件
ls -al | cat – file2.txt #读取stdin和file2.txt，拼接后显示到stdin，其中“－”表示stdin

#cat命令的一些文件查看选项
cat -n file1.txt	#显示内容时为每行加上行号，不会修改原文件
cat -T file1.txt	#将文件中的制表符显示为“^|”
cat -s file.txt		#压缩相邻的空白行
```
用head和tail命令查看文件的指定部分：
```bash
head -n 5 file.txt	#查看file.txt的前５行
head -n -4 file.txt	#查看file.txt除了后４行之外的所有内容 
tail -n 5 file.txt	#查看file.txt的后５行
tail -n -6 file.txt	#查看file.txt除了前（6-1=5）行之外的所有内容
```

#### 二、录制并和回终端会话
在绝大多数GNU/Linux发行版上都可以找到script和scriptreplay这两个命令，它们实现了类似于视频录制的功能，但是生成的记录文件是两个非常小的文本文件。

录制终端会话：
```bash
script -t 2> timing.data -a output.data #-t选项表示将时序数据导入stderr，2>用于将stderr重定向到timing.data文件，-a选项表示将命令数据存储到output.output文件
..................... #开始录制回话，此时正常敲命令即可
exit #要结束录制，输入exit。此时在当前目录生成了timing.data和output.data两个文件
```
回放终端会话：
```bash
scriptreplay timing.data output.data
```

#### 三、用find命令进行文件查找
```bash
find [-H] [-L] [-P] [-D debugopts] [-Olevel] [starting-point...] [expression]
```
在find命令中，-H,-L和-P参数控制符号引用的处理方式，starting-point指定要查找的文件和目录列表（直到“-”、“！”或“(”），expression指定如何匹配文件和如何处理匹配的文件。starting-point的缺省值是“.”，expression的缺省值是-print。  
查找文件
```bash
find /home -name “*.txt” #在/home目录下，查找文件名为*.txt的文件
find / -path “*log*”     #在/目录下，查找文件路径中包含log的文件
find . -maxdepth 1 		 #在当前目录下，查找深度为１的文件
find . -type d			 #在当前目录下，查找文件类型为“目录”的文件
find . ! -name “*.txt”	 #在当前目录下，查找文件名不是*.txt的文件
find . -type f -atime -7 #在当前目录下，查找文件类型为“文件”且最近访问时间小于７分钟的文件
find . -type f -amin ＋7 #在当前目录下，查找文件类型为“文件”且最近访问时间大于7天的文件
find . -type f -size +2k #在当前目录下，查找文件类型为“文件”且文件大小大于２kb的文件
```
处理查找到的文件
```bash
find . -type f -name “*.swp” -delete #删除查找到的文件
find . -type f -exec file '{}' \; #将查找到的每个文件都执行一次file操作
```
-exec可以接任意命令，其中{}表示一个匹配，将被替换为匹配的文件名。  
{}被单引号括起来以及分号以\作为前缀都是为了转义。-exec只能接单个命令，但可以通过把多个命令写到一个shell脚本中，然后在-exec中使用这个脚本。-exec执行命令的工作目录是find命令的工作目录，而-execdir功能与-exec的类似但是执行命令的工作目录为匹配文件所在的目录。

#### 四、用xargs命令从stdin构建和执行其它命令
```bash
xargs [option] [command [initial-arguments]]
```
xargs命令用IFS（空格、回车和制表符等）切割stdin的数据流，将切割得到的项以空格隔开得到一个单行，然后逐个把单行中的项用作initial-arguments后面的参数并各执行一次command（缺省值为/bin/echo）。  
```bash
#指定stdin数据流的分隔符，缺省值为IFS
echo "arg1Xarg2Xarg3Xarg4" | xargs -d X	#用”X”作为分隔符

#指定每行显式多少项（改变行数）
cat example.txt | xargs -n 3 #每行显示３个元素


#将stdin数据流格式化后作为参数传给其它命令
#单个参数
find /tmp -name core -type f -print0 | xargs -0 /bin/rm -f 
#-0选项表示以"\0"切割stdin数据流（避免因文件名包含IFS而引发错误）；xargs得到的每项都将作为"/bin/rm -f"后面的参数

#多个参数
$ cat example.txt 
1.md
2.md
3.md
4.md
5.md
$ cat example.txt | xargs -I {} echo {}.bak 
#"-I {}"选项表示将command的参数中出现的"{}"替换成xargs得到的项
1.md.bak
2.md.bak
3.md.bak
4.md.bak
5.md.bak
```

#### 五、用tr命令进行转换
```bash
tr [OPTION]... SET1 [SET2]
```
tr命令将stdin的字符串转换、压缩或删除之后输出到stdout。   
SET1和SET2是字符类或字符集，如果它们的长度不相等，那么SET2会不断重复其最后一个字符直到长度与SET1相同；如果SET2的长度大于SET1，那么在SET2中超出SET1长度的那部分字符会全部被忽略。
字符集可以自定义也可以使用系统预定义的字符类。例如：
```bash
echo 12345 | tr '0-9' '987654321' #自定义字符集
tr '[:digit:]' '[:lower:]' #系统预定义字符类
```
'A-Z'、'a-z'、'ABC-}'、'aA.,'、'a-ce-x'和'a-c0-9'等都是合法的字符集。定义字符集时只需要使用“起始字符-终止字符”这种格式就可以，也可以跟其它字符或字符类结合使用。如果“起始字符-终止字符”不是一个连续的字符序列，那么它就会被视为包含3个元素的集合，即：起始字符、-和终止字符。  
使用举例：  
```bash
#将字符串中的字符从一个字符集转换为另一个字符集
$ echo 12345 | tr '0-9' '987654321'	#加密
87654
$ echo 87654 | tr '987654321' '0-9'	#解密
12345
#压缩：-s选项可以将连续的重复字符压缩成单个字符
$ echo "GNU is     not     UNIX. Recursive    right ?" | tr -s ' '
GNU is not UNIX. Recursive right ?
#删除：-d选项可以用于删除字符
$ echo "Hello 123 world 456" | tr -d "0-9"
Hello  world 
```

#### 六、校验和与核实
文件在存取和传输时可能发生损坏（如从网上下载的ISO镜像文件一般容易出现错误），为了检查得到的文件是否与原文件完全一样，需要进行校验。md5sum和SHA-1是使用最广泛的校验和技术，它们通过比较原文件的校验字符串和得到的文件的校验字符串是否一致来判断文件是否出现损坏。  
md5sum命令和sha1sum命令的使用方法几乎完全一样，以md5sum命令为例：  
```bash
#md5sum的用法
$ md5sum example.txt 
7d204d995547503396aef84e1185ea11  example.txt
$ md5sum example.txt > example.txt.md5
$ ls
example.txt  example.txt.md5
$ md5sum -c example.txt.md5 
example.txt: OK

#对目录内的所有文件进行校验
$ find directory_path -type f -print0 | xargs -0 md5sum >> directory.md5
$ md5sum -c directory.md5
```










### 第三部分 以文件之名

#### 一、生成任意大小文件与批量生成空白文件
1、生成任意大小文件  
生成一个包含随机数据的文件，用于测试应用程序的效率、文件分隔功能，或用于创建环回文件系统（环回文件自身包含文件系统，这种文件可能像物理设备一样使用mount命令进行挂载）。  
```bash
$ dd if=/dev/zero of=junk.data bs=1M count=1
1+0 records in
1+0 records out
1048576 bytes (1.0 MB, 1.0 MiB) copied, 0.000916106 s, 1.1 GB/s
$ ll -h junk.data 
-rw-r--r-- 1 secfbth secfbth 1.0M Jan 24 11:49 junk.data
```
（1）dd命令从输入复制一份副本到输出。输入可以为普通文件、设备文件和stdin等，输出可以为普通文件、设备文件和stdout等；  
（2）if选项代表输入（缺省为stdin），而of选项代表输出文件（缺省为stdout）。/dev/zero是一个会不断返回0值字节（即'\0'）的字符设备文件；  
（3）bs选项代表以字节为单位的块大小，而count选项代表要复制的块数，故最终生成的文件的大小等于bs * count。块大小支持多种计量单位，如下表所示：  

单位|代码
-|-
字节（1B）|c
字（2B）|w
块（512B）|b
千字节（1024B）|k
兆字节（1024KB）|M
吉字节（1024MB）|G

（4）dd是一个运行于设备底层的命令，操作不当可能会把磁盘清空或损坏数据，所以一定要反复检查dd命令的语法是否正确，尤其是of参数。

2、批量生成空白文件  
touch命令用于修改文件的时间戳（访问时间/修改时间），如果文件不存在就生成相应文件名的空白文件。
```bash
touch test.txt	#默认将test.txt的时间戳改为当前的时间，如果test.txt不存在，就生成test.txt空文件
touch -m -d “Jun 24 19:33” test.txt	#-m选项代表只改最近修改时间，-d选项指定时间
```
用touch命令批量生成不同名字的空白文件：  
```bash
#方法1
for name in {1..100}.txt
do
touch $name
done

#方法2
for ((i=0;i<100;i++))
do
name="file$i.txt"
touch $name
done
```

#### 二、两个已排序文本文件的交集、差集和求差
- 交集：两个文件共有的行
- 差集：出现在一个文件但未出现在另一个文件的行
- 求差：两个文件互不相同的行

comm命令用于比较两个已排序文件（文件内元素的默认分隔符为换行符），包含很多不错的选项可用来调整输出，以便对两个文件执行交集、差集和求差操作。  
1、comm命令
```bash
$ cat file1.txt 
apple
banana
eraser
orange
paper
pencil
strawberry
$ cat file2.txt 
eraser
green
paper
pencil
purple
red
yellow
$ comm file1.txt file2.txt #不指定选项时,第一列为只在file1.txt出现的行，第二列为只在file2.txt出现的行，第三列为同时在file1.txt和file2.txt出现的行
apple
banana
		eraser
	green
orange
		paper
		pencil
	purple
	red
strawberry
	yellow

```
-1、-2和-3选项分别代表不显示第一列、第二列和第三列；如果指定的文件未排序，会输出错误提示。  
2、交集、差集和求差
```bash
$ comm -1 -2 file1.txt file2.txt #交集：不显示第一列和第二列
eraser
paper
pencil
$ comm -2 -3 file1.txt file2.txt #差集{A}：不显示第二列和第三列
apple
banana
orange
strawberry
$ comm -3 file1.txt file2.txt | sed 's/^\t//' #求差：不显示第三列，并删除多余的制表符
apple
banana
green
orange
purple
red
strawberry
yellow
```



















































---


参考：  
《Linux Shell脚本攻略》


