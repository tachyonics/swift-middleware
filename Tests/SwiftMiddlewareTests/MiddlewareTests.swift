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
        let outputWriter = StringWriter()

        try await middleware.handle("", outputWriter: outputWriter,
                                    context: FakeContext(), next: { str, outputWriter, _ in await outputWriter.write(str) })
        let result = await outputWriter.theString
        
        XCTAssertEqual(result, "foofoo")
    }

    func testTuple() async throws {
        let middleware = TransformingMiddlewareTuple(AddSuffix("foo"), AddSuffix("bar"))
        let outputWriter = StringWriter()
        
        try await middleware.handle("", outputWriter: outputWriter,
                                    context: FakeContext(), next: { str, outputWriter, _ in await outputWriter.write(str + "haha") })
        let result = await outputWriter.theString

        XCTAssertEqual(result, "foobarhahabarfoo")
    }

    func testTriple() async throws {
        let middleware = TransformingMiddlewareTuple(AddSuffix("foo"), TransformingMiddlewareTuple(AddSuffix("bar"), AddSuffix("baz")))
        let outputWriter = StringWriter()

        try await middleware.handle("", outputWriter: outputWriter,
                                    context: FakeContext(), next: { str, outputWriter, _ in await outputWriter.write(str + "haha") })
        let result = await outputWriter.theString
        
        XCTAssertEqual(result, "foobarbazhahabazbarfoo")
    }
   
    func testSingletonStack() async throws {
        let stack = MiddlewareStack {
            AddSuffix("foo")
        }
        
        let outputWriter = StringWriter()

        try await stack.handle("", outputWriter: outputWriter,
                               context: FakeContext(), next: { str, outputWriter, _ in await outputWriter.write(str) })
        let result = await outputWriter.theString

        XCTAssertEqual(result, "foofoo")
    }
    
    func testTripleStack() async throws {
        let stack = MiddlewareStack {
            AddSuffix("foo")
            AddSuffix("bar")
            AddSuffix("baz")
        }
        
        let outputWriter = StringWriter()

        try await stack.handle("", outputWriter: outputWriter,
                               context: FakeContext(), next: { str, outputWriter, _ in await outputWriter.write(str + "haha") })
        let result = await outputWriter.theString

        XCTAssertEqual(result, "foobarbazhahabazbarfoo")
    }
    
    func testTripleStackWithTransform() async throws {
        let stack = MiddlewareStack {
            AddSuffix("foo")
            AddSuffix("bar")
            BoxingMiddleware()
            AddSuffixBoxed("baz")
        }
        
        let outputWriter = StringWriter()

        try await stack.handle("", outputWriter: outputWriter,
                               context: FakeContext(), next: { stringBox, outputWriter, _ in await outputWriter.write(StringBox(stringBox.contents + "haha")) })
        let result = await outputWriter.theString

        XCTAssertEqual(result, "foobarbazhahabazbarfoo")
    }
    
    @available(macOS 13.0.0, *)
    func testDynamic() async throws {
        let middleware = DynamicMiddlewareStack(AddSuffix("foo"), AddSuffix("bar"), AddSuffix("baz"))
        let outputWriter = StringWriter()

        try await middleware.handle("", outputWriter: outputWriter, context: FakeContext(), next:  { str, outputWriter, _ in await outputWriter.write(str + "haha") })
        let result = await outputWriter.theString
        XCTAssertEqual(result, "foobarbazhahabazbarfoo")
    }
}

struct FakeContext {}
struct FakeContext2 {}

actor StringWriter {
    private(set) var theString: String = ""
    
    func write(_ new: String) {
        self.theString += new
    }
}

struct StringBox {
    let contents: String
    
    init(_ contents: String) {
        self.contents = contents
    }
}

struct StringBoxWriter {
    let wrappedWriter: StringWriter
    
    func write(_ new: StringBox) async {
        await self.wrappedWriter.write(new.contents)
    }
}

struct AddSuffix: MiddlewareProtocol {
    typealias Input = String
    typealias OutputWriter = StringWriter
    typealias Context = FakeContext

    let suffix: String

    init(_ suffix: String) {
        self.suffix = suffix
    }
    
    public func handle(_ input: Input,
                       outputWriter: OutputWriter,
                       context: Context,
                       next: (Input, OutputWriter, Context) async throws -> Void) async throws {
        try await next(input + self.suffix, outputWriter, context)
        
        await outputWriter.write(self.suffix)
    }
}

struct AddSuffixBoxed: MiddlewareProtocol {
    typealias Input = StringBox
    typealias OutputWriter = StringBoxWriter
    typealias Context = FakeContext2

    let suffix: String

    init(_ suffix: String) {
        self.suffix = suffix
    }
    
    public func handle(_ input: Input,
                       outputWriter: OutputWriter,
                       context: Context,
                       next: (Input, OutputWriter, Context) async throws -> Void) async throws {
        try await next(StringBox(input.contents + self.suffix), outputWriter, context)
        
        await outputWriter.write(StringBox(self.suffix))
    }
}

struct BoxingMiddleware: TransformingMiddlewareProtocol {
    typealias IncomingInput = String
    typealias OutgoingInput = StringBox
    typealias IncomingOutputWriter = StringWriter
    typealias OutgoingOutputWriter = StringBoxWriter
    typealias IncomingContext = FakeContext
    typealias OutgoingContext = FakeContext2
    
    func handle(_ input: String, outputWriter: StringWriter, context: FakeContext,
                next: (StringBox, StringBoxWriter, FakeContext2) async throws -> Void) async throws {
        let wrappedWriter = StringBoxWriter(wrappedWriter: outputWriter)
        try await next(StringBox(input), wrappedWriter, FakeContext2())
    }
}

