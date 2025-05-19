//
//  Square.swift
//  SquareGame
//
//  Created by Chanuka Wijesooriya on 2025-05-11.
//

import Foundation
import SwiftUI

struct Square: Identifiable {
    let id = UUID()
    var color: Color
    var isFlipped: Bool = false
    var isMatched: Bool = false
}
