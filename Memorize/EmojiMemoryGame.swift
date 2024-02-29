//
//  EmojiMeroyGame.swift
//  Memorize
//
//  Created by Vic Z.Ding on 2023/2/22.
//

// ViewModel
import SwiftUI

// Migrating from the Observable Object protocol to the Observable macro
@Observable class EmojiMemoryGame {
    
    typealias Card = MemoryGame<String>.Card
    
    private static let emojis = ["🚂", "🚀", "🚁", "🚜", "🚕", "🏎️", "🚑", "🚓", "🚒", "✈️", "🚲", "🛸", "⛵️", "🛶", "🚚", "🛵", "🏍️", "🛺", "🚢", "🛰️"]
    
    // send notification if model changes | objectWillChange.send
    private var model = createMemoryGame()
    
    static func createMemoryGame() -> MemoryGame<String> {
                
        return MemoryGame<String>(numberOfPairsOfCards: 10) { pairIndex in
            if emojis.indices.contains(pairIndex) {
                return emojis[pairIndex]
            } else {
                return "⁉️"
            }
        }
    }
        
    // MARK: - Access to the Model

    var cards: Array<Card> {
        return model.cards
    }
    
    // MARK: - Intent(s)
    
    func choose(_ card: Card) {
        model.choose(card)
    }
    
    func shuffle() {
        model.shuffle()
    }
}
