//#-hidden-code
import Foundation
import PlaygroundSupport

let page = PlaygroundPage.current
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy

//#-end-hidden-code
/*:
# Mikado 2.0
 ## A new concept of the old Chinese game
 
Mikado 2.0 is a game implemented in Augmented Reality (thanks to the framework of Apple: ARkit) where the user has to shoot the toothpicks to increase its score, without taking the ones which are rotating to don't lose point.

 
 ### Rules:
 * The player has to hit the toothpicks that aren't rotating around him thanks to a ball that he can throw tapping on the screen
 * Every toothpick hit will increase or decrease the score of the player
 * If the toothpick is rotating, it will decrease the score, otherwise the toothpick will increase it
* The goal is to achieve the highest score as possible
 
 **Thank you so much for your attention.**

 **Try to change this variable to reduce or increment the frequency of spawning toothpicks**
 */

//#-code-completion(everything, hide)
//#-code-completion(everything, show, 60, 70, 80, 90)
let frequency = /*#-editable-code*/ 60 /*#-end-editable-code*/

/*:
 **Try to modify the max number of toothpicks accepted in the view every moment.**
 */

let maxNumberOfToothPicks = /*#-editable-code*/ 1500 /*#-end-editable-code*/

/*:
 ## Side note:
 When the max number of toothpicks is reached, a refresh button will appear below the the score to give you the opportunity to delete all toothpicks.
 */
//#-hidden-code

if let frequence = frequency as? Int {
    if let maxNumber = maxNumberOfToothPicks as? Int {
        switch frequence {
        case -Int.max..<0:
            page.assessmentStatus = .fail(hints: ["Only positive numbers are accepted in the variables"], solution: nil)
        case 0:
            page.assessmentStatus = .fail(hints: ["0 is not a good number for the frequency!", "Try something different!"], solution: nil)
        case 1..<20:
            page.assessmentStatus = .fail(hints: ["This frequency is not very interesting", "Try something bigger like 60!"], solution: nil)
        case 100...Int.max:
            page.assessmentStatus = .fail(hints: ["This frequency is too high", "Try something different!"], solution: "Try to put 60 in the frequency!")
        default:
            break
        }
        switch maxNumber {
        case -Int.max..<0:
            page.assessmentStatus = .fail(hints: ["Only positive numbers are accepted in the variables"], solution: nil)
        case 0:
            page.assessmentStatus = .fail(hints: ["0 is not a good max number of toothpicks because of no toothpicks will appear!", "Try something bigger!"], solution: nil)
        case 2300...Int.max:
            page.assessmentStatus = .fail(hints: ["The max number of toothpicks is too big!", "Try something smaller!"], solution: nil)
        default:
            break
        }

        proxy?.send(.data(try NSKeyedArchiver.archivedData(withRootObject: frequency, requiringSecureCoding: false)))
        proxy?.send(.data(try NSKeyedArchiver.archivedData(withRootObject: maxNumberOfToothPicks, requiringSecureCoding: false)))
    } else {
        page.assessmentStatus = .fail(hints: ["Please insert only integer numbers into the maxNumberOfToothPicks variable and try again!"] , solution: "Use numbers like 1000,1300,1500 for an awesome experience!")

    }
} else {
    page.assessmentStatus = .fail(hints: ["Please insert only integer numbers into the frequency variable and try again!"] , solution: "Use numbers like 60,70,80 for an awesome experience!")
}

//#-end-hidden-code
