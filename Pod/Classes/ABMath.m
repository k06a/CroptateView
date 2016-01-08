//
//  ABMath.m
//  ABCropRotateView
//
//  Created by Anton Bukov on 08.01.16.
//

#import "ABMath.h"

NSValue *val(CGPoint p) {
    return [NSValue valueWithCGPoint:p];
}

CGPoint rotate(CGPoint p, CGFloat a) {
    return CGPointMake(p.x*cos(a) - p.y*sin(a), p.x*sin(a) + p.y*cos(a));
}

CGPoint translate(CGPoint p, CGFloat x, CGFloat y) {
    return CGPointMake(p.x + x, p.y + y);
}

NSArray *rotateAll(NSArray *ps, CGFloat a) {
    NSMutableArray *r = [NSMutableArray array];
    for (NSValue *value in ps)
        [r addObject:val(rotate(value.CGPointValue, a))];
    return r;
}

NSArray *translateAll(NSArray *ps, CGFloat x, CGFloat y) {
    NSMutableArray *r = [NSMutableArray array];
    for (NSValue *value in ps)
        [r addObject:val(translate(value.CGPointValue, x, y))];
    return r;
}

/**
 * Computes the intersection point of two lines, both given as
 * a two-element array of Point.
 */
CGPoint intersection(NSArray *a, NSArray *b) {
    CGFloat x1 = [a[0] CGPointValue].x;
    CGFloat y1 = [a[0] CGPointValue].y;
    CGFloat x2 = [a[1] CGPointValue].x;
    CGFloat y2 = [a[1] CGPointValue].y;
    
    CGFloat x3 = [b[0] CGPointValue].x;
    CGFloat y3 = [b[0] CGPointValue].y;
    CGFloat x4 = [b[1] CGPointValue].x;
    CGFloat y4 = [b[1] CGPointValue].y;
    
    return CGPointMake (
        (((x1*y2 - y1*x2)*(x3 - x4) - (x1 - x2)*(x3*y4 - y3*x4))) / ((x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4)),
        (((x1*y2 - y1*x2)*(y3 - y4) - (y1 - y2)*(x3*y4 - y3*x4))) / ((x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4))
    );
}

/**
 * Perform the crop calculation.
 */
NSArray *crop(CGFloat originalWidth, CGFloat originalHeight, CGFloat angle,
              CGFloat targetWidth, CGFloat targetHeight)
{
    CGFloat angleInRadians = angle * (M_PI / 180);
    
    NSArray *original = @[
        val(CGPointZero),
        val(CGPointMake(originalWidth,0)),
        val(CGPointMake(originalWidth,originalHeight)),
        val(CGPointMake(0,originalHeight))
    ];
    
    // Center the original on the origin.
    original = translateAll(original, -originalWidth/2, -originalHeight/2);
    
    NSArray *rotated = rotateAll(original, angleInRadians);
    
    // Due to symmetry we could handle one of the cases below as a reflection of the other,
    // but that would make drawing the explanatory diagram a bit harder.
    
    if (angle >= 0) {
        // Ray goes through top left corner of inscribed rectangle.
        NSArray *ray = @[
            val(CGPointZero),
            val(CGPointMake(-targetWidth/2, -targetHeight/2))
        ];
        
        // Bound is line from top left to bottom left of rotated rectangle.
        NSArray *bound = @[rotated[0], rotated[3]];
        
        // Top Left intersection.
        CGPoint intersectTL = intersection(ray, bound);
        
        // Ray goes through top right corner of inscribed rectangle.
        NSArray *ray2 = @[
            val(CGPointZero),
            val(CGPointMake(targetWidth/2, -targetHeight/2))
        ];
        // Bound is line from top left to top right of rotated rectangle.
        NSArray *bound2 = @[rotated[0], rotated[1]];
        // Top Right intersection.
        CGPoint intersectTR = intersection(ray2, bound2);
        
        // Pick the intersection closest to the origin. Since the slopes are the same, we can just pick
        // the one with the biggest coordinate value (we compare in the quadrant where x and y are negative,
        // that's why max and not min is used).
        CGPoint intersect = CGPointMake(MAX(intersectTL.x, -intersectTR.x), MAX(intersectTL.y, intersectTR.y));

        return @[
            val(intersect),
            val(CGPointMake(-intersect.x, intersect.y)),
            val(CGPointMake(-intersect.x, -intersect.y)),
            val(CGPointMake(intersect.x, -intersect.y))
        ];
    } else {
        NSArray *ray = @[
            val(CGPointZero),
            val(CGPointMake(targetWidth/2, -targetHeight/2))
        ];
        NSArray *bound = @[rotated[1], rotated[2]];
        CGPoint intersectTR = intersection(ray, bound);
        
        NSArray *ray2 = @[
            val(CGPointZero),
            val(CGPointMake(-targetWidth/2, -targetHeight/2))
        ];
        NSArray *bound2 = @[rotated[0], rotated[1]];
        CGPoint intersectTL = intersection(ray2, bound2);
        
        CGPoint intersect = CGPointMake(MAX(intersectTL.x, -intersectTR.x), MAX(intersectTL.y, intersectTR.y));
        
        return @[
            val(intersect),
            val(CGPointMake(-intersect.x, intersect.y)),
            val(CGPointMake(-intersect.x, -intersect.y)),
            val(CGPointMake(intersect.x, -intersect.y))
        ];
    }
}

/**
 * Computes the width and height of a rectangle given as a list of four points.
 * It is assumed that ps[0] = top left, ps[1] = top right,
 * ps[2] = bottom right and ps[3] = bottom left.
 */
CGSize sizeOfRect(NSArray *ps) {
    return CGSizeMake([ps[1] CGPointValue].x - [ps[0] CGPointValue].x,
                      [ps[3] CGPointValue].y - [ps[0] CGPointValue].y);
}

/**
 *  Do the computations.
 */
CGSize compute(CGFloat originalWidth, CGFloat originalHeight,
               CGFloat targetWidth, CGFloat targetHeight, CGFloat a)
{
    return sizeOfRect(crop(originalWidth, originalHeight, a, targetWidth, targetHeight));
}
