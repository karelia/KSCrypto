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

/**
 @result The SHA1 digest of all bytes written to the stream.
 
 The stream needs to know when you've finished writing bytes. This is signified
 by calling `-close`. So until `-close` is called, this method returns `nil`.
 */
@property(nonatomic, copy, readonly) NSData *SHA1Digest;

@end


@interface KSSHA1Stream (KSURLHashing)

/**
 Hashes the contents of a file.
 
 @param URL The URL of the file to be hashed. May be anything Cocoa's URL Loading system supports.
 @result The SHA1 digest of the file at `URL`, or `nil` if accessing the file failed.
 */
+ (NSData *)SHA1DigestOfContentsOfURL:(NSURL *)URL __attribute((nonnull(1)));

/**
 Asynchronously hashes the contents of a file.
 
 Only suitable for calling from threads with a running runloop at present.
 `handler` is called on an arbitrary thread/queue. `digest` is `nil` if accesing
 the file failed, with `error` providing details.
 
 @param url The URL of the file to be hashed. May be anything Cocoa's URL Loading system supports.
 @param handler A block to be called when hashing finishes
 */
+ (void)SHA1HashContentsOfURL:(NSURL *)url completionHandler:(void (^)(NSData *digest, NSError *error))handler __attribute__((nonnull(1,2)));

@end


#pragma mark -


@interface NSData (KSSHA1Stream)

/**
 Hashes an `NSData` object.
 
 @return The SHA1 digest of the receiver.
 */
- (NSData *)ks_SHA1Digest;

/**
 Hashes an `NSData` object.
 
 @return The SHA1 digest of the receiver, in a human-friendly hex form.
 */
- (NSString *)ks_SHA1DigestString;

/**
 Converts a raw SHA1 digest to a more human-friendly string form.
 
 @param digest An existing SHA1 digest
 @return The SHA1 digest, converted to a human-friendly hex form.
 */
+ (NSString *)ks_stringFromSHA1Digest:(NSData *)digest;

@end
