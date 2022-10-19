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

public enum Middlewares {
    public func startingPhase<HandlerType: MiddlewareHandlerProtocol, MiddlewareType: MiddlewareProtocol>(next handler: HandlerType,
                                                                                                          with middleware: MiddlewareType)
    -> some MiddlewarePhaseProtocol
    where MiddlewareType.InputType == HandlerType.InputType, MiddlewareType.OutputType == HandlerType.OutputType {
        return MiddlewarePhase(next: handler, with: middleware)
    }
}
