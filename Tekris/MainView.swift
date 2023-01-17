//
//  ContentView.swift
//  Teckris
//
//  Created by Teck Tea on 06/01/2023.
//

import SwiftUI
import Foundation

var board = Board()

struct MainView: View {
    @EnvironmentObject var board: Board
    @State var isPresented = false
    @State var Pause = false
    var bgColor: Double {
        return board.level < 10 ? Double(board.level)/10 : 1
    }
    
    var body: some View {
        ZStack {
            Background(bgColor: bgColor)
            VStack{
                ScoresView(size: 12.0)
                    .onTapGesture {
//A tap on the scores triggers the pause
                        Pause = true
                    }
                Spacer()
            }
            VStack {
                Spacer()
                Spacer()
//Board drawing
                BlankBoard()
                    .onAppear(perform: {
//The game starts right as the board is drawn
                        board.NewBrick()
                    })
                Spacer()
                Buttons(board: board)
                    .padding(.bottom)
            }
            .alert("Recommencer ?", isPresented: $board.gameOver) {
                Button("Oui") {
//Alert is shown when gameOver is true. When "Oui" is clicked, the board resets along with all the scores and a new game starts.
                    board.reset()
                    board.NewBrick()
                }
            }
            .sheet(isPresented: $Pause) {
//Modal pause view call
                PauseView().opacity(0.7)
            }
        }
    }
}

//Changing the background gradient's colors dynamically based on the property bgColor which is a computed property that changes according to the player's level.
struct Background: View {
    let bgColor: Double
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [ Color(red: bgColor, green: 1 - bgColor, blue: 1 - bgColor), Color(red: 1 - bgColor, green: 1 - bgColor, blue: bgColor), Color(red: bgColor, green: 1 - bgColor, blue: bgColor)]), startPoint: .bottomTrailing, endPoint: .topLeading)
            .foregroundColor(.white)
            .ignoresSafeArea()
            .opacity(0.8)
    }
}

//Basic modal view that pauses the game and displays the scores
struct PauseView: View {
    var body: some View {
        ZStack{
            Background(bgColor: 0.9)
            VStack{
                Text("Breaktime")
                    .font(.system(size: 30, weight: .bold))
                    .padding(.bottom, 30)
                ScoresView(size: 25)
                        .padding(.horizontal, 40)
            }
        }
        .onAppear{
            board.isPaused = true
        }
        .onDisappear{
            board.isPaused = false
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(board)
    }
}


