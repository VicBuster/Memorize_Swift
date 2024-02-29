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
    
    var game: EmojiMemoryGame
    
    // a token which provides a namespace for the id's used in matchGeometryEffect
    @Namespace private var dealingNamespace
    
    // property: a var inside a struct or a class
    // every variable has a specific type and a value
    // Text is also a struct that behaves like a View
    // this is a computed property, the value isn't stored, it is computed instead
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
        ZStack(alignment: .bottom) {
            VStack {
                gameBody
                HStack {
                    Spacer()
                    shuffle
                }
                .padding(.horizontal)
            }
            deckBody
        }
        .padding()
    }
    
    // private state used to temporary track
    // whether a card has been dealt or not
    // contains id's of MemoryGame<String>.Cards
    @State private var dealt = Set<Int>()
    
    // marks the given card as having been dealt
    private func deal(_ card: EmojiMemoryGame.Card) {
        dealt.insert(card.id)
    }
    
    // returns whether the given card has not been dealt yet
    private func isUndealt(_ card: EmojiMemoryGame.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    private func zIndex(of card: EmojiMemoryGame.Card) -> Double {
        -Double(game.cards.firstIndex(where: { $0.id == card.id }) ?? 0)
    }
    
    // the body of the game itself
    // (i.e. not include any of the control buttons or the deck)
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
                        // animate the user Intent function that chooses a card
                        // (using the default animation)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            game.choose(card)
                        }
                    }
            }
        }
        .foregroundColor(CardConstants.color)
    }

    private func dealAnimation(for card: EmojiMemoryGame.Card) -> Animation {
        var delay = 0.0
        if let index = game.cards.firstIndex(where: {$0.id == card.id}) {
            delay = Double(index) * (CardConstants.totalDealDuration / Double(game.cards.count))
        }
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
    
    // the body of the deck from which we deal the cards out
    var deckBody: some View {
        ZStack {
            ForEach(game.cards.filter(isUndealt)) { card in
                CardView(card: card)
                    // see other matchedGeometryEffect above
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
            // animated user Intent function call
            // TODO: YOU MUST ADD THIS INTENT FUNC TO YOUR VIEWMODEL
            withAnimation {
                game.shuffle()
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
    
    @State private var animatedBonusRemaining: Double = 0
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack {
                // Group is a "bag of Lego" container
                // it's useful for propagating view modifiers to multiple views
                // (as we are doing below, for example, with opacity)
                Group {
                    if (card.isConsumingBonusTime) {
                        // 0 degree is to the right, so minus 90 should be up
                        Pie(startAngle: Angle(degrees: 0 - 90), endAngle: Angle(degrees: (1 - animatedBonusRemaining) * 360 - 90))
                            .onAppear {
                                animatedBonusRemaining = card.bonusRemaining
                                withAnimation(.linear(duration: card.bonusTimeRemaining)) {
                                    animatedBonusRemaining = 0
                                }
                            }
                    } else {
                        // 0 degree is to the right, so minus 90 should be up
                        Pie(startAngle: Angle(degrees: 0 - 90), endAngle: Angle(degrees: (1 - card.bonusRemaining) * 360 - 90))
                    }
                }
                    .padding(5)
                    .opacity(0.4)
//                // 0 degree is to the right, so minus 90 should be up
//                Pie(startAngle: Angle(degrees: 0 - 90), endAngle: Angle(degrees: (1 - card.bonusRemaining) * 360 - 90))
//                    .padding(5).opacity(0.4)
                Text(card.content)
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                    // when card.isMatched changes, it animates.
//                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: card.isMatched)
                    // font is not animatable, so put in a static size and use animatable scaleEffect
                    .font(Font.system(size: DrawingConstants.fontSize))
                    // view modifications like this .scaleEffect are not affected by the call to .animation ABOVE it
                    .scaleEffect(scale(thatFits: geometry.size))
            }
            .cardify(isFaceUp: card.isFaceUp)
        })
    }
    
    // the "scale factor" to scale our Text up so that it fits the geometry.size offered to us
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
