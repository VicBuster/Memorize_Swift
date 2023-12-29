//
//  EmojiMeroyGame.swift
//  Memorize
//
//  Created by Vic Z.Ding on 2023/2/22.
//

// ViewModel
import SwiftUI

class EmojiMemoryGame: ObservableObject {
    
    typealias Card = MemoryGame<String>.Card
    private static let emojis = ["🚂", "🚀", "🚁", "🚜", "🚕", "🏎️", "🚑", "🚓", "🚒", "✈️", "🚲", "🛸", "⛵️", "🛶", "🚚", "🛵", "🏍️", "🛺", "🚢", "🛰️"]
    
    // send notification if model changes | objectWillChange.send
    @Published private var model = createMemoryGame()
    
    static func createMemoryGame() -> MemoryGame<String> {
                
        return MemoryGame<String>(numberOfPairsOfCards: 10) { pairIndex in
            return emojis[pairIndex]
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
    
}
