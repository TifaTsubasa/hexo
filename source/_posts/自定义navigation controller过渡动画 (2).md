title: 自定义navigation controller过渡动画 (2)
date: 2016-02-18 15:33:04
categories: Swift过渡指南
---

来自于[PeteC/InteractiveViewControllerTransitions](https://github.com/PeteC/InteractiveViewControllerTransitions)的定制过渡效果，这是个人非常喜欢的一种动画方式，习惯于成为**元素重用**，本章将要用Swift重写这个项目，掌握针对于页面的过渡动画，让自己的APP更具个性化。

[源码见Github](https://github.com/TifaTsubasa/SwiftTransitionExample)

![](http://7xq01t.com1.z0.glb.clouddn.com/tsusolo.com%2Fqiniutransition2.gif)
<!-- more -->
页面定制化的过渡方式同样依赖于`UIViewControllerAnimatedTransitioning`, 如果还不是很了解，可以复习一下[自定义navigation controller过渡动画](http://tsusolo.com/2016/02/01/%E8%87%AA%E5%AE%9A%E4%B9%89navigation%20controller%E8%BF%87%E6%B8%A1%E5%8A%A8%E7%94%BB/)

---
### 设计思路
* 整个过渡动画的核心在于图片的移动，看上去是将tableViewCell上的图片移动到下一页控制器的view上，实际上我们会拷贝一份imageView从cell的位置移动到视图中心
* 动画的其他部分无非与设置各个view的透明度

### 步骤
#### 1.初始化项目
* 两层控制器
* 相应的视图和模型
* push和pop动画接口
* 资源文件，详见[源码](https://github.com/TifaTsubasa/SwiftTransitionExample)
![](http://7xq01t.com1.z0.glb.clouddn.com/tsusolo.com%2Fqiniucustom-transition-finder.png)
* 控制器的初始化
![](http://7xq01t.com1.z0.glb.clouddn.com/custom-transition-page1.png)
![](http://7xq01t.com1.z0.glb.clouddn.com/custom-transition-page2.png)
初始化的过程比较重复，copy相应的代码就好
> Swift Tip:
有一段初始化数据的代码比较有意思，可以感受一下
这里用到了`lazy`关键字进行懒加载，避免了oc里的判断。在赋值的右边，用到了一个匿名函数，并且紧接括号执行返回数组，比较类似于JavaScript的匿名立即执行函数
``` swift
    lazy var things: [TTThing] = {
        let arr = []  // 通过字面量设置数组
        return arr
    }()
```



#### 2.设置过渡动画
上一章已经详细说明过渡动画的设置方式，这里就直接进入核心部分----**动画效果的处理**
##### 1.过场时间设置
依旧以push过场为例，在新建的`TTCustomPushAnimation.swift`文件内，首先实现
``` swift
func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 1
}
```
设置过场时间为1s，1秒的速度方便调试

##### 2.view获取
然后来到动画大剧场
``` swift
func animateTransition(transitionContext: UIViewControllerContextTransitioning)
```
在`animateTransition`内中设置
取得动画所需view
``` swift
let containerView = transitionContext.containerView()
let fromVc = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! TTCustomFromController
let toVc = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! TTCustomToController
let cell = fromVc.collection.cellForItemAtIndexPath((fromVc.collection.indexPathsForSelectedItems()?.first)!) as! TTThingCell
let snapImageView = cell.imgView.snapshotViewAfterScreenUpdates(false)
```
除了过场必要的containerView、fromVc、toVc之外，我们还要通过collection取得点击的cell，并将这个cell上的ImageView拷贝成`snapImageView`备用

  > Swift Tip:
这里在取得fromVc、toVc、cell时都用到了`as!`进行强制类型转换，加上感叹号避免在之后调用中的可选解析
，但是在逻辑上就需要保证相应类型的正确，后面的代码会做相应类型保护

##### 3.过场参数设置
除了必要的动画时间,还需要获得`snapImageView`在动画中的起始frame和终止frame(frame同时影响位置和大小)
``` swift
let duration = self.transitionDuration(transitionContext)
let startFrame = cell.imgView.superview!.convertRect(cell.imgView.frame, toView: containerView)
let finalFrame = toVc.view.convertRect(toVc.imgView.frame, toView: containerView)
```
记得动画舞台`containerView`么，`snapImageView`会在整个过场中置于其中进行动画操作，所以我们使用`convertRect`将Cell上imageView的frame转换到containerView作为起始frame，将toVc上ImageView转换到containerView作为终止frame
![](http://7xq01t.com1.z0.glb.clouddn.com/animation-demo.png)

##### 4.动画初始化
获得所有动画所需的属性后，接下来就是动画的准备活动了
``` swift
containerView?.addSubview(toVc.view)
containerView?.addSubview(snapImageView)

snapImageView.frame = startFrame
cell.imgView.hidden = true
toVc.view.alpha = 0
toVc.imgView.hidden = true
```

---

**如果你也喜爱游戏，欢迎支持我的**[APP](https://itunes.apple.com/app/id986716705)
![](http://7xq01t.com1.z0.glb.clouddn.com/2016-02-16-1444295065.png)
