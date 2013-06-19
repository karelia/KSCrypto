//
//  KSSHA1Digest.m
//  Sandvox
//
//  Created by Mike on 19/06/2013.
//  Copyright (c) 2013 Karelia Software. All rights reserved.
//

#import "KSSHA1Digest.h"

#import "KSSHA1Stream.h"


@implementation KSSHA1Digest

- initWithSHA1Context:(CC_SHA1_CTX *)context;
{
    if (self = [self init])
    {
        CC_SHA1_Final(_md, context);
    }
    return self;
}

+ (KSSHA1Digest *)digestWithData:(NSData *)data;  // returns nil if the data isn't valid
{
    if (data.length != CC_SHA1_DIGEST_LENGTH) return nil;
    
    KSSHA1Digest *result = [[KSSHA1Digest alloc] init];
    [data getBytes:result->_md length:CC_SHA1_DIGEST_LENGTH];
    return [result autorelease];
}

- (NSData *)data;
{
    return [NSData dataWithBytes:_md length:CC_SHA1_DIGEST_LENGTH];
}

- (NSString *)description;
{
    return [NSData ks_stringFromSHA1Digest:self.data];
}

#pragma mark Equality

- (BOOL)isEqualToSHA1Digest:(KSSHA1Digest *)aDigest;
{
    NSData *myData = [[NSData alloc] initWithBytesNoCopy:_md length:CC_SHA1_DIGEST_LENGTH freeWhenDone:NO];
    BOOL result = [myData isEqualToData:aDigest.data];
    [myData release];
    return result;
}

- (BOOL)isEqual:(id)object;
{
    if (![object isKindOfClass:[KSSHA1Digest class]]) return NO;
    return [self isEqualToSHA1Digest:object];
}

- (NSUInteger)hash; { return _md; }

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone; { return [self retain]; }

@end
