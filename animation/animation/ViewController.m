//
//  ViewController.m
//  animation
//
//  Created by 诸超杰 on 16/9/7.
//  Copyright © 2016年 dome.naizui. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UICollisionBehaviorDelegate>

/**
 *  按钮
 */
@property (nonatomic, weak) IBOutlet UIButton *button;


@property (weak, nonatomic) IBOutlet UIView *greView;

/**
 *  执行动画的View
 */
@property (nonatomic, weak) IBOutlet UIView *animationView;



@property (nonatomic, strong) UIDynamicAnimator *dynamic;
@property (nonatomic, strong) UIAttachmentBehavior *attachment;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
//    [self.greView addGestureRecognizer:pan];
    
    //添加事件
    [self.button addTarget:self action:@selector(Animation) forControlEvents:(UIControlEventTouchUpInside)];
    
    
    
    
}
- (IBAction)refreshBtn:(id)sender {
    
    self.animationView.frame = CGRectMake(200, 100, self.animationView.frame.size.width, self.animationView.frame.size.height);
    self.greView.frame = CGRectMake(200, 399, self.greView.frame.size.width, self.greView.frame.size.height);
    [self.dynamic removeAllBehaviors];
    
}

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
    
//    self.attachment.anchorPoint = currentP; //物体牵引点

    
    
    /**
     *  推力
     */
    UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[self.animationView] mode:(UIPushBehaviorModeInstantaneous)];
//    //推力速度
//    push.magnitude = 2;
//    //推的方向
//    push.angle = 2;
    push.pushDirection = CGVectorMake(currentP.x - self.animationView.center.x, currentP.y - self.animationView.center.y);
    [_dynamic addBehavior:push];
    
    
}

#pragma mark 手指运动
- (void)pan:(UIPanGestureRecognizer *)pan {
    
    CGPoint point = [pan locationInView:self.view];
//    CGPoint point = [pan velocityInView:self.view];
    
    
//    CGFloat x = old.x - point.x;
//    CGFloat y = old.y - point.y;
//    self.greView.center = CGPointMake(self.greView.center.x + point.x, self.greView.center.y + point.y);
//    self.greView.center = point;
}


#pragma mark  力学动画
/**
 *  力学动画
 */
- (IBAction)kitAnimation:(id)sender {
    
    // 初始化动画的持有者 //ReferenceView是参考视图，就是以他为相对位置
    _dynamic = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    //物体属性
//    [self dynamicItemBehavior];
    //重力
//    [self dynamicAnimation];
//    //弹力
    [self collisionAnimation];
    //牵引力
//    [self attachmentAnimation];
    //推力
    [self pushAnimation];
//    //黑洞、吸引力
//    [self snapAnimation];
}


/**
 *  物体属性
 */
- (void)dynamicItemBehavior {
    /**
     @property (readwrite, nonatomic) CGFloat elasticity; 0...1 弹性系数
     @property (readwrite, nonatomic) CGFloat friction; // 摩擦系数，0就是绝对光滑
     @property (readwrite, nonatomic) CGFloat density; // 密度1 by default
     @property (readwrite, nonatomic) CGFloat resistance; // 0: no velocity damping
     @property (readwrite, nonatomic) CGFloat angularResistance; // 0: no angular velocity damping
     //上面两个属性应该是旋转时有没有角阻尼。
     @property (readwrite, nonatomic) BOOL allowsRotation; //允许自身旋转
     */
     
     
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.animationView]];
    itemBehavior.elasticity = 0.8; //自身弹性
    itemBehavior.allowsRotation = YES; //允许旋转
    [itemBehavior addAngularVelocity:1 forItem:self.animationView]; //让物体旋转
    [self.dynamic addBehavior:itemBehavior];
}


/**
 *  力学动画一、重力
 */
- (void)dynamicAnimation {
    
    // 初始化力学行为 UIGravityBehavior为所有类的基类
    UIGravityBehavior *behavior =[[UIGravityBehavior alloc] initWithItems:@[self.animationView]];

    /**
     @property (readwrite, nonatomic) CGVector gravityDirection;  //重力向量
     @property (readwrite, nonatomic) CGFloat angle; //向量的方向
     @property (readwrite, nonatomic) CGFloat magnitude; //magnitude 重力大小
     */
    //设置
    /**
     *  angle 为重力方向 magnitude 为重力加速度
     */
    [behavior setAngle:  3.14 / 2 magnitude:0.5];
//    behavior.gravityDirection = CGVectorMake(0, 1);
    
    //加入力学行为
    [_dynamic addBehavior:behavior];
    
    
}

/**
 * 力学动画二、弹力
 */
- (void)collisionAnimation {
    
    //初始化弹力行为
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.animationView, self.greView]];
    //设置边界
//    [collisionBehavior addBoundaryWithIdentifier:@"边界" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(self.view.frame.size.height, 600)];
    
    collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
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
}

/**
 *  力学动画三、吸附力
 */
- (void)attachmentAnimation {
    
    //关于吸附力，首先要解释一下，大家可以把吸附力理解为在吸附原点有一根棍，注意是棍不是绳子，连接着item。也就是说吸附力是刚性的。
    //可以看到这里我们用的吸附力的构造方法是一个点，length就代表"棍"的长度，运行程序发现物体在重力的作用下会以Anchor为中心，以length为半径，稍微转一下。
    /**
     @property (readonly, nonatomic) UIAttachmentBehaviorType attachedBehaviorType; 模式
     
     @property (readwrite, nonatomic) CGPoint anchorPoint; //吸附点
     */
    _attachment = [[UIAttachmentBehavior alloc] initWithItem:self.animationView attachedToAnchor:CGPointMake(self.view.frame.size.width / 2, 0)];
    _attachment.length = 100;  //吸附距离
    _attachment.damping = 0.5; //阻尼 // 那个棍子吸附的力量，越大就越不能伸缩 ，类似于一个跟30xp的弹簧。
    _attachment.frequency = 1; //振动频率
    [_dynamic addBehavior:_attachment];
    
}

/**
 *  力学动画四、推力
 */
- (void)pushAnimation {
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
}

/**
 *  吸附力  黑洞
 */

- (void)snapAnimation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.animationView snapToPoint:CGPointMake(100, 100)];
        snap.damping = 50; //阻尼
        [self.dynamic addBehavior:snap];
    });
}
#pragma mark 力学碰撞代理
- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id <UIDynamicItem>)item1 withItem:(id <UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    self.greView.backgroundColor = [UIColor colorWithRed:arc4random() % 256 / 255.0  green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:1];
    NSLog(@"began contact item");
}

- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id <UIDynamicItem>)item1 withItem:(id <UIDynamicItem>)item2
{
    self.greView.backgroundColor = [UIColor colorWithRed:arc4random() % 256 / 255.0  green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:1];
    NSLog(@"end contanct item");
}


//边界碰撞
- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(id <NSCopying>)identifier atPoint:(CGPoint)p
{
    self.greView.backgroundColor = [UIColor colorWithRed:arc4random() % 256 / 255.0  green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:1];
    NSLog(@"began contact boundary");
}

- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(id <NSCopying>)identifier
{
    self.greView.backgroundColor = [UIColor colorWithRed:arc4random() % 256 / 255.0  green:arc4random() % 256 / 255.0 blue:arc4random() % 256 / 255.0 alpha:1];
    NSLog(@"end contact boundary");
}


#pragma mark   基本动画

- (void)Animation {
    
    //基础动画
//    [self ConfigoldAnimation];
    
    //更加简单的基础动画
//    [self configSimpleAnimation];
    
    //关键帧动画
//    [self configKeyAnimation];
    
    //有动画选项的动画
//    [self ConfigPotionsAnimation];
    
    //春天动画
//    [self ConfigSpringAnimation];
    
    //CALayer动画
//    [self ConfigBasicAnimation];
    
    //组动画 / 帧动画
//    [self ConfigGroupAnimation];
}


/**
 *  基础动画
 */
- (void)ConfigoldAnimation {
    //开始配置动画
    [UIView beginAnimations:@"viewAnimation" context:nil];
    
    // 动画事件延时2秒
    [UIView setAnimationDelay:2];
    
    // 动画时间2秒 默认0.2
    [UIView setAnimationDuration:2];
    
    // 设置代理
    [UIView setAnimationDelegate:self];
    
    /**  动画的方式
     UIViewAnimationCurveEaseInOut,         // slow at beginning and end
     UIViewAnimationCurveEaseIn,            // slow at beginning
     UIViewAnimationCurveEaseOut,           // slow at end
     UIViewAnimationCurveLinear
     */
    [UIView setAnimationCurve:(UIViewAnimationCurveEaseIn)];
    
    // frame的变化 ===> 变化到(0,0)点，100 100大小
    self.animationView.frame = CGRectMake(0, 0, 100, 100);
    
    // 颜色变化
    self.animationView.backgroundColor = [UIColor redColor];
    
    // 不透明度变化
    self.animationView.alpha = 0.5;
    
    // 开始动画
    [UIView commitAnimations];
}

/**
 *  更简单的基础动画
 */
- (void)configSimpleAnimation {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.animationView.frame = CGRectMake(100, 100, 100, 100);
        self.animationView.backgroundColor = [UIColor redColor];
        self.animationView.alpha = 0.4;

    } completion:^(BOOL finished) {
      
        //方法执行完以后的执行的闭包
        
    }];
}

/**
 *  关键帧动画
 */
- (void)configKeyAnimation {
    
    //http://www.devtalking.com/articles/uiview-keyframe-animation/
    
    /**
     *  options
     *
     *  @param UIViewKeyframeAnimationOptionCalculationModeDiscrete
     
     UIViewKeyframeAnimationOptionCalculationModeLinear     
     Linear 键帧之间的转换是线性内插值替换的，像上面图中红色的。这意味着一个动画可以出现加速和减速,因为动画是增量变化的。, //连续运算模式 个人理解:按程序员自己分配的每一帧时间分别执行
     
     UIViewKeyframeAnimationOptionCalculationModeDiscrete
     Discrete 在每个键帧结束的时候瞬时转换，像上面图中蓝色的。这种情况下，实际上是没有动画的，仅仅是跳到另个键帧上 //离散运算模式 个人理解:就是智障
     
     UIViewKeyframeAnimationOptionCalculationModePaced      
     Paced 一个简单的算法使键帧动画点上匀速执行 //均匀执行运算模式 个人理解:设置每一帧的所占时间，开始时间变的没有效果，只是单纯按属性变化范围来给定时间了。个人理解:总时间10m,第一帧width从0-3 第二帧width从3-10;第一帧占三秒 第二帧占七秒。
     
     UIViewKeyframeAnimationOptionCalculationModeCubic      
     Cubic 键帧点之间画立方样条，然后动画沿着这条线，上图绿色的部分。这可能导致在开始时动画朝相反的方向。 //平滑运算模式  个人理解:**动画执行的速度一致** 无论是那一帧，所以有可能会出现了动画朝相反的方法。因为是按程序员设置。
     
     UIViewKeyframeAnimationOptionCalculationModeCubicPaced 
     CubicPaced 这忽略了键帧动画中定义的定时，强制不同键帧位置之间匀速执行。例如粉红色的部分。这将导致动画看起来匀速平滑，但是会忽略你开始设置的动画时间 //平滑均匀运算模式 个人理解:每一帧设置的时间就没有效果了
     */
    
    // 关键帧动画
    [UIView animateKeyframesWithDuration:10 delay:0.1 options:(UIViewKeyframeAnimationOptionCalculationModePaced) animations:^{
        
        /**
         *  statrTime:开始时间是按总的Duration的百分比，eq:0.5就是从整个动画时间的中间时间开始
         *  relativeDuration:动画总时间的百分比，eq:0.5就是整个动画时间的一半
         */
        
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.1 animations:^{
            self.animationView.frame = CGRectMake(0, 0, 100, 100);
            self.animationView.backgroundColor = [UIColor redColor];
            self.animationView.alpha = 0.4;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.1 relativeDuration:0.8 animations:^{
            self.animationView.frame = CGRectMake(0, 200, 100, 100);
            self.animationView.backgroundColor = [UIColor greenColor];
            self.animationView.alpha = 1;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.9 relativeDuration:0.1 animations:^{
            self.animationView.frame = CGRectMake(00, 400, 100, 100);
                        self.animationView.backgroundColor = [UIColor redColor];
            self.animationView.alpha = 1;
        }];

        
    } completion:nil];
    

}


/**
 *  有动画选项的动画
 */
- (void)ConfigPotionsAnimation {
    
    /**
     *  options
     *
     *  @param UIViewAnimationOptionAllowAnimatedContent 
     UIViewAnimationOptionLayoutSubviews            //进行动画时布局子控件
     UIViewAnimationOptionAllowUserInteraction      //进行动画时允许用户交互
     UIViewAnimationOptionBeginFromCurrentState     //从当前状态开始动画
     UIViewAnimationOptionRepeat                    //无限重复执行动画
     UIViewAnimationOptionAutoreverse               //执行动画回路
     UIViewAnimationOptionOverrideInheritedDuration //忽略嵌套动画的执行时间设置
     UIViewAnimationOptionOverrideInheritedCurve    //忽略嵌套动画的曲线设置
     UIViewAnimationOptionAllowAnimatedContent      //转场：进行动画时重绘视图
     UIViewAnimationOptionShowHideTransitionViews   //转场：移除（添加和移除图层的）动画效果
     UIViewAnimationOptionOverrideInheritedOptions  //不继承父动画设置
     */
    
        [UIView animateWithDuration:2 delay:0.1 options:(UIViewAnimationOptionAllowAnimatedContent) animations:^{
            
            self.animationView.frame = CGRectMake(0, 0, 100, 100);
            self.animationView.backgroundColor = [UIColor redColor];
            
        } completion:^(BOOL finished) {
            
        }];
    
}

/**
 *  春天动画
 */
- (void)ConfigSpringAnimation {
    
    /**
     *  Spring动画
     *
     *  @param duration     持续时间
     *  @param delay        延时
     *  @param dampingRatio 衰减率
     *  @param velocity     初始速度
     *  @param options      运动曲线
     *  @param animations   动画过程
     *  @param completion   动画结束
     */
    

    
    [UIView animateWithDuration:2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:100 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        self.animationView.frame = CGRectMake(0, 0, 100, 100);
    } completion:nil];
    
}


/**
 *  CALayer动画CABasicAnimation
 */
- (void)ConfigBasicAnimation {
    
    CABasicAnimation *baseAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    //baseAnimation.fromValue 如果不设置，这个属性就是从当前位置开始
    
    baseAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(100, 0)];
    
    [baseAnimation setValue:[NSValue valueWithCGPoint:CGPointMake(100, 0)] forKey:@"endPoint"];
    [baseAnimation setValue:self.animationView forKey:@"sender"];
    
    //baseAnimation.byValue //相对位置
    
    baseAnimation.duration = 1;
    
    baseAnimation.repeatCount = 1;
    
    //设置代理
    baseAnimation.delegate = self;
    
    //加速运动
    baseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    //若不设置下面两个属性，动画执行完后复原位
    baseAnimation.removedOnCompletion = false;
    baseAnimation.fillMode = kCAFillModeForwards;

    [self.animationView.layer addAnimation:baseAnimation forKey:@"animation"];
    NSLog(@"1.view.frame,%f,%f",self.animationView.frame.origin.x, self.animationView.frame.origin.y);
    /**
     *  核心动画移动的是因为动画是通过view的layer设置位置的。而设置layer的位置后，uiview的位置是不会发生变化的，所以虽然看见红色移动了，但其实红色view.frame没变化,所以在动画执行完以后需要设置view的frame
     */
}

//帧动画
- (void)ConfigKeyFrameAnimation {
    CAKeyframeAnimation *keyFrame = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    CGFloat center = self.animationView.layer.position.x;
    CGFloat left = center - 10;
    CGFloat right = center + 10;
    NSNumber *c = [NSNumber numberWithFloat:center];
    NSNumber *l = [NSNumber numberWithFloat:left];
    NSNumber *r = [NSNumber numberWithFloat:right];
    keyFrame.values = @[c, l, c, r, c];
    keyFrame.duration = 0.5;
    keyFrame.repeatCount = 100;
    [self.animationView.layer addAnimation:keyFrame forKey:@"晃动"];
}

//组动画
- (void)ConfigGroupAnimation {
    
    /*
     可选的KeyPath
     transform.scale = 比例轉換
     transform.scale.x
     transform.scale.y
     transform.rotation = 旋轉
     transform.rotation.x
     transform.rotation.y
     transform.rotation.z
     transform.translation
     transform.translation.x
     transform.translation.y
     transform.translation.z
     
     opacity = 透明度
     margin
     zPosition
     backgroundColor 背景颜色
     cornerRadius 圆角
     borderWidth
     bounds
     contents
     contentsRect
     cornerRadius
     frame
     hidden
     mask
     masksToBounds
     opacity
     position
     shadowColor
     shadowOffset
     shadowOpacity
     shadowRadius
     
     */
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 3;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.beginTime = 1;
    animation.duration = 1;
    animation.toValue = @300;
    
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation1.duration = 2;
    animation1.beginTime = 2;
    animation1.toValue = @0.3;
    
    group.animations = @[animation, animation1];
    
    [self.animationView.layer addAnimation:group forKey:@"组动画"];
}

//转场动画
- (void)ConfigTransferAnimation {

}




#pragma mark base动画代理方法
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    CGPoint endpoint = [[anim valueForKey:@"endPoint"] CGPointValue];
    UIView *view = (UIView *)[anim valueForKey:@"sender"];
    view.layer.position = endpoint;
    
    NSLog(@"2.view.frame,%f,%f",self.animationView.frame.origin.x, self.animationView.frame.origin.y);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}









@end
