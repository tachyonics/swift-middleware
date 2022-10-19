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
public protocol MiddlewareNodeChainProtocol: _MiddlewareSendable {
    associatedtype InputType
    associatedtype OutputType
    associatedtype MiddlewareType: MiddlewareProtocol where MiddlewareType.InputType == InputType, MiddlewareType.OutputType == OutputType
    associatedtype NodeChainType: MiddlewareNodeChainProtocol where NodeChainType.InputType == InputType, NodeChainType.OutputType == OutputType
    
    var with: MiddlewareType { get }
    var previousChain: NodeChainType { get }
}

extension MiddlewareNodeChainProtocol {
    // the `MiddlewareNodeChain` is built up in reverse order
    // this function will flip the order of the middleware and place handlers
    // inbetween.
    func transform<HandlerType: MiddlewareHandlerProtocol>(next: HandlerType)
    -> some MiddlewareHandlerProtocol<InputType, OutputType, HandlerType.ContextType>
    where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType {
        let transformedNext = ComposedMiddlewarePhaseHandler(next: next, with: self.with)
        
        // need recursion terminating condition but won't return the same type
        //guard let previousChain = self.previousChain else {
        //    return transformedNext
        //}
                
        return self.previousChain.transform(next: transformedNext)
    }
}

public struct MiddlewareNodeChain<InputType, OutputType, MiddlewareType: MiddlewareProtocol,
                                  NodeChainType: MiddlewareNodeChainProtocol>: MiddlewareNodeChainProtocol
where MiddlewareType.InputType == InputType, MiddlewareType.OutputType == OutputType,
      NodeChainType.InputType == InputType, NodeChainType.OutputType == OutputType {
    public let with: MiddlewareType
    public let previousChain: NodeChainType
    
    public init(previousChain: NodeChainType, with: MiddlewareType) {
        self.previousChain = previousChain
        self.with = with
    }
}
#endif
