//
//  ContentView.swift
//  SquareGame
//
//  Created by Chanuka Wijesooriya on 2025-05-11.
//

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
    @State private var moves: Int = 0

    let colors: [Color] = [.red, .blue, .green, .orange, .purple, .yellow, .pink, .cyan]

    // Timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 15) {
            if gameEnded {
                VStack {
                    Text("Congratulations!")
                        .font(.title)
                        .padding(.bottom, 5)
                    Text("Time Spent: \(Int(gameTime)) seconds")
                    Text("Moves: \(moves)")
                }
            } else {
                HStack(spacing: 40) {
                    Text("Time: \(Int(timeElapsed))s")
                    Text("Moves: \(moves)")
                }
                .font(.headline)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(squares.indices, id: \.self) { index in
                    let square = squares[index]
                    ZStack {
                        Rectangle()
                            .fill(square.isMatched || square.isFlipped ? square.color : .gray)
                            .frame(height: 80)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .opacity(square.isMatched ? 0 : 1)
                    }
                    .onTapGesture {
                        handleTap(index)
                    }
                }
            }
            .padding()

            if gameEnded {
                Button("Restart Game") {
                    startGame()
                }
                .padding(.top)
            }
        }
        .onAppear {
            startGame()
        }
        .onReceive(timer) { _ in
            if !gameEnded {
                timeElapsed = Date().timeIntervalSince(startTime)
            }
        }
    }

    func startGame() {
        var tempSquares: [Square] = []
        let allColors = colors + colors
        let shuffledColors = allColors.shuffled()

        for color in shuffledColors {
            tempSquares.append(Square(color: color))
        }

        squares = tempSquares
        startTime = Date()
        timeElapsed = 0
        moves = 0
        firstFlippedIndex = nil
        secondFlippedIndex = nil
        isProcessing = false
        gameEnded = false
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
            moves += 1 // Count one move per 2 selections

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
            gameEnded = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

