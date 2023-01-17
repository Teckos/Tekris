//
//  Buttons.swift
//  Teckris
//
//  Created by Teck Tea on 10/01/2023.
//

import SwiftUI
let arrowSize = 25.0
let bWidth = 80.0
let bHeight = 50.0

//Displays all 4 buttons
struct Buttons: View {
    var board: Board
    var body: some View {
        VStack{
            HStack{
                Spacer()
                SingleButton(typeOfMove: "arrow.clockwise")
                Spacer()
            }.padding(.vertical, 5)
            HStack{
                SingleButton(typeOfMove: "arrow.left")
                
                Button {
                } label: {
                    Image(systemName: "arrow.down")
                }
                .simultaneousGesture(LongPressGesture().onEnded { _ in
                    board.fastMoveDown()
                })
                .simultaneousGesture(TapGesture().onEnded {
                    board.moveDown()
                                    })
                .font(.system(size: arrowSize, weight: .bold))
                .frame(width : bWidth, height: bHeight)
                .background(.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                
                SingleButton(typeOfMove: "arrow.right")
            }
        }
    }
}

//Struct that draws a button and associates the proper method according on the direction
//The button that move down is different so it's not in the switch
struct SingleButton: View {
    let typeOfMove: String
    var body: some View {
        
        Button {
            switch typeOfMove {
            case "arrow.clockwise":
                board.rotation()
            case "arrow.left":
                board.moveLeft()
            case "arrow.right":
                board.moveRight()
            default:
                Text("")
            }
        } label: {
            Image(systemName: typeOfMove)
        }.font(.system(size: arrowSize, weight: .bold))
            .frame(width : bWidth, height: bHeight)
            .background(.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        Buttons(board: Board())
    }
}
