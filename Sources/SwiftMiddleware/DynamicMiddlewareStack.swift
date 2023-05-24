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

@available(macOS 13.0.0, *)
public struct DynamicMiddlewareStack<Input, OutputWriter, Context>: MiddlewareProtocol {
    typealias Stack = Array<(String, any MiddlewareProtocol<Input, OutputWriter, Context>)>

    var stack: [(String, any MiddlewareProtocol<Input, OutputWriter, Context>)]

    public init(_ list: any MiddlewareProtocol<Input, OutputWriter, Context>...) {
        self.stack = list.enumerated().map { i, m in ("\(i)", m) }
    }
    
    public func handle(_ input: Input,
                       outputWriter: OutputWriter,
                       context: Context,
                       next: (Input, OutputWriter, Context) async throws -> Void) async throws {
        let iterator = stack.makeIterator()
        try await self.run(input, outputWriter: outputWriter, context: context, iterator: iterator, finally: next)
    }

    func run(
        _ input: Input,
        outputWriter: OutputWriter,
        context: Context,
        iterator: Stack.Iterator,
        finally: (Input, OutputWriter, Context) async throws -> Void
    ) async throws {
        var iterator = iterator
        switch iterator.next() {
        case .none:
            try await finally(input, outputWriter, context)
        case .some(let middleware):
            try await middleware.1.handle(input, outputWriter: outputWriter, context: context) { (input, outputWriter, context) in
                try await self.run(input, outputWriter: outputWriter, context: context, iterator: iterator, finally: finally)
            }
        }
    }
}
