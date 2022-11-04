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

#if compiler(>=5.7)
@available(macOS 13.0.0, *)
public struct DynamicMiddlewareStack<Input, Output, Context>: MiddlewareProtocol {
    typealias Stack = Array<(String, any MiddlewareProtocol<Input, Output, Context>)>

    var stack: [(String, any MiddlewareProtocol<Input, Output, Context>)]

    public init(_ list: any MiddlewareProtocol<Input, Output, Context>...) {
        self.stack = list.enumerated().map { i, m in ("\(i)", m) }
    }

    public func handle(_ input: Input, context: Context, next: (Input, Context) async throws -> Output) async throws -> Output {
        let iterator = stack.makeIterator()
        return try await self.run(input, context: context, iterator: iterator, finally: next)
    }

    func run(
        _ input: Input,
        context: Context,
        iterator: Stack.Iterator,
        finally: (Input, Context) async throws -> Output
    ) async throws -> Output {
        var iterator = iterator
        switch iterator.next() {
        case .none:
            return try await finally(input, context)
        case .some(let middleware):
            return try await middleware.1.handle(input, context: context) { (input, context) in
                try await self.run(input, context: context, iterator: iterator, finally: finally)
            }
        }
    }
}
#endif
