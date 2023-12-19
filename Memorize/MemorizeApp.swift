//
//  MemorizeApp.swift
//  Memorize
//
//  Created by Vic Z.Ding on 2023/2/19.
//

import SwiftUI

@main
struct MemorizeApp: App {
    var body: some Scene {
        WindowGroup {
            EmojiMemoryGameView(game: EmojiMemoryGame())
        }
    }
}
