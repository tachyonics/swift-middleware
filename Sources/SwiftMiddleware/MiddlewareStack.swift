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
@resultBuilder
public struct MiddlewareBuilder {
    public static func buildBlock<M0: MiddlewareProtocol>(_ m0: M0) -> M0 {
        return m0
    }

    public static func buildPartialBlock<M0: MiddlewareProtocol>(first: M0) -> M0 {
        return first
    }

    public static func buildPartialBlock<M0: MiddlewareProtocol, M1: MiddlewareProtocol>(
        accumulated m0: M0,
        next m1: M1
    ) -> MiddlewareTuple<M0, M1> where M0.Input == M1.Input, M0.Output == M1.Output, M0.Context == M1.Context {
        return MiddlewareTuple(m0, m1)
    }
}

public func MiddlewareStack<Input, Output, Context>(@MiddlewareBuilder _ builder: () -> some MiddlewareProtocol<Input, Output, Context>)
-> some MiddlewareProtocol<Input, Output, Context> {
    return builder()
}
#endif
