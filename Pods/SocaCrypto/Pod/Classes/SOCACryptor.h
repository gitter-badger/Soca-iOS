//
//  SOCACryptor.h
//  Pods
//
//  Created by Zhuhao Wang on 4/9/15.
//
//

#import <Foundation/Foundation.h>

@interface SOCACryptor : NSObject
typedef NS_ENUM(NSInteger, SOCACryptorOpeartion) {
    SOCACryptorOpeartionEncrypt,
    SOCACryptorOpeartionDecrypt
};
typedef NS_ENUM(NSInteger, SOCACryptorAlgorithm) {
    SOCACryptorAlgorithmAES
};
typedef NS_ENUM(NSInteger, SOCACryptorMode) {
    SOCACryptorModeCFB
};

- (instancetype)initWithOperaion:(SOCACryptorOpeartion)operation mode:(SOCACryptorMode)mode algorithm:(SOCACryptorAlgorithm)algorithm initializaionVector:(NSData *)iv key:(NSData *)key;
- (NSData *)update:(NSData *)data;
@end
