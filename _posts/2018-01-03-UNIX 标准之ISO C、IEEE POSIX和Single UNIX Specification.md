---
layout: post
title: UNIX 标准之ISO C、IEEE POSIX和Single UNIX Specification
tags:
  - 操作系统
---

UNIX标准用于保证不同的UNIX系统实现能提供一致的编程环境，从而使得在一个UNIX系统上开发和打包的UNIX程序也可以在其它UNIX系统上运行。UNIX标准涉及ISO C、IEEE POSIX和Single UNIX Specification这三个关系密切的标准。


### 一、ISO C标准
C语言是一种在恰当的时间出现的恰当的语言，统治了操作系统编程。 ISO C标准的目的在于提高C程序在不同操作系统之间的移植性，既包括UNIX系统，也包括非UNIX系统。

１、ISO C标准化历程  
（1）1989年，ANSI Standard X3.159-1989标准通过，并在之后进一步上升为International Standard ISO/IEC9899:1990标准。
其中，ANSI（the American National Standards Institute）是International Organization for Standardization (ISO)中代表美国的成员，而IEC指的是the International Electrotechnical Commission；  
（2）1999年，ISO C标准更新为ISO/IEC 9899:1999，主要增强了对于数值处理应用的支持；  
（3）1999年之后，分别于2001、2004和2007年发布了3个对ISO C标准的技术勘误。  
目前，ISO C标准由the ISO/IEC international standardization working group for the C programming language, known as ISO/IEC JTC1/SC22/WG14, or WG14 for short负责维护。

２、ISO C标准的内容主要包括如下两块：C语言的语法和语义；C语言标准库。其中，C语言标准库可以按照其头文件划分为24个区（POSIX.1标准完全包含了这些头文件），如下图所示：
![Headers defined by the ISO C standard](/assets/image/20180103iso.png)


### 二、IEEE POSIX标准
POSIX（Portable Operating System Interface）是一组最初由IEEE（Institute of Electrical and Electronics Engineers）开发形成的标准族，原本指是the IEEE Standard 1003.1-1988（操作系统接口），但是后来进一步扩展为包含很多带1003标识的标准和草案（如shell和utilities (1003.2)）。下面主要关注与UNIX环境编程密切相关的the 1003.1 operating system interface standard，并用POSIX.1指代the IEEE Standard 1003.1-1988标准的各种版本。

与ISO C标准的目的一样，POSIX标准的目的在于提高应用程序在不同UNIX操作系统之间的移植性，它规定了符合POSIX标准的操作系统必须提供的服务。实际上，除了UNIX和UNIX-like系统外，很多其它的操作系统也遵循该标准。

１、POSIX.1标准化历程  
（1）1988年，IEEE将the IEEE Standard 1003.1-1988标准提交给ISO。这个IEEE标准被更新为IEEE
Standard 1003.1-1990 [IEEE 1990]后，成为International Standard ISO/IEC 9945-1:1990标准。此后，该标准经历了多次修改和扩展；  
（2）ISO于2008年接受了IEEE提交的POSIX.1最近修改版本，并于2009年将它发布为International Standard ISO/IEC 9945:2009标准；
（3）经过20多年的发展，POSIX.1标准已经相对成熟和稳定，现在由the Austin Group（http://www.opengroup.org/austin）负责维护。

２、POSIX.1标准的内容  
值得注意的是，the 1003.1 standard指定的是接口而不涉及具体实现，所有的例程都称为函数，因而没有区分系统调用和库函数。换句话说，POSIX规定那些库函数是一个符合标准规范的系统必须提供的（参数、功能、返回值），但是并没有提到系统调用——虽然大多数库函数会引发系统调用，但也有一些可以在系统内核之外实现。
- POSIX.1接口分为必需头文件和可选头文件。注意，POSIX.1标准完全包含了ISO C标准库函数，因而它的必需头文件包括ISO C标准库函数的所有头文件；
- 必需头文件如下图所示：
![Required headers defined by the POSIX standard](/assets/image/20180103posix.png)
- 可选头文件按照功能的不同进一步划分为40个分区，每个分区用由2~3个字母缩写构成的选项码来标识。每个分区包含多个接口，而这些接口依赖于特定选项的支持（很多选项用于处理实时扩展）。
其中，包含未被废弃接口的分区有24个，如下图所示：
![POSIX.1 optional interface groups and codes](/assets/image/20180103posix1.png)
特别地，其中的XSI分区所包含的头文件如下图所示：
![XSI option headers defined by the POSIX standard](/assets/image/20180103xsi.png)


### 三、Single UNIX Specification标准
１、Single UNIX Specification标准化历程
Single UNIX Specification标准的第一个版本由X/Open于1994年发布，此后经过多次更新，于2010年由Open Group发布第四个版本（SUSv4）。其中，Open Group是由两个工业社团——X/Open和Open Software Foundation (OSF)于1996年合并而构成的。

２、Single UNIX Specification标准与UNIX系统
- Open Group拥有UNIX商标，使用Single UNIX Specification标准来判断一个系统能否被称为UNIX系统。系统提供商必须以文件形式提供符合性声明，通过验证符合性的测试后，才能得到使用UNIX商标的许可证；
- Single UNIX Specification标准以POSIX.1作为其基本规范部分（即Single UNIX Specification标准是POSIX.1标准的超集），并额外定义了一些接口来扩展功能。

特别地，所有UNIX系统都是遵循XSI（The X/Open System Interfaces）的实现。XSI是POSIX.1标准中可选接口头文件中的一个功能分区（如上所述）。XSI除描述了一些可选的POSIX.1接口外，还定义了遵循XSI的实现所必须支持的可选POSIX.1接口。这些必须被支持的接口包括file synchronization、thread stack address and size attributes、thread process-shared synchronization和 the _XOPEN_UNIX symbolic constant。


### 四、典型UNIX系统
UNIX系统的各种版本和变体都起源于PDP-11上运行的UNIX分时系统的第9（1976）和第7版本（1979），这两个系统是在贝尔实验室外首先得到广泛应用的UNIX系统，演进出了如下3个分支：
- AT&T分支开发出System III 和 System V（被称为UNIX商用版本）；
- 加州伯克利分校分支开发出4.xBSD；
- AT&T贝尔实验室的计算科学研究中心推出的UNIX研究版本，开发出UNIX分时系统第8和第9版本，并终止于1990年的第10版本。

典型的UNIX系统包括 FreeBSD、 Linux、 Mac OS X和Solaris等，虽然其中只有 Mac OS X和Solaris可以称自己为UNIX系统，但是所有这4个系统都提供了相似的编程环境，因为它们都在某种程度上符合POSIX标准。

１、FreeBSD基于4.4BSD-Lite操作系统，由FreeBSD project发布。FreeBSD project开发的所有软件（包括其二进制代码和源代码）都是可以免费使用的。

２、Linux由Linus Torvalds于1991年参考MINIX这个类UNIX系统开发而成。Linux系统相比于其它系统的一个显著特点是：它经常是支持新硬件的第一个操作系统。Linux另一个独特之处在于它的商业模式：自由软件——可以从互联网上的很多站点中下载到。尽管Linux是自由的，但是它有一个GPL许可（GNU公共许可）。

３、Mac OS X的核心操作系统（称为“Darwin”）基于Mach kernel、FreeBSD、an object-oriented framework for drivers和其它内核扩展等的集合。

４、Solaris由Sun Microsystems（现为Oracle）开发，基于System V Release 4（SVR4），是唯一个在商业上取得成功的SVR4后裔。为了建立围绕Solaris的外部开发人员社区，Sun Microsystems于2005年将Solaris操作系统的大部分源代码开放给公众。

--- 

参考：  
《现代操作系统》  
《UNIX环境高级编程》























