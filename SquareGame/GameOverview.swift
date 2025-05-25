import SwiftUI

struct GameOverView: View {
    var score: Int
    var highScore: Int
    var onRetry: () -> Void
    var onExit: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("💀 Game Over")
                .font(.largeTitle)
                .foregroundColor(.white)

            Text("Score: \(score)")
            Text("High Score: \(highScore)")

            Button("Try Again", action: onRetry)
                .buttonStyle(ButtonStyleConfig())

            Button("Exit to Start", action: onExit)
                .buttonStyle(ButtonStyleConfig())
        }
    }
}

