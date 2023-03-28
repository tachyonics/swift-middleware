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

public struct TransformTuple<T0: TransformProtocol, T1: TransformProtocol>: TransformProtocol
where T0.Output == T1.Input, T0.Context == T1.Context {
    public typealias Input = T0.Input
    public typealias Output = T1.Output
    public typealias Context = T0.Context

    @usableFromInline let t0: T0
    @usableFromInline let t1: T1

    @inlinable
    public init(_ t0: T0, _ t1: T1) {
        self.t0 = t0
        self.t1 = t1
    }

    @inlinable
    public func transform(_ input: T0.Input, context: T0.Context) async throws -> T1.Output {
        let intermediate = try await self.t0.transform(input, context: context)
        
        return try await self.t1.transform(intermediate, context: context)
    }
}
