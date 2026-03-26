import SwiftUI

enum MorRoute {
    case welcome
    case howToPlay
    case modePicker
    case playing
    case gameOver
}

@MainActor
final class MorExperienceStore: ObservableObject {
    @Published var route: MorRoute = .welcome
    @Published var currentMode: TrainingMode = .learn
    @Published var game: MorGameEngine?
    @Published var summary = GameSummary(score: 0, level: 1, accuracy: 100, isHighScore: false)

    func showInstructions() {
        route = .howToPlay
    }

    func showModePicker() {
        route = .modePicker
    }

    func startGame(mode: TrainingMode) {
        currentMode = mode
        game = MorGameEngine(mode: mode) { [weak self] summary in
            self?.summary = summary
            self?.route = .gameOver
        }
        route = .playing
    }

    func replay() {
        startGame(mode: currentMode)
    }
}

struct MorRootView: View {
    @StateObject private var store = MorExperienceStore()

    var body: some View {
        ZStack {
            MorTheme.backgroundGradient()
                .ignoresSafeArea()

            switch store.route {
            case .welcome:
                MorWelcomeScreen(onPlay: store.showInstructions)
            case .howToPlay:
                MorHowToPlayScreen(onStart: store.showModePicker)
            case .modePicker:
                MorModeSelectionScreen(onSelectMode: store.startGame)
            case .playing:
                if let game = store.game {
                    MorGameplayScreen(game: game)
                }
            case .gameOver:
                MorGameOverScreen(summary: store.summary, onReplay: store.replay)
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct MorScreenFrame<Content: View>: View {
    let content: (CGFloat) -> Content

    var body: some View {
        GeometryReader { proxy in
            let width = MorTheme.frameWidth(for: proxy.size.width)
            let minHeight = max(0, proxy.size.height - (MorTheme.screenVerticalPadding * 2))

            #if os(watchOS)
            ScrollView(.vertical, showsIndicators: false) {
                content(width)
                    .frame(width: width)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: minHeight, alignment: .center)
                    .padding(.vertical, MorTheme.screenVerticalPadding)
            }
            .scrollBounceBehavior(.basedOnSize)
            .padding(.horizontal, MorTheme.screenHorizontalPadding)
            #else
            VStack {
                Spacer(minLength: MorTheme.screenVerticalPadding)
                content(width)
                Spacer(minLength: MorTheme.screenVerticalPadding)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, MorTheme.screenHorizontalPadding)
            #endif
        }
    }
}

private struct MorWelcomeScreen: View {
    let onPlay: () -> Void

    var body: some View {
        MorScreenFrame { width in
            VStack(spacing: MorTheme.sectionSpacing) {
                MorLogoView()

                Text("Learn Morse Code")
                    .font(MorTheme.subtitleFont)
                    .foregroundStyle(Color.white.opacity(0.92))

                PrimaryActionButton(title: "Play", action: onPlay)
                    .padding(.top, 8)
            }
            .frame(width: width)
        }
    }
}

private struct MorHowToPlayScreen: View {
    let onStart: () -> Void

    var body: some View {
        MorScreenFrame { width in
            VStack(spacing: MorTheme.sectionSpacing) {
                Text("How to Play:")
                    .font(MorTheme.subtitleFont.weight(.semibold))
                    .foregroundStyle(.white)

                GlassPanel {
                    VStack(alignment: .leading, spacing: 10) {
                        instructionRow(label: "Quick Tap", signal: .dot, meaning: "Dot")
                        instructionRow(label: "Long Press", signal: .dash, meaning: "Dash")
                    }
                    .font(MorTheme.instructionFont)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                PrimaryActionButton(title: "Start", action: onStart)
            }
            .frame(width: width)
        }
    }

    private func instructionRow(label: String, signal: MorseSignal, meaning: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
            Text("=")
            MorseChipView(signal: signal, color: .white)
            Text(meaning)
            Spacer(minLength: 0)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
}

private struct MorModeSelectionScreen: View {
    let onSelectMode: (TrainingMode) -> Void

    var body: some View {
        MorScreenFrame { width in
            VStack(spacing: 16) {
                Text("Select a Mode")
                    .font(MorTheme.subtitleFont.weight(.semibold))
                    .foregroundStyle(.white)

                PrimaryActionButton(title: "Learn") {
                    onSelectMode(.learn)
                }

                PrimaryActionButton(title: "Test") {
                    onSelectMode(.test)
                }
            }
            .frame(width: width)
        }
    }
}

private struct MorGameplayScreen: View {
    @ObservedObject var game: MorGameEngine

    var body: some View {
        MorScreenFrame { width in
            VStack(spacing: MorTheme.gameplaySpacing) {
                HStack {
                    HeartMeterView(lives: game.lives)
                    Spacer()
                    Text("\(game.score)")
                        .font(MorTheme.instructionFont)
                        .foregroundStyle(Color.white.opacity(0.9))
                }

                GameplayCardView(
                    prompt: game.currentPrompt,
                    enteredSignals: game.enteredSignals,
                    mode: game.mode,
                    feedback: game.feedback
                )

                MorsePressPad(isLocked: game.isInputLocked) { signal in
                    game.submit(signal)
                }
            }
            .frame(width: width)
        }
    }
}

private struct MorGameOverScreen: View {
    let summary: GameSummary
    let onReplay: () -> Void

    var body: some View {
        MorScreenFrame { width in
            VStack(spacing: 10) {
                Text("Game Over!")
                    .font(MorTheme.subtitleFont.weight(.semibold))
                    .foregroundStyle(.white)

                GlassPanel {
                    VStack(spacing: 4) {
                        Text(summary.isHighScore ? "New High Score!" : "Final Score")
                            .font(MorTheme.instructionFont)
                            .foregroundStyle(Color.white.opacity(0.78))

                        HStack(spacing: 6) {
                            if summary.isHighScore {
                                Image(systemName: "trophy.fill")
                                    .foregroundStyle(MorTheme.accentYellow)
                            }

                            Text("\(summary.score)")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(MorTheme.accentBlue)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                HStack(spacing: 10) {
                    SummaryStatView(title: "Level", value: "\(summary.level)")
                    SummaryStatView(title: "Accuracy", value: "\(summary.accuracy)%")
                }

                PrimaryActionButton(title: "Play Again", action: onReplay)
                    .padding(.top, MorTheme.gameplaySpacing)
            }
            .frame(width: width)
        }
    }
}
