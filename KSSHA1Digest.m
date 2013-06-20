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
    static char sHEHexDigits[] = "0123456789abcdef";
    
	unsigned char digestString[2 * CC_SHA1_DIGEST_LENGTH];
    NSUInteger i;
	for (i=0; i<CC_SHA1_DIGEST_LENGTH; i++)
	{
		digestString[2*i]   = sHEHexDigits[_md[i] >> 4];
		digestString[2*i+1] = sHEHexDigits[_md[i] & 0x0f];
	}
    
	return [[[NSString alloc] initWithBytes:(const char *)digestString
                                     length:2 * CC_SHA1_DIGEST_LENGTH
                                   encoding:NSASCIIStringEncoding] autorelease];
}

#pragma mark Equality

- (BOOL)isEqualToSHA1Digest:(KSSHA1Digest *)aDigest;
{
    NSData *myData = [[NSData alloc] initWithBytesNoCopy:_md length:CC_SHA1_DIGEST_LENGTH freeWhenDone:NO];
    BOOL result = [aDigest isEqualToSHA1DigestData:myData];
    [myData release];
    return result;
}

- (BOOL)isEqual:(id)object;
{
    if (![object isKindOfClass:[KSSHA1Digest class]]) return NO;
    return [self isEqualToSHA1Digest:object];
}

- (NSUInteger)hash; { return *_md; }

- (BOOL)isEqualToSHA1DigestData:(NSData *)data;
{
    NSData *myData = [[NSData alloc] initWithBytesNoCopy:_md length:CC_SHA1_DIGEST_LENGTH freeWhenDone:NO];
    BOOL result = [myData isEqualToData:data];
    [myData release];
    return result;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone; { return [self retain]; }

@end
