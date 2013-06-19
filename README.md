Features
========

* Adapts `NSOutputStream`'s API for use to generate SHA1 digests.
* `KSSHA1Digest` class to encapsulate digests and avoid accidents from comparing them to inappropriate `NSData` instances

Also provides convenience methods for:

* Directly hashing a lump of data: `-[NSData ks_SHA1Digest]`.
* Hashing the contents of a URL, even a remote one: `+SHA1DigestOfContentsOfURL:`

Contact
=======

I'm Mike Abdullah, of [Karelia Software](http://karelia.com). [@mikeabdullah](http://twitter.com/mikeabdullah) on Twitter.

Questions about the code should be left as issues at https://github.com/karelia/KSCrypto or message me on Twitter.

Dependencies
============

CommonCrypto (and Foundation, obviously).

Licence
=======

Copyright 2011-2012 Karelia Software. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Usage
=====

1. Add `KSSHA1Stream.h` and `KSSHA1Stream.m` to your project. Ideally, make this repo a submodule, but hey, it's your codebase, do whatever you feel like.
2. Link against `CommonCrypto`

To hash a stream of data:

1. `[[KSSHA1Stream alloc] init]`
2. Call `-write:maxLength:` as your data arrives. `KSSHA1Stream` promises to always process all bytes passed to it
3. Call `-close` on the stream
4. Retrieve the result using the `SHA1Digest` property
