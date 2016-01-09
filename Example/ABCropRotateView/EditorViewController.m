//
//  EditorViewController.m
//  ABCropRotateView
//
//  Created by Anton Bukov on 01.08.2016.
//

#import <ABCropRotateView/ABCropRotateView.h>
#import "EditorViewController.h"

@interface EditorViewController ()

@property (weak, nonatomic) IBOutlet ABCropRotateView *cropRotateView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cropRotateViewRatio;

@end

@implementation EditorViewController

#pragma mark - Actions

- (IBAction)resetRatio:(id)sender {
    [self.cropRotateView resetCropRatioToOriginalImageRatio];
}

- (IBAction)changeRatio:(UIButton *)sender {
    NSArray<NSString *> *xy = [sender.currentTitle componentsSeparatedByString:@":"];
    [self.cropRotateView setCropRatioX:xy[0].integerValue ratioY:xy[1].integerValue];
}

- (IBAction)angleChanged:(UISlider *)sender {
    self.cropRotateView.rotationAngle = sender.value*M_PI/180;
}

- (IBAction)doneTapped:(id)sender {
    [self.delegate editorController:self didEditPhoto:self.cropRotateView.resultImage];
}

- (IBAction)resizeTapped:(UIButton *)sender {
    NSArray<NSString *> *xy = [sender.currentTitle componentsSeparatedByString:@":"];
    [UIView animateWithDuration:0.3 animations:^{
        NSLayoutConstraint *ratioConstraint =
            [NSLayoutConstraint constraintWithItem:self.cropRotateViewRatio.firstItem
                                         attribute:self.cropRotateViewRatio.firstAttribute
                                         relatedBy:self.cropRotateViewRatio.relation
                                            toItem:self.cropRotateViewRatio.secondItem
                                         attribute:self.cropRotateViewRatio.secondAttribute
                                        multiplier:xy[0].doubleValue/xy[1].doubleValue
                                          constant:self.cropRotateViewRatio.constant];
        [self.cropRotateView removeConstraint:self.cropRotateViewRatio];
        [self.cropRotateView addConstraint:ratioConstraint];
        self.cropRotateViewRatio = ratioConstraint;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - View

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cropRotateView.image = self.image;
}

@end
