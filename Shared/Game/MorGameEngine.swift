import Foundation

@MainActor
final class MorGameEngine: ObservableObject {
    @Published private(set) var mode: TrainingMode
    @Published private(set) var currentPrompt: MorsePrompt
    @Published private(set) var enteredSignals: [MorseSignal] = []
    @Published private(set) var feedback: RoundFeedback = .neutral
    @Published private(set) var score = 0
    @Published private(set) var lives = 3
    @Published private(set) var level = 1
    @Published private(set) var totalInputs = 0
    @Published private(set) var correctInputs = 0
    @Published private(set) var isInputLocked = false

    private let onGameOver: (GameSummary) -> Void
    private let highScoreKey = "mor.highScore"
    private var roundsCleared = 0
    private var transitionTask: Task<Void, Never>?

    init(mode: TrainingMode, onGameOver: @escaping (GameSummary) -> Void) {
        self.mode = mode
        self.currentPrompt = MorseAlphabet.prompts.first ?? MorsePrompt(character: "A", sequence: [.dot, .dash])
        self.onGameOver = onGameOver
    }

    deinit {
        transitionTask?.cancel()
    }

    var accuracy: Int {
        guard totalInputs > 0 else { return 100 }
        let ratio = Double(correctInputs) / Double(totalInputs)
        return Int((ratio * 100).rounded())
    }

    func submit(_ signal: MorseSignal) {
        guard !isInputLocked else { return }
        guard enteredSignals.count < currentPrompt.sequence.count else { return }

        MorHaptics.tap()
        totalInputs += 1

        let nextIndex = enteredSignals.count
        let expectedSignal = currentPrompt.sequence[nextIndex]

        guard signal == expectedSignal else {
            handleFailure(at: nextIndex, received: signal)
            return
        }

        correctInputs += 1
        score += 20 * level
        enteredSignals.append(signal)

        if enteredSignals.count == currentPrompt.sequence.count {
            handleSuccess()
        }
    }

    private func handleSuccess() {
        isInputLocked = true
        feedback = .success
        roundsCleared += 1
        level = (roundsCleared / 4) + 1
        MorHaptics.success()

        schedule(after: MorTheme.roundTransitionDelay) { [weak self] in
            self?.advanceToNextPrompt()
        }
    }

    private func handleFailure(at index: Int, received: MorseSignal) {
        isInputLocked = true
        lives -= 1
        feedback = .error(index: index, received: received)
        MorHaptics.failure()

        if lives <= 0 {
            schedule(after: MorTheme.failureTransitionDelay) { [weak self] in
                self?.finishGame()
            }
            return
        }

        schedule(after: MorTheme.failureTransitionDelay) { [weak self] in
            self?.resetCurrentPrompt()
        }
    }

    private func advanceToNextPrompt() {
        enteredSignals = []
        feedback = .neutral
        isInputLocked = false
        currentPrompt = choosePrompt()
    }

    private func resetCurrentPrompt() {
        enteredSignals = []
        feedback = .neutral
        isInputLocked = false
    }

    private func choosePrompt() -> MorsePrompt {
        let availableCount = min(MorseAlphabet.prompts.count, max(5, level + 4))
        let pool = Array(MorseAlphabet.prompts.prefix(availableCount))
        let filteredPool = pool.filter { $0 != currentPrompt }
        return filteredPool.randomElement() ?? pool.randomElement() ?? currentPrompt
    }

    private func finishGame() {
        transitionTask?.cancel()

        let defaults = UserDefaults.standard
        let existingHighScore = defaults.integer(forKey: highScoreKey)
        let isHighScore = score > existingHighScore

        if isHighScore {
            defaults.set(score, forKey: highScoreKey)
        }

        onGameOver(
            GameSummary(
                score: score,
                level: max(level, 1),
                accuracy: accuracy,
                isHighScore: isHighScore
            )
        )
    }

    private func schedule(after nanoseconds: UInt64, action: @escaping @MainActor () -> Void) {
        transitionTask?.cancel()
        transitionTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled else { return }
            action()
        }
    }
}
