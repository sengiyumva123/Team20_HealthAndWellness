// SoundGenerator.swift
import AVFoundation

class SoundGenerator {
    private let audioEngine = AVAudioEngine()
    private let sampleRate: Double = 44100
    private let duration: Double = 5.0
    
    enum SoundArchetype: String {
        case falling, water, flying
    }
    
    func generateSound(for text: String) -> URL? {
        let archetype = detectArchetype(from: text)
        let fileName = "\(Date().timeIntervalSince1970)_\(archetype.rawValue).wav"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        switch archetype {
        case .falling:
            generateWindSound(saveTo: fileURL)
        case .water:
            generateWaterSound(saveTo: fileURL)
        case .flying:
            generateWhooshSound(saveTo: fileURL)
        }
        
        return fileURL
    }
    
    private func detectArchetype(from text: String) -> SoundArchetype {
        let lowerText = text.lowercased()
        
        if ["water", "ocean", "sea", "river", "wave"].contains(where: lowerText.contains) {
            return .water
        } else if ["fly", "air", "sky", "wing", "float"].contains(where: lowerText.contains) {
            return .flying
        }
        return .falling
    }
    
    private func generateWindSound(saveTo url: URL) {
        // Implement using AVAudioEngine
        // This is a simplified version - actual implementation would be more complex
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(sampleRate * duration))!
        
        for i in 0..<Int(buffer.frameCapacity) {
            let time = Double(i) / sampleRate
            let value = Float(sin(2 * .pi * 100 * time) * Float(exp(-0.1 * time))
            buffer.floatChannelData?.pointee[i] = value * 0.5 // Reduce volume
        }
        
        do {
            let file = try AVAudioFile(forWriting: url, settings: format.settings)
            try file.write(from: buffer)
        } catch {
            print("Error saving sound file: \(error)")
        }
    }
    
    private func generateWaterSound(saveTo url: URL) {
        // Similar implementation for water sound
    }
    
    private func generateWhooshSound(saveTo url: URL) {
        // Similar implementation for whoosh sound
    }
}