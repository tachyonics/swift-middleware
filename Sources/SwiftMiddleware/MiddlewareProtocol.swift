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
    
public typealias Middleware<Input, Output, Context> = (Input, Context, _ next: (Input, Context) async throws -> Output) async throws -> Output

#if compiler(>=5.7)
public protocol MiddlewareProtocol<Input, Output, Context> {
    associatedtype Input
    associatedtype Output
    associatedtype Context
    
    func handle(_ input: Input, context: Context, next: (Input, Context) async throws -> Output) async throws
    -> Output
}
#else
public protocol MiddlewareProtocol {
    associatedtype Input
    associatedtype Output
    associatedtype Context
    
    func handle(_ input: Input, context: Context, next: (Input, Context) async throws -> Output) async throws
    -> Output
}
#endif
