//
//  KSSHA1Stream.m
//  Sandvox
//
//  Created by Mike on 12/03/2011.
//  Copyright © 2011 Karelia Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "KSSHA1Stream.h"


@interface KSAsyncSHA1Stream : KSSHA1Stream
{
    void (^_completionBlock)(NSData *digest, NSError *error);
}

- (id)initWithURL:(NSURL *)url completionHandler:(void (^)(NSData *digest, NSError *error))handler __attribute__((nonnull(1,2)));

@end


#pragma mark -


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
    CC_SHA1_Update(&_ctx, buffer, (CC_LONG) len);
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
	return [[self class] ks_stringFromSHA1Digest:[self ks_SHA1Digest]];
}

+ (NSString *)ks_stringFromSHA1Digest:(NSData *)digestData;
{
    if (!digestData) return nil;
    
    static char sHEHexDigits[] = "0123456789abcdef";
    
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
    
    NSData *result;
    if ([URL isFileURL])
    {
        KSSHA1Stream *hasher = [[KSSHA1Stream alloc] init];

#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_6
        NSInputStream *stream = [[NSInputStream alloc] initWithURL:URL];
#else
        NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:[URL path]];
#endif
        [stream open];

#define READ_BUFFER_SIZE 2048*CC_SHA1_BLOCK_BYTES   // just experimentation, but bigger has always run faster for me so far
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

        [stream close];
        [stream release];

        [hasher close];
        result = [[[hasher SHA1Digest] copy] autorelease];
        [hasher release];
    }
    else
    {
        KSSHA1Stream *hasher = [[KSSHA1Stream alloc] initWithURL:URL];
        
        // Run the runloop until done
        while (!(result = [hasher SHA1Digest]))
        {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
        }

        // Finish up. Empty hash means load failed
        if ([result length])
        {
            result = [[result copy] autorelease];
        }
        else
        {
            result = nil;
        }
        
        [hasher release];
    }


    return result;
}

+ (void)SHA1HashContentsOfURL:(NSURL *)url completionHandler:(void (^)(NSData *digest, NSError *error))handler __attribute__((nonnull(1,2)));
{
    [[[KSAsyncSHA1Stream alloc] initWithURL:url completionHandler:handler] release];
}

- (id)initWithURL:(NSURL *)URL;
{
    if (self = [self init])
    {
        [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:URL]
                                      delegate:self];
    }
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


#pragma mark -


@implementation KSAsyncSHA1Stream

- (id)initWithURL:(NSURL *)url completionHandler:(void (^)(NSData *digest, NSError *error))handler;
{
    // Rely on super's NSURLConnection to retain us
    if (self = [self initWithURL:url])
    {
        _completionBlock = [handler copy];
    }
    return self;
}

- (void)dealloc;
{
    [_completionBlock release];
    [super dealloc];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [super connectionDidFinishLoading:connection];
    _completionBlock([self SHA1Digest], nil);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [super connection:connection didFailWithError:error];
    _completionBlock(nil, error);
}

@end
