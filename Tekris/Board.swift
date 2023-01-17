//
//  ClassBoard.swift
//  Teckris
//
//  Created by Teck Tea on 10/01/2023.
//

import Foundation
import SwiftUI


let initC: Color = .white //Default tile color
let wall:Color = .gray //Default wall color
let initLine: [Color] = [wall, initC, initC, initC, initC, initC, initC, initC, initC, initC, initC, wall] //Basic line: wall, 10x tiles, wall
let grayLine: [Color] = [wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall,] //Bottom wall
//let blankLine: [Color] = [initC, initC, initC, initC, initC, initC, initC, initC, initC, initC, initC, initC] //For testing purpose
let testLine: [Color] = [wall, .pink, .pink, .pink, .pink, initC, .pink, .pink, .pink, .pink, .pink, wall] //For testing purpose
let upperLine: [Color] = [wall, wall, wall, wall, initC, initC, initC, initC, wall, wall, wall, wall] //Top of the board where only the tiles showing the next brick are displayed
let initColumn: [[Color]] = [upperLine, upperLine, upperLine, upperLine, initLine, initLine, initLine, initLine, initLine, initLine, initLine, initLine, initLine, initLine, initLine, initLine, testLine, testLine, testLine, testLine, testLine, testLine, testLine, testLine, grayLine] //The board itself, stacking the lines from top to bottom (0 to 24)
let initBrick:((Int,Int),(Int,Int),(Int,Int),(Int,Int), Color, Int) = ((0,0),(0,0),(0,0),(0,0),.white, 1) //Tuple defining a tetronimo : (Tile1(y,x), tile2... tile3, color, rotation index)

let screenWidth: CGFloat = UIScreen.main.bounds.width //Screen size so everything can scale accordingly to the device' screen.
let screenHeight: CGFloat = UIScreen.main.bounds.height
let size = screenHeight / 34 //Size of a single tile

class Board : ObservableObject {
    //Basically game area. We only need a Color to be stored in this array of array.
    @Published var array:[[Color]] = initColumn
    //Tetronimo/brick are coordinates (for each bloc), a color and a rotation index. They are used to fill the array above with the proper color.
    @Published var brick:((Int,Int),(Int,Int),(Int,Int),(Int,Int), Color, Int) = initBrick
    @Published var iteration: Int = 0
    var gameOver = false
    var newBrick = Bricks.cyan //Should be Bricks.random() but for demo purpose the very first brick is a bar
    var speed = 1.0
    var score = 0
    var lines = 0
    let step = 2000 //Threshold for level increase
    var tetrisCombo = 0
    var lastAddedScore: [String] = [""] //Had to rely on this array to record every score increase so I know when there are continuous tetrises
    var level = 0
    var isPaused = false
    
    //I call them Bricks but they should be called "tetronimos". Enum based on the colors (could have been the shapes).
    enum Bricks: CaseIterable {
        case cyan, orange, blue, purple, yellow, red, green
        //Method to return a random brick
        static func random<G: RandomNumberGenerator>(using generator: inout G) -> Bricks {
                return Bricks.allCases.randomElement(using: &generator)!
            }
        static func random() -> Bricks {
            var g = SystemRandomNumberGenerator()
            return Bricks.random(using: &g)
        }
    }
    
    //As the name suggests, this method resets the whole instance.
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
    
    //Basically returns the tuple with the brick informations based on the Enum pick.
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
    
    //Stores the current brick informations before displaying them and calls the next brick that will be previewed.
    func NewBrick(){
        let currentBrick:((Int,Int),(Int,Int),(Int,Int),(Int,Int), Color, Int) = returnNewBrick(newBrick)
        brick.0 = currentBrick.0
        brick.1 = currentBrick.1
        brick.2 = currentBrick.2
        brick.3 = currentBrick.3
        brick.4 = currentBrick.4
        brick.5 = 1 //Rotation index
        newBrick = Bricks.random()
        //Draws the brick if possible, otherwise gameOver
        if array[4][5] == initC && array[4][6] == initC {
            array[brick.0.0][brick.0.1] = brick.4
            array[brick.1.0][brick.1.1] = brick.4
            array[brick.2.0][brick.2.1] = brick.4
            array[brick.3.0][brick.3.1] = brick.4
            autoMoveDown()
        } else {
            gameOver = true
        }
    }
    
    //Displays the next brick.
    func nextBrick(){
        let nextBrick:((Int,Int),(Int,Int),(Int,Int),(Int,Int), Color, Int) = returnNewBrick(newBrick)
        array[nextBrick.0.0][nextBrick.0.1] = nextBrick.4
        array[nextBrick.1.0][nextBrick.1.1] = nextBrick.4
        array[nextBrick.2.0][nextBrick.2.1] = nextBrick.4
        array[nextBrick.3.0][nextBrick.3.1] = nextBrick.4
    }
    
    //Removes the brick from the color array (board) but doesn't empty brick (informations remain).
    func deleteBrick(){
        array[brick.0.0][brick.0.1] = initC
        array[brick.1.0][brick.1.1] = initC
        array[brick.2.0][brick.2.1] = initC
        array[brick.3.0][brick.3.1] = initC
    }

    //Bad function call. SHould have been "drawBrick".
    func moveBrick(){
        array[brick.0.0][brick.0.1] = brick.4
        array[brick.1.0][brick.1.1] = brick.4
        array[brick.2.0][brick.2.1] = brick.4
        array[brick.3.0][brick.3.1] = brick.4
    }

    //Checks if a brick can move towards a direction once. If so, updates brick "coordinates" by changing the tiles values. Then redraws the brick on array.
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
    
    //Delete the brick from array and then checks if the intended displacement set as arguments is possible.
    func collision(_ futureMove: ((Int, Int),(Int, Int),(Int, Int),(Int, Int))) -> Bool {
        //Checks possible collision beforehand
        deleteBrick()
        if brick.0.0 + futureMove.0.0 >= 0 &&
           brick.1.0 + futureMove.1.0 >= 0 &&
           brick.2.0 + futureMove.2.0 >= 0 &&
           brick.3.0 + futureMove.3.0 >= 0 {
            return array[brick.0.0 + futureMove.0.0][brick.0.1 + futureMove.0.1] == initC &&
                array[brick.1.0 + futureMove.1.0][brick.1.1 + futureMove.1.1] == initC &&
                array[brick.2.0 + futureMove.2.0][brick.2.1 + futureMove.2.1] == initC &&
                array[brick.3.0 + futureMove.3.0][brick.3.1 + futureMove.3.1] == initC
        } else {
            return false
        }
    }
    
    //Auto moves a brick down as long as it's possible every 1/speed second. The higher the speed, the shorter the interval, the faster the brick moves.
    //If isPaused is true (a tap on the scores i nthe mainView), the thread is paused.
    func autoMoveDown() {
        var timer: Timer!
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / speed, repeats: true) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.isPaused == true ? 600 : 0)){
                if self.collision(((1, 0), (1, 0), (1, 0), (1, 0))) {
                    self.brick.0.0 += 1
                    self.brick.1.0 += 1
                    self.brick.2.0 += 1
                    self.brick.3.0 += 1
                    self.moveBrick()
//After the 4th displacement down, the nextBrick is called and is displayed. That way the current moving brick and the preview don't overlap.
                    self.iteration += 1
                    if self.iteration >= 4 {
                        self.nextBrick()
                    }
                } else {
//If the brick can't move any further down, method checkBoard is called to check if there are lines completed and summon a new brick.
                    self.moveBrick()
                    self.checkBoard()
                    timer.invalidate()
                    self.iteration = 0
                    self.NewBrick()
                }
            }
        }
    }
    
//A long pressure on the bottom arrow button triggers the fast move down.
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
    
//Checks the whole board for completed lines. Gives bonus score in case of Tetris (4 adjacent lines) and another bonus if Tetrises are linked (no single line scoring in between). lastAddedScore is used to record the score increase and allows to look for the combos.
//Speed and level are changed inside the loop.
//The while loop stops once y reaches the top of the board (3).
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
    
//Checks if a specific line is full
    func checkLine(_ y: Int) -> Bool {
        var line: Bool = true
        for x in 1...10 {
            line = line && (array[y][x] != initC)
        }
        return line
    }
    
//Loop that moves down every single line starting from a specific line until 3 (highest line).
    func deleteLine(_ line: Int){
        for y in stride(from: line - 1, to: 3, by: -1){
            for x in 1...10 {
                array[y+1][x] = array[y][x]
            }
        }
    }

//Rotation functions. Lots of them cuz we need to check and update for each rotation index and each Bricks (shape).
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
