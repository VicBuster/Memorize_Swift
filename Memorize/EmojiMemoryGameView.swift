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
        
        ScrollView {
            LazyVGrid (columns: [GridItem(.adaptive(minimum: 70))]) {
                ForEach(game.cards) { card in
                    // combiner View
                    CardView(card)
                        .aspectRatio(2 / 3, contentMode: .fit)
                        .onTapGesture {
                            self.game.choose(card)
                        }
                }
            }
        }
        .foregroundColor(.red)
        .padding(.horizontal)
    }
}

struct CardView: View {
    
    private let card: EmojiMemoryGame.Card
    
    init(_ card: EmojiMemoryGame.Card) {
        self.card = card
    }
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack {
                let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                if card.isFaceUp {
                    shape.fill(.white)
                    shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
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
        static let cornerRadius: CGFloat = 20.0
        static let lineWidth: CGFloat = 3.0
        static let fontScale: CGFloat = 0.9
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiMemoryGameView(game: EmojiMemoryGame())
            .preferredColorScheme(.light)
        EmojiMemoryGameView(game: EmojiMemoryGame())
            .preferredColorScheme(.dark)
    }
}
