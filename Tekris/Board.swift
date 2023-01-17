//
//  ClassBoard.swift
//  Teckris
//
//  Created by Teck Tea on 10/01/2023.
//

import Foundation
import SwiftUI


let initC: Color = .white
let wall:Color = .gray
let initLine: [Color] = [wall, initC, initC, initC, initC, initC, initC, initC, initC, initC, initC, wall]
let grayLine: [Color] = [wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall,]
let blankLine: [Color] = [initC, initC, initC, initC, initC, initC, initC, initC, initC, initC, initC, initC]
let testLine: [Color] = [wall, .pink, .pink, .pink, .pink, initC, .pink, .pink, .pink, .pink, .pink, wall]
let upperLine: [Color] = [wall, wall, wall, wall, initC, initC, initC, initC, wall, wall, wall, wall]
let initColumn: [[Color]] = [upperLine, upperLine, upperLine, upperLine, initLine, initLine, initLine, initLine, initLine, initLine, initLine, initLine, initLine, initLine, initLine, initLine, testLine, testLine, testLine, testLine, testLine, testLine, testLine, testLine, grayLine]
let initBrick:((Int,Int),(Int,Int),(Int,Int),(Int,Int), Color, Int) = ((0,0),(0,0),(0,0),(0,0),.white, 1)

let screenWidth: CGFloat = UIScreen.main.bounds.width
let screenHeight: CGFloat = UIScreen.main.bounds.height
let size = screenHeight / 34

class Board : ObservableObject {
    @Published var array:[[Color]] = initColumn
    @Published var brick:((Int,Int),(Int,Int),(Int,Int),(Int,Int), Color, Int) = initBrick
    @Published var iteration: Int = 0
    var gameOver = false
    var newBrick = Bricks.cyan //Bricks.random()
    var speed = 1.0
    var score = 0
    var lines = 0
    let step = 2000
    var tetrisCombo = 0
    var lastAddedScore: [String] = [""]
    var level = 0
    var isPaused = false
    
    enum Bricks: CaseIterable {
        case cyan, orange, blue, purple, yellow, red, green
        static func random<G: RandomNumberGenerator>(using generator: inout G) -> Bricks {
                return Bricks.allCases.randomElement(using: &generator)!
            }
        static func random() -> Bricks {
            var g = SystemRandomNumberGenerator()
            return Bricks.random(using: &g)
        }
    }
    
    func reset() {
        array = initColumn
        brick = initBrick
        iteration = 0
         gameOver = false
         newBrick = Bricks.random() //Bricks.random()
         speed = 1.0
         score = 0
         lines = 0
         tetrisCombo = 0
         lastAddedScore = [""]
        level = 0
    }
    
    func returnNewBrick(_ newBrick: Bricks) -> ((Int,Int),(Int,Int),(Int,Int),(Int,Int), Color, Int) {
        let tile1: (Int, Int)
        let tile2: (Int, Int)
        let tile3: (Int, Int)
        let tile4: (Int, Int)
        let color: Color
        let offset: Int = 1
        switch newBrick {
        case .cyan:
            //bar
            color = .cyan
            tile1 = (3, 3 + offset)
            tile2 = (3, 4 + offset)
            tile3 = (3, 5 + offset)
            tile4 = (3, 6 + offset)
            iteration = 2
        case .orange:
            //L
            color = .orange
            tile1 = (1, 4 + offset)
            tile2 = (2, 4 + offset)
            tile3 = (3, 4 + offset)
            tile4 = (3, 5 + offset)
        case .blue:
            //L inverted
            color = .blue
            tile1 = (1, 5 + offset)
            tile2 = (2, 5 + offset)
            tile3 = (3, 5 + offset)
            tile4 = (3, 4 + offset)
        case .purple:
            //triangle
            color = .purple
            tile1 = (1, 4 + offset)
            tile2 = (2, 4 + offset)
            tile3 = (2, 5 + offset)
            tile4 = (3, 4 + offset)
            iteration = 1
        case .yellow:
            //square
            color = .yellow
            tile1 = (2, 4 + offset)
            tile2 = (2, 5 + offset)
            tile3 = (3, 4 + offset)
            tile4 = (3, 5 + offset)
            iteration = 1
        case .red:
            //stairs ascending
            color = .red
            tile1 = (1, 5 + offset)
            tile2 = (2, 5 + offset)
            tile3 = (2, 4 + offset)
            tile4 = (3, 4 + offset)
        case .green:
            //stairs descending
            color = .green
            tile1 = (1, 4 + offset)
            tile2 = (2, 4 + offset)
            tile3 = (2, 5 + offset)
            tile4 = (3, 5 + offset)
        }
        return (tile1, tile2, tile3, tile4, color, 1)
    }
    
    func NewBrick(){
        let currentBrick:((Int,Int),(Int,Int),(Int,Int),(Int,Int), Color, Int) = returnNewBrick(newBrick)
        brick.0 = currentBrick.0
        brick.1 = currentBrick.1
        brick.2 = currentBrick.2
        brick.3 = currentBrick.3
        brick.4 = currentBrick.4
        brick.5 = 1 //Rotation index
        newBrick = Bricks.random()
        if array[4][5] == initC && array[4][6] == initC {
            array[brick.0.0][brick.0.1] = brick.4
            array[brick.1.0][brick.1.1] = brick.4
            array[brick.2.0][brick.2.1] = brick.4
            array[brick.3.0][brick.3.1] = brick.4
            autoMoveDown()
//            autoLoop()
        } else {
            gameOver = true
        }
    }
    
    func nextBrick(){
        let nextBrick:((Int,Int),(Int,Int),(Int,Int),(Int,Int), Color, Int) = returnNewBrick(newBrick)
        array[nextBrick.0.0][nextBrick.0.1] = nextBrick.4
        array[nextBrick.1.0][nextBrick.1.1] = nextBrick.4
        array[nextBrick.2.0][nextBrick.2.1] = nextBrick.4
        array[nextBrick.3.0][nextBrick.3.1] = nextBrick.4
    }
    
    func deleteBrick(){
        array[brick.0.0][brick.0.1] = initC
        array[brick.1.0][brick.1.1] = initC
        array[brick.2.0][brick.2.1] = initC
        array[brick.3.0][brick.3.1] = initC
    }

    func moveBrick(){
        array[brick.0.0][brick.0.1] = brick.4
        array[brick.1.0][brick.1.1] = brick.4
        array[brick.2.0][brick.2.1] = brick.4
        array[brick.3.0][brick.3.1] = brick.4
    }

    func moveLeft(){
        if collision(((0,-1),(0,-1),(0,-1),(0,-1))) && (brick.0.1 - 1 >= 0)
        && (brick.1.1 - 1 >= 0) && (brick.2.1 - 1 >= 0) && (brick.3.1 - 1 >= 0)
        {
            brick.0.1 -= 1
            brick.1.1 -= 1
            brick.2.1 -= 1
            brick.3.1 -= 1
        }
        moveBrick()
    }
    
    func moveRight(){
        if collision(((0,1),(0,1),(0,1),(0,1))) && (brick.0.1 + 1 <= 10)
        && (brick.1.1 + 1 <= 10) && (brick.2.1 + 1 <= 10) && (brick.3.1 + 1 <= 10)
        {
            brick.0.1 += 1
            brick.1.1 += 1
            brick.2.1 += 1
            brick.3.1 += 1
        }
        moveBrick()
    }

    func moveDown(){
        if collision(((1,0),(1,0),(1,0),(1,0))) && (brick.0.0 + 1 < 24)
            && (brick.1.0 + 1 < 24) && (brick.2.0 + 1 < 24) && (brick.3.0 + 1 < 24)
        {
            brick.0.0 += 1
            brick.1.0 += 1
            brick.2.0 += 1
            brick.3.0 += 1
            iteration += 1
        }
        moveBrick()
    }
    
    func collision(_ futureMove: ((Int, Int),(Int, Int),(Int, Int),(Int, Int))) -> Bool {
        //Checks possible collision beforehand
        deleteBrick()
        if brick.0.0 + futureMove.0.0 >= 0 &&
           brick.1.0 + futureMove.1.0 >= 0 &&
           brick.2.0 + futureMove.2.0 >= 0 &&
           brick.3.0 + futureMove.3.0 >= 0 {
//            moveBrick()
            return array[brick.0.0 + futureMove.0.0][brick.0.1 + futureMove.0.1] == initC &&
                array[brick.1.0 + futureMove.1.0][brick.1.1 + futureMove.1.1] == initC &&
                array[brick.2.0 + futureMove.2.0][brick.2.1 + futureMove.2.1] == initC &&
                array[brick.3.0 + futureMove.3.0][brick.3.1 + futureMove.3.1] == initC
        } else {
//            moveBrick()
//            array[15][5] = .red
//            array[15][6] = .red
            
            return false
        }
    }
    

    func autoMoveDown() {
        var timer: Timer!
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / speed, repeats: true) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.isPaused == true ? 360 : 0)){
                if self.collision(((1, 0), (1, 0), (1, 0), (1, 0))) {
                    //                self.deleteBrick()
                    self.brick.0.0 += 1
                    self.brick.1.0 += 1
                    self.brick.2.0 += 1
                    self.brick.3.0 += 1
                    self.moveBrick()
                    self.iteration += 1
                    if self.iteration >= 4 {
                        self.nextBrick()
                    }
                    
                } else {
                    self.moveBrick()
                    self.checkBoard()
                    timer.invalidate()
                    self.iteration = 0
                    self.NewBrick()
                    
                }
            }
        }
    }
    
    func fastMoveDown() {
        while self.collision(((1, 0), (1, 0), (1, 0), (1, 0))) {
                self.brick.0.0 += 1
                self.brick.1.0 += 1
                self.brick.2.0 += 1
                self.brick.3.0 += 1
                self.moveBrick()
                self.iteration += 1
                if self.iteration >= 4 {
                    self.nextBrick()
                }
            }
        self.moveBrick()
                self.iteration = 0
    }
    
    func checkBoard() {
        var y: Int = 23
        var combo: Int = 0
        while y != 3 {
            if checkLine(y) {
                combo += 1
                score += 100
                lines += 1
                lastAddedScore.append("single")
                deleteLine(y)
                if (combo > 0) {
                    let count = lastAddedScore.count - 1
                    if (combo % 4 == 0) {
                        if lastAddedScore[count] == "single" && count >= 9 && lastAddedScore[count - 1] == "single"
                            && lastAddedScore[count - 2] == "single" && lastAddedScore[count - 3] == "single" && lastAddedScore[count - 4] == "tetris"
                        {
                            score += 400
                        }
                        board.tetrisCombo += 1
                        score += 400
                        lastAddedScore.append("tetris")
                    }
                }
            } else {
                combo = 0
                y -= 1
            }
            withAnimation(.easeIn){
                level = Int(Double(score/step))
            }
            speed = ((10 + Double(level*3))/10 <= 4 ? (10 + Double(level*3))/10 : 4)
        }
        
    }
    
    func checkLine(_ y: Int) -> Bool {
        var line: Bool = true
        for x in 1...10 {
            line = line && (array[y][x] != initC)
        }
        return line
    }
    
    func deleteLine(_ line: Int){
        for y in stride(from: line - 1, to: 3, by: -1){
            for x in 1...10 {
                array[y+1][x] = array[y][x]
            }
        }
    }
    
    func rotation() {
        switch brick.4 {
        case .cyan:
            rotationBar()
        case .purple:
            rotationTriangle()
        case .orange:
            rotationL()
        case .blue:
            rotationLInvert()
        case .green:
            rotationStairsDesc()
        case .red:
            rotationStairsAsc()
        default:
            Text("")
        }
    }
    
    func rotationTriangle() {
        if brick.5 == 1 && collision(((1,1),(0,0),(1,-1),(-1,-1))){
            brick.0.0 += 1
            brick.0.1 += 1
            brick.2.0 += 1
            brick.2.1 += -1
            brick.3.0 += -1
            brick.3.1 += -1
            brick.5 += 1
            
        } else if brick.5 == 2 && collision(((1,-1),(0,0),(-1,-1),(-1,1))){
            brick.0.0 += 1
            brick.0.1 += -1
            brick.2.0 += -1
            brick.2.1 += -1
            brick.3.0 += -1
            brick.3.1 += 1
            brick.5 += 1
            
        } else if brick.5 == 3 && collision(((-1,-1),(0,0),(-1,1),(1,1))){
            brick.0.0 += -1
            brick.0.1 += -1
            brick.2.0 += -1
            brick.2.1 += 1
            brick.3.0 += 1
            brick.3.1 += 1
            brick.5 += 1
            
        } else if brick.5 == 4 && collision(((-1,1),(0,0),(1,1),(1,-1))){
            brick.0.0 += -1
            brick.0.1 += 1
            brick.2.0 += 1
            brick.2.1 += 1
            brick.3.0 += 1
            brick.3.1 += -1
            brick.5 = 1
        }
        moveBrick()
    }
    
    func rotationBar() {
        if brick.5 == 1 && collision(((-1,2),(0,1),(1,0),(2,-1))){
            brick.0.0 += -1
            brick.0.1 += 2
            brick.1.0 += 0
            brick.1.1 += 1
            brick.2.0 += 1
            brick.2.1 += 0
            brick.3.0 += 2
            brick.3.1 += -1
            brick.5 += 1
            
        } else if brick.5 == 2 && collision(((2,1),(1,0),(0,-1),(-1,-2))){
            brick.0.0 += 2
            brick.0.1 += 1
            brick.1.0 += 1
            brick.1.1 += 0
            brick.2.0 += 0
            brick.2.1 += -1
            brick.3.0 += -1
            brick.3.1 += -2
            brick.5 += 1
            
        } else if brick.5 == 3 && collision(((1,-2),(0,-1),(-1,0),(-2,1))){
            brick.0.0 += 1
            brick.0.1 += -2
            brick.1.0 += 0
            brick.1.1 += -1
            brick.2.0 += -1
            brick.2.1 += 0
            brick.3.0 += -2
            brick.3.1 += 1
            brick.5 += 1
            
        } else if brick.5 == 4 && collision(((-2,-1),(-1,0),(0,1),(1,2))){
            brick.0.0 += -2
            brick.0.1 += -1
            brick.1.0 += -1
            brick.1.1 += 0
            brick.2.0 += 0
            brick.2.1 += 1
            brick.3.0 += 1
            brick.3.1 += 2
            brick.5 = 1
        }
        moveBrick()
    }
    
    func rotationL() {
        if brick.5 == 1 && collision(((1,1),(0,0),(-1,-1),(0,-2))){
            brick.0.0 += 1
            brick.0.1 += 1
            brick.1.0 += 0
            brick.1.1 += 0
            brick.2.0 += -1
            brick.2.1 += -1
            brick.3.0 += 0
            brick.3.1 += -2
            brick.5 += 1
            
        } else if brick.5 == 2 && collision(((1,-1),(0,0),(-1,1),(-2,0))){
            brick.0.0 += 1
            brick.0.1 += -1
            brick.1.0 += 0
            brick.1.1 += 0
            brick.2.0 += -1
            brick.2.1 += 1
            brick.3.0 += -2
            brick.3.1 += 0
            brick.5 += 1
            
        } else if brick.5 == 3 && collision(((-1,-1),(0,0),(1,1),(0,2))){
            brick.0.0 += -1
            brick.0.1 += -1
            brick.1.0 += 0
            brick.1.1 += 0
            brick.2.0 += 1
            brick.2.1 += 1
            brick.3.0 += 0
            brick.3.1 += 2
            brick.5 += 1
            
        } else if brick.5 == 4 && collision(((-1,1),(0,0),(1,-1),(2,0))){
            brick.0.0 += -1
            brick.0.1 += 1
            brick.1.0 += 0
            brick.1.1 += 0
            brick.2.0 += 1
            brick.2.1 += -1
            brick.3.0 += 2
            brick.3.1 += 0
            brick.5 = 1
        }
        moveBrick()
    }
    
    func rotationLInvert() {
        if brick.5 == 1 && collision(((1,1),(0,0),(-1,-1),(-2,0))){
            brick.0.0 += 1
            brick.0.1 += 1
            brick.1.0 += 0
            brick.1.1 += 0
            brick.2.0 += -1
            brick.2.1 += -1
            brick.3.0 += -2
            brick.3.1 += 0
            brick.5 += 1
            
        } else if brick.5 == 2 && collision(((1,-1),(0,0),(-1,1),(0,2))){
            brick.0.0 += 1
            brick.0.1 += -1
            brick.1.0 += 0
            brick.1.1 += 0
            brick.2.0 += -1
            brick.2.1 += 1
            brick.3.0 += 0
            brick.3.1 += 2
            brick.5 += 1
            
        } else if brick.5 == 3 && collision(((-1,-1),(0,0),(1,1),(2,0))){
            brick.0.0 += -1
            brick.0.1 += -1
            brick.1.0 += 0
            brick.1.1 += 0
            brick.2.0 += 1
            brick.2.1 += 1
            brick.3.0 += 2
            brick.3.1 += 0
            brick.5 += 1
            
        } else if brick.5 == 4 && collision(((-1,1),(0,0),(1,-1),(0,-2))){
            brick.0.0 += -1
            brick.0.1 += 1
            brick.1.0 += 0
            brick.1.1 += 0
            brick.2.0 += 1
            brick.2.1 += -1
            brick.3.0 += 0
            brick.3.1 += -2
            brick.5 = 1
        }
        moveBrick()
    }
    
    func rotationStairsDesc() {
        if brick.5 == 1 && collision(((1,1),(0,0),(1,-1),(0,-2))){
            brick.0.0 += 1
            brick.0.1 += 1
            brick.1.0 += 0
            brick.1.1 += 0
            brick.2.0 += 1
            brick.2.1 += -1
            brick.3.0 += 0
            brick.3.1 += -2
            brick.5 += 1
        } else if brick.5 == 2 && collision(((1,-1),(0,0),(-1,-1),(-2,0))){
            brick.0.0 += 1
            brick.0.1 += -1
            brick.1.0 += 0
            brick.1.1 += 0
            brick.2.0 += -1
            brick.2.1 += -1
            brick.3.0 += -2
            brick.3.1 += 0
            brick.5 += 1
        } else if brick.5 == 3 && collision(((-1,-1),(0,0),(-1,1),(0,2))){
            brick.0.0 += -1
            brick.0.1 += -1
            brick.1.0 += 0
            brick.1.1 += 0
            brick.2.0 += -1
            brick.2.1 += 1
            brick.3.0 += 0
            brick.3.1 += 2
            brick.5 += 1
        } else if brick.5 == 4 && collision(((-1,1),(0,0),(1,1),(2,0))){
            brick.0.0 += -1
            brick.0.1 += 1
            brick.1.0 += 0
            brick.1.1 += 0
            brick.2.0 += 1
            brick.2.1 += 1
            brick.3.0 += 2
            brick.3.1 += 0
            brick.5 = 1
        }
        moveBrick()
    }
    
    func rotationStairsAsc() {
        if brick.5 == 1 && collision(((1,1),(0,0),(-1,1),(-2,0))){
            brick.0.0 += 1
            brick.0.1 += 1
            brick.1.0 += 0
            brick.1.1 += 0
            brick.2.0 += -1
            brick.2.1 += 1
            brick.3.0 += -2
            brick.3.1 += 0
            brick.5 += 1
        } else if brick.5 == 2 && collision(((1,-1),(0,0),(1,1),(0,2))){
            brick.0.0 += 1
            brick.0.1 += -1
            brick.1.0 += 0
            brick.1.1 += 0
            brick.2.0 += 1
            brick.2.1 += 1
            brick.3.0 += 0
            brick.3.1 += 2
            brick.5 += 1
        } else if brick.5 == 3 && collision(((-1,-1),(0,0),(1,-1),(2,0))){
            brick.0.0 += -1
            brick.0.1 += -1
            brick.1.0 += 0
            brick.1.1 += 0
            brick.2.0 += 1
            brick.2.1 += -1
            brick.3.0 += 2
            brick.3.1 += 0
            brick.5 += 1
        } else if brick.5 == 4 && collision(((-1,1),(0,0),(-1,-1),(0,-2))){
            brick.0.0 += -1
            brick.0.1 += 1
            brick.1.0 += 0
            brick.1.1 += 0
            brick.2.0 += -1
            brick.2.1 += -1
            brick.3.0 += 0
            brick.3.1 += -2
            brick.5 = 1
        }
        moveBrick()
    }
}
