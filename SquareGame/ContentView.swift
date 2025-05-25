import SwiftUI

struct ContentView: View {
    @StateObject private var logic = GameLogic()
    @State private var hasStarted = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            colorfulBackground().edgesIgnoringSafeArea(.all)

            if !hasStarted {
                StartView(hasStarted: $hasStarted, logic: logic)
            } else {
                VStack(spacing: 15) {
                    Text("Level \(logic.currentLevel)")
                        .font(.title)
                        .foregroundColor(.white)

                    if logic.showGameOver {
                        GameOverView(score: logic.score,
                                     highScore: logic.highScore,
                                     onRetry: { logic.startGame(level: logic.currentLevel) },
                                     onExit: {
                                         hasStarted = false
                                     })
                    } else if logic.gameEnded {
                        Text("🎉 You Completed All Levels!")
                            .foregroundColor(.white)
                            .font(.title2)
                    } else {
                        HStack(spacing: 20) {
                            Text("⏱ \(Int(logic.timeRemaining))s")
                            Text("Moves: \(logic.moves)")
                            Text("Score: \(logic.score)")
                        }
                        .foregroundColor(.white)

                        GameView(logic: logic)

                        Button("Exit to Start") {
                            hasStarted = false
                        }
                        .buttonStyle(ButtonStyleConfig())
                    }
                }
                .padding()
                .onReceive(timer) { _ in
                    if hasStarted && !logic.gameEnded {
                        logic.updateTimer()
                    }
                }
            }
        }
    }
}


#Preview {
    struct StartViewPreviewWrapper: View {
        @State private var started = false
        @StateObject private var gameLogic = GameLogic()

        var body: some View {
            StartView(hasStarted: $started, logic: gameLogic)
        }
    }

    return StartViewPreviewWrapper()
}
