---
title: iOS-持久化存储技术选型
date: 2016-02-22 16:23:05
categories: iOS
permalink: iOS-endorance-storage
---

iOS有一道经典的面试题：数据的持久化存储有哪些方式？
标准答案：常见的持久化存储方法有NSUserDefaults、plist、归档存文件、sqlite、CoreData已经新兴的Realm
这样的答案对付面试官应该是够了，而实际运用中，你真的能搞清这些技术面向的场景么？
<!-- more -->

---
### 技术分类
* 偏好设置
偏好设置是最简单的归档方式，适合存储简单的配置条目。使用NSUserDefaults单例就可以存储一些可序列化的类，通过keyValue的方式写入和读取，偏好设置实际上是一个plist文件
* plist文件、归档
plist和归档都是将对象整体保存到文件内
iOS开发里，plist随处可见，它比较像是json的表格可视化文件，能够存储一些可序列化的类型，如下
``` swift
NSArray;
NSMutableArray;
NSDictionary;
NSMutableDictionary;
NSData;
NSMutableData;
NSString;
NSMutableString;
NSNumber;
NSDate;
```
  归档能够将遵守`NSCoding`协议的对象整体打包保存到文件里，从文件里解档读出的对象也可直接使用
* sqlite、CoreData、Realm
这三类都属于数据库存储，除了能够将数据逐条保存下来，最大的优势就是能够查询。当然，这三类数据库都有着自己的学习曲线，每个都需要一定的时间去掌握

### 需求及技术分析
技术应当紧紧围绕需求，根据不同的用途选择最匹配的方式，很重要！！！（这波给几分🐵）
简单举几例，来说明在实际项目中，各存储方式的应用场景
* 偏好设置
用户的设置：例如字体大小、音乐播放的码率之类的简单数据，APP是否是第一次登陆、版本号等程序需要的参数
* plist文件、归档
比如某商品推荐APP，需求希望缓存10个商品，避免网络加载时显示空白。最简便的方法就是将10个商品的模型放进数组，一次性打包成data保存到文件里，需要的时候直接解档就可以使用
* sqlite、CoreData、Realm
数据库最大的存储优势其实就在于查询，能想到最需要数据库本地存储，就是TODO List类的APP，需要存储各种事务安排，并且能够分类排序查询

---
### 真·干货 ------ [TTLite](https://github.com/TifaTsubasa/TTLite)
在实际的iOS开发中，复杂的本地存储场景是非常少的。很多时候，业务逻辑根本还没有到达需要花大量时间去研究数据库的程度，那么什么样的思路能够满足常见的存储要求呢？
**轻查询、重存储、易学习且使用方便**

> #### 介绍
TTLite基于SQLite存储，使用FDMB提供的事务进行数据操作，封装了大量的sql语句，将建表、插入、删除、查询等操作封装成更加面对对象的方法，可以直接操作模型对象，整存整取，方便使用

---
**数据库是软件开发里非常重要的一环，在时间允许的情况下，认真研究一门数据库还是非常重要的 ^.^**

---
**如果你也喜爱游戏，欢迎支持我的APP**  [Up 游戏专辑](https://itunes.apple.com/app/id986716705)
![](http://7xq01t.com1.z0.glb.clouddn.com/2016-02-16-1444295065.png)
