//
//  Audio Engine.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/24/24.
//

import Foundation
import AVFoundation

class AudioEngine {
    private let audioEngine = AVAudioEngine();
    let audioSession = AVAudioSession.sharedInstance()
    private let inputNode: AVAudioInputNode;
    private let outputNode: AVAudioOutputNode;

    
    init(){
        print(self.audioSession.currentRoute);
        self.inputNode = self.audioEngine.inputNode
        self.outputNode = self.audioEngine.outputNode
        let mixerNode = AVAudioMixerNode()
        

        self.audioEngine.attach(mixerNode)
        //self.audioEngine.connect(self.inputNode, to: mixerNode, format: inputNode.inputFormat(forBus: 0))
        //self.audioEngine.connect(mixerNode, to: self.outputNode, format: outputNode.outputFormat(forBus: 0))
        
        
        do {
            try self.audioSession.setCategory(.playback);
            try self.audioSession.setActive(true)
        }
        catch{
            print("Error setting audio session category.");
            return;
        }
        //print(self.audioSession.currentRoute);
        self.addOutputNode();
        print(self.audioSession.currentRoute);
        do {
            self.audioEngine.prepare();
            try self.audioEngine.start();
        }
        catch{
            print("Unable to start audio engine.")
            return;
        }
    }

    
    func addOutputNode() {
        //let outputNode = self.audioEngine.outputNode
        let outputFormat = self.outputNode.outputFormat(forBus: 0)

        self.outputNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { [weak self] (buffer, time) in
            self?.processAudioBuffer(buffer)
        }
    }

    func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        // Here you can process the audio buffer and transmit it to your custom speaker
        print("PROCESSING");
        transmitBufferToCustomSpeaker(buffer)
    }

    func transmitBufferToCustomSpeaker(_ buffer: AVAudioPCMBuffer) {
        
        guard let channelData = buffer.floatChannelData else { return }

               let channelCount = Int(buffer.format.channelCount)
        for channel in 0..<channelCount {
            let channelDataPointer = channelData[channel]
            let channelDataBuffer = UnsafeBufferPointer(start: channelDataPointer, count: Int(buffer.frameLength))
            
            // Convert to Data
            let data = Data(buffer: channelDataBuffer)
            
            // Send data to the custom speaker
            sendAudioDataToSpeaker(data)
        }
        print("TRANSMITTING");
        // Implement your custom transmission logic here
        // For example, sending the buffer data over a network connection to the custom speaker
    }
    func sendAudioDataToSpeaker(_ data: Data) {
        print("PLEASE");
        // Implement the network transmission logic here
    }

}
