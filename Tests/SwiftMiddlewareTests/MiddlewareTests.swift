//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-middleware open source project
//
// Copyright (c) swift-middleware project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of swift-middleware project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import SwiftMiddleware

final class MiddlewareTests: XCTestCase {
    func testExample() async throws {

        let middleware = AddSuffix("foo")

        let result = try await middleware.handle("", context: FakeContext(), next: { str, _ in str })
        XCTAssertEqual(result, "foofoo")
    }

    func testTuple() async throws {
        let middleware = MiddlewareTuple(AddSuffix("foo"), AddSuffix("bar"))

        let result = try await middleware.handle("", context: FakeContext(), next: { str, _ in str + "haha" })
        XCTAssertEqual(result, "foobarhahabarfoo")
    }

    func testTriple() async throws {
        let middleware = MiddlewareTuple(AddSuffix("foo"), MiddlewareTuple(AddSuffix("bar"), AddSuffix("baz")))

        let result = try await middleware.handle("", context: FakeContext(), next: { str, _ in str + "haha" })
        XCTAssertEqual(result, "foobarbazhahabazbarfoo")
    }
    
#if compiler(>=5.7)
    func testSingletonStack() async throws {
        let stack = MiddlewareStack {
            AddSuffix("foo")
        }
        
        let result = try await stack.handle("", context: FakeContext(), next: { str, _ in str })

        XCTAssertEqual(result, "foofoo")
    }
    
    func testTripleStack() async throws {
        let stack = MiddlewareStack {
            AddSuffix("foo")
            AddSuffix("bar")
            AddSuffix("baz")
        }
        
        let result = try await stack.handle("", context: FakeContext(), next: { str, _ in str + "haha" })

        XCTAssertEqual(result, "foobarbazhahabazbarfoo")
    }
    
    func testTripleTransformedStack() async throws {
        let stack = MiddlewareTransformStack(inwardTransform: StringBoxingTransformer(),
                                             outwardTransform: StringUnboxingTransformer()) {
            AddSuffix("foo")
        } _: {
            AddSuffixBoxed("bar")
            AddSuffixBoxed("baz")
        }
        
        let result = try await stack.handle("", context: FakeContext(), next: { stringBox, _ in StringBox(stringBox.contents + "haha") })

        XCTAssertEqual(result, "foobarbazhahabazbarfoo")
    }

    @available(macOS 13.0.0, *)
    func testDynamic() async throws {
        let middleware = DynamicMiddlewareStack(AddSuffix("foo"), AddSuffix("bar"), AddSuffix("baz"))

        let result = try await middleware.handle("", context: FakeContext(), next: { str, _ in str + "haha" })
        XCTAssertEqual(result, "foobarbazhahabazbarfoo")
    }
#endif
}

struct FakeContext {}

struct AddSuffix: MiddlewareProtocol {
    typealias Input = String
    typealias Output = String
    typealias Context = FakeContext

    let suffix: String

    init(_ suffix: String) {
        self.suffix = suffix
    }

    func handle(_ input: String, context: FakeContext, next: (String, FakeContext) async throws -> String) async throws -> String {
        try await next(input + self.suffix, context) + self.suffix
    }
}

struct StringBox {
    let contents: String
    
    init(_ contents: String) {
        self.contents = contents
    }
}

struct AddSuffixBoxed: MiddlewareProtocol {
    typealias Input = StringBox
    typealias Output = StringBox
    typealias Context = FakeContext

    let suffix: String

    init(_ suffix: String) {
        self.suffix = suffix
    }

    func handle(_ input: StringBox, context: FakeContext, next: (StringBox, FakeContext) async throws -> StringBox) async throws -> StringBox {
        try await StringBox(next(StringBox(input.contents + self.suffix), context).contents + self.suffix)
    }
}

struct StringBoxingTransformer: TransformProtocol {
    typealias Input = String
    typealias Output = StringBox
    typealias Context = FakeContext
    
    func transform(_ input: String, context: Context) async throws -> StringBox {
        return StringBox(input)
    }
}

struct StringUnboxingTransformer: TransformProtocol {
    typealias Input = StringBox
    typealias Output = String
    typealias Context = FakeContext
    
    func transform(_ input: StringBox, context: Context) async throws -> String {
        return input.contents
    }
}

