//
//  YGAppDelegate.h
//  ZapOrbit
//
//  Created by Yoel R. GARCIA DIAZ on 14/03/2014.
//  Copyright (c) 2014 Lewis Dots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGUserInfo.h"

@interface UIImage(PlaceholderWithColor)
+ (UIImage *)imageWithColor:(UIColor *)color;
@end
@implementation UIImage(PlaceholderWithColor)
+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end

@interface UIImage(TintColour)
- (UIImage *)imageWithTintColor:(UIColor *)colour;
@end
@implementation UIImage(TintColour)
- (UIImage *)imageWithTintColor:(UIColor *)colour {
	UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0, self.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
	CGContextClipToMask(context, rect, self.CGImage);
	[colour setFill];
	CGContextFillRect(context, rect);
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}
@end

@interface NSDate(FriendlyDate)
- (NSString *)formattedDateRelativeToNow:(NSDate *)date;
@end
@implementation NSDate(FriendlyDate)
- (NSString *)formattedDateRelativeToNow:(NSDate *)date {
	CGFloat timeDiff = -(float)[date timeIntervalSinceNow] / (60*60);
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	if(timeDiff < 24) {
		if (timeDiff < 1) {
			if ((int)(timeDiff*60) < 1)
				[dateFormatter setDateFormat:[NSString stringWithFormat:@"'Now'"]];
			else
				[dateFormatter setDateFormat:[NSString stringWithFormat:@"'%d min'", (int)(timeDiff*60)]];
		}
		else {
			if ((int)(((float)timeDiff-(int)timeDiff)*60) == 0) {
				[dateFormatter setDateFormat:[NSString stringWithFormat:@"'%dh'", (int)timeDiff]];
			} else
				[dateFormatter setDateFormat:[NSString stringWithFormat:@"'%dh %dm'", (int)timeDiff, (int)(((float)timeDiff-(int)timeDiff)*60)]];
		}
	}
	else if (timeDiff > 168) {
		float weeks = timeDiff/168;
		float days = (weeks-(int)weeks)*7;
		if (days < 1 && weeks < 2)
			[dateFormatter setDateFormat:[NSString stringWithFormat:@"'%dw'", (int)weeks]];
		else if (days < 1)
			[dateFormatter setDateFormat:[NSString stringWithFormat:@"'%dw'", (int)weeks]];
		else
			[dateFormatter setDateFormat:[NSString stringWithFormat:@"'%dw %dd'", (int)weeks, (int)days]];
	}
	else if (timeDiff > 24) {
		float days = timeDiff/24;
		float hours = (days-(int)days)*24;
		if (hours < 1 && days < 2)
			[dateFormatter setDateFormat:[NSString stringWithFormat:@"'%dd'", (int)days]];
		else if (hours < 1)
			[dateFormatter setDateFormat:[NSString stringWithFormat:@"'%dd'", (int)days]];
		else
			[dateFormatter setDateFormat:[NSString stringWithFormat:@"'%dd %dh'", (int)days, (int)hours]];
	}
	return [dateFormatter stringFromDate:date];
}
@end

@class AppSettings;

@interface YGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AppSettings *appSettings;

@end

// NOT IN USE
@interface UIImage (JTImageDecode)
-(UIImage *)decodedImage;
@end
@implementation UIImage (JTImageDecode)
-(UIImage *)decodedImage {
	CGImageRef imageRef = self.CGImage;
	// System only supports RGB, set explicitly and prevent context error
	// if the downloaded image is not the supported format
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef context = CGBitmapContextCreate(NULL,
												 CGImageGetWidth(imageRef),
												 CGImageGetHeight(imageRef),
												 8,
												 // width * 4 will be enough because are in ARGB format, don't read from the image
												 CGImageGetWidth(imageRef) * 4,
												 colorSpace,
												 // kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little
												 // makes system don't need to do extra conversion when displayed.
												 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
	CGColorSpaceRelease(colorSpace);
	
	if ( ! context) {
		return nil;
	}
	CGRect rect = (CGRect){CGPointZero, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)};
	CGContextDrawImage(context, rect, imageRef);
	CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	UIImage *decompressedImage = [[UIImage alloc] initWithCGImage:decompressedImageRef];
	CGImageRelease(decompressedImageRef);
	return decompressedImage;
}
@end
