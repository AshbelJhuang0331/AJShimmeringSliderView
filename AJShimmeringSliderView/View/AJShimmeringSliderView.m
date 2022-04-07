//
//  AJShimmeringSliderView.m
//  AJShimmeringSliderView
//
//  Created by ChuanJie Jhuang on 2020/3/4.
//  Copyright © 2020 ChuanJie Jhuang. All rights reserved.
//

#import "AJShimmeringSliderView.h"

static NSString *const SliderPlaceholderShimmeringAnimationKey = @"slider_placeholder_shimmering_animation_key";
static NSString *const SliderPlaceholderSpotLightAnimationKey = @"slider_placeholder_spot_light_animation_key";
static double const SliderBarInnerButtonPortion = 60 / 311.0;

@interface AJShimmeringSliderView ()

@property (nonatomic, assign) BOOL startDragging;
@property (nonatomic, assign) CGFloat startDraggingX;
@property (nonatomic, strong) CAShapeLayer *indicatorLayer;
@property (nonatomic, strong) CALayer *filledInLayer;
@property (nonatomic, strong) CATextLayer *placeholderTextLayer;
@property (nonatomic, strong) CATextLayer *placeholderSpotLightTextLayer;
@property (nonatomic, strong) CALayer *indicatorImageLayer;

@end

@implementation AJShimmeringSliderView

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.fullThreshold = 1.0;
        self.animationType = AJShimmeringSliderViewAnimationTypeDefault;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.fullThreshold = 1.0;
        self.animationType = AJShimmeringSliderViewAnimationTypeDefault;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.fullThreshold = 1.0;
        self.animationType = AJShimmeringSliderViewAnimationTypeDefault;
    }
    return self;
}

#pragma mark - Override

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow == nil) {
        // Will be removed from window, similar to -viewDidUnload.
        // Unsubscribe from any notifications here.
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)didMoveToWindow {
    if (self.window) {
        // Added to a window, similar to -viewDidLoad.
        // Subscribe to notifications here.
        if (self.animationType == AJShimmeringSliderViewAnimationTypeSpotLight) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePlaceholderSpotLightGradient) name:UIApplicationDidEnterBackgroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPlaceholderSpotLightGradient) name:UIApplicationDidBecomeActiveNotification object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePlaceholderShimmeringGradient) name:UIApplicationDidEnterBackgroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPlaceholderShimmeringGradient) name:UIApplicationDidBecomeActiveNotification object:nil];
        }
    }
}

//- (void)dealloc {
//    NSLog(@"shimmeringSliderView dealloc!");
//}

- (void)drawRect:(CGRect)rect {
    
    if (self.placeholderTextLayer == nil) {
        self.placeholderTextLayer = [CATextLayer layer];
        [self updatePlaceholderTextLayer];
        [self.layer addSublayer:self.placeholderTextLayer];
        self.placeholderSpotLightTextLayer = [CATextLayer layer];
        [self updatePlaceholderSpotLightTextLayer];
        [self.layer addSublayer:self.placeholderSpotLightTextLayer];
        [self addPlaceholderSpotLightGradient];
        if (self.animationType == AJShimmeringSliderViewAnimationTypeSpotLight) {
            [self addPlaceholderSpotLightGradient];
        } else {
            [self addPlaceholderShimmeringGradient];
        }
    }
    
    if (self.filledInLayer == nil) {
        self.filledInLayer = [[CALayer alloc] init];
        [self.filledInLayer setFrame:CGRectMake(0, 0, 0, self.bounds.size.height)];
        self.filledInLayer.cornerRadius = self.cornerRadius;
        self.filledInLayer.backgroundColor = [self.filledInColor CGColor];
        [self.layer addSublayer:self.filledInLayer];
    }
    
    if (self.indicatorLayer == nil) {
        UIBezierPath *barBezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width * SliderBarInnerButtonPortion, self.bounds.size.height - 2) cornerRadius:self.cornerRadius];
        self.indicatorLayer = [[CAShapeLayer alloc] init];
        [self.indicatorLayer setFrame:CGRectMake(0, 1, self.bounds.size.width * SliderBarInnerButtonPortion, self.bounds.size.height - 2)];
        self.indicatorLayer.path = [barBezierPath CGPath];
        self.indicatorLayer.borderWidth = 1;
        self.indicatorLayer.borderColor = [[UIColor clearColor] CGColor];
        self.indicatorLayer.cornerRadius = self.cornerRadius;
        self.indicatorLayer.fillColor = [[UIColor whiteColor] CGColor];
        self.indicatorLayer.strokeColor = self.indicatorOutlineColor == nil ? [[UIColor colorWithRed:225 / 255.0 green:225 / 255.0 blue:225 / 255.0 alpha:1.0] CGColor] : [self.indicatorOutlineColor CGColor];
        [self.layer addSublayer:self.indicatorLayer];
    }
    
    if (self.indicatorImageLayer == nil) {
        self.indicatorImageLayer = [CALayer layer];
        self.indicatorImageLayer.contents = (__bridge id _Nullable)[self.indicatorImage CGImage];
        [self.indicatorImageLayer setFrame:CGRectMake(0, 0, 20, 20)];
        [self.indicatorImageLayer setContentsScale:[[UIScreen mainScreen] scale]];
        self.indicatorImageLayer.masksToBounds = YES;
        self.indicatorImageLayer.position = CGPointMake(CGRectGetMidX(self.indicatorLayer.bounds), CGRectGetMidY(self.indicatorLayer.bounds));
        [self.indicatorLayer addSublayer:self.indicatorImageLayer];
    }
    
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
    
    [self setProgress:self.progress];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint current = [touch locationInView:self];
    CGFloat barEndPointX = self.bounds.size.width - self.indicatorLayer.bounds.size.width - 1;
//    CGPoint previous=[touch previousLocationInView:self];
//    CGPoint precise=[touch preciseLocationInView:self];
    if (CGRectContainsPoint(self.indicatorLayer.frame, current)) {
        self.startDragging = YES;
        self.startDraggingX = current.x;
//        NSLog(@"begin - progress: %f", self.progress);
        self.progress = (self.indicatorLayer.frame.origin.x) / barEndPointX;
        if (self.delegate && [self.delegate respondsToSelector:@selector(shimmeringSliderViewDidBeginSliding:)]) {
            [self.delegate shimmeringSliderViewDidBeginSliding:self];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint current = [touch locationInView:self];
//    CGPoint previous = [touch previousLocationInView:self];
    CGFloat barEndPointX = self.bounds.size.width - self.indicatorLayer.bounds.size.width - 1;
    if (self.startDragging) {
//        CGFloat xDeviation = current.x - previous.x;
//        CGFloat newOriginX = self.indicatorLayer.frame.origin.x + xDeviation;
        CGFloat newOriginX = current.x - (self.bounds.size.width * SliderBarInnerButtonPortion / 2);
        if (newOriginX > barEndPointX) {
            newOriginX = barEndPointX;
        }
        if (newOriginX < 0) {
            newOriginX = 0;
        }
        self.progress = newOriginX / barEndPointX;
        if (self.delegate && [self.delegate respondsToSelector:@selector(shimmeringSliderViewDidMove:)]) {
            [self.delegate shimmeringSliderViewDidMove:self];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.startDragging) {
        CGFloat originX = self.indicatorLayer.frame.origin.x;
        CGFloat barEndPointX = self.bounds.size.width - self.indicatorLayer.bounds.size.width - 1;
        if (originX < self.fullThreshold * barEndPointX && self.isAutoBounceBack) {
            self.progress = 0;
            if (self.delegate && [self.delegate respondsToSelector:@selector(shimmeringSliderViewDidAutoBounceBackToInitialPosition:)]) {
                [self.delegate shimmeringSliderViewDidAutoBounceBackToInitialPosition:self];
            }
        } else {
            if (originX >= self.fullThreshold * barEndPointX) {
                self.progress = 1.0;
            } else {
                self.progress = originX / barEndPointX;
            }
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(shimmeringSliderViewDidEndSliding:)]) {
            [self.delegate shimmeringSliderViewDidEndSliding:self];
        }
    }
    self.startDragging = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
   if (self.startDragging) {
       CGFloat originX = self.indicatorLayer.frame.origin.x;
       CGFloat barEndPointX = self.bounds.size.width - self.indicatorLayer.bounds.size.width - 1;
       if (originX < self.fullThreshold * barEndPointX && self.isAutoBounceBack) {
           self.progress = 0;
           if (self.delegate && [self.delegate respondsToSelector:@selector(shimmeringSliderViewDidAutoBounceBackToInitialPosition:)]) {
               [self.delegate shimmeringSliderViewDidAutoBounceBackToInitialPosition:self];
           }
       } else {
           if (originX >= self.fullThreshold * barEndPointX) {
               self.progress = 1.0;
           } else {
               self.progress = originX / barEndPointX;
           }
       }
       if (self.delegate && [self.delegate respondsToSelector:@selector(shimmeringSliderViewDidEndSliding:)]) {
           [self.delegate shimmeringSliderViewDidEndSliding:self];
       }
   }
   self.startDragging = NO;
}

#pragma mark - Public

- (void)setFilledInColor:(UIColor *)filledInColor {
    _filledInColor = filledInColor;
    if (self.filledInLayer != nil) {
        self.filledInLayer.backgroundColor = [self.filledInColor CGColor];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = [borderColor CGColor];
}

- (void)setPlaceholderText:(NSString *)placeholderText {
    _placeholderText = placeholderText;
    [self updatePlaceholderTextLayer];
    [self updatePlaceholderSpotLightTextLayer];
    
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor {
    _placeholderTextColor = placeholderTextColor;
    [self updatePlaceholderTextLayer];
    [self updatePlaceholderSpotLightTextLayer];
}

- (void)setProgress:(CGFloat)progress {
    if (progress > 1.0) {
        progress = 1.0;
    }
    _progress = progress;
    CGFloat barEndPointX = self.bounds.size.width - self.indicatorLayer.bounds.size.width - 1;
    CGFloat newOriginX = _progress * barEndPointX;
    if (progress == 0) {
        [self.indicatorLayer setFrame:CGRectMake(newOriginX, 1, self.bounds.size.width * SliderBarInnerButtonPortion, self.bounds.size.height - 2)];
        [self.filledInLayer setFrame:CGRectMake(0, 0, newOriginX + 4, self.bounds.size.height)];
    } else {
        [CATransaction setValue:(NSNumber *)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self.indicatorLayer setFrame:CGRectMake(newOriginX, 1, self.bounds.size.width * SliderBarInnerButtonPortion, self.bounds.size.height - 2)];
        [self.filledInLayer setFrame:CGRectMake(0, 0, newOriginX + 4, self.bounds.size.height)];
        [CATransaction commit];
    }
}

- (void)setAnimationType:(AJShimmeringSliderViewAnimationType)animationType {
    _animationType = animationType;
    [self updatePlaceholderTextLayer];
    [self updatePlaceholderSpotLightTextLayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.animationType == AJShimmeringSliderViewAnimationTypeSpotLight) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePlaceholderSpotLightGradient) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPlaceholderSpotLightGradient) name:UIApplicationDidBecomeActiveNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePlaceholderShimmeringGradient) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPlaceholderShimmeringGradient) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    [self removePlaceholderShimmeringGradient];
    [self removePlaceholderSpotLightGradient];
    if (self.animationType == AJShimmeringSliderViewAnimationTypeSpotLight) {
        [self addPlaceholderSpotLightGradient];
    } else {
        [self addPlaceholderShimmeringGradient];
    }
}

#pragma mark - Private

- (void)addPlaceholderShimmeringGradient {
    CAGradientLayer *shimmeringLayer = [[CAGradientLayer alloc] init];
    shimmeringLayer.frame = self.placeholderTextLayer.bounds;
    shimmeringLayer.colors = @[(id)[[UIColor colorWithWhite:0.95 alpha:1.0] CGColor], (id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithWhite:0.95 alpha:1.0] CGColor]];
    shimmeringLayer.startPoint = CGPointMake(0.0, 1.0);
    shimmeringLayer.endPoint = CGPointMake(1.0, 1.0);
    shimmeringLayer.locations = @[@0, @0.5, @1.0];
    self.placeholderTextLayer.mask = shimmeringLayer;

    CABasicAnimation *shimmeringAnimation = [CABasicAnimation animationWithKeyPath:@"locations"];
    shimmeringAnimation.fromValue = @[@-1.0, @-0.5, @0.0];
    shimmeringAnimation.toValue = @[@1.0, @1.5, @2.0];
    shimmeringAnimation.duration = 2.0;
    shimmeringAnimation.repeatCount = INFINITY;
    [shimmeringLayer addAnimation:shimmeringAnimation forKey:SliderPlaceholderShimmeringAnimationKey];
}

- (void)removePlaceholderShimmeringGradient {
    if (self.placeholderTextLayer.mask != nil) {
        [self.placeholderTextLayer.mask removeAnimationForKey:SliderPlaceholderShimmeringAnimationKey];
        self.placeholderTextLayer.mask = nil;
    }
}

- (void)addPlaceholderSpotLightGradient {
    CAGradientLayer *spotLightLayer = [[CAGradientLayer alloc] init];
    spotLightLayer.frame = CGRectMake(0, 0, self.placeholderSpotLightTextLayer.bounds.size.width * 2.0, self.placeholderSpotLightTextLayer.bounds.size.height);
    spotLightLayer.colors = @[(id)[[UIColor clearColor] CGColor], (id)[[UIColor colorWithRed:88 / 255.0 green:211 / 255.0 blue:62 / 255.0 alpha:1.0] CGColor], (id)[[UIColor clearColor] CGColor]];
    spotLightLayer.startPoint = CGPointMake(0.0, 1.0);
    spotLightLayer.endPoint = CGPointMake(1.0, 1.0);
    spotLightLayer.locations = @[@0, @0.5, @1.0];
    self.placeholderSpotLightTextLayer.mask = spotLightLayer;

    CABasicAnimation *spotLightAnimation = [CABasicAnimation animationWithKeyPath:@"locations"];
    spotLightAnimation.fromValue = @[@-1.0, @-0.5, @0.0];
    spotLightAnimation.toValue = @[@1.0, @1.5, @2.0];
    spotLightAnimation.duration = 2.0;
    spotLightAnimation.repeatCount = INFINITY;
    [spotLightLayer addAnimation:spotLightAnimation forKey:SliderPlaceholderSpotLightAnimationKey];
}

- (void)removePlaceholderSpotLightGradient {
    if (self.placeholderSpotLightTextLayer.mask != nil) {
        [self.placeholderSpotLightTextLayer.mask removeAnimationForKey:SliderPlaceholderSpotLightAnimationKey];
        self.placeholderSpotLightTextLayer.mask = nil;
    }
}

- (void)updatePlaceholderTextLayer {
    if (self.placeholderTextLayer != nil) {
        CGRect placeholderTextRect = [self.placeholderText boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont fontWithName:@"PingFangTC-Semibold" size:16.0]} context:nil];
        [self.placeholderTextLayer setString:self.placeholderText];
        [self.placeholderTextLayer setForegroundColor:self.placeholderTextColor.CGColor];
        [self.placeholderTextLayer setFrame:placeholderTextRect];
        [self.placeholderTextLayer setFont:CFBridgingRetain([UIFont fontWithName:@"PingFangTC-Semibold" size:16.0].fontName)];
        [self.placeholderTextLayer setAlignmentMode:kCAAlignmentCenter];
        [self.placeholderTextLayer setFontSize:16.0];
        [self.placeholderTextLayer setContentsScale:[[UIScreen mainScreen] scale]];
        self.placeholderTextLayer.masksToBounds = YES;
        self.placeholderTextLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
}

- (void)updatePlaceholderSpotLightTextLayer {
    if (self.placeholderSpotLightTextLayer != nil) {
        NSString *spotLightText = self.animationType == AJShimmeringSliderViewAnimationTypeSpotLight ? self.placeholderText : @"";
        CGRect placeholderTextRect = [spotLightText boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont fontWithName:@"PingFangTC-Semibold" size:16.0]} context:nil];
        if (self.animationType == AJShimmeringSliderViewAnimationTypeSpotLight) {
            [self.placeholderSpotLightTextLayer setString:self.placeholderText];
        } else {
            [self.placeholderSpotLightTextLayer setString:@""];
        }
        [self.placeholderSpotLightTextLayer setForegroundColor:[[UIColor colorWithRed:88 / 255.0 green:211 / 255.0 blue:62 / 255.0 alpha:1.0] CGColor]];
        [self.placeholderSpotLightTextLayer setFrame:placeholderTextRect];
        [self.placeholderSpotLightTextLayer setFont:CFBridgingRetain([UIFont fontWithName:@"PingFangTC-Semibold" size:16.0].fontName)];
        [self.placeholderSpotLightTextLayer setAlignmentMode:kCAAlignmentCenter];
        [self.placeholderSpotLightTextLayer setFontSize:16.0];
        [self.placeholderSpotLightTextLayer setContentsScale:[[UIScreen mainScreen] scale]];
        self.placeholderSpotLightTextLayer.masksToBounds = YES;
        self.placeholderSpotLightTextLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
}
@end
