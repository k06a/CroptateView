//
//  ABCropRotateView.m
//  ABCropRotateView
//
//  Created by Anton Bukov on 08.01.16.
//

#import "ABMath.h"
#import "ABGridView.h"
#import "ABCroptateView.h"

@interface ABCroptateView () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) ABGridView *cropGridView;

@property (nonatomic, strong) NSIndexPath *selectedCropIndexPath;
@property (nonatomic, assign) NSInteger selectedTag;
@property (nonatomic, assign) CGPoint centerRotateOffset;
@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, readonly) CGFloat angleScale;
@property (nonatomic, assign) CGFloat deltaX;
@property (nonatomic, assign) CGFloat deltaY;

@end

@implementation ABCroptateView

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image {
    [self.imageView removeFromSuperview];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    [self.scrollView addSubview:self.imageView];
    
    [self resetCropRatioToOriginalImageRatio];
    [UIView performWithoutAnimation:^{
        [self updateScrollViewSettings];
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView performWithoutAnimation:^{
            //[self updateScrollViewSettings];
        }];
    });
}

- (UIImage *)resultImage {
    return [self createResultImage];
}

- (NSInteger)cropRatioX {
    return self.cropGridView.x;
}

- (NSInteger)cropRatioY {
    return self.cropGridView.y;
}

- (void)resetCropRatioToOriginalImageRatio {
    self.cropGridView.x = self.image.size.width;
    self.cropGridView.y = self.image.size.height;
    [self updateScrollViewSettings];
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
}

- (void)setCropRatioX:(NSInteger)ratioX ratioY:(NSInteger)ratioY {
    self.cropGridView.x = ratioX;
    self.cropGridView.y = ratioY;
    [self updateScrollViewSettings];
}

- (void)setRotationAngle:(CGFloat)rotationAngle {
    _rotationAngle = rotationAngle;
    [self updateScrollViewSettings];
}

- (CGFloat)angle {
    if (isnan(_rotationAngle) || isinf(_rotationAngle))
        return 0;
    return _rotationAngle;
}

#pragma mark - View

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.clipsToBounds = YES;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.scrollView.layer.shouldRasterize = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.bouncesZoom = YES;
    self.scrollView.bounces = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] init];
    [self.scrollView addSubview:self.imageView];
    
    self.cropGridView = [[ABGridView alloc] initWithFrame:self.bounds];
    self.cropGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.cropGridView];
}

- (void)dealloc {
    self.scrollView.delegate = nil;
}

- (void)layoutSubviews {
    [self letsLayout];
}

- (void)layoutIfNeeded {
    [self letsLayout];
}

- (void)letsLayout {
    CGAffineTransform tr = self.scrollView.transform;
    self.scrollView.transform = CGAffineTransformIdentity;
    self.scrollView.frame = self.bounds; // Access frame when transform is identity
    self.scrollView.transform = tr;
    
    [self updateScrollViewSettings];
}

#pragma mark - Calculations

- (CGFloat)angleScale {
    CGSize size = compute(self.imageView.image.size.width,
                          self.imageView.image.size.height,
                          self.cropGridView.x,
                          self.cropGridView.y,
                          self.angle*180/M_PI);
    
    CGFloat r = sqrt(size.width*size.width + size.height*size.height);
    
    CGFloat w, h;
    CGFloat t;
    if (self.imageView.image.size.width/self.imageView.image.size.height <
        self.cropGridView.x*1.0/self.cropGridView.y) {
        w = self.imageView.image.size.width;
        h = w/self.cropGridView.x*self.cropGridView.y;
        t = self.imageView.image.size.width/size.width;
    } else {
        h = self.imageView.image.size.height;
        w = h/self.cropGridView.y*self.cropGridView.x;
        t = self.imageView.image.size.height/size.height;
    }
    
    self.deltaX = ^{
        CGFloat vv = cos(ABS(self.angle) + atan2(self.cropGridView.y,self.cropGridView.x))*r/2;
        CGFloat v = cos(M_PI_2-ABS(self.angle))*size.height;
        return w/2-(vv+v);
    }();
    self.deltaY = ^{
        CGFloat vv = cos(ABS(self.angle) + atan2(self.cropGridView.x,self.cropGridView.y))*r/2;
        CGFloat v = cos(M_PI_2-ABS(self.angle))*size.width;
        return h/2-(vv+v);
    }();
    
    if (isnan(t) || isinf(t))
        return 1;
    return t;
}

- (UIImage *)createResultImage {
    /*
    if (self.cropGridView.x == self.imageView.image.size.width &&
        self.cropGridView.y == self.imageView.image.size.height &&
        ABS(self.angle) < 0.01)
    {
        return self.imageView.image;
    }
    */
    
    CGFloat width = self.cropGridView.bounds.size.width;
    CGFloat height = self.cropGridView.bounds.size.height;
    CGFloat w = width*self.cropGridView.x/MAX(self.cropGridView.x,self.cropGridView.y);
    CGFloat h = height*self.cropGridView.y/MAX(self.cropGridView.x,self.cropGridView.y);
    
    CGFloat aScale = [UIScreen mainScreen].scale;
    CGFloat zoomScale = self.scrollView.zoomScale;
    
    UIEdgeInsets inset = self.scrollView.contentInset;
    inset.top = round(inset.top*aScale)/aScale;
    inset.bottom = round(inset.bottom*aScale)/aScale;
    inset.left = round(inset.left*aScale)/aScale;
    inset.right = round(inset.right*aScale)/aScale;
    CGRect rect = CGRectMake(self.scrollView.contentOffset.x+inset.left-self.deltaX*zoomScale/2,self.scrollView.contentOffset.y+inset.top-self.deltaY*zoomScale/2,w,h);
    
    rect.origin.x /= zoomScale;
    rect.origin.y /= zoomScale;
    rect.size.width /= zoomScale;
    rect.size.height /= zoomScale;
    
    CGPoint p = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGPoint p2 = [self.scrollView.superview convertPoint:CGPointMake(self.scrollView.superview.bounds.size.width/2,self.scrollView.superview.bounds.size.height/2) toView:self.imageView];
    rect.origin.x -= p.x - p2.x;
    rect.origin.y -= p.y - p2.y;
    
    rect.origin.x = round(rect.origin.x);
    rect.origin.y = round(rect.origin.y);
    rect.size.width = round(rect.size.width);
    rect.size.height = round(rect.size.height);
    
    return [self crop:self.imageView.image rect:rect angle:self.angle scale:self.angleScale];
}

- (UIImage*)crop:(UIImage *)image rect:(CGRect)rect angle:(CGFloat)angle scale:(CGFloat)angleScale {
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, CGRectGetWidth(rect)/2, CGRectGetHeight(rect)/2);
    CGContextRotateCTM(context, angle);
    CGContextScaleCTM(context, angleScale, angleScale);
    CGContextTranslateCTM(context, -CGRectGetWidth(rect)/2, -CGRectGetHeight(rect)/2);
    [image drawAtPoint:CGPointMake(-CGRectGetMinX(rect), -CGRectGetMinY(rect))];
    UIImage *cropped_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cropped_image;
}

#pragma mark - Scroll View

- (void)updateScrollViewSettings {
    if (self.cropGridView.x == 0 || self.cropGridView.y == 0)
        return;
    
    CGFloat angle = self.angle;
    CGFloat angleScale = self.angleScale;
    
    CGFloat width = self.imageView.image.size.width;
    CGFloat height = self.imageView.image.size.height;
    CGFloat xx = self.cropGridView.x;
    CGFloat yy = self.cropGridView.y;
    
    CGFloat w, h;
    if (width/height < xx/yy) { //wider
        w = width;
        h = w/xx*yy;
    } else {
        h = height;
        w = h/yy*xx;
    }
    CGFloat zoomScale = MIN(self.scrollView.bounds.size.width/w, self.scrollView.bounds.size.height/h);
    CGFloat dx = MAX(0,self.scrollView.bounds.size.width/2-w/2*zoomScale+self.deltaX*zoomScale);
    CGFloat dy = MAX(0,self.scrollView.bounds.size.height/2-h/2*zoomScale+self.deltaY*zoomScale);
    
    self.scrollView.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.25 delay:0.0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        self.scrollView.contentInset = UIEdgeInsetsMake(dy,dx,dy,dx);
        self.scrollView.minimumZoomScale = MIN(zoomScale,1.0);
        self.scrollView.maximumZoomScale = MAX(zoomScale,1.0);
        self.scrollView.zoomScale = self.cropGridView.hidden ? self.scrollView.minimumZoomScale : MIN(self.scrollView.maximumZoomScale,MAX(self.scrollView.minimumZoomScale,self.scrollView.zoomScale));
    } completion:^(BOOL finished) {
        self.scrollView.userInteractionEnabled = !self.cropGridView.hidden;
    }];
    
    self.scrollView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(angle),angleScale,angleScale);
    self.cropGridView.hidden = (ABS(angle)*180/M_PI < 0.3 && ABS(self.cropGridView.x*1.0/self.cropGridView.y - self.imageView.image.size.width*1.0/self.imageView.image.size.height) < FLT_EPSILON);
    self.scrollView.userInteractionEnabled = !self.cropGridView.hidden;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
