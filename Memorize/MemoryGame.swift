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
    
    mutating func shuffle() {
        cards.shuffle()
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
        
        for pairIndex in 0..<max(2, numberOfPairsOfCards) {
            
            let content = createCardContent(pairIndex)
            cards.append(Card(content: content, id: pairIndex * 2))
            cards.append(Card(content: content, id: pairIndex * 2 + 1))
        }
        
        cards.shuffle()
    }
    
    struct Card: Identifiable, Equatable {
        
        var isFaceUp = false {
            // property observer
            didSet {
                if isFaceUp {
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        var isMatched = false {
            didSet {
                stopUsingBonusTime()
            }
        }
        // generic type
        let content: CardContent
        
        // ObjectIdentifiable
        let id: Int
        
//        static func == (lhs: Card, rhs: Card) -> Bool {
//            return lhs.isFaceUp == rhs.isFaceUp &&
//            lhs.isMatched == rhs.isMatched &&
//            lhs.content == rhs.content &&
//            lhs.id == rhs.id
//        }
        
        
        // MARK: - Bonus Time
        // this could give matching bonus time
        // if the user matched the cards
        // before a certain amount of time passes during which card is face up
        
        // could be zero which means "no bonus available" for this card
        var bonusTimeLimit: TimeInterval = 6
        
        // how long this card has ever been faced up
        private var faceUpTime: TimeInterval {
            if let lastFaceUpDate = self.lastFaceUpDate {
                return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
            } else {
                return pastFaceUpTime
            }
        }
        
        // the last time this card was turned up (and is still face up)
        var lastFaceUpDate: Date?
        // the accumulated time this card has been face up in the past
        // (i.e. not including the current time it's been face up if it is currently so)
        var pastFaceUpTime: TimeInterval = 0
        
        // how much time left before the bonus opportunity runs out
        var bonusTimeRemaining: TimeInterval {
            max(0, bonusTimeLimit - faceUpTime)
        }
        // percentage of the bonus time remaining
        var bonusRemaining: Double {
            (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining / bonusTimeLimit : 0
        }
        // whether the card was matched during the bonus time period
        var hasEarnedBonus: Bool {
            isMatched && bonusTimeRemaining > 0
        }
        // whether we are currently face up, unmatched and have not yet used up bonus window
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && bonusTimeRemaining > 0
        }
        
        // called when the card transitions to face up state
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime, lastFaceUpDate == nil {
                lastFaceUpDate = Date()
            }
        }
        // called when the card goes back face down (or gets matched)
        private mutating func stopUsingBonusTime() {
            pastFaceUpTime = faceUpTime
            self.lastFaceUpDate = nil
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
