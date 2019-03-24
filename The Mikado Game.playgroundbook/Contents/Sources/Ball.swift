//
//  Ball.swift
//  LiveViewTestApp
//
//  Created by Raffaele on 23/03/2019.
//

import Foundation
import UIKit
import ARKit

public class Ball: SCNNode {
    
    var firstPosition : SCNVector3!
    var time: TimeInterval!
    var direction : SCNVector3!
    
    init(firstPosition: SCNVector3, direction: SCNVector3) {
        super.init()
        self.firstPosition = firstPosition
        self.direction = direction
        createBall()
        time = Date().timeIntervalSince1970
        self.position = firstPosition
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func createBall(){
        
        let geometry = SCNSphere(radius: 0.01)
        geometry.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "woodTexture")
        self.geometry = geometry
        self.position = firstPosition
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        self.physicsBody?.contactTestBitMask = 0
        self.physicsBody?.isAffectedByGravity = false
        
    }
    
    public func move() -> Bool {
        self.position = SCNVector3(self.position.x + direction.x,self.position.y + direction.y,self.position.z + direction.z) // speed of the ball
        let distance = SCNVector3( position.x - firstPosition.x , position.y - firstPosition.y,position.z - firstPosition.z )
        let x = distance.x
        let y = distance.y
        let z = distance.z
        let lenght = sqrtf(x*x + y*y + z*z)
        if lenght > 0.3 {
            return false
        }
        return true
    }
    
    
    
}
