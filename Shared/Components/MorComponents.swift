import SwiftUI

struct MorLogoView: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("M")
                .foregroundStyle(MorTheme.offWhite)
            ZStack(alignment: .bottom) {
                Text("o")
                    .foregroundStyle(MorTheme.accentBlue)
                Circle()
                    .fill(MorTheme.accentBlue)
                    .frame(width: 7, height: 7)
                    .offset(y: -4)
            }
            ZStack(alignment: .bottom) {
                Text("r")
                    .foregroundStyle(MorTheme.offWhite)
                Capsule()
                    .fill(MorTheme.accentBlue)
                    .frame(width: 18, height: 4)
                    .offset(y: 7)
            }
        }
        .font(MorTheme.logoFont)
    }
}

struct PrimaryActionButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MorTheme.buttonFont)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(isPressed ? MorTheme.buttonBluePressed : MorTheme.buttonBlue)
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.9), lineWidth: 1.4)
                )
                .shadow(color: MorTheme.buttonBlue.opacity(0.35), radius: 12, y: 8)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct HeartMeterView: View {
    let lives: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: "heart.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(index < lives ? Color.red : Color.white.opacity(0.88))
            }
        }
    }
}

struct MorseTrackView: View {
    let sequence: [MorseSignal]
    let enteredSignals: [MorseSignal]
    let mode: TrainingMode
    let feedback: RoundFeedback

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(sequence.enumerated()), id: \.offset) { index, originalSignal in
                MorseChipView(
                    signal: displayedSignal(for: index, fallback: originalSignal),
                    color: displayedColor(for: index)
                )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(MorTheme.trackBackground)
        )
    }

    private func displayedSignal(for index: Int, fallback: MorseSignal) -> MorseSignal {
        if case let .error(errorIndex, received) = feedback, errorIndex == index {
            return received
        }
        return fallback
    }

    private func displayedColor(for index: Int) -> Color {
        if case let .error(errorIndex, _) = feedback, errorIndex == index {
            return Color(red: 0.86, green: 0.10, blue: 0.10)
        }

        if index < enteredSignals.count {
            return MorTheme.trackActive
        }

        if mode.showsGuide && index == enteredSignals.count {
            return MorTheme.trackActive
        }

        return MorTheme.trackIdle
    }
}

struct MorseChipView: View {
    let signal: MorseSignal
    let color: Color

    var body: some View {
        Capsule()
            .fill(color)
            .frame(width: signal == .dot ? 10 : 24, height: 6)
            .frame(width: 24, height: 10)
    }
}

struct GameplayCardView: View {
    let prompt: MorsePrompt
    let enteredSignals: [MorseSignal]
    let mode: TrainingMode
    let feedback: RoundFeedback

    var body: some View {
        VStack(spacing: 16) {
            StylizedLetterView(letter: prompt.character)
                .padding(.top, 8)

            MorseTrackView(
                sequence: prompt.sequence,
                enteredSignals: enteredSignals,
                mode: mode,
                feedback: feedback
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(cardFill)
        .overlay(
            RoundedRectangle(cornerRadius: MorTheme.largeCornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        )
    }

    private var cardFill: some ShapeStyle {
        switch feedback {
        case .success:
            return LinearGradient(
                colors: [MorTheme.successTop, MorTheme.successBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        case .error:
            return LinearGradient(
                colors: [MorTheme.errorTop, MorTheme.errorBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        case .neutral:
            return LinearGradient(
                colors: [MorTheme.cardTop, MorTheme.cardBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

struct StylizedLetterView: View {
    let letter: String

    var body: some View {
        ZStack(alignment: .center) {
            Text(letter)
                .font(.system(size: MorTheme.symbolFontSize, weight: .black, design: .rounded))
                .foregroundStyle(MorTheme.accentYellow)
                .shadow(color: MorTheme.accentYellow.opacity(0.15), radius: 6)

            Rectangle()
                .fill(MorTheme.accentBlue.opacity(0.45))
                .frame(width: letter == "I" ? 24 : 34, height: 5)
                .offset(y: 4)
        }
        .frame(height: MorTheme.symbolFontSize + 6)
    }
}

struct MorsePressPad: View {
    let isLocked: Bool
    let onSignal: (MorseSignal) -> Void

    @State private var pressStart = Date()
    @State private var isPressing = false

    var body: some View {
        Text("Press Here")
            .font(MorTheme.buttonFont)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(isLocked ? MorTheme.buttonBlue.opacity(0.55) : (isPressing ? MorTheme.buttonBluePressed : MorTheme.buttonBlue))
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.9), lineWidth: 1.4)
            )
            .scaleEffect(isPressing ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: isPressing)
            .contentShape(Capsule())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !isLocked else { return }
                        if !isPressing {
                            pressStart = Date()
                            isPressing = true
                        }
                    }
                    .onEnded { _ in
                        guard !isLocked else {
                            isPressing = false
                            return
                        }

                        let duration = Date().timeIntervalSince(pressStart)
                        isPressing = false
                        onSignal(duration >= MorTheme.pressThreshold ? .dash : .dot)
                    }
            )
    }
}

struct SummaryStatView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.78))
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.12))
        )
    }
}

struct GlassPanel<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: MorTheme.largeCornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: MorTheme.largeCornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
    }
}
