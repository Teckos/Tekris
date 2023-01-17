# Tekris
SwiftUI Tetris

I wanted to know if I was able to code a game with a simple gameplay such as Tetris (but yet with a not so obvious mechanism behind the scene).
Came up with this solution: 
-An array (array) 12 x 24 of Color (actual game board being 10 x 20)
-A tuple (brick) of 4 tuples ((y, x)) defining a tetronimo : (Tile1(y,x), tile2, tile3, tile 4, color, rotation index)
The array is displayed and then the color of each block is changed by the color (brick.4) of the tetronimo (each single tuple (y, x) being basically coordinates).
Whenever the brick moves, its coordonates are updated within the tuple while blocks' color is changed accordingly in the array.
I don't know how it was handled originally. There are certainly other ways but I found this solution elegant and simple enough.
Also have to reckon it's kinda ugly but it's working just fine and serves its purpose. 

Managed this within 4 days with en entire day struggling with the autoMoveDown() method overseeing collision(). I was assuming it worked properly while it didn't.
At first it was testing if there was a color (other than initC) at the future location for all 4 tiles forming the tetronimo. See the flaw? 
Couldn't work with shapes other than the bar because of the tiles "behind". 
Example L shaped brick (orange):

1

2

3  4

The method collision(((1,0),(1,0),(1,0),(1,0))) (tests if there's a collision with a y+1 movement, so towards the bottom) was never true because of the tiles 2 & 1 which future location were respectively 3 & 2.
Overcome this simply by deleting the actual brick before testing it's future location. The brick is redrawn right after the conditions are tested.

Had to look up on wikis how the rotations were supposed happen (pivots) and what the scores and bonuses for Tetris and Tetrises combos were.
