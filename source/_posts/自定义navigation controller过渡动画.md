layout: design
title: 自定义navigation controller过渡动画
date: 2016-02-01 15:51:04
categories: Swift过渡指南
---

除了导航控制器自带的左右滑动的过渡动画，如何去自定义一个特殊的导航过渡效果呢
[源码见Github](https://github.com/TifaTsubasa/SwiftTransitionExample)

* 1.较流行的缩放过渡，不少APP都在采用这种方式，比如豌豆荚的一览，iOS9新加的APP之间的切换，这里推荐一下朋友的[LCNavigationController](https://github.com/LeoiOS/LCNavigationController)，想偷个懒的话可以尝试一下

![](http://7xq01t.com1.z0.glb.clouddn.com/transition1.gif)
<!-- more -->
* 2.元素重用的过渡方式
我习惯将这种将view过渡到下一页的方式称
为元素重用，这里的演示效果来自于[PeteC/InteractiveViewControllerTransitions](https://github.com/PeteC/InteractiveViewControllerTransitions)，[下一章](http://localhost:4000/2016/02/18/%E8%87%AA%E5%AE%9A%E4%B9%89navigation%20controller%E8%BF%87%E6%B8%A1%E5%8A%A8%E7%94%BB%202.html)会用swift重写这个项目

![](http://7xq01t.com1.z0.glb.clouddn.com/tsusolo.com/qiniutransition2.gif)

### 设计思路
缩放过渡的思路其实非常简单，在push/pop过程中，设置上一层控制器view的scale就营造出下沉的效果，重点是

**如何控制导航过渡的过程**

### 步骤
#### 1.初始化控制器

``` swift
TTScaleNavigationController.swift // 继承UINavigationController用来重写导航的动画设置
TTScaleFirstController.swift	// 导航的前一页控制器
TTScaleSecondController.swift	// 导航的后一页控制器
```
首先需要初始化一个导航控制器和两个ViewController做基本的push/pop，当然，只有默认的左右滑动的效果😁

#### 2.设置过渡动画
**在什么地方控制转场的过程，如何修改转场动画呢?**

这里就要用到iOS7新增的API，苹果提供的自定义转场动画的协议`UIViewControllerAnimatedTransitioning`，负责管理在转场切换过程发生的事件

**以自定义push转场为例：**

##### 1. 创建过场动画的接口类
首先我们需要一个继承于`NSObject`，遵守`UIViewControllerAnimatedTransitioning`协议的类
``` swift
class TTPushTransition: NSObject, UIViewControllerAnimatedTransitioning {

}
```

##### 2. 设置过场时间
在`TTPushTransition`中使用协议中的方法设置过场时间为1s(正常的过场时间大约为0.3s，1s用于测试)
``` swift
func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 1
}
```
##### 3. 设置push过场动画
首先我们需要理清一下过场动画的流程：

* 我们将导航的前一页控制器称为fromVc，下一页控制称为toVc
  在push过程中，TTScaleFirstController是fromVc，TTScaleSecondController是toVc
  在pop过程中则反过来，TTScaleSecondController是fromVc，TTScaleFirstController是toVc
![](http://7xq01t.com1.z0.glb.clouddn.com/tsusolo.com%2Fqiniufrom%26to.png)
* 在导航push过程中，将fromVc视图的scale从1设置到0.7，将toVc视图的frame从屏幕右方移动到屏幕中间

过场的动画，需要在`UIViewControllerAnimatedTransitioning`提供的

``` swift
public func animateTransition(transitionContext: UIViewControllerContextTransitioning)
```
方法内实现，方法中的过场上下文`transitionContext`，会提供设置动画的所需的各个对象
``` swift
// 使用对应key取得相应控制器
let fromVc = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
let toVc = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)

let duration = self.transitionDuration(transitionContext)	// 根据另一协议方法获得过场时间
let containerView = transitionContext.containerView()	// 过场容器视图
```
过场上下文提供了一个容器视图`containerView`，在过场过程中，这个视图就相当一个舞台，fromVc和toVc的View可以在容器内做各种动画，首先我们需要准备一下舞台
``` swift
containerView?.addSubview(toVc!.view)	// 默认fromVc的视图已经加入容器内
let screenW = UIScreen.mainScreen().bounds.width
let screenH = UIScreen.mainScreen().bounds.height
toVc?.view.frame = CGRectMake(screenW, 0, screenW, screenH)
```
设置好toVc的视图位置后，就开始正式的动画设置了
``` swift
UIView.animateWithDuration(duration, animations: { () -> Void in
    fromVc?.view.transform = CGAffineTransformMakeScale(0.7, 0.7) // fromVc视图的scale设置到0.7
    toVc?.view.frame = CGRectMake(0, 0, screenW, screenH)	// toVc视图从屏幕右方移动到屏幕中间
    }) { (_) -> Void in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
	}
```
需要注意的是，在动画结束时，必须调用`transitionContext.completeTransition(!transitionContext.transitionWasCancelled())`来清理舞台，如果传入一个`true`好像也没有问题，但是在加入右划返回手势，滑动一半取消时，就会出现问题，因此需要根据过场是否被取消来正确清理过场上下文
##### 4. 更改导航的方式
完成上面三步，我们就写好了过场的剧本，接下来就得请演员`TTScaleNavigationController`上台表演了
``` swift
import UIKit

class TTScaleNavigationController: UINavigationController, UINavigationControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (operation == .Push) {
            return TTPushTransition()
        }
		return nil
    }
}
```
在UINavigationControllerDelegate的方法中，设置push状态的过场是写好的"剧本"，编译运行一次，push的动画已经像模像样了，不过好像只会生效一次o(╯□╰)o，需要完善pop的动画
##### 5. 设置pop的动画
设置pop动画的流程跟push类似，也需要新建一个遵守`UIViewControllerAnimatedTransitioning`的NSObject类，唯一不同的是设置动画，但实际上也就是push动画的逆向，这里就直接贴上代码了
``` swift
import UIKit

class TTPopTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        let fromVc = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toVc = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)

        let duration = self.transitionDuration(transitionContext)
        let screenW = UIScreen.mainScreen().bounds.width
        let screenH = UIScreen.mainScreen().bounds.height

        containerView?.addSubview(toVc!.view)
        containerView?.sendSubviewToBack(toVc!.view)
        UIView.animateWithDuration(duration, animations: { () -> Void in
            fromVc?.view.frame = CGRectMake(screenW, 0, screenW, screenH)
            toVc?.view.transform = CGAffineTransformMakeScale(1, 1)
            }) { (_) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}
```

然后完善一下`TTScaleNavigationController`的协议方法，补充pop状态需要的过场
``` swift
func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    if (operation == .Push) {
        return TTPushTransition()
    } else if operation == .Pop {
        return TTPopTransition()
    }
    return nil
}
```
再次运行项目，导航的过场已经基本完善了，已经拥有了想象动画，但是！！！

##### 6. 右划返回手势
重写了导航控制器之后，右划手势就失效了，需要手动添加手势😔

回到`TTScaleNavigationController`中，手势需要一个新的对象来记录手势状态，并且这个对象最终会通知导航进行相应操作，添加
``` swift
var interactivePopTransition: UIPercentDrivenInteractiveTransition?
```
然后在`viewDidLoad`方法中添加边缘手势
``` swift
let popRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "handlePopRecognizer:")
popRecognizer.edges = .Left;
self.view.addGestureRecognizer(popRecognizer)
```
记得补充手势的响应方法，这里使用了Swift的`switch`特性来判断状态并记录状态
``` swift
func handlePopRecognizer(recognizer: UIScreenEdgePanGestureRecognizer) {
    // 获取手势在屏幕横屏范围的滑动百分比，并控制在0.0 - 1.0之间
    var progress = recognizer.translationInView(self.view).x / self.view.bounds.width
    progress = min(1.0, max(0.0, progress))

    switch recognizer.state {
    case .Began:    // 开始滑动：初始化UIPercentDrivenInteractiveTransition对象，并开启导航pop
        interactivePopTransition = UIPercentDrivenInteractiveTransition()
        self.popViewControllerAnimated(true)
    case .Changed:  // 滑动过程中，根据在屏幕上滑动的百分比更新状态
        interactivePopTransition?.updateInteractiveTransition(progress)
    case .Ended, .Cancelled:    // 滑动结束或取消时，判断手指位置，在左半屏幕取消pop，在右半屏幕完成pop过程
        if progress > 0.5 {
            interactivePopTransition?.finishInteractiveTransition()
        } else {
            interactivePopTransition?.cancelInteractiveTransition()
        }
        interactivePopTransition = nil
    default: break
    }
}
```
最后，还要把我们记录下来的`UIPercentDrivenInteractiveTransition`对象通知给导航控制器
``` swift
func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactivePopTransition
}
```
终于，一个自定义过场方式的导航控制器就完活儿了😉

### 优化
##### 1. 添加阴影
为toVc的视图添加左侧的阴影，提高两个视图的层次感
![](http://gamecd.com.cn/images/swift-transition/transition-shadow.png)
在`TTPushTransition`的动画设置方法中，添加
``` swift
// shadows
toVc?.view.layer.shadowOffset = CGSizeMake(-3, 0);
toVc?.view.layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.3).CGColor
toVc?.view.layer.shadowOpacity = 1
```

##### 2. 渐亮渐暗效果
为fromVc提供push渐暗，pop渐亮的效果

思路是在fromVc和toVc的视图中间，插入一层黑色的view，并调节这一view的透明度，在`TTPushTransition`的动画设置方法中，在动画开始前插入蒙版视图
``` swift
let blackView = UIView(frame: CGRectMake(0, 0, screenW, screenH))
blackView.backgroundColor = UIColor.blackColor()
blackView.alpha = 0
containerView?.insertSubview(blackView, belowSubview: toVc!.view)
```
在动画中，设置`blackView.alpha = 0.7`并在动画结束时`blackView.removeFromSuperview()`
pop过程自然就是一个相反的过程了，同样插入一个蒙版透明度从0.7到0

##### 3. 优化参数
记得修改动画时间到0.3，fromVc视图的scale为0.95 😜

---

**如果你也喜爱游戏，欢迎支持我的APP**  [Up 游戏专辑](https://itunes.apple.com/app/id986716705)
![](http://7xq01t.com1.z0.glb.clouddn.com/2016-02-16-1444295065.png)
