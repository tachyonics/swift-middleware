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
                                    InwardTransformType: TransformProtocol,
                                    OutwardTransformType: TransformProtocol,
                                    InnerMiddlewareType: MiddlewareProtocol>: TransformMiddlewareProtocol
where InwardTransformType.Input == OuterMiddlewareType.Input,
      OutwardTransformType.Output == OuterMiddlewareType.Output,
      InwardTransformType.Output == InnerMiddlewareType.Input,
      OutwardTransformType.Input == InnerMiddlewareType.Output,
      InwardTransformType.Context == InnerMiddlewareType.Context,
      OutwardTransformType.Context == InnerMiddlewareType.Context,
      OuterMiddlewareType.Context == InnerMiddlewareType.Context{
    typealias Context = InnerMiddlewareType.Context
    typealias OriginalInput = InwardTransformType.Input
    typealias TransformedInput = InwardTransformType.Output
    typealias OriginalOutput = OutwardTransformType.Input
    typealias TransformedOutput  = OutwardTransformType.Output
    
    let outerMiddleware: OuterMiddlewareType
    let inwardTransform: InwardTransformType
    let outwardTransform: OutwardTransformType
    let innerMiddleware: InnerMiddlewareType
    
    init(inwardTransform: InwardTransformType, outwardTransform: OutwardTransformType,
         outerMiddleware: OuterMiddlewareType, innerMiddleware: InnerMiddlewareType) {
        self.outerMiddleware = outerMiddleware
        self.inwardTransform = inwardTransform
        self.outwardTransform = outwardTransform
        self.innerMiddleware = innerMiddleware
    }
    
    func handle(_ input: InwardTransformType.Input, context: InnerMiddlewareType.Context,
                next: (InnerMiddlewareType.Input, InnerMiddlewareType.Context) async throws-> InnerMiddlewareType.Output) async throws
    -> OutwardTransformType.Output {
        return try await self.outerMiddleware.handle(input, context: context) { inputFromOuterMiddleware, contextFromOuterMiddleware in
            let transformedInput = try await self.inwardTransform.transform(inputFromOuterMiddleware, context: contextFromOuterMiddleware)
            
            let originalOutput = try await self.innerMiddleware.handle(transformedInput,
                                                                       context: context) { inputFromInnerMiddlware, contextFromInnerMiddlware in
                try await next(inputFromInnerMiddlware, contextFromInnerMiddlware)
            }
            
            return try await self.outwardTransform.transform(originalOutput, context: context)
        }
    }
}

public func MiddlewareTransformStack<OriginalInput, TransformedInput, OriginalOutput, TransformedOutput, Context>(
    inwardTransform: some TransformProtocol<OriginalInput, TransformedInput, Context>,
    outwardTransform: some TransformProtocol<OriginalOutput, TransformedOutput, Context>,
    @MiddlewareBuilder outer outerBuilder: () -> some MiddlewareProtocol<OriginalInput, TransformedOutput, Context>,
    @MiddlewareBuilder inner innerBuilder: () -> some MiddlewareProtocol<TransformedInput, OriginalOutput, Context>)
-> some TransformMiddlewareProtocol<OriginalInput, TransformedInput, OriginalOutput, TransformedOutput, Context> {
    return TransformMiddleware(inwardTransform: inwardTransform, outwardTransform: outwardTransform,
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
