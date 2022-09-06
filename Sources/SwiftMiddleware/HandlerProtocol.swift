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

#if compiler(<5.7)
public protocol HandlerProtocol: _MiddlewareSendable {
    associatedtype InputType
    associatedtype OutputType
    associatedtype ContextType
       
    func handle(input: InputType, context: ContextType) async throws -> OutputType
}

public protocol MiddlewareHandlerProtocol: HandlerProtocol where ContextType == MiddlewareContext {
    
}
#else
public protocol HandlerProtocol<InputType, OutputType, ContextType>: _MiddlewareSendable {
    associatedtype InputType
    associatedtype OutputType
    associatedtype ContextType
       
    func handle(input: InputType, context: ContextType) async throws -> OutputType
}

public protocol MiddlewareHandlerProtocol<InputType, OutputType, ContextType>: HandlerProtocol where ContextType == MiddlewareContext {
    
}
#endif
