import SwiftUI

struct GameView: View {
    @ObservedObject var logic: GameLogic

    var columns: [GridItem] {
        switch logic.currentLevel {
        case 1: return Array(repeating: .init(.flexible()), count: 4)
        case 2: return Array(repeating: .init(.flexible()), count: 5)
        case 3: return Array(repeating: .init(.flexible()), count: 5)
        default: return Array(repeating: .init(.flexible()), count: 4)
        }
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(logic.squares.indices, id: \.self) { index in
                let square = logic.squares[index]
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(square.isMatched || square.isFlipped ? square.color : Color.black.opacity(0.2))
                        .frame(height: 80)
                        .opacity(square.isMatched ? 0 : 1)
                        .animation(.easeInOut(duration: 0.3), value: square.isFlipped)
                }
                .onTapGesture {
                    logic.handleTap(index)
                }
            }
        }
    }
}
