//
//  MemoryGame.swift
//  Memorize
//
//  Created by Vic Z.Ding on 2023/2/22.
//

// Model
import Foundation

// Equatable: can use "=="
struct MemoryGame<CardContent> where CardContent: Equatable {
    
    private(set) var cards: Array<Card>
    
    // computed property
    private var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get {
            cards.indices.filter({cards[$0].isFaceUp}).oneAndOnly
        }
        set {
            // newValue: when indexOfTheOneAndOnlyFaceUpCard has value
            cards.indices.forEach{cards[$0].isFaceUp = ($0 == newValue)}
        }
    }
    
    mutating func choose(_ card: Card) {
        
        // !: exclamation point, assume it is .some case, or it will crash
        // let chosenindex: Int = self.index(of: card)!
        // if let chosenIndex: Int = self.index(of: card) {
        
        if let chosenIndex: Int = cards.firstIndex(where: {$0.id == card.id}), !cards[chosenIndex].isFaceUp, !cards[chosenIndex].isMatched {
            if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                cards[chosenIndex].isFaceUp = true
            } else {
                indexOfTheOneAndOnlyFaceUpCard = chosenIndex
            }
        }
    }
    
    // external name and internal name
    func index(of card: Card) -> Int? {
        
        for index in 0..<self.cards.count {
            if self.cards[index].id == card.id {
                return index
            }
        }
        return nil
    }
    
    init(numberOfPairsOfCards: Int, createCardContent: (Int) -> CardContent) {
        cards = []
        
        for pairIndex in 0..<numberOfPairsOfCards {
            
            let content = createCardContent(pairIndex)
            cards.append(Card(content: content, id: pairIndex * 2))
            cards.append(Card(content: content, id: pairIndex * 2 + 1))
        }
    }
    
    struct Card: Identifiable {
        
        var isFaceUp = false
        var isMatched = false
        // generic type
        let content: CardContent
        
        // ObjectIdentifiable
        let id: Int
    }
}

extension Array {
    var oneAndOnly: Element? {
        if count == 1 {
            return first
        } else {
            return nil
        }
    }
}
