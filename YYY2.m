//
//  YYY2.m
//  test_imageMag_01
//
//  Created by admin on 15/11/17.
//  Copyright © 2015年 admin. All rights reserved.
//

#import "YYY2.h"

@implementation YYY2
#pragma 222
MagickWand *mw = NewMagickWand();
MagickSetFormat(mw, "gif");
NSLog(@"Going into ImageMagick stuff");
int var = 0;
for (UIImage *img in imgs) {
    MagickWand *localWand = NewMagickWand();
    NSData *dataObj = UIImagePNGRepresentation(img);
    MagickReadImageBlob(localWand, [dataObj bytes], [dataObj length]);
    duration = [(NSNumber *)_gifFrameProperties[var] floatValue];
    if (duration == 0) {
        duration = 0.03; //(gif delay time default is 0.1)
    }
    size_t delayTime = (size_t)duration * 100;
    MagickSetImageDelay(localWand, delayTime);
    MagickAddImage(mw, localWand);
    DestroyMagickWand(localWand);
    var++;
    NSLog(@"the value is >>>>>>> %d", var);
}
@end
