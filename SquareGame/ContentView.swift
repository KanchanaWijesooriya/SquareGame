import SwiftUI
import Combine

struct ContentView: View {
    
    @State private var squares: [Square] = []
    @State private var firstFlippedIndex: Int? = nil
    @State private var secondFlippedIndex: Int? = nil
    @State private var isProcessing = false
    @State private var startTime = Date()
    @State private var gameEnded = false
    @State private var gameTime: TimeInterval = 0
    @State private var timeElapsed: TimeInterval = 0
    @State private var timeRemaining: TimeInterval = 60
    @State private var moves: Int = 0
    @State private var hasStarted = false
    @State private var currentLevel: Int = 1
    @State private var showGameOver: Bool = false

    let colors: [Color] = [.red, .blue, .green, .orange, .purple, .yellow, .pink, .cyan]
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.4), .purple.opacity(0.4)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            if !hasStarted {
                VStack(spacing: 20) {
                    Text("Match the Colors!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Button(action: {
                        withAnimation {
                            hasStarted = true
                            startGame(level: 1)
                        }
                    }) {
                        Text("Start Game")
                            .font(.title2)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(Color.white.opacity(0.9))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                }
            } else {
                VStack(spacing: 15) {
                    Text("Level \(String(format: "%02d", currentLevel))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    if showGameOver {
                        VStack(spacing: 15) {
                            Text("⛔ Game Over")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("You ran out of time!")
                                .foregroundColor(.white)

                            Button("Try Again") {
                                withAnimation {
                                    startGame(level: currentLevel)
                                }
                            }
                            .buttonStyle(startButtonStyle())

                            Button("Exit to Start") {
                                withAnimation {
                                    hasStarted = false
                                    showGameOver = false
                                }
                            }
                            .buttonStyle(startButtonStyle())
                        }
                        .padding()
                    } else if gameEnded && currentLevel >= 2 {
                        VStack(spacing: 10) {
                            Text("🎉 Congratulations!")
                                .font(.title)
                                .foregroundColor(.white)

                            Text("⏱ Time Spent: \(Int(gameTime)) seconds")
                                .foregroundColor(.white)

                            Text("Moves: \(moves)")
                                .foregroundColor(.white)

                            Button(action: {
                                withAnimation {
                                    startGame(level: currentLevel + 1)
                                }
                            }) {
                                Text("Next Level")
                            }
                            .buttonStyle(startButtonStyle())

                            Button(action: {
                                withAnimation {
                                    hasStarted = false
                                    gameEnded = false
                                }
                            }) {
                                Text("Exit to Start")
                            }
                            .buttonStyle(startButtonStyle())
                        }
                        .padding()
                    } else {
                        HStack(spacing: 40) {
                            if currentLevel >= 2 {
                                Text("\(Int(timeRemaining))s left")
                            } else {
                                Text("⏱ Time: \(Int(timeElapsed))s")
                            }
                            Text("Moves: \(moves)")
                        }
                        .font(.headline)
                        .foregroundColor(.white)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                            ForEach(squares.indices, id: \.self) { index in
                                let square = squares[index]
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(square.isMatched || square.isFlipped ? square.color : Color.gray.opacity(0.3))
                                        .frame(height: 80)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                        )
                                        .opacity(square.isMatched ? 0 : 1)
                                        .animation(.easeInOut(duration: 0.3), value: square.isFlipped)
                                }
                                .onTapGesture {
                                    handleTap(index)
                                }
                            }
                        }
                        .padding()

                        Button(action: {
                            withAnimation {
                                hasStarted = false
                                gameEnded = false
                            }
                        }) {
                            Text("Exit to Start")
                        }
                        .buttonStyle(startButtonStyle())
                        .padding(.top, 10)
                    }
                }
                .padding()
                .onReceive(timer) { _ in
                    if !gameEnded && hasStarted && !showGameOver {
                        timeElapsed = Date().timeIntervalSince(startTime)

                        if currentLevel >= 2 {
                            timeRemaining -= 1
                            if timeRemaining <= 0 {
                                showGameOver = true
                            }
                        }
                    }
                }
            }
        }
    }

    func startGame(level: Int = 1) {
        var tempSquares: [Square] = []
        let pairCount = 8
        let allColors = (colors.prefix(pairCount) + colors.prefix(pairCount)).shuffled()

        for color in allColors {
            tempSquares.append(Square(color: color))
        }

        squares = tempSquares
        currentLevel = level
        startTime = Date()
        timeElapsed = 0
        timeRemaining = level >= 2 ? 60 : 9999
        moves = 0
        firstFlippedIndex = nil
        secondFlippedIndex = nil
        isProcessing = false
        gameEnded = false
        showGameOver = false
    }

    func handleTap(_ index: Int) {
        guard !isProcessing, !squares[index].isFlipped, !squares[index].isMatched else { return }

        if firstFlippedIndex == nil {
            firstFlippedIndex = index
            squares[index].isFlipped = true
        } else if secondFlippedIndex == nil {
            secondFlippedIndex = index
            squares[index].isFlipped = true
            isProcessing = true
            moves += 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                checkMatch()
            }
        }
    }

    func checkMatch() {
        if let first = firstFlippedIndex, let second = secondFlippedIndex {
            if squares[first].color == squares[second].color {
                squares[first].isMatched = true
                squares[second].isMatched = true
            } else {
                squares[first].isFlipped = false
                squares[second].isFlipped = false
            }

            firstFlippedIndex = nil
            secondFlippedIndex = nil
            isProcessing = false
        }

        if squares.allSatisfy({ $0.isMatched }) {
            gameTime = timeElapsed

            if currentLevel < 2 {
                // Automatically start next level after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    startGame(level: currentLevel + 1)
                }
            } else {
                gameEnded = true
            }
        }
    }

    func startButtonStyle() -> some ButtonStyle {
        ButtonStyleConfig()
    }

    struct ButtonStyleConfig: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.title2)
                .padding(.horizontal, 40)
                .padding(.vertical, 15)
                .background(Color.white.opacity(configuration.isPressed ? 0.7 : 0.9))
                .foregroundColor(.blue)
                .cornerRadius(12)
                .shadow(radius: 5)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
