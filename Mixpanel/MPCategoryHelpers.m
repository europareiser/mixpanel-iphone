#import "MPCategoryHelpers.h"
#import <QuartzCore/QuartzCore.h>

// NB If you add any more fingerprint methods, increment this.
#define MP_FINGERPRINT_VERSION 1

@implementation UIView (MPHelpers)

- (int)mp_fingerprintVersion
{
    return MP_FINGERPRINT_VERSION;
}

- (UIImage *)mp_snapshotImage
{
    CGFloat offsetHeight = 0.0f;
    
    //Avoid the status bar on phones running iOS < 7
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] == NSOrderedAscending &&
        ![UIApplication sharedApplication].statusBarHidden) {
        offsetHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    CGSize size = self.layer.bounds.size;
    size.height -= offsetHeight;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0f, -offsetHeight);
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self drawViewHierarchyInRect:CGRectMake(0.0f, 0.0f, size.width, size.height) afterScreenUpdates:YES];
    } else {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
#else
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
#endif
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)mp_snapshotForBlur
{
    UIImage *image = [self mp_snapshotImage];
    // hack, helps with colors when blurring
    NSData *imageData = UIImageJPEGRepresentation(image, 1); // convert to jpeg
    return [UIImage imageWithData:imageData];
}

@end