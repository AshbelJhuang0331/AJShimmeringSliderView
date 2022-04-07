//
//  AJShimmeringSliderView.h
//  AJShimmeringSliderView
//
//  Created by ChuanJie Jhuang on 2020/3/4.
//  Copyright © 2020 ChuanJie Jhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AJShimmeringSliderView;
@protocol AJShimmeringSliderViewDelegate <NSObject>

@optional

/// Tells the delegate when the user begin slide view within the receiver.
/// @param sliderView The slider-view object in which the slider began.
- (void)shimmeringSliderViewDidBeginSliding:(AJShimmeringSliderView *)sliderView;

/// Tells the delegate when the user is sliding view within the receiver.
/// @param sliderView The slider-view object in which the slider moved.
- (void)shimmeringSliderViewDidMove:(AJShimmeringSliderView *)sliderView;

/// Tells the delegate when the user is sliding view to end within the receiver.
/// @param sliderView  The slider-view object in which the slider moving ended.
- (void)shimmeringSliderViewDidEndSliding:(AJShimmeringSliderView *)sliderView;

/// Tells the delegate when the slider-view back to start within the receiver.
/// @param sliderView The slider-view object in which the slider backing to start position.
- (void)shimmeringSliderViewDidAutoBounceBackToInitialPosition:(AJShimmeringSliderView *)sliderView;
@end

IB_DESIGNABLE
@interface AJShimmeringSliderView : UIView

typedef NS_ENUM(NSUInteger, AJShimmeringSliderViewAnimationType) {
    // Default place holder animation effect which is shimmering.
    AJShimmeringSliderViewAnimationTypeDefault = 0,
    // Placeholder shimmering animation effect.
    AJShimmeringSliderViewAnimationTypeShimmering = 1,
    // Placeholder spotlight animation effect.
    AJShimmeringSliderViewAnimationTypeSpotLight = 2,
};

/// The delegate of the slider-view object.
@property (nonatomic, weak) id<AJShimmeringSliderViewDelegate> delegate;

/// Moving progress.
@property (nonatomic, assign) IBInspectable CGFloat progress;

/// Filled in color of the slider-view object.
@property (nonatomic, strong) IBInspectable UIColor *filledInColor;

/// Corner radius of the slider-view object.
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;

/// Border width of the slider-view object.
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;

/// Border color of the slider-view object.
@property (nonatomic, assign) IBInspectable UIColor *borderColor;

/// Placeholder text of the slider-view object.
@property (nonatomic, strong) IBInspectable NSString *placeholderText;

/// Placeholder text color of the slider-view object.
@property (nonatomic, strong) IBInspectable UIColor *placeholderTextColor;

/// Indicator outline color of the slider-view object.
@property (nonatomic, strong) IBInspectable UIColor *indicatorOutlineColor;

/// Indicator image of the slider-view object.
@property (nonatomic, strong) IBInspectable UIImage *indicatorImage;

/// Whether slider-view object is auto bouncing back.
@property (nonatomic, assign) IBInspectable BOOL isAutoBounceBack;

/// The threshold to full of the slider-view object.
@property (nonatomic, assign) IBInspectable CGFloat fullThreshold;

/// Animation type of the slider-view object.
@property (nonatomic, assign) IBInspectable AJShimmeringSliderViewAnimationType animationType;

@end

NS_ASSUME_NONNULL_END
