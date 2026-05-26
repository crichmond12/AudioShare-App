//
//  Inbound Handler.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/23/24.
//

import Foundation
import NIO

final class InboundHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let byteBuffer = self.unwrapInboundIn(data)
        if let receivedString = byteBuffer.getString(at: 0, length: byteBuffer.readableBytes) {
            print("Received from server: \(receivedString)")
        }
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("Error: \(error)")
        context.close(promise: nil)
    }
}
