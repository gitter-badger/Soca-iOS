//
//  SOCACryptor.m
//  Pods
//
//  Created by Zhuhao Wang on 4/9/15.
//
//

#import "SOCACryptor.h"
#import "SOCADigest.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation SOCACryptor {
    CCCryptorRef cryptor;
}

-(instancetype)initWithOperaion:(SOCACryptorOpeartion)operation mode:(SOCACryptorMode)mode algorithm:(SOCACryptorAlgorithm)algorithm initializaionVector:(NSData *)iv key:(NSData *)key
{
    self = [super init];
    if (self) {
        CCCryptorCreateWithMode([self.class getOperation:operation], [self.class getMode:mode], [self.class getAlgorithm:algorithm], ccNoPadding, iv.bytes, key.bytes, key.length, nil, 0, 0, 0, &cryptor);
    }
    return self;
}

-(NSData *)update:(NSData *)data
{
    NSMutableData *result = [[NSMutableData alloc] initWithLength:data.length];
    CCCryptorUpdate(cryptor, data.bytes, data.length, result.mutableBytes, result.length, nil);
    return [[NSData alloc] initWithData:result];
}

- (void)dealloc
{
    CCCryptorRelease(cryptor);
}

+ (CCOperation)getOperation:(SOCACryptorOpeartion)operation {
    switch (operation) {
        case SOCACryptorOpeartionDecrypt:
            return kCCDecrypt;
            break;
        case SOCACryptorOpeartionEncrypt:
            return kCCEncrypt;
            break;
    }
}

+ (CCMode)getMode:(SOCACryptorMode)mode {
    switch (mode) {
        case SOCACryptorModeCFB:
            return kCCModeCFB;
            break;
    }
}

+ (CCAlgorithm)getAlgorithm:(SOCACryptorAlgorithm)algorithm {
    switch (algorithm) {
        case SOCACryptorAlgorithmAES:
            return kCCAlgorithmAES;
            break;
    }
}

@end
