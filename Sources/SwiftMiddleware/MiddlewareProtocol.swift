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
    
public typealias Middleware<Input, OutputWriter, Context> = (Input, OutputWriter, Context, _ next: (Input, OutputWriter, Context) async throws -> Void) async throws -> Void

public protocol TransformingMiddlewareProtocol<IncomingInput, OutgoingInput, IncomingOutputWriter, OutgoingOutputWriter, IncomingContext, OutgoingContext> {
    associatedtype IncomingInput
    associatedtype OutgoingInput
    associatedtype IncomingOutputWriter
    associatedtype OutgoingOutputWriter
    associatedtype IncomingContext
    associatedtype OutgoingContext
    
    func handle(_ input: IncomingInput,
                outputWriter: IncomingOutputWriter,
                context: IncomingContext,
                next: (OutgoingInput, OutgoingOutputWriter, OutgoingContext) async throws -> Void) async throws
}

public protocol MiddlewareProtocol<Input, OutputWriter, Context>: TransformingMiddlewareProtocol
where IncomingInput == Input, OutgoingInput == Input,
IncomingOutputWriter == OutputWriter, OutgoingOutputWriter == OutputWriter,
IncomingContext == Context, OutgoingContext == Context {
    associatedtype Input
    associatedtype OutputWriter
    associatedtype Context
}
