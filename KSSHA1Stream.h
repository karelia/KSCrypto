//
//  KSSHA1Stream.h
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

#import <Foundation/Foundation.h>
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

// Only suitable for calling from threads with a running runloop at present
// Completion handler is called on an arbitrary thread/queue
// digest is nil if failed to load for some reason, and then error should give some more info
+ (void)SHA1HashContentsOfURL:(NSURL *)url completionHandler:(void (^)(NSData *digest, NSError *error))handler __attribute__((nonnull(1,2)));

@end


#pragma mark -


@interface NSData (KSSHA1Stream)

// Cryptographic hashes
- (NSData *)ks_SHA1Digest;

- (NSString *)ks_SHA1DigestString;
+ (NSString *)ks_stringFromSHA1Digest:(NSData *)digest;

@end
