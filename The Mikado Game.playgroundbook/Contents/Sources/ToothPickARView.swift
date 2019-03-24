//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  An auxiliary source file which is part of the book-level auxiliary sources.
//  Provides the implementation of the "always-on" live view.
//

import UIKit
import ARKit
import SceneKit
import PlaygroundSupport

public struct PhysicsMask {
    static let playerBall = 0
    static let toothPick = 1
}


@available(iOS 11.3, *)
public class ToothPickARView: LiveViewController, ARSessionDelegate {
    
    
    // Variables
    var balls: [Ball] = []
    var timer = Timer()
    var activatedThread: Bool = false
    let updateAnimation = DispatchQueue(label: "com.raffaele.thread", qos: .background)
    var counterColorToothPick: Int = 0
    var currentPosition: SCNVector3 = SCNVector3(0,0,0)
    @IBOutlet weak var sceneArView: ARSCNView!
    var scoreValue: Int = 0
    var frequency: Int = 0
    var maxNumberToothPicks: Int = 0
    var firstSend: Bool = true
    
    // Layout
    
    let score : UILabel = {
        let text = UILabel()
        text.text = "     0     "
        text.textColor = UIColor.white
        if let image = UIImage(named: "woodTexture") {
            text.backgroundColor = UIColor(patternImage: image)
        }
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont.boldSystemFont(ofSize: 80.0)
        text.isHidden = false
        return text
    }()
    var imageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "woodViewFinder")
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    let restartButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.setImage(UIImage(named: "refresh.png"), for: .normal)
        button.isHidden = false
        button.addTarget(self, action: #selector(restartTheGame), for: .touchUpInside)
        return button
    }()
    
    
    public override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        setUpSceneArView()
        activateThread()
        updateColorToothPick()
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        sceneArView.session.pause()
        score.layer.masksToBounds = true
        score.layer.cornerRadius = 500
        
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        addTapGestureToSceneView()
        configureLighting()
        setUpConstraints()
        
    }
   
   
  
    
    public override func receive(_ message: PlaygroundValue) {

        guard case .data(let messageData) = message else { return }
        do {
            if let incomingObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(messageData) as? Int {
                
                if firstSend {
                    
                    frequency = incomingObject
                    createTimer(for: frequency)
                    firstSend = false
                    
                } else {
                    
                    maxNumberToothPicks = incomingObject
                    restartTheGame()
                    firstSend = true
                    
                }
            }
            
        } catch let error {
            
            fatalError("Error handled: \(error)")
            
        }
 
    }
    
   
    
    func createTimer(for frequency: Int) {
        
        let calculatedFrequency = Double(frequency) * 0.01
        createToothPicks()
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(calculatedFrequency), target: self, selector: #selector(createToothPicks), userInfo: nil, repeats: true)

    }
    
}

// MARK : SETUP

@available(iOS 11.3,*)
extension ToothPickARView {
    
    public func setUpConstraints() {
        
        self.view.addSubview(score)
        self.view.addSubview(restartButton)
        self.view.addSubview(imageView)
        NSLayoutConstraint.activate([score.topAnchor.constraint(equalTo: sceneArView.topAnchor, constant: 80),
                                     score.rightAnchor.constraint(equalTo: sceneArView.rightAnchor),
                                     restartButton.topAnchor.constraint(equalTo: score.bottomAnchor, constant: 40),
                                     restartButton.rightAnchor.constraint(equalTo: sceneArView.rightAnchor, constant: -80),
                                     restartButton.widthAnchor.constraint(equalToConstant: 60),
                                     restartButton.heightAnchor.constraint(equalToConstant: 60),
                                     imageView.centerXAnchor.constraint(equalTo: sceneArView.centerXAnchor),
                                     imageView.centerYAnchor.constraint(equalTo: sceneArView.centerYAnchor),
                                     imageView.widthAnchor.constraint(equalToConstant: 60),
                                     imageView.heightAnchor.constraint(equalToConstant: 60)])

    }
    
    public func setUpSceneArView() {
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = []
        if #available(iOS 12.0, *) {
            
            configuration.detectionObjects = []
            
        }
        configuration.planeDetection = [] //empty array (as opposed to .horizontal .vertical)
        sceneArView.session.run(configuration)
        sceneArView.scene.physicsWorld.contactDelegate = self
        sceneArView.delegate = self
        sceneArView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneArView.scene.physicsWorld.gravity = SCNVector3(0, -0.01, 0)
        
    }
    
}


// MARK : Tap Gesture
@available(iOS 11.3,*)
extension ToothPickARView {
    
    public func addTapGestureToSceneView() {

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detectToothPick(withGestureRecognizer:)))
        sceneArView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    func configureLighting() {
        
        sceneArView.autoenablesDefaultLighting = true
        sceneArView.automaticallyUpdatesLighting = true
        
    }
    
    /*
     * PRECONDITION: The user have tapped on the screen everywhere
     * POSTCONDITION: a ball is throw from the center
     */
    @objc func detectToothPick(withGestureRecognizer recognizer: UITapGestureRecognizer) {
        
        throwBall(from: sceneArView.pointOfView!)
        
    }
}


// MARK: Physic Contacts

@available(iOS 11.3, *)
extension ToothPickARView: SCNPhysicsContactDelegate {
   
    /*
     * PRECONDITION: there is a contact between two physicBody
     * POSTCONDITION: the score is updated correctly, the two node are removed and an effect of explotion is
     * showed
     */
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        let maskA = contact.nodeA.physicsBody!.contactTestBitMask
        let maskB = contact.nodeB.physicsBody!.contactTestBitMask
        
        switch(maskA, maskB){
            
        case (PhysicsMask.playerBall, PhysicsMask.toothPick):
            hit(node: contact.nodeB, ball: contact.nodeA as! Ball)
            updateScore(dueTo: contact.nodeB)
            contact.nodeA.removeFromParentNode()
            contact.nodeB.removeFromParentNode()
            break
        case (PhysicsMask.toothPick, PhysicsMask.playerBall):
            hit(node: contact.nodeA, ball: contact.nodeB as! Ball)
            updateScore(dueTo: contact.nodeA)
            contact.nodeA.removeFromParentNode()
            contact.nodeB.removeFromParentNode()
            break
        default:
            break
            
        }
    }
    
    /*
     * POSTCONDITION: The score is updated due to the node hit
    */
    public func updateScore(dueTo node: SCNNode) {
        
        if node.name == "stop" {
            
            scoreValue = scoreValue + 1
            score.text = "     \(scoreValue)     "
            
        } else if node.name == "moving" {
            
            scoreValue = scoreValue - 2
            score.text = "     \(scoreValue)     "
            
        }
    }
    
}

// MARK :
@available(iOS 11.3, *)
extension ToothPickARView: ARSCNViewDelegate {
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        for (_,ball) in balls.enumerated().reversed() {
            ball.move()
        }

    }

  
 
   
}

// MARK : Animation

@available(iOS 11.3, *)
extension ToothPickARView {
    
    /*
     * POSTCONDITION: the ball is removed from the array of all balls and the explode function is called
     */
    public func hit(node: SCNNode, ball: Ball) {
        explode(ball: ball,toothPick: node, rotation: ball.rotation)
//        node.removeFromParentNode()
        for (i,ballNode) in balls.enumerated().reversed() {
            if ballNode == ball {
//                ball.removeFromParentNode()
                balls.remove(at: i)
                return
            }
        }
    }
    
    /*
     * POSTCONDITION: an explotion, taken from the file "Explosion.scnp" is showed in the position of the node
     */
    public func explode(ball: Ball, toothPick: SCNNode,
                         rotation: SCNVector4) {
    
        let currentTime = Date().timeIntervalSince1970
        let deltaTime = Float(currentTime - ball.time)
        let correctPosition = SCNVector3(ball.position.x * deltaTime, ball.position.y * deltaTime, ball.position.z * deltaTime)
        let explosion =
            SCNParticleSystem(named: "Explosion.scnp", inDirectory:
                nil)!
        explosion.particleImage = toothPick.geometry?.firstMaterial?.diffuse.contents
        explosion.emitterShape = ball.geometry
        explosion.birthLocation = .surface
        
        let rotationMat = SCNMatrix4MakeRotation(rotation.w, rotation.x,
                                   rotation.y, rotation.z)
        let translationMat =  SCNMatrix4MakeTranslation(correctPosition.x, correctPosition.y,
                                      correctPosition.z)
        let transformMat = SCNMatrix4Mult(rotationMat, translationMat)
        sceneArView.scene.addParticleSystem(explosion, transform: transformMat)
    }

}


// MARK: Creation
@available(iOS 11.3, *)
extension ToothPickARView {
    
   
    /*
     * PRECONDITION: The number of toothpicks is less than the MAX number
     * POSTCONDITION: a certain number of toothpicks are added into the scene
     */
    @objc public func createToothPicks() {
        if counterColorToothPick < maxNumberToothPicks {
            for i in 0..<30 {
                
                updatePositionRandomically()
                guard let toothPickScene = SCNScene(named: "toothpick_correct.scn") else {
                    print("error 1")
                    return
                }
                guard let toothPickNode = toothPickScene.rootNode.childNode(withName: "toothpick", recursively: false)
                    else {
                        print("error")
                        return
                }
                
                toothPickNode.simdScale = float3(0.02)
                //            toothPickNode.scale = SCNVector3(0.005,0.005,0.005)
                toothPickNode.physicsBody = SCNPhysicsBody.dynamic()
                toothPickNode.physicsBody?.mass = 0.01
                toothPickNode.physicsBody?.friction = 5
                toothPickNode.physicsBody?.rollingFriction = 5

//                toothPickNode.physicsBody?.mass = 0.01
//                toothPickNode.physicsBody?.friction = 5
//                toothPickNode.physicsBody?.rollingFriction = 5
    //            toothPickNode.rotate(by: SCNQuaternion(1, 1, 1, 0.55), aroundTarget: SCNVector3(0, 0, 0))
    //            let action = SCNAction.rotateBy(x: 1, y: 1, z: 1, duration: 1)
    //            toothPickNode.runAction(action)
                
                if i < 2 {
                    toothPickNode.geometry?.firstMaterial?.diffuse.contents =  #imageLiteral(resourceName: "woodTexture2")
                } else if i < 9 {
                    toothPickNode.geometry?.firstMaterial?.diffuse.contents =  #imageLiteral(resourceName: "woodTexture5")
                } else if i < 19 {
                    toothPickNode.geometry?.firstMaterial?.diffuse.contents =  #imageLiteral(resourceName: "woodTexture4")
                } else if i < 24 {
                    toothPickNode.geometry?.firstMaterial?.diffuse.contents =  #imageLiteral(resourceName: "woodTexture5")
                } else {
                    toothPickNode.geometry?.firstMaterial?.diffuse.contents =  #imageLiteral(resourceName: "woodTexture3")
                }
//                let physicShape = SCNPhysicsShape(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0), options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
//                toothPickNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicShape)
                toothPickNode.position = SCNVector3(currentPosition.x + Float(i) * 0.001, currentPosition.y + 0.2 , currentPosition.z)
//                toothPickNode.name = "\(counterColorToothPick)"
                let action = SCNAction.rotate(by:  10 * CGFloat(Double.pi/180), around: toothPickNode.position, duration: 2)
                let repeatAction = SCNAction.repeatForever(action)
                toothPickNode.runAction(repeatAction)
                let rotateX = random(min: -10, max: 10)
                let rotateY = random(min: -10, max: 10)
                let rotateZ = random(min: -10, max: 10)
                toothPickNode.physicsBody?.contactTestBitMask = PhysicsMask.toothPick
                toothPickNode.name = "stop"
                toothPickNode.rotation = SCNVector4(rotateX, rotateY, rotateZ, 0.55)
                counterColorToothPick = counterColorToothPick + 1
                sceneArView.scene.rootNode.addChildNode(toothPickNode)
            }
            
        } else {
            restartButton.isHidden = false
        }
    }
    
}

// MARK: Update

@available(iOS 11.3, *)
extension ToothPickARView {
    /*
     * POSTCONDITION: a new random position (SCNVector3) is uploaded into a variable
     */
    @objc public func updatePositionRandomically() {
        
        let positionX = random(min: -5, max: 5)
        let positionY = random(min: -5, max: 5)
        let positionZ = random(min: -5, max: 5)
        currentPosition = SCNVector3(positionX,positionY,positionZ)
    }
    

    
}

// MARK: Restart

@available(iOS 11.3, *)
extension ToothPickARView {
    
  
    @objc public func restartTheGame() {
        activateThread()
        counterColorToothPick = 0
        
        for elem in sceneArView.scene.rootNode.childNodes {
            elem.removeFromParentNode()
        }
        restartButton.isHidden = true
        
    }
    
}


// MARK: Thread

@available(iOS 11.3, *)
extension ToothPickARView {
    public func activateThread() {
        activatedThread = true
    }
    public func deactivateThread() {
        activatedThread = false
    }
    
    /*
     * POSTCONDITION: a certain number of toothpicks are animating with an infinite rotation
     */
    public func updateColorToothPick() {
        updateAnimation.async {
            while(self.activatedThread) {
                sleep(UInt32(TIME_INTERVAL_FOR_UPDATE_ANIMATION))
//                    if !self.colorToothPicks.isEmpty {
                        for _ in 0..<5 {
                            var randomNodeNumber: Int = 0
//                            while self.colorToothPicks[randomNodeNumber] {
                                randomNodeNumber = Int(random(min: 0, max: CGFloat(self.counterColorToothPick)))
//                            }
                            var count = 0
//                            self.colorToothPicks[randomNodeNumber] = true
                            if !self.sceneArView.scene.rootNode.childNodes.isEmpty {
                                
                                for elem in self.sceneArView.scene.rootNode.childNodes {
                                    if count == randomNodeNumber {
                                        print("aaaa")
                                        elem.removeAllActions()
                                        let action = SCNAction.rotate(by: 360 * CGFloat(Double.pi/180), around: elem.position, duration: 2)
                                        let repeatAction = SCNAction.repeatForever(action)
                                        elem.runAction(repeatAction)
                                        elem.name = "moving"
                                        elem.physicsBody?.contactTestBitMask = PhysicsMask.toothPick
                                    }
                                    count = count + 1
                                }
                            }

                        }
//                    }
            }
        }
    }
    
}
// MARK: Throw Ball
@available(iOS 11.3, *)
extension ToothPickARView {
    /*
     * POSTCONDITION: the ball is thrown from the center of the ipad
     */
    public func throwBall(from node: SCNNode) {
        
        let pointOfView = sceneArView.pointOfView!
        let position = SCNVector3Make(0, 0, -0.05)
        let rightPosition: SCNVector3 = node.convertPosition(position, to: nil)
        var direction = SCNVector3(pointOfView.position.x - node.position.x, pointOfView.position.y - node.position.y,pointOfView.position.z - node.position.z)
        direction = SCNVector3(rightPosition.x - pointOfView.position.x,rightPosition.y - pointOfView.position.y , rightPosition.z - pointOfView.position.z)
        let ball = Ball(firstPosition: rightPosition, direction: direction)
        balls.append(ball)
        sceneArView.scene.rootNode.addChildNode(ball)
    }
    
    
}

// MARK : Random generator

public func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

public func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}
