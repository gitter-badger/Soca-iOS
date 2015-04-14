//
//  SOCADigest.m
//  Pods
//
//  Created by Zhuhao Wang on 4/9/15.
//
//

#import "SOCADigest.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation SOCADigest
+ (NSData *)MD5ByData:(NSData *)value {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value.bytes, (CC_LONG)value.length, result);
    return [[NSData alloc]initWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}

+ (NSData *)MD5ByString:(NSString *)value {
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    return [self MD5ByData:data];
}
@end
