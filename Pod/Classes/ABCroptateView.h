//
//  ABCropRotateView.h
//  ABCropRotateView
//
//  Created by Anton Bukov on 08.01.16.
//

#import <UIKit/UIKit.h>

@interface ABCroptateView : UIView

// Image
@property (strong, nonatomic) UIImage *image;
@property (readonly, nonatomic) UIImage *resultImage;

// Crop
@property (readonly, nonatomic) NSInteger cropRatioX;
@property (readonly, nonatomic) NSInteger cropRatioY;
- (void)resetCropRatioToOriginalImageRatio;
- (void)setCropRatioX:(NSInteger)ratioX ratioY:(NSInteger)ratioY;

// Rotate
@property (assign, nonatomic) CGFloat rotationAngle;

@end
