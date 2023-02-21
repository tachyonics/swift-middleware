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
public struct OptionalMiddleware<M0: MiddlewareProtocol>: MiddlewareProtocol {
    public typealias Input = M0.Input
    public typealias Output = M0.Output
    public typealias Context = M0.Context
    
    let optionalMiddleware: M0?
    
    public init(_ optionalMiddleware: M0?) {
        self.optionalMiddleware = optionalMiddleware
    }
    
    public func handle(_ input: Input, context: Context, next: (Input, Context) async throws -> Output) async throws
    -> Output {
        if let optionalMiddleware = optionalMiddleware {
            return try await optionalMiddleware.handle(input, context: context) { input, context in
                try await next(input, context)
            }
        } else {
            return try await next(input, context)
        }
    }
}

@resultBuilder
public struct MiddlewareBuilder {
    public static func buildBlock<M0: MiddlewareProtocol>(_ m0: M0) -> M0 {
        return m0
    }
    
    /// Add support for optionals.
    public static func buildOptional<M0: MiddlewareProtocol>(_ m0: M0?) -> OptionalMiddleware<M0> {
        return OptionalMiddleware(m0)
    }

    /// Add support for if statements.
    public static func buildEither<M0: MiddlewareProtocol>(first m0: M0) -> M0 {
        return m0
    }

    public static func buildEither<M0: MiddlewareProtocol>(second m0: M0) -> M0 {
        return m0
    }

    public static func buildPartialBlock<M0: MiddlewareProtocol>(first: M0) -> M0 {
        return first
    }

    public static func buildPartialBlock<M0: MiddlewareProtocol, M1: MiddlewareProtocol>(
        accumulated m0: M0,
        next m1: M1
    ) -> MiddlewareTuple<M0, M1> where M0.Input == M1.Input, M0.Output == M1.Output, M0.Context == M1.Context {
        return MiddlewareTuple(m0, m1)
    }
}

public func MiddlewareStack<Input, Output, Context>(@MiddlewareBuilder _ builder: () -> some MiddlewareProtocol<Input, Output, Context>)
-> some MiddlewareProtocol<Input, Output, Context> {
    return builder()
}
#endif
