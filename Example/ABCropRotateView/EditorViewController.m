//
//  EditorViewController.m
//  ABCropRotateView
//
//  Created by Anton Bukov on 01.08.2016.
//

#import <ABCropRotateView/ABCropRotateView.h>
#import "EditorViewController.h"

@interface EditorViewController ()

@property (strong, nonatomic) IBOutlet ABCropRotateView *cropRotateView;

@end

@implementation EditorViewController

#pragma mark - Actions

- (IBAction)resetRatio:(id)sender {
    [self.cropRotateView resetCropRatioToOriginalImageRatio];
}

- (IBAction)changeRatio:(UIButton *)sender {
    NSArray<NSString *> *xy = [sender.currentTitle componentsSeparatedByString:@":"];
    [self.cropRotateView setCropRatioX:[xy[0] integerValue] ratioY:[xy[1] integerValue]];
}

- (IBAction)angleChanged:(UISlider *)sender {
    self.cropRotateView.rotationAngle = sender.value*M_PI/180;
}

- (IBAction)doneTapped:(id)sender {
    [self.delegate editorController:self didEditPhoto:self.cropRotateView.resultImage];
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
