//
//  KSSHA1Stream.m
//  Sandvox
//
//  Created by Mike on 12/03/2011.
//  Copyright 2011-2012 Karelia Software. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "KSSHA1Stream.h"


@implementation KSSHA1Stream

- (id)init;
{
    if (self = [super init])
    {
        CC_SHA1_Init(&_ctx);
    }
    return self;
}

- (void)close;
{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1_Final(digest, &_ctx);

    _digest = [[NSData alloc] initWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}

- (void)dealloc;
{
    [_digest release];
    [super dealloc];
}

- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len;
{
    CC_SHA1_Update(&_ctx, buffer, len);
    return len;
}

@synthesize SHA1Digest = _digest;

@end


#pragma mark -


@implementation NSData (KSSHA1Stream)

- (NSData *)ks_SHA1Digest
{
	KSSHA1Stream *stream = [[KSSHA1Stream alloc] init];
    [stream write:[self bytes] maxLength:[self length]];
    [stream close];
    NSData *result = [[[stream SHA1Digest] copy] autorelease];

    [stream release];
    return result;
}

- (NSString *)ks_SHA1DigestString
{
	static char sHEHexDigits[] = "0123456789abcdef";

    NSData *digestData = [self ks_SHA1Digest];
    unsigned char *digest = (unsigned char *)[digestData bytes];

	unsigned char digestString[2 * CC_SHA1_DIGEST_LENGTH];
    NSUInteger i;
	for (i=0; i<CC_SHA1_DIGEST_LENGTH; i++)
	{
		digestString[2*i]   = sHEHexDigits[digest[i] >> 4];
		digestString[2*i+1] = sHEHexDigits[digest[i] & 0x0f];
	}

	return [[[NSString alloc] initWithBytes:(const char *)digestString
                                     length:2 * CC_SHA1_DIGEST_LENGTH
                                   encoding:NSASCIIStringEncoding] autorelease];
}

@end


#pragma mark -


@implementation KSSHA1Stream (KSURLHashing)

+ (NSData *)SHA1DigestOfContentsOfURL:(NSURL *)URL;
{
    NSParameterAssert(URL);
    KSSHA1Stream *hasher = [[KSSHA1Stream alloc] initWithURL:URL];

    NSData *result;
    if ([URL isFileURL])
    {
        NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:[URL path]];
        [stream open];

#define READ_BUFFER_SIZE 64*CC_SHA1_BLOCK_BYTES
        uint8_t buffer[READ_BUFFER_SIZE];

        while ([stream streamStatus] < NSStreamStatusAtEnd)
        {
            NSInteger length = [stream read:buffer maxLength:READ_BUFFER_SIZE];

            if (length > 0)
            {
                NSInteger written = [hasher write:buffer maxLength:length];
                NSAssert((written == length), @"KSSHA1Stream is expected to handle all data you pass to it, but didn't this time for some reason");
            }
        }

        [stream release];

        [hasher close];
        result = [hasher SHA1Digest];
    }
    else
    {
        // Run the runloop until done
        while (!(result = [hasher SHA1Digest]))
        {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
        }

        // Finish up. Empty hash means load failed
        if (![result length]) result = nil;
    }


    // Finish up. Empty hash means load failed
    result = [[result copy] autorelease];
    [hasher release];
    return result;
}

- (id)initWithURL:(NSURL *)URL;
{
    [self init];

    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:URL]
                                  delegate:self];

    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self write:[data bytes] maxLength:[data length]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self close];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _digest = [[NSData alloc] init];
}

@end
