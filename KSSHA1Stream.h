//
//  KSSHA1Stream.h
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

#import "KSSHA1Digest.h"


@interface KSSHA1Stream : NSOutputStream
{
  @private
    CC_SHA1_CTX     _ctx;
    
    NSStreamStatus  _status;
    KSSHA1Digest    *_digest;
    NSError         *_error;
}

// nil until you call -close
@property(nonatomic, copy, readonly) KSSHA1Digest *SHA1Digest;

@end


@interface KSSHA1Stream (KSURLHashing)

+ (KSSHA1Digest *)SHA1DigestOfContentsOfURL:(NSURL *)URL;

// Only suitable for calling from threads with a running runloop at present
// Completion handler is called on an arbitrary thread/queue
// digest is nil if failed to load for some reason, and then error should give some more info
+ (void)SHA1HashContentsOfURL:(NSURL *)url completionHandler:(void (^)(KSSHA1Digest *digest, NSError *error))handler __attribute__((nonnull(1,2)));

@end


#pragma mark -


@interface NSData (KSSHA1Stream)

// Cryptographic hashes
- (KSSHA1Digest *)ks_SHA1Digest;

- (NSString *)ks_SHA1DigestString;
+ (NSString *)ks_stringFromSHA1Digest:(NSData *)digest;

@end
