//
//  ColorToothPickAr.swift
//  MikadoGame
//
//  Created by Raffaele on 23/03/2019.
//

import Foundation
import SceneKit
import UIKit

public struct ColorToothPickAr {
    

    var position: SCNVector3
    var velocity: SCNVector3
    
    public init(position: SCNVector3, velocity: SCNVector3) {
        self.position = position
        self.velocity = velocity
    }
    
    
}
