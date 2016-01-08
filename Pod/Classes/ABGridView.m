//
//  ABGridView.m
//  ABCropRotateView
//
//  Created by Anton Bukov on 08.01.16.
//

#import "ABGridView.h"

@implementation ABGridView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setX:(NSInteger)x {
    _x = x;
    [self setNeedsDisplay];
}

- (void)setY:(NSInteger)y {
    _y = y;
    [self setNeedsDisplay];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return NO;
}

CGFloat roundScale(CGFloat value) {
    CGFloat scale = [UIScreen mainScreen].scale;
    return round(value*scale)/scale;
}

- (void)drawRect:(CGRect)rect {
    if (self.x == 0 || self.y == 0)
        return;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat w = roundScale(width*self.x/MAX(self.x,self.y));
    CGFloat h = roundScale(height*self.y/MAX(self.x,self.y));
    CGFloat dx = roundScale(MAX(0,width/2-w/2));
    CGFloat dy = roundScale(MAX(0,height/2-h/2));
    
    // Fill outer bounds
    [[[UIColor blackColor] colorWithAlphaComponent:0.5] setFill];
    CGContextFillRect(context, CGRectMake(0,0,width,dy));
    CGContextFillRect(context, CGRectMake(0,0,dx,height));
    CGContextFillRect(context, CGRectMake(0,height-dy,width,dy));
    CGContextFillRect(context, CGRectMake(width-dx,0,dx,height));
    
    // Draw lines
    [[UIColor whiteColor] setStroke];
    CGContextSetShouldAntialias(context, NO);
    CGFloat scale = [UIScreen mainScreen].scale;
    CGContextSetLineWidth(context, 1/scale);
    CGContextAddRect(context, CGRectMake(dx, dy+1/scale, w-1/scale, h-1/scale));
    NSInteger linesCount = 3;
    for (NSInteger i = 1; i < linesCount; i++) {
        CGContextMoveToPoint(context, dx, dy+roundScale(h*i/linesCount));
        CGContextAddLineToPoint(context, w+dx-1/scale, dy+roundScale(h*i/linesCount));
        CGContextMoveToPoint(context, dx+roundScale(w*i/linesCount), dy+1/scale);
        CGContextAddLineToPoint(context, dx+roundScale(w*i/linesCount), h+dy);
    }
    CGContextDrawPath(context, kCGPathStroke);
}

@end
