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
    
    @Namespace private var dealingNamespace
    
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
            deckBody
            HStack {
                restart
                Spacer()
                shuffle
            }
            .padding(.horizontal)
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
    
    private func zIndex(of card: EmojiMemoryGame.Card) -> Double {
        -Double(game.cards.firstIndex(where: { $0.id == card.id }) ?? 0)
    }
    
    var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: 2 / 3) { card in
            if isUndealt(card) || (card.isMatched && !card.isFaceUp) {
//                Rectangle().opacity(0)
                Color.clear
            } else {
                CardView(card:card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .padding(4)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
                    .zIndex(zIndex(of: card))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            game.choose(card)
                        }
                    }
            }
        }
        .foregroundColor(CardConstants.color)
    }
    
    // each card is dealt with delay which is related to index
    private func dealAnimation(for card: EmojiMemoryGame.Card) -> Animation {
        var delay = 0.0
        if let index = game.cards.firstIndex(where: {$0.id == card.id}) {
            delay = Double(index) * (CardConstants.totalDealDuration / Double(game.cards.count))
        }
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
    
    var deckBody: some View {
        ZStack {
            ForEach(game.cards.filter(isUndealt)) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
                    .zIndex(zIndex(of: card))
            }
        }
        .frame(width: CardConstants.undealWidth, height: CardConstants.undealHeight)
        .foregroundColor(CardConstants.color)
        .onTapGesture {
//            withAnimation(.easeInOut(duration: 3)) {
//                for card in game.cards {
//                    deal(card)
//                }
//            }
            for card in game.cards {
                withAnimation(dealAnimation(for: card)) {
                    deal(card)
                }
            }
        }
    }
    
    var shuffle: some View {
        Button("Shuffle") {
            withAnimation {
                game.shuffle()
            }
        }
    }
    
    var restart: some View {
        Button("Restart") {
            withAnimation {
                dealt = []
                game.restart()
            }
        }
    }
    
    private struct CardConstants {
        static let color = Color.red
        static let aspectRatio: CGFloat = 2 / 3
        static let dealDuration: Double = 0.5
        static let totalDealDuration: Double = 2
        static let undealHeight: CGFloat = 90
        static let undealWidth = undealHeight * aspectRatio
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
//                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: card.isMatched)
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
