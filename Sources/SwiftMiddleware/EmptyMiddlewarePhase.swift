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

public protocol EmptyMiddlewarePhaseProtocol {
    associatedtype InputType
    associatedtype OutputType
    associatedtype HandlerType: MiddlewareHandlerProtocol where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType
    
    var next: HandlerType { get }
}

public extension EmptyMiddlewarePhaseProtocol {
    func create<HandlerType: MiddlewareHandlerProtocol>(next: HandlerType) -> some EmptyMiddlewarePhaseProtocol
    where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType {
        return EmptyMiddlewarePhase(next: next)
    }
    
    func intercept<MiddlewareType: MiddlewareProtocol>(middleware: MiddlewareType) -> some MiddlewarePhaseProtocol
    where MiddlewareType.InputType == InputType, MiddlewareType.OutputType == OutputType {        
        return MiddlewarePhase(next: self.next, with: middleware)
    }
}

struct EmptyMiddlewarePhase<InputType, OutputType, HandlerType: MiddlewareHandlerProtocol>: EmptyMiddlewarePhaseProtocol
where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType {
    let next: HandlerType

    init(next: HandlerType) {
        self.next = next
    }
}
