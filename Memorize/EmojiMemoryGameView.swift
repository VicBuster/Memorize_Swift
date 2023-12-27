//
//  EmojiMemoryGameView.swift
//  Memorize
//
//  Created by Vic Z.Ding on 2023/2/19.
//

// View
import SwiftUI

// this struct behaves like a View
struct EmojiMemoryGameView: View {
    
    @ObservedObject var game: EmojiMemoryGame
    
    /// property: a var inside a struct or a class
    /// every variable has a specific type and a value
    /// Text is also a struct that behaves like a View
    var body: some View {
        
//        ScrollView {
//            LazyVGrid (columns: [GridItem(.adaptive(minimum: 70))]) {
//                ForEach(game.cards) { card in
//                    // combiner View
//                    CardView(card:card)
//                        .aspectRatio(2 / 3, contentMode: .fit)
//                        .onTapGesture {
//                            self.game.choose(card)
//                        }
//                }
//            }
//        }
//        .foregroundColor(.red)
//        .padding(.horizontal)
        
        AspectVGrid(items: game.cards, aspectRatio: 2 / 3) { card in
            if card.isMatched && !card.isFaceUp {
                Rectangle().opacity(0)
            } else {
                CardView(card:card)
                    .padding(4)
                    .onTapGesture {
                        self.game.choose(card)
                    }
            }
        }
        .foregroundColor(.red)
        .padding(.horizontal)
    }
}

struct CardView: View {
    
    let card: EmojiMemoryGame.Card
    
//    init(_ card: EmojiMemoryGame.Card) {
//        self.card = card
//    }
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack {
                let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                if card.isFaceUp {
                    shape.fill(.white)
                    shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
                    Circle().padding(5).opacity(0.4)
                    Text(card.content)
                        .font(font(in: geometry.size))
                } else if card.isMatched {
                    shape.opacity(0)
                } else {
                    shape.fill()
                }
            }
        })
    }
    
    private func font(in size: CGSize) -> Font {
        Font.system(size: min(size.width, size.height) * DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 10.0
        static let lineWidth: CGFloat = 3.0
        static let fontScale: CGFloat = 0.7
        
    }
}



struct EmojiMemoryGameView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
        game.choose(game.cards.first!)
        return EmojiMemoryGameView(game: game)
            .preferredColorScheme(.light)
//        EmojiMemoryGameView(game: game)
//            .preferredColorScheme(.dark)
    }
}
