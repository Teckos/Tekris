//
//  ScoresView.swift
//  Tekris
//
//  Created by Teck Tea on 13/01/2023.
//

import SwiftUI

//Displays the useful informations.
//Text size as argument so the view can be adjusted
struct ScoresView: View {
    @EnvironmentObject var board: Board
    let size : Double
    var body: some View {
        HStack{
            VStack{
                Text("Points:")
                Text("\(board.score)")
                Text("Lines:")
                Text("\(board.lines)")
                    .padding(.bottom, 50)
            }
            .font(.system(size: size, weight: .bold))
            .padding(.horizontal)
            Spacer()
            VStack{
                Text("Level:")
                Text("\(Int(board.level))")
                Text("Tetris:")
                Text("\(board.tetrisCombo)")
                    .padding(.bottom, 50)
            }
            .font(.system(size: size, weight: .bold))
            .padding(.horizontal)
        }
    }
}

struct ScoresView_Previews: PreviewProvider {
    static var previews: some View {
        ScoresView(size : 12.0)
            .environmentObject(board)
    }
}
