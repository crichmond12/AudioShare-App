//
//  Outbound Handler.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/23/24.
//

import Foundation
import NIO

final class OutboundHandler: ChannelOutboundHandler {
    public typealias OutboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let byteBuffer = self.unwrapOutboundIn(data)
        context.write(self.wrapOutboundOut(byteBuffer), promise: promise)
    }
}
