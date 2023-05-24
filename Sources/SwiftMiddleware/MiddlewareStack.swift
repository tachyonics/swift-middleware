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

public struct OptionalMiddleware<M0: MiddlewareProtocol>: MiddlewareProtocol {
    public typealias Input = M0.Input
    public typealias OutputWriter = M0.OutputWriter
    public typealias Context = M0.Context
    
    let optionalMiddleware: M0?
    
    public init(_ optionalMiddleware: M0?) {
        self.optionalMiddleware = optionalMiddleware
    }
    
    public func handle(_ input: Input,
                       outputWriter: OutputWriter,
                       context: Context,
                       next: (Input, OutputWriter, Context) async throws -> Void) async throws {
        if let optionalMiddleware = optionalMiddleware {
            try await optionalMiddleware.handle(input, outputWriter: outputWriter, context: context) { input, outputWriter, context in
                try await next(input, outputWriter, context)
            }
        } else {
            try await next(input, outputWriter, context)
        }
    }
}

@resultBuilder
public struct MiddlewareBuilder {
    public static func buildBlock<M0: TransformingMiddlewareProtocol>(_ m0: M0) -> M0 {
        return m0
    }
    
    /// Add support for optionals.
    public static func buildOptional<M0: TransformingMiddlewareProtocol>(_ m0: M0?) -> OptionalMiddleware<M0> {
        return OptionalMiddleware(m0)
    }

    /// Add support for if statements.
    public static func buildEither<M0: TransformingMiddlewareProtocol>(first m0: M0) -> M0 {
        return m0
    }

    public static func buildEither<M0: TransformingMiddlewareProtocol>(second m0: M0) -> M0 {
        return m0
    }

    public static func buildPartialBlock<M0: TransformingMiddlewareProtocol>(first: M0) -> M0 {
        return first
    }

    public static func buildPartialBlock<M0: TransformingMiddlewareProtocol, M1: TransformingMiddlewareProtocol>(
        accumulated m0: M0, next m1: M1) -> TransformingMiddlewareTuple<M0, M1>
    where M0.OutgoingInput == M1.IncomingInput, M0.OutgoingContext == M1.IncomingContext, M0.OutgoingOutputWriter == M1.IncomingOutputWriter {
        return TransformingMiddlewareTuple(m0, m1)
    }
}

public func MiddlewareStack<IncomingInput, OutgoingInput, IncomingOutputWriter, OutgoingOutputWriter, IncomingContext, OutgoingContext>(
    @MiddlewareBuilder _ builder: () -> some TransformingMiddlewareProtocol<IncomingInput, OutgoingInput,
                                                                            IncomingOutputWriter, OutgoingOutputWriter, IncomingContext, OutgoingContext>)
-> some TransformingMiddlewareProtocol<IncomingInput, OutgoingInput, IncomingOutputWriter, OutgoingOutputWriter, IncomingContext, OutgoingContext> {
    return builder()
}
