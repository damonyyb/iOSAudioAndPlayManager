//
//  XXBRippleView.m
//  waterTest
//
//  Created by Jinhong on 15/2/5.
//  Copyright (c) 2015年 xiaoxiaobing. All rights reserved.
//

#import "XXBRippleView.h"
#import "PCHHeader.h"


@interface XXBRippleView ()
/**
 *  圆圈的个数
 */
@property(nonatomic , assign)NSInteger 	radiuNumber;
/**
 *  控制动画的定时器
 */
@property(nonatomic , strong)NSTimer 	*animationTimer;
/**
 *  缩放比例
 */
@property(nonatomic , assign)CGFloat 	pantographProportion;
/**
 *  动画最后一次保证可以停止
 */
@property(nonatomic,  assign)NSInteger  count;
/**
 *  平均数计数器
 */
@property (nonatomic, assign)NSInteger  averageCount;
/**
 *  平均数
 */
@property (nonatomic ,assign)CGFloat    average;
@end

@implementation XXBRippleView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupRippleView];
        self.averageCount = 0;
        self.average = 0.0f;
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupRippleView];
    }
    return self;
}
- (void)setupRippleView{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self startRippleAnimation];
}
/**
 *  开始动画
 */
- (void)startRippleAnimation{
    /**
     * 正在动画的时候停止
     */
    if (self.animationTimer)
        return;
    _count = 0;
    
    NSTimer *animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(rippleAnimation) userInfo:nil repeats:YES];
    
    self.animationTimer = animationTimer;
    
    /**
     *  调整timer的优先级
     */
    [[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSRunLoopCommonModes];
}
/**
 *  开始动画随分贝
 */
- (void)startRippleAnimationWithPower:(CGFloat)power{
    CGFloat temppower  = self.maxRadius/self.minRadius - 1.0;
    self.pantographProportion= temppower *power*2<6.5?temppower *power*2:6.5;
    
    self.averageCount ++;
        self.average = (self.average +self.pantographProportion)/self.averageCount;
        
        if (self.averageCount == 50) {
    
//            NSLog(@"%g",self.average);
            
            CGFloat average = self.average;
            if (average>=0.0326641) {
                _animationTime = 1.8;
            }
            else if (average<0.032641 && average>=0.01633205){
                _animationTime = 2.5;
            }else if(average<0.01633205 && average>=0.008166025){
                _animationTime = 3.0;
            }else if(average<0.008166025 && average>=0.040830125){
                _animationTime = 4.0;
            }else if (average<0.040830125 && average>=0.0204150625){
                _animationTime = 5.0;
            }
//            NSLog(@"%f",_animationTime);
            
            self.averageCount = 0;
            self.average = 0;
            [self stopRippleAnimation];
           
           
        }
           [self startRippleAnimation];
    
//    }


   
}
/**
 *  动画一次
 */
- (void)startRippleAnimationOnce
{
    [self rippleAnimation];
    
}
/**
 *  停止动画
 */
- (void)stopRippleAnimation
{
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}
/**
 *  画圈的动画
 */
- (void)rippleAnimation
{
   //#define abc
//#ifdef abc
//#else
//    if(_count >= 8){
//        [self stopRippleAnimation];
//        _count = 0;
//    }
//    _count ++;
//    NSLog(@"%ld",(long)count);
//#endif
    UIColor *stroke = self.rippleColor;
    CGRect pathFrame = CGRectMake(-self.minRadius, -self.minRadius,self.minRadius * 2,self.minRadius * 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:self.minRadius ];
    
#pragma mark --- 弹框类改变了center的相对位置，单独使用此类请使用test的代码。
  //#define test
#ifdef test
    CGPoint shapePosition = [self convertPoint:self.center fromView:nil];
#else
    CGPoint center ;
    center.x  = self.center.x;
    center.y  = self.superview.center.y+30;
    CGPoint shapePosition = [self convertPoint:center fromView:self.superview.superview];
//  NSLog(@"%@%@",self.superview.superview,NSStringFromCGPoint(self.center));
#endif

    
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = path.CGPath;
    circleShape.position = shapePosition;
    circleShape.fillColor = [UIColor clearColor].CGColor;
    circleShape.opacity = 0;
  //circleShape.strokeColor = stroke.CGColor;
    circleShape.fillColor = stroke.CGColor;
    circleShape.lineWidth = self.rippleWidth;
    
    [self.layer addSublayer:circleShape];
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animation];
    scaleAnimation.keyPath = @"transform.scale";
    NSMutableArray *valueArray = [NSMutableArray array];
    for(int i = 0 ; i<6 ; i++)
    {
        CGFloat percent = i/6.0 * self.pantographProportion;
        NSValue *value = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0 + percent ,1.0 + percent, 1)];
        [valueArray addObject:value];
    }
    scaleAnimation.values = valueArray;
    //到达每个点得时间点 百分比
    scaleAnimation.keyTimes = @[@(0.1),@(0.4),@(0.65),@(0.85),@(0.95),@(1.0)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    /**
     *  动画时间
     */
    animation.duration = self.animationTime;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [circleShape addAnimation:animation forKey:nil];
}
- (UIColor *)rippleColor
{
    if (_rippleColor == nil) {
        _rippleColor = [UIColor grayColor];
    }
    return _rippleColor;
}
- (CGFloat)minRadius
{
    if(_minRadius <= 0)
    {
        _minRadius = 35.0;
    }
    return _minRadius;
}
- (CGFloat)maxRadius
{
    if (_maxRadius <= 0)
    {
        _maxRadius = 150.0;
    }
    return _maxRadius;
}
- (CGFloat)pantographProportion
{
    if (_pantographProportion <=0) {
        _pantographProportion = self.maxRadius/self.minRadius - 1.0;
    }
    return _pantographProportion;
}
- (CGFloat)rippleWidth
{
    if (_rippleWidth <= 0) {
        _rippleWidth = 1.0;
    }
    return _rippleWidth;
}
- (CGFloat)animationTime
{
    if (_animationTime <= 0 ) {
        _animationTime = 2.0;
    }
    return _animationTime;
}
@end
