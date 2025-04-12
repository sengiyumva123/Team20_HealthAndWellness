//
//  Untitled.swift
//  HealthAndWellness
//
//  Created by Sengi Mathias on 4/12/25.
//
import SwiftUI
extension Color{
    init(hex: String) {
            let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&int)

            let a, r, g, b: UInt64
            switch hex.count {
            case 3:
                (a, r, g, b) = (255, (int >> 8) * 17,
                                     (int >> 4 & 0xF) * 17,
                                     (int & 0xF) * 17)
            case 6:
                (a, r, g, b) = (255, int >> 16,
                                    int >> 8 & 0xFF,
                                    int & 0xFF)
            case 8:
                (a, r, g, b) = (int >> 24,
                                    int >> 16 & 0xFF,
                                    int >> 8 & 0xFF,
                                    int & 0xFF)
            default:
                (a, r, g, b) = (255, 128, 0, 128)
            }

            self.init(
                .sRGB,
                red: Double(r) / 255,
                green: Double(g) / 255,
                blue: Double(b) / 255,
                opacity: Double(a) / 255
            )
        }
    static var comet: Color {
        return Color(hex:"#5c5c7a")
        }
    static var gold:Color{
        return Color(hex: "f5a300")
    }
    static var GunPowder:Color{
        return Color(hex: "#3c3c58")
    }
    
}
