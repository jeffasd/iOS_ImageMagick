//
//  ViewController.m
//  test_imageMag_01
//
//  Created by admin on 15/11/17.
//  Copyright © 2015年 admin. All rights reserved.
//

#import "ViewController.h"
//#import "MagickWand.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>
#import <wand/MagickWand.h>
#import "YLGIFImage.h"
#import "YLImageView.h"

#define GIFINBOUNDLENAME        @"joy"
//#define GIFINBOUNDLENAME        @"jiafei"
#define DIRECTORYNAME_NORMAL          @"Normal"
#define DIRECTORYNAME_GIF           @"gif"

#define compressionQuality_Decode   0.1
#define compressionQuality_Create   0.75

#define ISDEFINE_WAND_1

@interface ViewController ()
{
    CGFloat duration;
    dispatch_queue_t _queueSerial;
    NSBlockOperation *_operation;
}
@property(nonatomic, strong)NSMutableArray *gifFrameProperties;
@property(nonatomic, strong)NSDictionary *gifProperties_jeffasd;
@end

@implementation ViewController

- (NSMutableArray *)gifFrameProperties
{
    if (_gifFrameProperties == nil) {
        _gifFrameProperties = [NSMutableArray new];
    }
    return _gifFrameProperties;
}

- (NSDictionary *)gifProperties_jeffasd
{
    if (_gifProperties_jeffasd == nil) {
        _gifProperties_jeffasd = [NSDictionary new];
    }
    return _gifProperties_jeffasd;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
//    NSData *data1 = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:GIFINBOUNDLENAME ofType:@"gif"]];
    
//JPEG
//    2015-11-18 14:23:09.548 test_imageMag_01[1263:71499] +++++111111
//    2015-11-18 14:23:13.909 test_imageMag_01[1263:71499] +++++222222
    
    //png
//    015-11-18 14:24:54.549 test_imageMag_01[1299:72888] +++++111111
//    2015-11-18 14:25:01.330 test_imageMag_01[1299:72888] +++++222222
    
//    NSLog(@"+++++111111");
//    [self decodeWithData:data1 GIFName:GIFINBOUNDLENAME];
//    NSLog(@"+++++222222");
    
    

    
    _queueSerial = dispatch_queue_create("serial", NULL);
    
    NSLog(@"the thread is %@", [NSThread currentThread]);
    [self decodeGIF];
    [self createGIF];
    
    
    
//    [self creategifImage:@"test_gif"];
    
//    [self showGIF:@"test_gif.gif"];
    
}

- (void)decodeGIF
{
    dispatch_async(_queueSerial, ^{
        NSLog(@"the ----------thread is %@", [NSThread currentThread]);
        //耗时的异步操作
        NSData *data1 = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:GIFINBOUNDLENAME ofType:@"gif"]];
        NSLog(@"+++++111111");
        [self decodeWithData:data1 GIFName:GIFINBOUNDLENAME];
        NSLog(@"+++++222222");
        dispatch_async(dispatch_get_main_queue(), ^{
            //回到主线程刷新UI
        });
    });
}

- (void)createGIF
{
    dispatch_async(_queueSerial, ^{
        
        NSLog(@"the ----------thread is %@", [NSThread currentThread]);
        //耗时的异步操作
        
//        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        _operation = [NSBlockOperation blockOperationWithBlock:^{
            
            [self creategifImage:@"test_gif"];
            dispatch_async(dispatch_get_main_queue(), ^{
                //回到主线程刷新UI
                [self showGIF:@"test_gif.gif"];
            });
            
        }];
        
        [_operation start];
        
//        if (_operation.isCancelled) {
//            NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
//            return;
//        }
        
//        [self creategifImage:@"test_gif"];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //回到主线程刷新UI
//            [self showGIF:@"test_gif.gif"];
//        });
        
        
    });
}

- (void)creategifImage:(NSString *)gifName
{
    NSArray *fileList = [self findGIFImageInNormal:GIFINBOUNDLENAME];
    NSMutableArray *dImgs = [NSMutableArray array];
    //合成gif
    int i = 0;
    NSString *filePath = [self imageDirectoryPath:DIRECTORYNAME_NORMAL];
    for (NSString *gifName in fileList) {
        //        float frameDuration = [(NSNumber *)_gifFrameProperties[i] floatValue];
        //        NSDictionary *frameProperty = [NSDictionary
        //                                       dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:frameDuration], (NSString *)kCGImagePropertyGIFDelayTime, nil]
        //                                       forKey:(NSString *)kCGImagePropertyGIFDictionary];
        NSString *fileURL = [filePath stringByAppendingPathComponent:gifName];
        
        [dImgs addObject:[UIImage imageWithContentsOfFile:fileURL]];
        
        //        CGImageDestinationAddImage(destination, [UIImage imageWithContentsOfFile:fileURL].CGImage, (__bridge CFDictionaryRef)frameProperty);
        //        CGImageDestinationAddImage(destination, dImg.CGImage, (__bridge CFDictionaryRef)_gifFrameProperties[i]);
        //        NSLog(@"the frameproperty is %@", _gifFrameProperties[i]);
        i++;
    }
    NSLog(@"---------------- Terminated due to memory issue");
    
    NSMutableArray *imgs = [[NSMutableArray alloc] init];
//    NSMutableArray *frames = [[NSMutableArray alloc] init];
    imgs = dImgs;
//    dImgs = nil;
    
    //创建输出路径
    NSString *documentStr = [self backPath:DIRECTORYNAME_GIF];
    NSString *pathName = [NSString stringWithFormat:@"%@.gif",gifName];
    NSString *path = [documentStr stringByAppendingPathComponent:pathName];
    NSLog(@"%@",path);
    
//    MagickWandGenesis();
    
    /**
     
     MagickSetFormat
     MagickSetFormat() sets the format of the magick wand.
     
     The format of the MagickSetFormat method is:
     
     MagickBooleanType MagickSetFormat(MagickWand *wand,const char *format)
     A description of each parameter follows:
     
     wand
     the magick wand.
     format
     the image format.
     
     MagickGetImageBlob
     MagickGetImageBlob() implements direct to memory image formats. It returns the image as a blob (a formatted "file" in memory) and its length, starting from the current position in the image sequence. Use MagickSetImageFormat() to set the format to write to the blob (GIF, JPEG, PNG, etc.).
     
     Utilize MagickResetIterator() to ensure the write is from the beginning of the image sequence.
     
     Use MagickRelinquishMemory() to free the blob when you are done with it.
     
     The format of the MagickGetImageBlob method is:
     
     unsigned char *MagickGetImageBlob(MagickWand *wand,size_t *length)
     A description of each parameter follows:
     
     wand
     the magick wand.
     length
     the length of the blob.
     
     MagickGetImagesBlob
     MagickGetImagesBlob() implements direct to memory image formats. It returns the image sequence as a blob and its length. The format of the image determines the format of the returned blob (GIF, JPEG, PNG, etc.). To return a different image format, use MagickSetImageFormat().
     
     Note, some image formats do not permit multiple images to the same image stream (e.g. JPEG). in this instance, just the first image of the sequence is returned as a blob.
     
     The format of the MagickGetImagesBlob method is:
     
     unsigned char *MagickGetImagesBlob(MagickWand *wand,size_t *length)
     A description of each parameter follows:
     
     wand
     the magick wand.
     length
     the length of the blob.
     
     MagickSetImageDelay
     MagickSetImageDelay() sets the image delay.
     
     The format of the MagickSetImageDelay method is:
     
     MagickBooleanType MagickSetImageDelay(MagickWand *wand,
     const size_t delay)
     A description of each parameter follows:
     
     wand
     the magick wand.
     delay
     the image delay in ticks-per-second units.
     
     
     MagickSetImageFormat
     MagickSetImageFormat() sets the format of a particular image in a sequence.
     
     The format of the MagickSetImageFormat method is:
     
     MagickBooleanType MagickSetImageFormat(MagickWand *wand,
     const char *format)
     A description of each parameter follows:
     
     wand
     the magick wand.
     format
     the image format.
     
     MagickWriteImages
     MagickWriteImages() writes an image or image sequence.
     
     The format of the MagickWriteImages method is:
     
     MagickBooleanType MagickWriteImages(MagickWand *wand,
     const char *filename,const MagickBooleanType adjoin)
     A description of each parameter follows:
     
     wand
     the magick wand.
     filename
     the image filename.
     adjoin
     join images into a single multi-image file.
     
     */
    
#pragma 111
#ifdef ISDEFINE_WAND_1
    MagickWandGenesis();
    MagickWand *mw = NewMagickWand();
//    MagickSetImageFormat(mw, "gif");
    NSString *imageFormat = @"GIF";
    MagickSetImageFormat(mw, [imageFormat cStringUsingEncoding:NSUTF8StringEncoding]);
    //抗锯齿
    MagickBooleanType typeAntialias = MagickSetAntialias(mw, MagickTrue);
    NSLog(@"the MagickBooleanTypeis %u ", typeAntialias);
    
    //压缩类型
    MagickSetCompression(mw, JPEGCompression);
    //压缩质量
    MagickSetCompressionQuality(mw, 1000);
    
//    MagickMontageImage
    //压缩类型
    MagickSetImageCompression(mw,JPEGCompression);
    
//    设置图像压缩质量
    MagickSetImageCompressionQuality(mw, 1);
    
//    MagickSetImageType(mw,MagickGetImageType(mw));
    
    NSLog(@"Going into ImageMagick stuff");
    int var = 0;
    for (UIImage *img in imgs)
    {
        if (_operation.isCancelled) {
            NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
            return;
        }
        
        MagickWand *localWand = NewMagickWand();
        NSData* dataObj = UIImageJPEGRepresentation(img, compressionQuality_Create);
//        NSData *dataObj = UIImagePNGRepresentation(img);
        MagickReadImageBlob(localWand, [dataObj bytes], [dataObj length]);
        duration = [(NSNumber *)_gifFrameProperties[var] floatValue];
        if (duration == 0) {
            duration = 0.03; //(gif delay time default is 0.1)
        }
        size_t delayTime = (size_t)roundf(duration * 100);
//        NSLog(@"the delay is %zu", delayTime);
        MagickSetImageDelay(localWand, delayTime);
        MagickAddImage(mw, localWand);
        
//        //压缩类型
//        MagickSetImageCompression(mw,JPEGCompression);
//        //    设置图像压缩质量
//        MagickSetImageCompressionQuality(mw, 1);
        
        DestroyMagickWand(localWand);
        var++;
        NSLog(@"the value is >>>>>>> %d", var);
    }
    //    2015-11-18 13:42:44.683 test_imageMag_01[995:55096] 111111-------------
    //    2015-11-18 13:44:26.489 test_imageMag_01[995:55096] 222222-------------
    NSLog(@"111111-------------");
    MagickWriteImages(mw, [path cStringUsingEncoding:NSUTF8StringEncoding], MagickTrue);
    NSLog(@"222222-------------");
    mw = DestroyMagickWand(mw);
    MagickWandTerminus();
#endif
    
#pragma 222
#ifdef ISDEFINE_WAND_2
    MagickWandGenesis();
    MagickWand *mw = NewMagickWand();
    MagickSetFormat(mw, "gif");
    
//    //抗锯齿
//    MagickBooleanType typeAntialias = MagickSetAntialias(mw, MagickTrue);
//    NSLog(@"the MagickBooleanTypeis %u ", typeAntialias);
    
    NSLog(@"Going into ImageMagick stuff");
    int var = 0;
    for (UIImage *img in imgs) {
        MagickWand *localWand = NewMagickWand();
        NSData* dataObj = UIImageJPEGRepresentation(img, compressionQuality_Create);
//        NSData *dataObj = UIImagePNGRepresentation(img);
        MagickReadImageBlob(localWand, [dataObj bytes], [dataObj length]);
        duration = [(NSNumber *)_gifFrameProperties[var] floatValue];
        if (duration == 0) {
            duration = 0.03; //(gif delay time default is 0.1)
        }
        size_t delayTime = (size_t)roundf(duration * 100);
//        NSLog(@"the delayTime is %zu", delayTime);
        MagickSetImageDelay(localWand, delayTime);
        MagickAddImage(mw, localWand);
        DestroyMagickWand(localWand);
        var++;
        NSLog(@"the value is >>>>>>> %d", var);
    }
    size_t my_size;
    MagickResetIterator(mw);
    NSLog(@"This is the part that takes forever");
    //Note, some image formats do not permit multiple images to the same image stream (e.g. JPEG). in this instance, just the first image of the sequence is returned as a blob.
//    2015-11-18 13:45:53.096 test_imageMag_01[1025:56261] This is the part that takes forever
//    2015-11-18 13:47:36.175 test_imageMag_01[1025:56261] the my_size is 61979276
    unsigned char * my_image = MagickGetImagesBlob(mw, &my_size);
//    NSLog(@"the my_size is %zu", my_size);
    NSData *dataGIF = [[NSData alloc] initWithBytes:my_image length:my_size];
    free(my_image);
//    mw = DestroyMagickWand(mw);
    DestroyMagickWand(mw);
    MagickWandTerminus();
//    NSLog(@"%@",path);
//    NSLog(@"111111");
    [dataGIF writeToFile:path atomically:YES];
    NSLog(@"222222");
//    NSLog(@"the gif has created-----");
#endif
    
//    frames = dImgs;
//    MagickWand *mw = NewMagickWand();
//    MagickSetFormat(mw, "gif");
//    NSLog(@"Going into ImageMagick stuff");
//    for (UIImage *img in frames) {
//        MagickWand *localWand = NewMagickWand();
//        NSData *dataObj = UIImagePNGRepresentation(img);
//        MagickReadImageBlob(localWand, [dataObj bytes], [dataObj length]);
//        //0.1 * 100 0.03 * 100 3
//        MagickSetImageDelay(localWand, 3);
//        MagickAddImage(mw, localWand);
//        DestroyMagickWand(localWand);
//    }
//    size_t my_size;
//    NSLog(@"This is the part that takes forever");
//    unsigned char * my_image = MagickGetImagesBlob(mw, &my_size);
//    NSLog(@"the my_size is %zu", my_size);
//    NSData *data = [[NSData alloc] initWithBytes:my_image length:my_size];
//    free(my_image);
//    DestroyMagickWand(mw);
//    
//    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    //    NSString *path = [paths objectAtIndex:0];
//    //    path = [NSString stringWithFormat:@"%@/animation.gif", path];
//    NSLog(@"Going to write to file");
//    
//    
////    //创建输出路径
////    NSString *documentStr = [self backPath:DIRECTORYNAME_GIF];
////    NSString *pathName = [NSString stringWithFormat:@"%@.gif",@"test_gif"];
////    NSString *path = [documentStr stringByAppendingPathComponent:pathName];
//    NSLog(@"%@",path);
//    
//    [data writeToFile:path atomically:YES];
//    NSLog(@"Wrote to file");
//    
//    NSURL *urlzor = [NSURL fileURLWithPath:path];
//    NSLog(@"%@", urlzor);
//    NSLog(@"%@", path);
    
    
    
//    NSString *documentStr = [self backPath:DIRECTORYNAME_GIF];
//    NSString *pathName = [NSString stringWithFormat:@"%@.gif",gifName];
//    NSString *path = [documentStr stringByAppendingPathComponent:pathName];
//    NSLog(@"%@",path);
    
    
//    MagickWand *mw = NewMagickWand();
//    MagickSetFormat(mw, "gif");
//    NSLog(@"Going into ImageMagick stuff");
//    for (UIImage *img in frames) {
//        MagickWand *localWand = NewMagickWand();
//        NSData *dataObj = UIImagePNGRepresentation(img);
//        MagickReadImageBlob(localWand, [dataObj bytes], [dataObj length]);
//        //0.1 * 100 0.03 * 100 3
//        MagickSetImageDelay(localWand, 3);
//        MagickAddImage(mw, localWand);
//        DestroyMagickWand(localWand);
//    }
//    size_t my_size;
//    NSLog(@"This is the part that takes forever");
//    unsigned char * my_image = MagickGetImagesBlob(mw, &my_size);
//    NSData *data = [[NSData alloc] initWithBytes:my_image length:my_size];
//    free(my_image);
//    DestroyMagickWand(mw);
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [paths objectAtIndex:0];
//    path = [NSString stringWithFormat:@"%@/animation.gif", path];
//    NSLog(@"Going to write to file");
//    
//    [data writeToFile:path atomically:YES];
//    NSLog(@"Wrote to file");
    
    
}

-(void)decodeWithData:(NSData *)data GIFName:(NSString *)gifName;
{
    //通过data获取image的数据源
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    //获取帧数
    size_t count = CGImageSourceGetCount(source);
    NSMutableArray* tmpArray = [NSMutableArray array];
    NSDictionary *imageProperties = CFBridgingRelease(CGImageSourceCopyProperties(source, NULL));
    self.gifProperties_jeffasd = [imageProperties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
//    NSLog(@"the gifPropertiy is %@", _gifProperties_jeffasd);
    for (size_t i = 0; i < count; i++)
    {
        //获取图像
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
        //生成image
        UIImage *image = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        //获取每一帧的图片信息
        NSDictionary* frameProperties = (__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(source, i, NULL) ;
        //保存每一帧图片信息
        //                [self.gifFrameProperties addObject:frameProperties];
//        NSLog(@"the frameproperty is %@", frameProperties);
        float frameDuration = [self frameDurationAtIndex:i source:source];
//        NSLog(@"the frameDuration is %3.9f", frameDuration);
        [self.gifFrameProperties addObject:[NSNumber numberWithFloat:frameDuration]];
        //                duration = [[[frameProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary] objectForKey:(NSString*)kCGImagePropertyGIFDelayTime] doubleValue];
        //                duration = MAX(duration, 0.01);
        
        [tmpArray addObject:image];
        CGImageRelease(imageRef);
    }
    //    NSLog(@"thd count is %lu, %@", (unsigned long)_gifFrameProperties.count, _gifFrameProperties);
    CFRelease(source);
    
    int i = 0;
    NSString *dircetoryPath = [self backPath:DIRECTORYNAME_NORMAL];
    for (UIImage *img in tmpArray) {
        
//        NSData *imageData = UIImagePNGRepresentation(img);//png花费时间比较长
        NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality_Decode);
        NSString *pathNum = [dircetoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.png",gifName, i]];
        
        //        NSData *imageData = UIImageJPEGRepresentation(img, 1);
        //        NSString *pathNum = [[self backPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d.jpeg",gifName, i]];
        
        [imageData writeToFile:pathNum atomically:NO];
        i++;
    }
}

//返回保存图片的路径
-(NSString *)backPath:(NSString *)directoryName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *imageDirectory = [path stringByAppendingPathComponent:directoryName];
    
    //    [fileManager createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    if (![fileManager fileExistsAtPath:imageDirectory]) {
        NSLog(@"there is no Directory: %@",imageDirectory);
        [fileManager createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"create Directory: Documents/%@",directoryName);
    }
    NSLog(@"the Directory is exist %@",imageDirectory);
    return imageDirectory;
}

- (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source
{
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source,index,nil);
    NSDictionary *frameProperties = (__bridge NSDictionary*)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString*)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString*)kCGImagePropertyGIFUnclampedDelayTime];
    if(delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    } else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString*)kCGImagePropertyGIFDelayTime];
        if(delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 0.011f)
        frameDuration = 0.100f;
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}
//返回保存图片的路径
-(NSString *)imageDirectoryPath:(NSString *)directoryName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *imageDirectory = [path stringByAppendingPathComponent:directoryName];
    return imageDirectory;
}
- (IBAction)createGif {
    
    NSArray *fileList = [self findGIFImageInNormal:GIFINBOUNDLENAME];
    NSMutableArray *dImgs = [NSMutableArray array];
    //合成gif
    int i = 0;
    NSString *filePath = [self imageDirectoryPath:DIRECTORYNAME_NORMAL];
    for (NSString *gifName in fileList) {
        //        float frameDuration = [(NSNumber *)_gifFrameProperties[i] floatValue];
        //        NSDictionary *frameProperty = [NSDictionary
        //                                       dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:frameDuration], (NSString *)kCGImagePropertyGIFDelayTime, nil]
        //                                       forKey:(NSString *)kCGImagePropertyGIFDictionary];
        NSString *fileURL = [filePath stringByAppendingPathComponent:gifName];
        
        [dImgs addObject:[UIImage imageWithContentsOfFile:fileURL]];
        
        //        CGImageDestinationAddImage(destination, [UIImage imageWithContentsOfFile:fileURL].CGImage, (__bridge CFDictionaryRef)frameProperty);
        //        CGImageDestinationAddImage(destination, dImg.CGImage, (__bridge CFDictionaryRef)_gifFrameProperties[i]);
        //        NSLog(@"the frameproperty is %@", _gifFrameProperties[i]);
        i++;
    }
    NSLog(@"---------------- Terminated due to memory issue");
    
    
    
    
    
    
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    //    int x = 1;
    //    UIImage *imagezor = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d", x] ofType:@"png"]];
    //    NSLog(@"%@", imagezor);
    //    while(imagezor != NULL) {
    //        [frames addObject:imagezor];
    //        x++;
    //        imagezor = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d", x] ofType:@"png"]];
    //        NSLog(@"%@", imagezor);
    //    }
    
    frames = dImgs;
    
    MagickWand *mw = NewMagickWand();
    MagickSetFormat(mw, "gif");
    NSLog(@"Going into ImageMagick stuff");
    for (UIImage *img in frames) {
        MagickWand *localWand = NewMagickWand();
        NSData *dataObj = UIImagePNGRepresentation(img);
        MagickReadImageBlob(localWand, [dataObj bytes], [dataObj length]);
        //0.1 * 100 0.03 * 100 3
        MagickSetImageDelay(localWand, 3);
        MagickAddImage(mw, localWand);
        DestroyMagickWand(localWand);
    }
    size_t my_size;
    NSLog(@"This is the part that takes forever");
    unsigned char * my_image = MagickGetImagesBlob(mw, &my_size);
    NSData *data = [[NSData alloc] initWithBytes:my_image length:my_size];
    free(my_image);
    DestroyMagickWand(mw);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [NSString stringWithFormat:@"%@/animation.gif", path];
    NSLog(@"Going to write to file");
    
    [data writeToFile:path atomically:YES];
    NSLog(@"Wrote to file");
    
    NSURL *urlzor = [NSURL fileURLWithPath:path];
    NSLog(@"%@", urlzor);
    NSLog(@"%@", path);
}


- (NSArray *)findGIFImageInNormal:(NSString *)gifName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //    NSString *strFile = [documentsDirectory stringByAppendingPathComponent:@"hello/config.plist"];
    //    NSLog(@"strFile: %@", strFile);
    
    NSString *strPath = [documentsDirectory stringByAppendingPathComponent:@"Normal"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:strPath]) {
        NSLog(@"there is no Directory: %@",strPath);
        //        [[NSFileManager defaultManager] createDirectoryAtPath:strPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //取得当前目录下的全部文件
    //    NSFileManager *fileManage = [NSFileManager defaultManager];
    //    NSArray *file = [fileManage subpathsOfDirectoryAtPath:strPath error:nil];
    //    NSArray *file = [self getFilenamelistOfType:@"png" fromDirPath:strPath];
    NSArray *file = [self getFilenamelistOfType:@"png" fromDirPath:strPath GIFName:gifName];
    //    NSLog(@"the file is %@", file);
    return file;
    
}

-(NSArray *) getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath GIFName:(NSString *)gifName
{
    NSArray *tempList = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil]
                         pathsMatchingExtensions:[NSArray arrayWithObject:type]];
    NSMutableArray *fileList = [NSMutableArray array];
    for (NSString *fileName in tempList) {
        //       NSString *name = [[fileName componentsSeparatedByString:@"."] objectAtIndex:0];
        //        if ([fileName isEqualToString:gifName] ) {
        ////            [fileList removeObject:fileName];
        //            [fileList addObject:fileName];
        //        }
        if ([fileName rangeOfString:gifName].location != NSNotFound) {
            //        if ([fileName rangeOfString:gifName] ) {
            //            [fileList removeObject:fileName];
            [fileList addObject:fileName];
        }
        
        //        NSLog(@"fileName is %@", name);
    }
    tempList = nil;
    
    //    //block比较方法，数组中可以是NSInteger，NSString（需要转换）
    //    NSComparator finderSort = ^(id string1,id string2){
    //
    //        if ([string1 integerValue] > [string2 integerValue]) {
    //            return (NSComparisonResult)NSOrderedDescending;
    //        }else if ([string1 integerValue] < [string2 integerValue]){
    //            return (NSComparisonResult)NSOrderedAscending;
    //        }
    //        else
    //            return (NSComparisonResult)NSOrderedSame;
    //    };
    //
    //    //数组排序：
    //    NSArray *resultArray = [fileList sortedArrayUsingComparator:finderSort];
    //    NSLog(@"第一种排序结果：%@",resultArray);
    
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|
    NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    NSComparator sort = ^(NSString *obj1,NSString *obj2){
        NSRange range = NSMakeRange(0,obj1.length);
        return [obj1 compare:obj2 options:comparisonOptions range:range];
    };
    NSArray *resultArray2 = [fileList sortedArrayUsingComparator:sort];
    //    NSLog(@"字符串数组排序结果%@",resultArray2);
    
    
    return resultArray2;
    //    return fileList;
}

- (void)showGIF:(NSString *)gifName
{
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *strPath = [documentsDirectory stringByAppendingPathComponent:@"gif/"];
    NSString *strFile = [strPath stringByAppendingPathComponent:gifName];
    //    NSLog(@"strFile: %@", strFile);
    
    if (![fileManage fileExistsAtPath:strFile]) {
        NSLog(@"there is no file: %@",strFile);
    }else{
        //有文件
        //        NSData *gif1 = [NSData dataWithContentsOfFile:strFile];
        //        CGRect frame1 = CGRectMake(0,20,self.view.frame.size.width, 0.75*self.view.frame.size.width);
        ////        frame1.size = [UIImage imageWithData:gif1].size;
        //        // view生成
        //        UIWebView *webView = [[UIWebView alloc] initWithFrame:frame1];
        //        webView.userInteractionEnabled = NO;//用户不可交互
        //
        //#pragma clang diagnostic push
        //#pragma clang diagnostic ignored "-Wnonnull"
        //// 被夹在这中间的代码针对于此警告都会无视并且不显示出来
        //        [webView loadData:gif1 MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
        //#pragma clang diagnostic pop
        //        [self.view addSubview:webView];
        
        YLImageView *imageView1 = [[YLImageView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 0.75*self.view.frame.size.width)];
        NSLog(@"the frame is %@", NSStringFromCGRect(imageView1.frame));
        [self.view addSubview:imageView1];
        //        imageView1.image = [YLGIFImage imageNamed:@"jiafeimiao.gif"];
        imageView1.image = [YLGIFImage imageWithContentsOfFile:strFile];
        
        
        //有文件
        //        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"test101" ofType:@"gif"]];
        
        //        [[imageName componentsSeparatedByString:@"."] objectAtIndex:0];
        //        NSString *bundleName = [[gifName componentsSeparatedByString:@"."] objectAtIndex:0];
        
        //        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:GIFINBOUNDLENAME ofType:@"gif"];
        //
        //        NSData *gif2 = [NSData dataWithContentsOfFile:bundlePath];
        //        CGRect frame2 = CGRectMake(20,480,400,500);
        ////        frame2.size = [UIImage imageWithData:gif1].size;
        //        // view生成
        //        UIWebView *webView1 = [[UIWebView alloc] initWithFrame:frame2];
        //        webView1.userInteractionEnabled = NO;//用户不可交互
        //
        //#pragma clang diagnostic push
        //#pragma clang diagnostic ignored "-Wnonnull"
        //        // 被夹在这中间的代码针对于此警告都会无视并且不显示出来
        //        [webView1 loadData:gif2 MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
        //#pragma clang diagnostic pop
        //        [self.view addSubview:webView1];
        
        
        
        
        YLImageView* imageView = [[YLImageView alloc] initWithFrame:CGRectMake(0, 360, self.view.frame.size.width, 0.75*self.view.frame.size.width)];
        NSLog(@"the frame is %@", NSStringFromCGRect(imageView.frame));
        [self.view addSubview:imageView];
        imageView.image = [YLGIFImage imageNamed:@"joy.gif"];
    }
    return;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
    NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
    NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
    NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
    NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
    NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
    [_operation cancel];

    if (_operation.isCancelled) {
        NSLog(@"4444444444444444444444444444444444");
    }
    
    // Dispose of any resources that can be recreated.
}

@end
