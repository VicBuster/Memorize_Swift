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
        
        // when you get or set this value, it goes to inline codes first
        get {
            cards.indices.filter({cards[$0].isFaceUp}).oneAndOnly
        }
        
//        get {
//            var faceUpCardIndices = [Int]()
//            for index in cards.indices {
//                if cards[index].isFaceUp {
//                    faceUpCardIndices.append(index)
//                }
//            }
//            if faceUpCardIndices.count == 1 {
//                return faceUpCardIndices[0]
//            } else {
//                return nil
//            }
//        }
        
        set {
            // newValue: when indexOfTheOneAndOnlyFaceUpCard has value
            cards.indices.forEach{cards[$0].isFaceUp = ($0 == newValue)}
        }
        
//        set {
//            for index in cards.indices {
//                if index != newValue {
//                    cards[index].isFaceUp = false
//                } else {
//                    cards[index].isFaceUp = true
//                }
//            }
//        }

    }
    
    // Marked mutating to modify state
    mutating func choose(_ card: Card) {
        
        /// nil is Optional.none
        /// !: exclamation point, assume it is .some(Optional.some) case, or it will crash
        /// let hello: String? = ...
        /// print(hello!) --> switch hello {
        ///                       case .none: // raise an exception(crash)
        ///                       case .some(let data): print(data)
        ///                   }
        /// if let safeHello = hello {   -->    switch hello {
        ///     print(safeHello)                    case .none: { // do something else }
        /// else {                                  case .some(let data): print(data)
        ///     // do something else            }
        /// }
        
        
        // let chosenIndex: Int = self.index(of: card)!
        // if let chosenIndex: Int = self.index(of: card) {
        
        if let chosenIndex: Int = cards.firstIndex(where: {$0.id == card.id}), 
            !cards[chosenIndex].isFaceUp,
            !cards[chosenIndex].isMatched {
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
    
    // external name 'of' and internal name 'card'
    // .firstIndex(where ...) does the same job
    func index(of card: Card) -> Int? {
        
        for index in 0..<self.cards.count {
            if self.cards[index].id == card.id {
                return index
            }
        }
        return nil
    }
    
    // createCardContent: a closure
    init(numberOfPairsOfCards: Int, createCardContent: (Int) -> CardContent) {
        cards = []
        
        for pairIndex in 0..<numberOfPairsOfCards {
            
            let content = createCardContent(pairIndex)
            cards.append(Card(content: content, id: pairIndex * 2))
            cards.append(Card(content: content, id: pairIndex * 2 + 1))
        }
    }
    
    struct Card: Identifiable, Equatable {
        
        var isFaceUp = false
        var isMatched = false
        // generic type
        let content: CardContent
        
        // ObjectIdentifiable
        let id: Int
        
        static func == (lhs: MemoryGame.Card, rhs: MemoryGame.Card) -> Bool {
            return lhs.isFaceUp == rhs.isFaceUp &&
            lhs.isMatched == rhs.isMatched &&
            lhs.content == rhs.content &&
            lhs.id == rhs.id
        }
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
