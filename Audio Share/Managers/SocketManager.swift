//
//  SocketManager.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/22/24.
//

import Foundation
import NIO
//import NIOTransportServices // if you're targeting iOS or macOS with the NIOTransportServices module

class SocketManager {
    private let group:MultiThreadedEventLoopGroup;// = MultiThreadedEventLoopGroup(numberOfThreads: 1);
    private let bootstrap:ClientBootstrap;
    private let channel: (any Channel)?;

    init(ip_address: String, port: Int){
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1);
        self.bootstrap = ClientBootstrap(group: group)
        .channelInitializer { channel in
            channel.pipeline.addHandlers([InboundHandler(), OutboundHandler()])
        }
        .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)

        do {
            let address = try SocketAddress(ipAddress: ip_address, port: port);
            self.channel = try bootstrap.connect(to: address).wait()
            // Write and flush data to the server
            let buffer = self.channel!.allocator.buffer(string: "Hello, Server!")
            self.channel!.writeAndFlush(NIOAny(buffer), promise: nil)

        }
        catch {
            print("why");
            self.channel = nil;
        }
        //channel.pipeline.addHandler(YourHandler()).wait()
    }
    
    
}
