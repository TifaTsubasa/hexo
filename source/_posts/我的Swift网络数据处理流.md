---
title: 我的Swift网络数据处理流
date: 2016-08-02 16:09:05
categories: iOS
permalink: swift-network-flow
---

这是一篇跳票了一万年的博客。。
网络请求是iOS端非常重要的一环，虽然有着诸如Alamofire等框架的加持，统一请求流程、简化请求代码依旧是需要仔细琢磨的事情
<!-- more -->

> 参考资料
> [如何处理 Swift 中的异步错误](http://swift.gg/2016/02/16/async-errors/)
> [陈乘方 一个 Swift 项目网络层的变迁.pdf](https://github.com/ThinkDevelopers/SwiftConChina/blob/master/2016_ppt/01.%E9%99%88%E4%B9%98%E6%96%B9%20%E4%B8%80%E4%B8%AA%20Swift%20%E9%A1%B9%E7%9B%AE%E7%BD%91%E7%BB%9C%E5%B1%82%E7%9A%84%E5%8F%98%E8%BF%81.pdf)
> [TTReflect：json/data 转模型](https://github.com/TifaTsubasa/TTReflect)

**最重要的:**  [项目源码](https://github.com/TifaTsubasa/SwiftNetWorkFlow)

### 框架
![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/swift-network-flow)

##### 1.网络请求层
网络请求层`NetworkKit`主要用来封装三方网络请求库，统一项目的网络请求方式，降低对于三方库的依赖性，并且负责将请求得到的data转为json数据

##### 2.数据处理层
数据处理层`Loader`负责管理请求的链接、参数等，同时将json转化为能够直接调用的模型数组，尽可能为控制器减负

### 请求层
首先看一下重构之前的网络请求层

``` swift
static func fetch(type: HttpRequestType, URLString url: String, parameters para: [String: AnyObject]? = nil, success: ((json: AnyObject) -> Void)?, error: ((statusCode: Int, json: AnyObject) -> Void)?, failure: ((error: ErrorType?) -> Void)? )
```
OC时代延续下来的代码，直接传入所有的请求参数和回调函数，调用起来极不灵活

##### 1.Fluent Interface
新的网络类改用了实例方法来调用请求，并使用流式接口设计保证调用的灵活性

``` swift
// 以 url、params为例
class NetworkKit {
  var url: String?
  var params: [String: AnyObject]?
  
  func fetch(url: String) -> Self {
    self.url = url
    return self
  }
  func params(params: [String: AnyObject]) -> Self {
    self.params = params
    return self
  }
}
```
很容易理解的代码，每个函数保存相应的属性并返回自身实例，保证了链式调用

``` swift
NetworkKit().fetch("https://tsusolo.com").params(["foo": "11"])
```

##### 2.请求结果分类
与以往 成功/失败 两类请求结果不同的是，这里将请求结果分为三类：
* success：请求成功且返回了正确的结果，通常HTTP状态码为200
* error：    请求成功但返回了失败的信息，比如未找到资源、权限错误等
* failure： 请求失败，例如网络错误

在NetworkKit中声明一下三种请求回调的类型，补充相应的流式接口
``` swift
class NetworkKit {
  typealias SuccessHandlerType = (AnyObject? -> Void)
  typealias ErrorHandlerType = ((Int, AnyObject?) -> Void)
  typealias FailureHandlerType = (NSError? -> Void)

  var successHandler: SuccessType?
  var errorHandler: ErrorType?
  var failureHandler: FailureType?
  // 以success为例，error、failure类似，详见源码
  func success(handler: SuccessHandlerType) -> Self {
    self.successHandler = handler
    return self
  }
}
```

现在的调用应该是这样子
``` swift
NetworkKit().fetch("https://tsusolo.com")
.success { (json) in
  print(json)
}.error { (code, errorJson) in
  print(errorJson)
}.failure { (error) in
  print(error)
}
```

> 请求时需要设置url、参数、header以及各类回调函数，Fluent Interface让NetworkKit在调用时自由增减参数，保证简洁性

##### 3.请求和状况处理
网络请求上，这里使用了`Alamofire`并为此为例
``` swift
var httpRequest: Request?
func request() -> Self {
    if let url = url {
      httpRequest = Alamofire.request(.GET, url, parameters: params, encoding: .URL, headers: headers)
        .response { request, response, data, error in
          let statusCode = response?.statusCode
          if let statusCode = statusCode {  // request success
            let json: AnyObject? = data.flatMap {
              return try? NSJSONSerialization.JSONObjectWithData($0, options: .MutableContainers)
            }
            if statusCode == 200 {
              self.successHandler?(json)
            } else {
              self.errorHandler?(statusCode, json)
            }
          } else {                          // request failure
            self.failureHandler?(error)
          }
      }
    }
    return self
  }
```
在`request`方法中，将链式调用保存下来的参数，置入`Alamofire`并发起请求，在`Alamofire`的回调函数中，根据响应结果进行分类，分别调用相应状况的回调函数。
> 1.这里使用了一个`httpRequest`保存了Alamofire的请求，可用于取消请求等操作
> 2.结果分类需要依据具体情况，示例中根据HTTP 200状态码来判断仅作为参考方式

##### 4.示例
使用豆瓣的电影API作为示例

``` swift
// 省略了error和failure的错误处理，看起来格外简洁 ^^
NetworkKit().fetch("https://api.douban.com/v2/movie/subject/1764796")
.success { (json) in
  print(json)
}.request()
```

### 模型映射
##### 1.TTReflect
在Objective-C时代，`JsonModel`、`MJExtension`、`Mantle`都是人气很高的json/model转换框架。年初开始探索Swift的时候，第一件事情就是寻找符合下列条件的Swift版json转model框架
* 模型不需要继承其他的第三方类型
* 模型不需要手写映射关系
* 支持嵌套映射

找了一圈发现并没有符合要求的框架，于是自己摸索一番，便有了现在的 [TTReflect](https://github.com/TifaTsubasa/TTReflect)（目前已更新到2.0版本），具体用法参见[Github](https://github.com/TifaTsubasa/TTReflect)，大概就是这样  ↓
![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/swift-network-flow-reflect)

##### 2.映射函数&模型的回调函数
不同的请求会返回不同的模型类型，需要为`NetworkKit`声明一个泛型，来标明模型类型并与`result`回调函数对应。同样使用Fluent Interface将json转换model的映射函数和`result`回调注入

``` swift
class NetworkKit<Model> {
  typealias ResultHandlerType = (Model -> Void)
  typealias ReflectHandlerType = (AnyObject? -> Model)

  var resultHanlder: ResultHandlerType?
  var reflectHandler: ReflectHandlerType?
  
  func result(handler: ResultHandlerType) -> Self {
    self.resultHanlder = handler
    return self
  }
  func reflect(f: ReflectHandlerType) -> Self {
    reflectHandler = f
    return self
  }
}
```

##### 3.回调模型
在请求方法`request`的`success`回调下，通过使用保存下来的映射函数，将json转换为相应的模型，并放入模型的回调中

``` swift
if statusCode == 200 {          // request success & response right
  self.successHandler?(json)
  if let reflectHandler = self.reflectHandler {
    self.resultHandler?(reflectHandler(json))
  }
}
```

**e.g.g**
调用时可以同时获得json和模型（以Movie模型为例）
``` swift
NetworkKit<Movie>().fetch("https://api.douban.com/v2/movie/subject/1764796")
.reflect { (json) -> Movie in
  Reflect<Movie>.mapObject(json: json)
}.success({ (json) in
  print(json)
}).result { (movie) in
  print(movie)
}.request()
```
> 在初始化Network时声明模型的类型，result回调函数就会返回指定类型的模型结果

### Loader
当控制器做网络请求的时候，是不需要知道请求细节的，只需要发出请求、拿到结果就可以了。将模型声明，请求参数和转换方式封装起来在loader中，减轻控制器的负担
``` swift
class MovieLoader: NetworkKit<Movie> {
  func load() -> Self {
    return self.fetch("https://api.douban.com/v2/movie/subject/1764796")
    .reflect { (json) -> Movie in
      Reflect<Movie>.mapObject(json: json)
    }.request()
  }
}
```
最后的调用就非常简单了

``` swift
MovieLoader().result { (movie) in
  self.titleLabel.text = movie.title
}.error({ (code, json) in
  print(code, json)
}).failure({ (error) in
  print("error: ", error)
}).load()
```

### 进阶
##### 1.方法拓展
假设你的请求是下拉刷新的时候发出的，你的请求代码可能就变得惨不忍睹

``` swift
MovieLoader().result { (movie) in
  tableView.endRefresh() // 停止刷新
  print(movie)
}.error({ (code, json) in
  tableView.endRefresh()
  print(code, json)
}).failure({ (error) in
  tableView.endRefresh()
  print("error: ", error)
}).load()
```
以类似`success`回调的方式，为`Network`添加一个`finish`回调，在请求结束时直接调用（详见源码），将相应操作统一处理

``` swift
MovieLoader().finish({
  tableView.endRefresh() // 停止刷新
}).result { (movie) in
  print(movie)
}.error({ (code, json) in
  print(code, json)
}).failure({ (error) in
  print("error: ", error)
}).load()
```

##### 2.复杂模型
再假设请求结果的json比较复杂，需要多个模型来承载，类似这样 ↓

``` bash
{
	"aa": {
		...
	},
	"bb": {
		...
	}
}
```
如果这里需要AA和BB两个模型来映射到相应的json值上，可以利用Swift元组来实现

``` swift
class Loader: NetworkKit<(AA, BB)> {
  func load() -> Self {
    let f: (AnyObject? -> (AA, BB)) = { j in
      let aModel = Reflect<AA>.mapObject(json: j?["aa"])
      let bModel = Reflect<BB>.mapObject(json: j?["bb"])
      return (aModel, bModel)
    }
    return self.fetch(someUrl).reflect(f).request()
  }
}
```
> 这里也可以使用更上层的模型同时包装AB类型，利用TTReflect的嵌套转换一次性搞定，根据实际需求使用

### 总结
从4月swiftcon后开始构思，历经多次重构，参考了各类资料，在2.0版上动用各类特性后（可见源码 branch 2.0），最终在定稿的时候回归朴质，用最简单的方式来处理。

网络请求是个挺复杂的问题，很多时候更依赖于实际情况，就比如你遇到了一个凡事都扔给你httpStatusCode 200的奇葩后端，你的请求状况分类就需要特别对待，再比如我的项目中的`error`回调，返回的是错误json中的message字段。也因此没有将文章的内容变成通用的lib，只是提供一份思路，旨在提供更优雅的请求方式

---
**如果你也喜爱游戏，欢迎支持我的APP**  [Up 游戏专辑](https://itunes.apple.com/app/id986716705)
![](http://7xq01t.com1.z0.glb.clouddn.com/2016-02-16-1444295065.png)
