//
//  KSSHA1Digest.h
//  Sandvox
//
//  Created by Mike on 19/06/2013.
//  Copyright (c) 2013 Karelia Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>


@interface KSSHA1Digest : NSObject <NSCopying>
{
  @private
    unsigned char _md[CC_SHA1_DIGEST_LENGTH];
}

- initWithSHA1Context:(CC_SHA1_CTX *)context;
+ (KSSHA1Digest *)digestWithData:(NSData *)data;  // returns nil if the data isn't valid

- (NSData *)data;
- (NSString *)description;  // gives a fairly human-friendly version of the digest

- (BOOL)isEqualToSHA1Digest:(KSSHA1Digest *)aDigest;
- (BOOL)isEqualToSHA1DigestData:(NSData *)data;

@end
