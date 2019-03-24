//#-hidden-code
import UIKit
import Foundation
import PlaygroundSupport

let page = PlaygroundPage.current
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
var colorToothPick: [(UIImage,Int,Int)] = []
var counter = 0
// function to add ToothPicks into the scene
func addToothPicks(image: UIImage ,count: Int, score: Int) {
    // Send messages
    colorToothPick.append((image,count,score))
    
    counter = counter + 1
}

//#-end-hidden-code

/*:
 # Mikado
 ## About the game
 [source]: https://en.wikipedia.org/wiki/Mikado_(game)
 blabla
 Mikado is a pick-up sticks game probably originating in China, played with a set of same-length sticks which can measure between 17 centimetres (6.7 in) and 50 centimetres (20 in).
 The goal of the real game is to take the toothpicks without moving the other ones.
 " In 1936, it was brought from Hungary (where it was called Marokko) to the United States and named pick-up sticks. This term is not very specific in respect to existing stick game variations. The "Mikado" name may have been avoided because it was a brand name of a game producer. The game is named for the highest scoring (blue) stick "Mikado" (Emperor of Japan)." [source]
 
 ![Mikado](Mikado.png)

 
 ## Let's start!
 
The mikado game can be played in single player or multiplayer. Read the **Rules** below to learn how to play.
 
 

 ### Single player Rules:
 * The player has to move one toothpick each time to the trash can that appears when the user selects one with the touch.
 * The trash can becomes bigger when the toothpick is on it.
 * Every toothpick put into the trash can, in the correct way, will increase the score of the player
 * If the user ,while is moving its toothpick, causes the movement of other toothpicks or other toothpicks are moving it will lose the same point as he should earn
 * Every toothpick has a different score based on its characteristics
 * Every match has a specific number of toothpicks and maximum score
 * The number of the toothpicks and the scores can be changed in code, otherwise there are default rules with 45 toothpicks and five different characteristics
 * Every player has to move one toothpick while the others aren't moving and put it into the trash can.
 * When all toothpicks are finished, the player can restart the game to try to beat its HighScore
 

 ### Multiplayer Rules:
 * One of the two player will start the game and will see his score on the left part
 * When it is his turn, every player has to move one toothpick each time to the trash can that appears when the user selects one with the touch.
 * The trash can becomes bigger when the toothpick is on it.
 * Every toothpick put into the trash can, in the correct way, will increase the score of the player
 * If the user ,while is moving its toothpick, causes the movement of other toothpicks or other toothpicks are moving the control of the game will be passed to the other player
 * Every player can continue to play until he makes a mistake. He can understand when he makes a mistake thanks to a label and his score becomes smaller than the other.
 * Every toothpick has a different score based on its characteristics
 * Every match has a specific number of toothpicks and maximum score
 * The number of the toothpicks and the scores can be changed in code
 * Every player has to move one toothpick while the others aren't moving and put it into the trash can.
 * When all toothpicks are finished, the player who reached the highest score wins the game
 */

/*:
 
 ### Side notes:
 Use the full landscape screen and different score for each toothpick types for the best result!
 Negative values will be automatically converted to positive ones.

 
 - Important:
 *This playground is targeted at people who have a very basic knowledge of the swift programming language.*
 
*/


/*:
 **You can also don't change anything on this page, default rules are already made for you!** 😉

 
You can find the basic code for **this** page down here. Try to change the multiPlayer variable to play in **singleplayer** (if it is **false**) and **multiplayer** (if it is **true**)
*/


//#-code-completion(everything, hide)
//#-code-completion(identifier, show, true, false)
let multiPlayer = /*#-editable-code*/ false /*#-end-editable-code*/


//#-code-completion(everything, hide)
//#-code-completion(everything, show, addToothPicks(image: #imageLiteral(resourceName: "woodTexture2"), count: 1, score: 50))
/*:
 **Now** try to change these function if you'd like to create your rules! The image changes the type of toothpicks, count the number of that type and score the quantity that increment or decrement your points.
 */
//#-editable-code

addToothPicks(image: #imageLiteral(resourceName: "woodTexture2"), count: 1, score: 50)
addToothPicks(image: #imageLiteral(resourceName: "woodTexture5"), count: 10, score: 10)
addToothPicks(image: #imageLiteral(resourceName: "woodTexture4"), count: 20, score: 4)
addToothPicks(image: #imageLiteral(resourceName: "woodTexture6"), count: 9, score: 12)
addToothPicks(image: #imageLiteral(resourceName: "woodTexture3"), count: 5, score: 10)

//#-end-editable-code

//#-hidden-code


proxy?.send(.data(try NSKeyedArchiver.archivedData(withRootObject: counter , requiringSecureCoding: false)))
proxy?.send(.data(try NSKeyedArchiver.archivedData(withRootObject: multiPlayer , requiringSecureCoding: false)))

for elem in colorToothPick {
    
    do { proxy?.send(.data(try NSKeyedArchiver.archivedData(withRootObject: elem.0, requiringSecureCoding: false))) } catch {
        fatalError()
    }
    do { proxy?.send(.data(try NSKeyedArchiver.archivedData(withRootObject: elem.1 , requiringSecureCoding: false))) } catch {
        fatalError()
    }
    do { proxy?.send(.data(try NSKeyedArchiver.archivedData(withRootObject: elem.2 , requiringSecureCoding: false))) } catch {
        fatalError()
    }
}


//#-end-hidden-code


/*:
 **When you have finished,I have other things to show you. You can go to the next page when you want** 💪🏻
 [Next page](@next)
 
 
 */

