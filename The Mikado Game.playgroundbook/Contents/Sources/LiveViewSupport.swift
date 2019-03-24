//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Provides supporting functions for setting up a live view.
//

import UIKit
import PlaygroundSupport

/// Instantiates a new instance of a live view.
///
/// By default, this loads an instance of `LiveViewController` from `LiveView.storyboard`.
public func instantiateLiveView(chapter: Int, page: Int) -> PlaygroundLiveViewable {
    //return the LiveView for the specific chapter and page
    let chapterAndPage = (chapter, page)
    var storyBoardName = "LiveView"
    switch chapterAndPage {
    case let (x , y ) where x > 0 && y > 0:
        storyBoardName = "LiveView" + "_\(x)" + "_\(y)"
        
    default:
        storyBoardName = "LiveView"
    }
    
    
    let storyboard = UIStoryboard(name: storyBoardName, bundle: nil)
    
    guard let viewController = storyboard.instantiateInitialViewController() else {
        fatalError("\(storyBoardName).storyboard does not have an initial scene; please set one or update this function")
    }
    
    guard let liveViewController = viewController as? LiveViewController else {
        fatalError("\(storyBoardName).storyboard's initial scene is not a LiveViewController; please either update the storyboard or this function")
    }
    
    return liveViewController

}
