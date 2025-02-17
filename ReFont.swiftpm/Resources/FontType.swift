
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
