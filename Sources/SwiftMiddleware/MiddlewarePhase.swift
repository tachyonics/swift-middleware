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

import Foundation

public protocol MiddlewarePhaseProtocol: _MiddlewareSendable {
    associatedtype InputType
    associatedtype OutputType
    associatedtype MiddlewareType: MiddlewareProtocol where MiddlewareType.InputType == InputType, MiddlewareType.OutputType == OutputType
    associatedtype HandlerType: MiddlewareHandlerProtocol where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType
    
    var with: MiddlewareType { get }
    var next: HandlerType { get }
}

public extension MiddlewarePhaseProtocol {
    func asHandler() -> some MiddlewareHandlerProtocol {
        return ComposedMiddlewarePhaseHandler(next: self.next, with: self.with)
    }
    
    func intercept<MiddlewareType: MiddlewareProtocol>(middleware: MiddlewareType) -> some MiddlewarePhaseProtocol
    where MiddlewareType.InputType == InputType, MiddlewareType.OutputType == OutputType {
        let newNext = ComposedMiddlewarePhaseHandler(next: self.next, with: self.with)
        
        return MiddlewarePhase(next: newNext, with: middleware)
    }
}

public struct MiddlewarePhase<InputType, OutputType, MiddlewareType: MiddlewareProtocol, HandlerType: MiddlewareHandlerProtocol>: MiddlewarePhaseProtocol
where MiddlewareType.InputType == InputType, MiddlewareType.OutputType == OutputType,
HandlerType.InputType == InputType, HandlerType.OutputType == OutputType {
    public let with: MiddlewareType
    public let next: HandlerType
    
    public init(next: HandlerType, with: MiddlewareType) {
        self.next = next
        self.with = with
    }
}

// handler chain, used to decorate a handler with middleware
struct ComposedMiddlewarePhaseHandler<InputType, OutputType, MiddlewareType: MiddlewareProtocol,
                                      HandlerType: MiddlewareHandlerProtocol>: Sendable
where MiddlewareType.InputType == InputType, MiddlewareType.OutputType == OutputType,
HandlerType.InputType == InputType, HandlerType.OutputType == OutputType {
    // the next handler to call
    let next: HandlerType
    
    // the middleware decorating 'next'
    let with: MiddlewareType
    
    public init(next: HandlerType, with: MiddlewareType) {
        self.next = next
        self.with = with
    }
}

extension ComposedMiddlewarePhaseHandler: MiddlewareHandlerProtocol {
    public func handle(input: InputType, context: MiddlewareContext) async throws -> OutputType {
        return try await with.handle(input: input, context: context, next: next)
    }
}
