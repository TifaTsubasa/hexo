---
title: Xcode8 + Cocoapods + Swift2.3 适配
date: 2016-09-22 12:23:05
categories: iOS
permalink: xcode8+swift2.3
---

![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/xcode8+swift2.3_cover.png)

Xcode8 GM + Swift3发布，影响最大的就是一直以来使用Swift2.3开发，包含各种依赖lib的成熟项目，虽然Xcode8提供了一键Swift2.3 convert Swift3的选项，但是转换完成后几百个error也是常事。所以，在Xcode8下继续使用Swift2.3开发是简便快速的方式。
<!-- more -->

### 项目适配
1.升级完Xcode8之后，老项目打开之后，会弹出转换到Swift3的提示，两次点击`Later`忽略它
![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/xcode8+swift2.3_convert.png)

> 可以通过 Edit -> Convert -> To Current Swift Syntax... 来手动转换到Swift3

2.通过将Build Settings里的`Use Legacy Swift Language Version`设置为Yes，限定项目的Swift版本为2.3

![Alt text](http://7xq01t.com1.z0.glb.clouddn.com/xcode8+swift2.3_swift_version.png)

### Cocoapods适配
我们可以使用上面的方式，同样将`Pods`project的`Use Legacy Swift Language Version`设置为Yes，老的项目就能够在Xcode8下以Swift2.3运行了。
但是重新运行`pod install`或`pod update`安装(更新)pods后，`Pods`project的`Use Legacy Swift Language Version`会被重置，我们可以通过pod钩子的方式，自动设置swift版本
在`Podfile`文件头部，加入代码

``` ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '2.3'
    end
  end
end
```
再次运行`pod install`后，所有的Swift依赖都会被限定为Swift2.3版本运行。


### End
继续使用Swift2.3只是权宜之策，待各类小问题解决之后，Swift3必然是大势所趋。
* 项目代码不是适配Swift3的难点，重点是三方框架
* 某些框架的Swift3存在小问题，比如Alamofire，支持Swift3的release 4.0，设备要求是iOS9+，对于项目来说几乎是不可接受的
* Cocoapods和项目project中的`Use Legacy Swift Language Version`，需要保持相同的设置
* Swift2.3和Swift3的代码不可以混用