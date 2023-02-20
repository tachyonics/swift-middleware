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
public protocol MiddlewareProtocol<OriginalInput, OriginalOutput, Context>: TransformMiddlewareProtocol
where OriginalInput == TransformedInput, OriginalInput == Input,
      OriginalOutput == TransformedOutput, OriginalOutput == Output {
    associatedtype Input
    associatedtype Output
}
#else
public protocol MiddlewareProtocol: TransformMiddlewareProtocol
where OriginalInput == TransformedInput, OriginalInput == Input,
      OriginalOutput == TransformedOutput, OriginalOutput == Output {
    associatedtype Input
    associatedtype Output
}
#endif
