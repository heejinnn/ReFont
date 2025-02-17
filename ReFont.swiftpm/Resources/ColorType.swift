
import SwiftUI

enum ColorType: String, CaseIterable {
    case black = "Black"
    case blue = "Blue"
    case cyan = "Cyan"
    case yellow = "Yellow"
    case red = "Red"
    case gray = "Gray"
    case brown = "Brown"
    case orange = "Orange"

    var uiColor: UIColor {
        switch self {
        case .black: return .black
        case .blue: return .blue
        case .cyan: return .cyan
        case .yellow: return .yellow
        case .red: return .red
        case .gray: return .gray
        case .brown: return .brown
        case .orange: return .orange
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
