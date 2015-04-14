//
//  SOCADigest.h
//  Pods
//
//  Created by Zhuhao Wang on 4/9/15.
//
//

#import <Foundation/Foundation.h>

@interface SOCADigest : NSObject
+ (NSData *)MD5ByData:(NSData *)value;
+ (NSData *)MD5ByString:(NSString *)value;
@end
