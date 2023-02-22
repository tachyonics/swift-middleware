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
public protocol TransformProtocol<Input, Output, Context> {
    associatedtype Input
    associatedtype Output
    associatedtype Context

    func transform(_ input: Input, context: Context) async throws -> Output
}

public protocol TransformMiddlewareProtocol<OriginalInput, TransformedInput, OriginalOutput, TransformedOutput, Context> {
    associatedtype OriginalInput
    associatedtype TransformedInput
    associatedtype OriginalOutput
    associatedtype TransformedOutput
    associatedtype Context

    func handle(_ input: OriginalInput, context: Context, next: (TransformedInput, Context) async throws -> OriginalOutput) async throws
    -> TransformedOutput
}

internal struct TransformMiddleware<OuterMiddlewareType: MiddlewareProtocol,
                                    RequestTransformType: TransformProtocol,
                                    ResponseTransformType: TransformProtocol,
                                    InnerMiddlewareType: MiddlewareProtocol>: TransformMiddlewareProtocol
where RequestTransformType.Input == OuterMiddlewareType.Input,
      ResponseTransformType.Output == OuterMiddlewareType.Output,
      RequestTransformType.Output == InnerMiddlewareType.Input,
      ResponseTransformType.Input == InnerMiddlewareType.Output,
      RequestTransformType.Context == InnerMiddlewareType.Context,
      ResponseTransformType.Context == InnerMiddlewareType.Context,
      OuterMiddlewareType.Context == InnerMiddlewareType.Context{
    typealias Context = InnerMiddlewareType.Context
    typealias OriginalInput = RequestTransformType.Input
    typealias TransformedInput = RequestTransformType.Output
    typealias OriginalOutput = ResponseTransformType.Input
    typealias TransformedOutput  = ResponseTransformType.Output
    
    let outerMiddleware: OuterMiddlewareType
    let requestTransform: RequestTransformType
    let responseTransform: ResponseTransformType
    let innerMiddleware: InnerMiddlewareType
    
    init(requestTransform: RequestTransformType, responseTransform: ResponseTransformType,
         outerMiddleware: OuterMiddlewareType, innerMiddleware: InnerMiddlewareType) {
        self.outerMiddleware = outerMiddleware
        self.requestTransform = requestTransform
        self.responseTransform = responseTransform
        self.innerMiddleware = innerMiddleware
    }
    
    func handle(_ input: RequestTransformType.Input, context: InnerMiddlewareType.Context,
                next: (InnerMiddlewareType.Input, InnerMiddlewareType.Context) async throws-> InnerMiddlewareType.Output) async throws
    -> ResponseTransformType.Output {
        return try await self.outerMiddleware.handle(input, context: context) { inputFromOuterMiddleware, contextFromOuterMiddleware in
            let transformedInput = try await self.requestTransform.transform(inputFromOuterMiddleware, context: contextFromOuterMiddleware)
            
            let originalOutput = try await self.innerMiddleware.handle(transformedInput,
                                                                       context: context) { inputFromInnerMiddlware, contextFromInnerMiddlware in
                try await next(inputFromInnerMiddlware, contextFromInnerMiddlware)
            }
            
            return try await self.responseTransform.transform(originalOutput, context: context)
        }
    }
}

public func MiddlewareTransformStack<OriginalInput, TransformedInput, OriginalOutput, TransformedOutput, Context>(
    requestTransform: some TransformProtocol<OriginalInput, TransformedInput, Context>,
    responseTransform: some TransformProtocol<OriginalOutput, TransformedOutput, Context>,
    @MiddlewareBuilder outer outerBuilder: () -> some MiddlewareProtocol<OriginalInput, TransformedOutput, Context>,
    @MiddlewareBuilder inner innerBuilder: () -> some MiddlewareProtocol<TransformedInput, OriginalOutput, Context>)
-> some TransformMiddlewareProtocol<OriginalInput, TransformedInput, OriginalOutput, TransformedOutput, Context> {
    return TransformMiddleware(requestTransform: requestTransform, responseTransform: responseTransform,
                               outerMiddleware: outerBuilder(), innerMiddleware: innerBuilder())
}
#else
public protocol TransformProtocol {
    associatedtype Input
    associatedtype Output
    associatedtype Context

    func transform(_ input: Input, context: Context) async throws -> Output
}

public protocol TransformMiddlewareProtocol {
    associatedtype OriginalInput
    associatedtype TransformedInput
    associatedtype OriginalOutput
    associatedtype TransformedOutput
    associatedtype Context

    func handle(_ input: OriginalInput, context: Context, next: (TransformedInput, Context) async throws -> OriginalOutput) async throws
    -> TransformedOutput
}
#endif
