---
layout: post
title: A Byte of Python习题：用于备份文件的Python脚本
categories:
  - Python
tags:
  - Python
---

最近在看[《简明 Python 教程(A Byte of Python)》](https://python.swaroopch.com/)，书中有一个小练习，需求为“我想要一款程序来备份我所有的重要文件”。具体要求如下：
- 需要备份的文件与目录应在一份列表中予以指定；
- 备份必须存储在一个主备份目录中；
- 备份文件将打包压缩成 zip 文件；
- zip 压缩文件的文件名由当前日期与时间构成；
- 我们使用在任何 GNU/Linux 或 Unix 发行版中都会默认提供的标准 zip 命令进行打包。
运行效果如下图所示：


跟着书中的思路，逐步修改完善，得到了如下完整实现：

{% highlight python %}
import time  
import os  
  
#用一个列表来存放所有需要备份的文件和目录  
sources = ['/path/to/file1', '/path/to/diretory1', '/path/to/file2',  
    '/path/to/file3', '/path/to/directory2']  
#指定用于存放备份文件的目标目录  
target_dir = '/path/to/backup/directory/'  
  
  
#如果目标目录不存在，就先创建该目录  
if not os.path.exists(target_dir):  
    os.mkdir(target_dir)  
today = target_dir + os.sep + time.strftime('%Y%m%d')  
if not os.path.exists(today):  
    os.mkdir(today)  
    print('Successfully created directory', today)  
  
#备份文件的命名方式为“日期+用户输入.zip”  
now = time.strftime('%H%M%S')  
comment = input('Enter a comment -->')  
if len(comment) == 0:  
    target = today + os.sep + now + '.zip'  
else:  
    target = today + os.sep + now + '_' + \  
        comment.replace(' ', '_') + '.zip'  
  
#通过os.system方法调用系统命令zip来实现文件的压缩和归档  
zip_command = 'zip -r {0} {1}'.format(target, ' '.join(sources))  
print('Zip commands is:')  
print(zip_command)  
  
print('Running:')  
if os.system(zip_command) == 0:  
    print('Successful backup to ' + target)  
else:  
    print('Backup FAILED')  
{% endhighlight %}

作为课外练习，书中提到可以尝试使用[zipfile模块](https://docs.python.org/3/library/zipfile.html)来替代os.system调用，实现相同的功能。通过查[Python文档](https://docs.python.org/3/library/)和google，写出了如下实现：

{% highlight python %}
import time  
import os  
import zipfile  
  
#用一个列表来存放所有需要备份的文件和目录  
sources = ['/path/to/file1', '/path/to/diretory1', '/path/to/file2',  
    '/path/to/file3', '/path/to/directory2']  
#指定用于存放备份文件的目标目录  
target_dir = '/path/to/backup/directory/'  
  
  
#如果目标目录不存在，就先创建该目录  
if not os.path.exists(target_dir):  
    os.mkdir(target_dir)  
today = target_dir + os.sep + time.strftime('%Y%m%d')  
if not os.path.exists(today):  
    os.mkdir(today)  
    print('Successfully created directory', today)  
  
#备份文件的命名方式为“日期+用户输入.zip”  
now = time.strftime('%H%M%S')  
comment = input('Enter a comment -->')  
if len(comment) == 0:  
    target = today + os.sep + now + '.zip'  
else:  
    target = today + os.sep + now + '_' + \  
        comment.replace(' ', '_') + '.zip'  
  
#对于文件列表中的目录，递归地提取其中包含的文件  
files = []  
while len(sources) != 0:  
    path = sources[0]  
    del sources[0]  
    if os.path.isfile(path):  
        files.append(path)  
    else:  
        for item in os.listdir(path):  
            sources.append(path + os.sep + item)  
  
#用zipfile模块压缩和归档文件列表中的所有文件  
with zipfile.ZipFile(target, 'x') as myzip:  
    print('Running:')  
    for filename in files:  
        print('adding:', filename)  
        myzip.write(filename)  
print('Successful backup to ' + target)  
{% endhighlight %}

