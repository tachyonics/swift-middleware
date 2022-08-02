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

#if compiler(>=5.6)
public typealias _MiddlewareSendable = Sendable
public protocol _MiddlewareSendableProtocol: Sendable {}
#else
public typealias _MiddlewareSendable = Any
public protocol _MiddlewareSendableProtocol {}
#endif
