**所有内容都是学习自网上分享的文章**
##Dynamic	
iOS7中推出的UIKit Dynamics，主要用于模拟现实中的二维动画。
###主要类
>UIDynamicAnimator： 封装了底层iOS物理引擎，为动力项
>UIDynamicBehavioer： 动力行为，为动力项提供不同的动力行为
>UIDynamicItem: 一个物体，被各种力量作用的物体  

###UIDynamicAnimatior
```
@property (nonatomic, strong) UIDynamicAnimator *dynamic;
// 初始化动画的持有者 //ReferenceView是参考视图，就是以他为相对位置
_dynamic = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
```  
```
// 传入一个 Reference view 创建一个 Dynamic Animator
- (instancetype)initWithReferenceView:(UIView*)view;

// 获取在 CGRect 内所有的动力项，这个 CGRect 是基于 Reference view 的二维坐标系统的
- (NSArray*)itemsInRect:(CGRect)rect;

// 添加动力行为
- (void)addBehavior:(UIDynamicBehavior *)behavior;

// 删除指定的动力行为
- (void)removeBehavior:(UIDynamicBehavior *)behavior;

// 删除所有的动力行为
- (void)removeAllBehaviors;

///Dynamic Animator‘s状态
@property (nonatomic, readonly, getter = isRunning) BOOL running;

// 获取所有的 Behaviors
@property (nonatomic, readonly, copy) NSArray* behaviors;

@property (nonatomic, readonly) UIView* referenceView;

// 这个 delegate 中有两个回调方法，一个是在 animator 暂停的时候调用，一个是在将要恢复的时候调用
@property (nonatomic, assign) id <UIDynamicAnimatorDelegate> delegate;

// 已经运行了多久的时间，是一个 NSTimeInterval
- (NSTimeInterval)elapsedTime;

// 如果动力项不是通过 animator 自动计算改变状态，比如，通过代码强制改变一个 item 的 transfrom 时，可以用这个方法通知 animator 这个 item 的改变。如果不用这个方法，animator 之后的动画会覆盖代码中对 item 做的改变，相当于代码改变 transform 变得没有意义。
- (void)updateItemUsingCurrentState:(id <UIDynamicItem>)item;
```  

###UIDynamicBehavior
UIDynamicBehavior是所有物理行为的父类  
```
// 在将要进行动画时的 block 回调
@property(nonatomic, copy) void (^action)(void)

// 添加到该动态行为中的子动态行为
@property(nonatomic, readonly, copy) NSArray *childBehaviors

//  该动态行为相关联的dynamicAnimator
@property(nonatomic, readonly) UIDynamicAnimator *dynamicAnimator

//添加一个子动态行为
- (void)addChildBehavior:(UIDynamicBehavior *)behavior

// 移除一个子动态行为
- (void)removeChildBehavior:(UIDynamicBehavior *)behavior

// 当该动态行为将要被添加到一个UIDynamicAnimator中时，这个方法会被调用。
- (void)willMoveToAnimator:(UIDynamicAnimator *)dynamicAnimator
```
###UIGravityBehavior重力类

UIGravityBehavior:重力行为需要指定重力的大小和方向，用gravityDircetion指定一个向量，或者设置angle和magnitude。  
**angle**:0 - 3.14 是一个从平衡向左到向右的方向。  
**magnitude**:是重力系数。通常设置angle和magnitide更加的直观
![重力gif.gif](http://upload-images.jianshu.io/upload_images/2725433-a47e05c25a2ecfdc.gif?imageMogr2/auto-orient/strip)
因为是第一次制作gif，所以看起来不是很流畅，一帧一帧的感觉，事实不是这个样子的。  
###UICollisionBehavior 弹力类
指定一个边界，当物体接触到一个边界的时候，就会进行回弹。这个类室友一个代理可以通过监控物体和边界物体和物体之间的碰撞时刻。
```
//初始化弹力行为
UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.animationView, self.greView]];
//设置边界
//[collisionBehavior addBoundaryWithIdentifier:@"边界" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(self.view.frame.size.height, 600)];
/**
UICollisionBehaviorModeItems        = 1 << 0,   物体间碰撞
UICollisionBehaviorModeBoundaries   = 1 << 1,   边界碰撞
UICollisionBehaviorModeEverything   = NSUIntegerMax
*/
//是否把关联视图设置为边界，这里的关联视图指的就是UIDynamicAnimator中的视图。把该属性设置为YES，运行代码，大家会发view掉落到底部时会与底部放生弹性碰撞。//前提条件是不超过所设边界。 如果边界小的话只是在边界内活动
collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
//代理
collisionBehavior.collisionDelegate = self;   
[_dynamic addBehavior:collisionBehavior];
```


```
//与物体碰撞时执行的代理方法
- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id <UIDynamicItem>)item1 withItem:(id <UIDynamicItem>)item2 atPoint:(CGPoint)p;
- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id <UIDynamicItem>)item1 withItem:(id <UIDynamicItem>)item2;

// The identifier of a boundary created with translatesReferenceBoundsIntoBoundary or setTranslatesReferenceBoundsIntoBoundaryWithInsets is nil
//与边界碰撞时执行的代理方法
- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(nullable id <NSCopying>)identifier atPoint:(CGPoint)p;
- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(nullable id <NSCopying>)identifier;
```
我把石头设置了重力，并且设置了两个物体的碰撞。  
![弹力gif.gif](http://upload-images.jianshu.io/upload_images/2725433-2fe3b8a229fde6cc.gif?imageMogr2/auto-orient/strip)
###UIAttachmentBehavior 附着行为、吸附力
对于这个类，网上的名称有很多，看到一段解释:*关于吸附力，首先要解释一下，大家可以把吸附力理解为在吸附原点有一根棍，注意是棍不是绳子，连接着item。也就是说吸附力是刚性的。*这里我更加偏向于这是一个类似弹簧的力。   


/**
@property (readonly, nonatomic)   UIAttachmentBehaviorType attachedBehaviorType; 模式     @property (readwrite, nonatomic) CGPoint anchorPoint; //吸附点
*/
_attachment = [[UIAttachmentBehavior alloc] initWithItem:self.animationView attachedToAnchor:CGPointMake(self.view.frame.size.width / 2, 0)];
_attachment.length = 100;  //吸附距离
_attachment.damping = 0.5; //阻尼 // 那个棍子吸附的力量，越大就越不能伸缩 ，类似于一个跟300xp的弹簧。
_attachment.frequency = 1; //振动频率
[_dynamic addBehavior:_attachment];


并且在手指在屏幕移动的方法中，将anchorPoint跟随手指移动,并且保持了弹力。 

```
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{ 
//    获取在屏幕上的手指对象
UITouch *touch = [touches anyObject];
//    获取手指之前在屏幕上的位置
CGPoint previousP = [touch previousLocationInView:self.view];
//    获取现在的位置
CGPoint currentP = [touch locationInView:self.view];

CGPoint newP  = CGPointMake(0, 0);
newP.x = self.animationView.center.x + (currentP.x - previousP.x);
newP.y = self.animationView.center.y + (currentP.y - previousP.y);

//    self.animationView.center = newP;
//    self.greView.center = currentP;

self.attachment.anchorPoint = currentP; //物体牵引点
}
```
非常好玩。。。(手动滑稽)
![牵引力.gif](http://upload-images.jianshu.io/upload_images/2725433-13808d733509b080.gif?imageMogr2/auto-orient/strip)
###UIPushBehavior 推力 
对物体施加的力，可以是持续的力也可以是一次性的理，有一个向量来表示里的方向和大小。

```
UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[self.animationView] mode:(UIPushBehaviorModeInstantaneous)];
/**
*  模式:UIPushBehaviorModeContinuous 持续型
*      UIPushBehaviorModeInstantaneous 一次性
*/
//推力速度
push.magnitude = 2;
//推的方向
push.angle = 2;
[_dynamic addBehavior:push];
```
这是属性值跟重力的属性值其实是一样的，也可以用向量的方式来定义。
___
```
UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[self.animationView] mode:(UIPushBehaviorModeInstantaneous)];
//    //推力速度
//    push.magnitude = 2;
//    //推的方向
//    push.angle = 2;
push.pushDirection = CGVectorMake(currentP.x - self.animationView.center.x, currentP.y - self.animationView.center.y);
[_dynamic addBehavior:push];
```
这里推力就是从手指点击屏幕的地方进行计算的。
![推力.gif](http://upload-images.jianshu.io/upload_images/2725433-45979a547022c972.gif?imageMogr2/auto-orient/strip)

###UISnapBehavior  黑洞 吸力
将物体向一个点吸

```
UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.animationView snapToPoint:CGPointMake(100, 100)];
snap.damping = 50; //阻尼
[self.dynamic addBehavior:snap];

```
这个类只有两个属性  
>snapPoint  黑洞的点  
>damping   阻尼   vaule 0...1之间   

###UIDynamicItemBehavior 自身物体属性

由于所有内容都是股沟前辈们的文章学习的，但是这个类好多博客都没有详细介绍或或者被末学忽略了，在不经意浏览中看到了这个大神的博客。风格排版非常喜欢，内容也很有深度，在此做记录，以后多想前辈学习。  
[大神的博客链接](http://vit0.com/blog/2014/03/08/ios-7-uikit-dynamic-xue-xi-zong-jie/)  
在这个类中可以添加物体属性，如密度、弹性系数、摩擦系数、阻力、转动阻力等。
> /**  
1、@property (readwrite, nonatomic) CGFloat elasticity; 0...1 弹性系数  
2、@property (readwrite, nonatomic) CGFloat friction; // 摩擦系数，0就是绝对光滑  
3、@property (readwrite, nonatomic) CGFloat density; // 密度1 by default  
4、@property (readwrite, nonatomic) CGFloat resistance; // 0: no velocity damping  运动过程中受到的阻力  
5、@property (readwrite, nonatomic) CGFloat angularResistance; // 0: no angular velocity damping
旋转时受到的阻力  
6、@property (readwrite, nonatomic) BOOL allowsRotation; //允许自身旋转  
*/


```
UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.animationView]];
itemBehavior.elasticity = 0.8; //自身弹性
itemBehavior.allowsRotation = YES; //允许旋转
[itemBehavior addAngularVelocity:1 forItem:self.animationView]; //让物体旋转
[self.dynamic addBehavior:itemBehavior];
```