import SwiftUI

struct StartView: View {
    @Binding var hasStarted: Bool
    @ObservedObject var logic: GameLogic

    var body: some View {
        VStack(spacing: 20) {
            Text("🎯 Match the Colors")
                .font(.largeTitle)
                .foregroundColor(.white)
                .bold()

            Text("🏆 High Score: \(logic.highScore)")
                .foregroundColor(.white)

            Button(action: {
                withAnimation {
                    hasStarted = true
                    logic.startGame(level: 1)
                }
            }) {
                Text("Start Game")
            }
            .buttonStyle(ButtonStyleConfig())
        }
    }
}

