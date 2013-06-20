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


@interface KSAsyncSHA1Stream : KSSHA1Stream
{
    void (^_completionBlock)(KSSHA1Digest *digest, NSError *error);
}

- (id)initWithURL:(NSURL *)url completionHandler:(void (^)(KSSHA1Digest *digest, NSError *error))handler __attribute__((nonnull(1,2)));

@end


#pragma mark -


@implementation KSSHA1Stream

- (id)init;
{
    if (self = [super init])
    {
        CC_SHA1_Init(&_ctx);
        _status = NSStreamStatusOpen;
    }
    return self;
}

- (void)close;
{
    _digest = [[KSSHA1Digest alloc] initWithSHA1Context:&_ctx];
    _status = NSStreamStatusClosed;
}

- (NSStreamStatus)streamStatus; { return _status; }

- (void)dealloc;
{
    [_digest release];
    [_error release];
    [super dealloc];
}

- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len;
{
    CC_SHA1_Update(&_ctx, buffer, (CC_LONG) len);
    return len;
}

@synthesize digest = _digest;

- (NSData *)SHA1Digest; { return self.digest.data; }

- (NSError *)streamError; { return _error; }

@end


#pragma mark -


@implementation NSData (KSSHA1Stream)

- (NSData *)ks_SHA1Digest
{
	KSSHA1Stream *stream = [[KSSHA1Stream alloc] init];
    [stream write:[self bytes] maxLength:[self length]];
    [stream close];
    NSData *result = [[[stream digest] copy] autorelease];

    [stream release];
    return result;
}

@end


#pragma mark -


@implementation KSSHA1Stream (KSURLHashing)

+ (KSSHA1Digest *)digestOfContentsOfURL:(NSURL *)URL;
{
    NSParameterAssert(URL);
    
    KSSHA1Digest *result;
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
        result = [[hasher.digest copy] autorelease];
        [hasher release];
    }
    else
    {
        KSSHA1Stream *hasher = [[KSSHA1Stream alloc] initWithURL:URL];
        
        // Run the runloop until done
        while (hasher.streamStatus < NSStreamStatusClosed)
        {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantPast]];
        }
        
        result = [[hasher.digest copy] autorelease];
        [hasher release];
    }


    return result;
}

+ (NSData *)SHA1DigestOfContentsOfURL:(NSURL *)URL; { return [self digestOfContentsOfURL:URL].data; }

+ (void)SHA1HashContentsOfURL:(NSURL *)url completionHandler:(void (^)(KSSHA1Digest *digest, NSError *error))handler __attribute__((nonnull(1,2)));
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
    _error = [error copy];
    _status = NSStreamStatusError;
}

@end


#pragma mark -


@implementation KSAsyncSHA1Stream

- (id)initWithURL:(NSURL *)url completionHandler:(void (^)(KSSHA1Digest *digest, NSError *error))handler;
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
    _completionBlock(self.digest, nil);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [super connection:connection didFailWithError:error];
    _completionBlock(nil, error);
}

@end
