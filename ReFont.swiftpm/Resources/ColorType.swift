
import SwiftUI

enum ColorType: String, CaseIterable {
    case black = "Black"
    case red = "Red"
    case orange = "Orange"
    case yellow = "Yellow"
    case green = "Green"
    case blue = "Blue"
    case indigo = "Indigo"
    case purple = "Purple"
    case white = "White"
    case gray = "Gray"
    case brown = "Brown"
    case pink = "Pink"
    case cyan = "Cyan"
    case lightGray = "Light Gray"
    case darkGray = "Dark Gray"
    
    var uiColor: UIColor {
        switch self {
        case .black: return .black
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        case .indigo: return .systemIndigo
        case .purple: return .purple
        case .white: return .white
        case .gray: return .gray
        case .brown: return .brown
        case .pink: return .systemPink
        case .cyan: return .cyan
        case .lightGray: return .lightGray
        case .darkGray: return .darkGray
        }
    }

    var swiftUIColor: Color {
        Color(uiColor: uiColor)
    }

    init?(from color: UIColor) {
        for option in ColorType.allCases {
            if option.uiColor == color {
                self = option
                return
            }
        }
        return nil
    }
}
