Features
========

Adapts `NSOutputStream`'s API for use to generate SHA1 digests.

Also provides convenience methods for:

* Directly hashing a lump of data: `-[NSData ks_SHA1Digest]`.
* Hashing the contents of a URL, even a remote one: `+SHA1DigestOfContentsOfURL:`
* Converting a digest into a hexadecimal string representation: `+ks_stringFromSHA1Digest:`

Contact
=======

I'm Mike Abdullah, of [Karelia Software](http://karelia.com). [@mikeabdullah](http://twitter.com/mikeabdullah) on Twitter.

Questions about the code should be left as issues at https://github.com/karelia/KSCrypto or message me on Twitter.

Dependencies
============

CommonCrypto (and Foundation, obviously).

Licence
=======

Copyright © 2011 Karelia Software

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Usage
=====

1. Add `KSSHA1Stream.h` and `KSSHA1Stream.m` to your project. Ideally, make this repo a submodule, but hey, it's your codebase, do whatever you feel like.
2. Link against `CommonCrypto`

To hash a stream of data:

1. `[[KSSHA1Stream alloc] init]`
2. Call `-write:maxLength:` as your data arrives. `KSSHA1Stream` promises to always process all bytes passed to it
3. Call `-close` on the stream
4. Retrieve the result using the `SHA1Digest` property
