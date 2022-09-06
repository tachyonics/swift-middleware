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

import Logging

public struct MiddlewareContext {
    public let logger: Logger?
    
    public init(logger: Logger? = nil) {
        self.logger = logger
    }
}

public protocol MiddlewareProtocol: _MiddlewareSendable {
    associatedtype InputType
    associatedtype OutputType
    
#if compiler(>=5.6)
    @Sendable
    func handle<HandlerType: MiddlewareHandlerProtocol>(
        input: InputType,
        context: MiddlewareContext,
        next: HandlerType) async throws -> OutputType
    where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType
#else
    func handle<HandlerType: MiddlewareHandlerProtocol>(
        input: InputType,
        context: MiddlewareContext,
        next: HandlerType) async throws -> OutputType
    where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType
#endif
}
