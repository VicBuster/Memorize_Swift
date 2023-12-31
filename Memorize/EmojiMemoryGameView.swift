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
        
        VStack {
            gameBody
            shuffle
        }
        .padding()
    }
    
    @State private var dealt = Set<Int>()
    
    private func deal(_ card: EmojiMemoryGame.Card) {
        dealt.insert(card.id)
    }
    
    private func isUndealt(_ card: EmojiMemoryGame.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: 2 / 3) { card in
            if isUndealt(card) || (card.isMatched && !card.isFaceUp) {
//                Rectangle().opacity(0)
                Color.clear
            } else {
                CardView(card:card)
                    .padding(4)
                    .transition(AnyTransition.asymmetric(insertion: .scale, removal: .opacity).animation(.easeInOut(duration: 1)))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            self.game.choose(card)
                        }
                    }
            }
        }
        .onAppear {
            withAnimation {
                for card in game.cards {
                    deal(card)
                }
            }
        }
        .foregroundColor(.red)
    }
    
    var shuffle: some View {
        Button("Shuffle") {
            withAnimation {
                game.shuffle()
            }
        }
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
                
                // 0 degree is to the right, so minus 90 should be up
                Pie(startAngle: Angle(degrees: 0 - 90), endAngle: Angle(degrees: 120 - 90))
                    .padding(5).opacity(0.4)
                Text(card.content)
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                    // when card.isMatched changes, it animates.
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                    // font is not animatable, so put in a static size and use animatable scaleEffect
                    .font(Font.system(size: DrawingConstants.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
            }
            .cardify(isFaceUp: card.isFaceUp)
        })
    }
    
    private func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) / (DrawingConstants.fontSize / DrawingConstants.fontScale)
    }
    
    private func font(in size: CGSize) -> Font {
        Font.system(size: min(size.width, size.height) * DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let fontSize: CGFloat = 32
        static let fontScale: CGFloat = 0.75
    }
}

struct EmojiMemoryGameView_Previews: PreviewProvider {
    static var previews: some View {
//        let game = EmojiMemoryGame()
//        game.choose(game.cards.first!)
        EmojiMemoryGameView(game: EmojiMemoryGame())
            .preferredColorScheme(.light)
        EmojiMemoryGameView(game: EmojiMemoryGame())
            .preferredColorScheme(.dark)
    }
}
