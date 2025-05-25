import SwiftUI

class GameLogic: ObservableObject {
    @Published var squares: [Square] = []
    @Published var currentLevel = 1
    @Published var moves = 0
    @Published var score = 0
    @Published var highScore = UserDefaults.standard.integer(forKey: "HighScore")
    @Published var gameEnded = false
    @Published var showGameOver = false
    @Published var timeElapsed: TimeInterval = 0
    @Published var timeRemaining: TimeInterval = 60

    private var startTime = Date()
    private var isProcessing = false
    private var firstFlippedIndex: Int? = nil
    private var secondFlippedIndex: Int? = nil

    let colors: [Color] = [.red, .blue, .green, .orange, .purple, .yellow, .pink, .cyan, .mint, .teal]

    func startGame(level: Int = 1) {
        currentLevel = level
        moves = 0
        score = 0
        timeElapsed = 0
        timeRemaining = level >= 2 ? 60 : 9999
        gameEnded = false
        showGameOver = false
        startTime = Date()
        setupGrid(for: level)
    }

    func setupGrid(for level: Int) {
        var tempSquares: [Square] = []
        let pairCount: Int

        switch level {
        case 1:
            pairCount = 8
        case 2:
            pairCount = 10
        case 3:
            pairCount = 9
        default:
            pairCount = 8
        }

        let selectedColors = (colors.prefix(pairCount) + colors.prefix(pairCount)).shuffled()
        for color in selectedColors {
            tempSquares.append(Square(color: color))
        }
        squares = tempSquares
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
                self.checkMatch()
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
            let gameTime = Date().timeIntervalSince(startTime)
            score += calculateScore(level: currentLevel, time: gameTime)

            if score > highScore {
                highScore = score
                UserDefaults.standard.set(score, forKey: "HighScore")
            }

            if currentLevel < 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.startGame(level: self.currentLevel + 1)
                }
            } else {
                gameEnded = true
            }
        }
    }

    func calculateScore(level: Int, time: TimeInterval) -> Int {
        let base = 100
        let timeLimit = 30.0
        let deduction = max(0, Int((time - timeLimit) / 5.0) * 10)
        return max(50, base - deduction)
    }

    func updateTimer() {
        timeElapsed = Date().timeIntervalSince(startTime)
        if currentLevel >= 2 {
            timeRemaining -= 1
            if timeRemaining <= 0 {
                showGameOver = true
            }
        }
    }
}

