//
//  KSSHA1Stream.h
//  Sandvox
//
//  Created by Mike on 12/03/2011.
//  Copyright 2011 Karelia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CommonCrypto/CommonDigest.h>



@interface KSSHA1Stream : NSOutputStream
{
  @private
    CC_SHA1_CTX _ctx;
    NSData      *_digest;
}

// nil until you call -close
@property(nonatomic, copy, readonly) NSData *SHA1Digest;

@end


@interface KSSHA1Stream (KSURLHashing)
+ (NSData *)SHA1DigestOfContentsOfURL:(NSURL *)URL;
- (id)initWithURL:(NSURL *)URL;
@end


#pragma mark -


@interface NSData (KSSHA1Stream)

// Cryptographic hashes
- (NSData *)ks_SHA1Digest;
- (NSString *)ks_SHA1DigestString;

@end
