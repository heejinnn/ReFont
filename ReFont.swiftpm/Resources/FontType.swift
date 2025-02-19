
enum FontType: String, CaseIterable {
    case helvetica = "Helvetica"
    case arial = "Arial"
    case helveticaNeue = "Helvetica Neue"
    case timesNewRoman = "Times New Roman"
    case courier = "Courier"
    case rockwell = "Rockwell"
    case markerFelt = "MarkerFelt-Thin"
    case noteworthy = "Noteworthy"
    case verdana = "Verdana"
    case snellRoundhand = "SnellRoundhand"
    case bradleyHand = "BradleyHandITCTT-Bold"
    case papyrus = "Papyrus"
    
    var displayName: String {
        switch self {
        case .helvetica: return "Helvetica"
        case .arial: return "Arial"
        case .helveticaNeue: return "Helvetica Neue"
        case .verdana: return "Verdana"
        case .courier: return "Courier"
        case .rockwell: return "Rockwell"
        case .markerFelt: return "Marker Felt"
        case .noteworthy: return "Noteworthy"
        case .timesNewRoman: return "Times New Roman"
        case .snellRoundhand: return "Snell Roundhand"
        case .bradleyHand: return "Bradley Hand"
        case .papyrus: return "Papyrus"
        }
    }
}
