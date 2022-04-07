//
//  ViewController.m
//  AJShimmeringSliderView
//
//  Created by Chuan-Jie Jhuang on 2022/4/7.
//

#import "ViewController.h"
#import "AJShimmeringSliderView.h"

@interface ViewController ()<AJShimmeringSliderViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet AJShimmeringSliderView *sliderView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sliderView.delegate = self;
}

#pragma mark - AJShimmeringSliderViewDelegate

- (void)shimmeringSliderViewDidBeginSliding:(AJShimmeringSliderView *)sliderView {
   
}

- (void)shimmeringSliderViewDidMove:(AJShimmeringSliderView *)sliderView {
    _progressLabel.text = [NSString stringWithFormat:@"progress: %.2f", sliderView.progress];
}

- (void)shimmeringSliderViewDidEndSliding:(AJShimmeringSliderView *)sliderView {
    _progressLabel.text = [NSString stringWithFormat:@"progress: %.2f", sliderView.progress];
}

- (void)shimmeringSliderViewDidAutoBounceBackToInitialPosition:(AJShimmeringSliderView *)sliderView {
    _progressLabel.text = [NSString stringWithFormat:@"progress: %.2f", sliderView.progress];
}

@end
