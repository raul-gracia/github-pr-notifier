//
//  Extensions.swift
//  Github PR Notifier
//
//  Created by Raul Gracia on 29/07/2023.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
            case 3: // RGB (12-bit)
                (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
            default:
                (r, g, b) = (0, 0, 0)
        }
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
    
    func isLight(threshold: Float = 0.5) -> Bool {
        let components = self.cgColor?.components
        guard let red = components?[0], let green = components?[1], let blue = components?[2] else {
            return false
        }
        let brightness = Float(red * 0.299 + green * 0.587 + blue * 0.114)
        return brightness > threshold
    }
}


extension String {
    func humanize() -> String {
        let withoutUnderscores = self.replacingOccurrences(of: "_", with: " ")
        let lowercase = withoutUnderscores.lowercased()
        return lowercase.capitalized
    }
}
