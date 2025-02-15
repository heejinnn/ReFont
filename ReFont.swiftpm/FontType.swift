

enum FontType: String, CaseIterable {
    case helvetica = "Helvetica"
    case helveticaNeue = "Helvetica Neue"
    case courier = "Courier"
    case rockwell = "Rockwell"
    case markerFelt = "MarkerFelt-Thin"
    case noteworthy = "Noteworthy"
    case timesNewRoman = "Times New Roman"
    case snellRoundhand = "SnellRoundhand"
    case bradleyHand = "BradleyHandITCTT-Bold"
    
    var displayName: String {
        switch self {
        case .helvetica: return "Helvetica"
        case .helveticaNeue: return "Helvetica Neue"
        case .courier: return "Courier"
        case .rockwell: return "Rockwell"
        case .markerFelt: return "Marker Felt"
        case .noteworthy: return "Noteworthy"
        case .timesNewRoman: return "Times New Roman"
        case .snellRoundhand: return "Snell Roundhand"
        case .bradleyHand: return "Bradley Hand"
        }
    }
}

import SwiftUI

enum ColorOption: String, CaseIterable {
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

    // UIColor에서 ColorOption으로 변환하는 초기화 메서드
    init?(from color: UIColor) {
        for option in ColorOption.allCases {
            if option.uiColor == color {
                self = option
                return
            }
        }
        return nil
    }
}
