---
title: 在iOS项目中导入React Native
date: 2016-04-5 11:23:05
categories: React Native
permalink: react-native-in-iOS
---

React Native的势头越来越猛，但凡提及Native，皆是一片666，大有替代原生APP的趋势，也许Native有着大好形势，但目前看来，尚有太多不足。
![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/simple-native-logo)
<!--more-->

### 开始
##### 在iOS原生项目中动态使用React Native定制界面
如果你已经是一个iOS开发者，继续原生项目开发可能是更好的选择，而React Native，也许更加适合原生项目中部分动态页(例如广告、咨询详情)的编写，方便页面的多端重用和即时修改。
[完整项目Github地址](https://github.com/TifaTsubasa/SimpleNative)

#### 1.安装环境
如果你之前只接触过iOS开发，使用终端也仅限于CocoaPods、Git，那么环境配置一定会费一番劲。
* 安装Node.js
	Node.js官方下载：[https://nodejs.org/en/download/](https://nodejs.org/en/download/)
	在官网可以下载到对应系统的Node安装包，非常简单
	> 推荐使用nvm安装管理Node.js，能够更好的控制node的版本
	nvm github地址：[https://github.com/creationix/nvm](https://github.com/creationix/nvm)
	中文安装方法：[http://www.tuicool.com/articles/vmi6Zv7](http://www.tuicool.com/articles/vmi6Zv7)
	
* 安装CocoaPods
	CocoaPods是iOS开发最常用的依赖管理工具
	CocoaPods安装使用方法：[唐巧blog](http://blog.devtang.com/2014/05/25/use-cocoapod-to-manage-ios-lib-dependency/)

#### 2.iOS原生项目
我们需要准备一个简单的原生项目`SimpleNative`，选用的语言是**Swift**
在`Main.storyboard`中初始化项目框架：导航控制器内有两层视图控制器，在第一层Controller中居中设置一个button用来push，第二层Controller空白待用
![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/simple-native-natigation.png)


#### 3.初始化React Native的node依赖
##### 1.初始化node
在终端中，定位到iOS项目的根目录，运行
`npm init`
然后一路回车即可
> 注意：node项目的命名不能使用大写字母，所以指定name时输入`simple-native` 后回车

执行完毕之后，在项目根目录下生成了一个`package.json`文件，类似于CocoaPods的`Podfile`文件，用来管理项目依赖

##### 2.安装React Native
再项目根目录下运行
`npm install --save react-native`
> 由于国内的网络问题，npm安装比较缓慢，可以使用[淘宝npm镜像](http://npm.taobao.org/)替代

安装完毕之后，根目录下会生成`node_modules`文件夹，里面保存了`react`和`react-native`的依赖
`--save`参数会在`package.json`文件中保存`react`和`react-native`的依赖声明

#### 4.初始化CocoaPods
在项目根目录下，运行
`pod init`
在项目根目录下生成了`Podfile`，用任何编辑器打开，编写React Native的依赖
``` ruby
platform :ios, '7.0'

target 'SimpleNative' do
  pod 'React', :path => './node_modules/react-native', :subspecs => [
    'Core',
    'RCTImage',
    'RCTNetwork',
    'RCTText',
    'RCTWebSocket',
    # Add any other subspecs you want to use in your project
  ]
end

target 'SimpleNativeTests' do

end

target 'SimpleNativeUITests' do

end
```
在项目的target下，pod导入`React`，路径指向了当前目录下`'./node_modules/react-native'`，然后还有一堆乱七八糟的子依赖(一个都不能少！)
运行`pod install`安装依赖，本地安装速度很快

#### 5.绑定Native的视图
##### 1.导入Native View
由于使用的是Swift项目，我们需要一个OC-Swift桥接文件导入Native的类，在桥接文件夹导入
`#import <RCTRootView.h>`

##### 2.设置Native View
点击`SimpleNative.xcworkspace`打开iOS项目，新建一个`ReactView`继承于UIView，并为这个view添加RCTRootView的子视图
``` swift
import UIKit

class ReactView: UIView {
    
    weak var rootView: RCTRootView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let jsCodeLocation = NSURL(string: "http://localhost:8081/index.ios.bundle?platform=ios")
        let rootView = RCTRootView(bundleURL: jsCodeLocation, moduleName: "SimpleNative", initialProperties: nil, launchOptions: nil)
        self.rootView = rootView
        self.addSubview(rootView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootView.frame = self.bounds
    }
}
```
然后在第二层控制器中居中显示一个View，并绑定为`ReactView`
![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/simple-native-react-view.png)

再次运行项目，点击push按钮后，就会见到第一个红彤彤的Native错误了，但是这表示已经成功绑定了Native
![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/simple-native-error)

#### 6.启动Native服务
在ReactView的初始化中，我们为rootView指定了bundleURL和moduleName，其中moduleName既是当前项目名，而bundleURL，就要一步一步实现了，步步都是坑😓
##### 1.新建index.ios.js
在项目根目标下，新建ReactComponents文件夹，并在文件夹中新建`index.ios.js`文件，在js文件中
写入react代码
官方推荐的简单代码为
``` javascript
'use strict';

import React, {
  Text,
  View
} from 'react-native';

var styles = React.StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'red'
  }
});

class SimpleNative extends React.Component {
  render() {
    return (
      <View style={styles.container}>
        <Text>This is a simple application.</Text>
      </View>
    )
  }
}

React.AppRegistry.registerComponent('SimpleNative', () => SimpleNative);
```
> 如果你希望显示一个更帅气的Native界面，可以拷贝链接代码：[Github搜索页](http://7xq01t.com1.z0.glb.clouddn.com/index.ios.js)

##### 2.启动node服务
建好了js文件，需要启动一个端口为8081的服务将index.ios.js打包成index.ios.bundle
在项目根目录下运行
```
(JS_DIR=`pwd`/ReactComponents; cd node_modules/react-native; npm run start -- --root $JS_DIR)
```
分解一下命令：
1.将新建的ReactComponents文件夹目录赋值到JS_DIR上，注意需要是全路径！！！
2.进入`node_modules/react-native`
3.绑定`JS_DIR`会监听ReactComponents文件夹下的文件，然后`npm run start`启动native的node服务
4.三行命令最好用()包装起来，可以避免运行后定位到`node_modules/react-native`文件夹下

**再次运行iOS项目，当然也可以直接在模拟器上 Commend + R刷新，就会获得另一个错误。。。**
~~~~~
##### 3.开启Http支持
苹果在iOS9之后默认关闭了对HTTP的支持，需要打开以访问localhost的服务
在iOS项目的`Info.plist`文件中，加入
``` xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```
加入后，plist看起来是这样的
![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/simple-native-pllist)
更多关于[App Transport Security](http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http)

#### 7.最后
重新运行iOS项目，点击push按钮后，在绿色加载条之后(第一次打包编译比较慢)，就能看到native的界面了，在搜索栏输入内容后回车，能够简单搜索Github内容（需要在index.ios.js添加[Github搜索页](http://7xq01t.com1.z0.glb.clouddn.com/index.ios.js)代码）
![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/simple-native-github-search)

如果将ReactView放置全屏显示，就更像一个原生的应用了 😉

---
**如果你也喜爱游戏，欢迎支持我的APP**  [Up 游戏专辑](https://itunes.apple.com/app/id986716705)
![](http://7xq01t.com1.z0.glb.clouddn.com/2016-02-16-1444295065.png)
