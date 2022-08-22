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

public protocol HandlerProtocol: _MiddlewareSendable {
    associatedtype InputType
    associatedtype OutputType
    associatedtype ContextType
       
    func handle(input: InputType, context: ContextType) async throws -> OutputType
}

public protocol MiddlewareHandlerProtocol: HandlerProtocol where ContextType == MiddlewareContext {
    
}
