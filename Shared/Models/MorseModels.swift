import Foundation

enum TrainingMode: String, CaseIterable, Identifiable {
    case learn = "Learn"
    case test = "Test"

    var id: String { rawValue }

    var showsGuide: Bool {
        self == .learn
    }
}

enum MorseSignal: String, CaseIterable, Codable, Hashable {
    case dot
    case dash
}

struct MorsePrompt: Identifiable, Equatable {
    let character: String
    let sequence: [MorseSignal]

    var id: String { character }
}

struct GameSummary: Equatable {
    let score: Int
    let level: Int
    let accuracy: Int
    let isHighScore: Bool
}

enum RoundFeedback: Equatable {
    case neutral
    case success
    case error(index: Int, received: MorseSignal)
}

enum MorseAlphabet {
    static let prompts: [MorsePrompt] = [
        MorsePrompt(character: "A", sequence: [.dot, .dash]),
        MorsePrompt(character: "B", sequence: [.dash, .dot, .dot, .dot]),
        MorsePrompt(character: "C", sequence: [.dash, .dot, .dash, .dot]),
        MorsePrompt(character: "D", sequence: [.dash, .dot, .dot]),
        MorsePrompt(character: "E", sequence: [.dot]),
        MorsePrompt(character: "F", sequence: [.dot, .dot, .dash, .dot]),
        MorsePrompt(character: "G", sequence: [.dash, .dash, .dot]),
        MorsePrompt(character: "H", sequence: [.dot, .dot, .dot, .dot]),
        MorsePrompt(character: "I", sequence: [.dot, .dot]),
        MorsePrompt(character: "J", sequence: [.dot, .dash, .dash, .dash]),
        MorsePrompt(character: "K", sequence: [.dash, .dot, .dash]),
        MorsePrompt(character: "L", sequence: [.dot, .dash, .dot, .dot]),
        MorsePrompt(character: "M", sequence: [.dash, .dash]),
        MorsePrompt(character: "N", sequence: [.dash, .dot]),
        MorsePrompt(character: "O", sequence: [.dash, .dash, .dash]),
        MorsePrompt(character: "P", sequence: [.dot, .dash, .dash, .dot]),
        MorsePrompt(character: "Q", sequence: [.dash, .dash, .dot, .dash]),
        MorsePrompt(character: "R", sequence: [.dot, .dash, .dot]),
        MorsePrompt(character: "S", sequence: [.dot, .dot, .dot]),
        MorsePrompt(character: "T", sequence: [.dash]),
        MorsePrompt(character: "U", sequence: [.dot, .dot, .dash]),
        MorsePrompt(character: "V", sequence: [.dot, .dot, .dot, .dash]),
        MorsePrompt(character: "W", sequence: [.dot, .dash, .dash]),
        MorsePrompt(character: "X", sequence: [.dash, .dot, .dot, .dash]),
        MorsePrompt(character: "Y", sequence: [.dash, .dot, .dash, .dash]),
        MorsePrompt(character: "Z", sequence: [.dash, .dash, .dot, .dot])
    ]
}
