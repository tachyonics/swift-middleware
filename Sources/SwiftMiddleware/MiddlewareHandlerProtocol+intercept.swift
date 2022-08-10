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

public extension MiddlewareHandlerProtocol {
    func startingPhase<MiddlewareType: MiddlewareProtocol>(with middleware: MiddlewareType) -> some MiddlewarePhaseProtocol
    where MiddlewareType.InputType == InputType, MiddlewareType.OutputType == OutputType {        
        return MiddlewarePhase(next: self, with: middleware)
    }
}
