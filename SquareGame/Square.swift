//
//  Square.swift
//  SquareGame
//
//  Created by Chanuka Wijesooriya on 2025-05-11.
//

import Foundation
import SwiftUI

struct Square: Identifiable {
    var id = UUID()
    var color: Color
    var isMatched = false
    var isFlipped = false
}
