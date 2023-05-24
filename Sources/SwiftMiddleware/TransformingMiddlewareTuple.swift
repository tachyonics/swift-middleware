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

public struct TransformingMiddlewareTuple<M0: TransformingMiddlewareProtocol, M1: TransformingMiddlewareProtocol>: TransformingMiddlewareProtocol
where M0.OutgoingInput == M1.IncomingInput, M0.OutgoingContext == M1.IncomingContext, M0.OutgoingOutputWriter == M1.IncomingOutputWriter {
    public typealias IncomingInput = M0.IncomingInput
    public typealias OutgoingInput = M1.OutgoingInput
    public typealias IncomingOutputWriter = M0.IncomingOutputWriter
    public typealias OutgoingOutputWriter = M1.OutgoingOutputWriter
    public typealias IncomingContext = M0.IncomingContext
    public typealias OutgoingContext = M1.OutgoingContext

    @usableFromInline let m0: M0
    @usableFromInline let m1: M1

    @inlinable
    public init(_ m0: M0, _ m1: M1) {
        self.m0 = m0
        self.m1 = m1
    }

    @inlinable
    public func handle(_ input: IncomingInput,
                       outputWriter: IncomingOutputWriter,
                       context: IncomingContext,
                       next: (OutgoingInput, OutgoingOutputWriter, OutgoingContext) async throws -> Void) async throws {
        try await m0.handle(input, outputWriter: outputWriter, context: context) { input, outputWriter, context in
            try await m1.handle(input, outputWriter: outputWriter, context: context, next: next)
        }
    }
}
