//
//  BlocView.swift
//  Teckris
//
//  Created by Teck Tea on 06/01/2023.
//

import SwiftUI

//Draws the whole board (excluding top left and top right)
struct BlankBoard: View {
    @EnvironmentObject var board: Board
    var body: some View {
        VStack {
            ForEach (1..<25) {y in
                HStack {
                    ForEach (0..<12) {x in
                        if (y >= 1) && (y <= 2){
                            if (x >= 4) && (x <= 7) {
                                SingleBloc(color: board.array[y][x])
                            }
                        } else {
                            SingleBloc(color: board.array[y][x])
                        }
                    }
                }
            }
        }
    }
}

//As the name suggests, draws a single bloc
struct SingleBloc: View {
    let color: Color
    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .frame(width: size, height: size)
            .foregroundColor(color)
            .padding(-3.5)
    }
}

struct BlankBoard_Previews: PreviewProvider {
    static var previews: some View {
        BlankBoard()
            .environmentObject(Board())
    }
}
