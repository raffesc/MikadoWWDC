//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  An auxiliary source file which is part of the book-level auxiliary sources.
//  Provides the implementation of the "always-on" live view.
//

import UIKit
import PlaygroundSupport
import Foundation
import SceneKit
// per usare il numero neperiano
import Darwin
let e = Darwin.M_E


public class ToothPickScene : LiveViewController {
    
   
    // Variables
    
    @IBOutlet weak var sceneView: SCNView!
    var scene : SCNScene!
    let cameraNode = SCNNode()
    let camera = SCNCamera()
    let camPos = SCNVector3(x: -8, y: 12, z: 16)
    let camRot = SCNVector4(x: -0.67, y: -0.5, z: -0.14, w: 0.55)
    var selectedNode: SCNNode!
    var isFirstPlaying: Bool = true
    var colorToothPick: [ColorToothPick] = []
    var multiPlayer: Bool = true
    var count = -2
    var totalNumberOfFunctionCalled = 10000
    var zDepth: Float!
    var firstScoreValue: Int = 0
    var colorPick: ColorToothPick = ColorToothPick(image: UIImage(), score: 0, count: 0)
    var secondScoreValue: Int = 0
    var maxNumberOfToothPick: Int = 0
    var firstMove: Bool = false

    
    // MARK : Layout
    
    var suggestionText : UILabel = {
        let text = UILabel()
        text.text = "Oh no! Give the iPad to the other one"
        text.textColor = UIColor.white
        text.isHidden = true
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont.boldSystemFont(ofSize: 30.0)
        return text
    }()
    let firstScore : UILabel = {
        let text = UILabel()
        text.text = "     0     "
        text.textColor = UIColor.groundColor
        if let image = UIImage(named: "woodTexture") {
            text.backgroundColor = UIColor(patternImage: image)
        }
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont.boldSystemFont(ofSize: 50.0)
        return text
    }()
    let restartButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.groundColor
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 15.0
        button.isHidden = false
        button.setTitle(" RESTART ", for: .normal)
        if let image = UIImage(named: "refresh") {
            button.setImage(UIImage(named: "woodTexture"), for: .normal)
        }
        button.addTarget(self, action: #selector(restartButtonAction), for: .touchUpInside)
        return button
    }()
    let secondScore : UILabel = {
        let text = UILabel()
        text.text = "     0     "
        text.font = UIFont.boldSystemFont(ofSize: 50.0)
        if let image = UIImage(named: "woodTexture") {
            text.backgroundColor = UIColor(patternImage: image)
        }
        text.textColor = UIColor.white
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    var imageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "delete_close")
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    
    // MARK: Communication
    
    public override func receive(_ message: PlaygroundValue) {
        
        guard case .data(let messageData) = message else { return }
        
        if (count == -2  || count == totalNumberOfFunctionCalled * 3 ) {

            do {
                if let incomingObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(messageData) as? Int {
                    totalNumberOfFunctionCalled = incomingObject
                  
                }
            } catch let error {
                firstScore.text = "Error"
                fatalError("\(error)")
            }
            count = -1
            return
        }
        
        if (count == -1) {
            do {
                if let incomingObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(messageData) as? Bool {
                    multiPlayer = incomingObject
                    restartButtonAction()

                }
            } catch let error {
                firstScore.text = "Error"
                fatalError("\(error)")
            }
            count = count + 1
            return
        }
        
        switch count%3 {
        case 0:
            do {
                if let incomingObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(messageData) as? UIImage {
                    colorPick.image = incomingObject
                }
                count = count + 1
            } catch let error {
                
                fatalError("\(error)")
            }
            break
        case 1:
            do {
                if let incomingObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(messageData) as? Int {
                    if incomingObject < 0 {
                        colorPick.count = -incomingObject
                    } else {
                        colorPick.count = incomingObject
                    }
                    
                }
                count = count + 1
            } catch let error {
                
                fatalError("\(error)")
            }
            break
        case 2:
            do {
                if let incomingObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(messageData) as? Int {
                    
                    if incomingObject < 0 {
                        colorPick.score = -incomingObject
                    } else {
                        colorPick.score = incomingObject
                    }
                }
                count = count + 1
                colorToothPick.append(colorPick)
                createToothPick(with: colorPick.image, number: colorPick.count, score: colorPick.score)
            } catch let error {
                
                fatalError("\(error)")
            }
            break
        default:
            break
            
        }
        
        
    }

    
}


// MARK : Touches

extension ToothPickScene {
    
    /*
     * POSTCONDITION: if we select one of the toothPicks node,
     * it will be stored in selectedNode and the scene is ready to move it
     */
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        selectedNode = nil
        suggestionText.isHidden = true
        if let hit = sceneView.hitTest(touch.location(in: sceneView), options: nil).first {
            
            if hit.node.name != "floor" {
                imageView.isHidden = false
                selectedNode = hit.node
                firstMove = true
                zDepth = sceneView.projectPoint(selectedNode.position).z
                sceneView.allowsCameraControl = false
            }
        }
    }
    
    /*
     * PRECONDITION: we have selected a toothpick node
     * POSTCONDITION: the toothpick is moved, based on our movement of the touch
     */
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard selectedNode != nil else { return }
        
        for touch in touches {
            let touchPoint = touch.location(in: sceneView)
            if !imageView.isHidden {
                if touchPoint.x > imageView.center.x - 35  && touchPoint.x < imageView.center.x + 35 && touchPoint.y > imageView.center.y - 35 && touchPoint.y < imageView.center.y + 35 {
                    imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    imageView.image = UIImage(named: "delete_open")
                    
                }
            }
            selectedNode.position = sceneView.unprojectPoint(SCNVector3(x: Float(touchPoint.x), y: Float(touchPoint.y), z: zDepth))
            selectedNode.physicsBody?.isAffectedByGravity = false
        }
    }
    
    /*
     * PRECONDITION: we were selecting a toothpick node
     * POSTCONDITION: if we put the toothPick into the trash can, it will be removed and the score is updated. Otherwise it will fall down due to the gravity.
     */
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        guard selectedNode != nil else {
            return
        }
        selectedNode.physicsBody?.isAffectedByGravity = true
        let touchPoint = touch.location(in: sceneView)
        imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        imageView.image = UIImage(named: "delete_close")
        if !imageView.isHidden {
            imageView.isHidden = true
            if touchPoint.x > imageView.center.x - 35  && touchPoint.x < imageView.center.x + 35 && touchPoint.y > imageView.center.y - 35 && touchPoint.y < imageView.center.y + 35 {

                for element in colorToothPick {
                    if selectedNode.geometry?.firstMaterial!.diffuse.contents as! UIImage == element.image  {
                        
                        if multiPlayer {
                            
                            if isFirstPlaying {
                                
                                firstScoreValue = firstScoreValue + element.score
                                firstScore.text = "     \(firstScoreValue)     "
                                firstScore.textColor = UIColor.white
                                secondScore.textColor = UIColor.groundColor
                                firstMove = false
                                
                            } else {
                                
                                secondScoreValue = secondScoreValue + element.score
                                secondScore.text = "     \(secondScoreValue)     "
                                secondScore.textColor = UIColor.white
                                firstScore.textColor = UIColor.groundColor
                                firstMove = false
                                
                            }
                        } else {
                            
                            if isFirstPlaying {
                                
                                secondScoreValue = secondScoreValue + element.score
                                secondScore.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                                secondScore.text = "     \(secondScoreValue)     "
                                firstMove = false
                                
                            }
                            
                        }
                       
                    }
                    
                }
                
                selectedNode.removeFromParentNode()
                maxNumberOfToothPick = maxNumberOfToothPick - 1
                if (maxNumberOfToothPick == 0) {
                    
                    restartButton.isHidden = false
                    
                }
                
            }
        }
        
        sceneView.allowsCameraControl = true
        
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        sceneView.allowsCameraControl = true
    }
    
    
}

// MARK: Restart

extension ToothPickScene {
    
    /*
     * POSTCONDITION: the game is restarted as at the beginning
     */
    @objc func restartButtonAction() {

        let colorToothPickHelper = colorToothPick
        colorToothPick.removeAll()
        for elem in colorToothPickHelper {
            createToothPick(with: elem.image, number: elem.count, score: elem.score)
        }
        restartButton.isHidden = true
        firstScoreValue = 0
        secondScoreValue = 0
        scene = nil
        firstScore.text = "     0     "
        secondScore.text = "     0     "
        firstScore.textColor = UIColor.white
        secondScore.textColor = UIColor.groundColor
        firstScore.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        secondScore.transform = CGAffineTransform(scaleX: 1, y: 1)
        isFirstPlaying = true
        firstMove = false
        setupScene()
        
    }
    
}

// MARK: Delegate conform to Scene

extension ToothPickScene: SCNSceneRendererDelegate {
    
    /*
     * PRECONDITION: we have touched the screen at least one time
     * POSTCONDITION: if the velocity of one toothpick, different from the last one selected, the button the trash can will be hidden and if you're playing multiplayer the turn passed to the other, otherwise you lose points
     */
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if firstMove {
            for x in 0..<maxNumberOfToothPick {
                
                let node = scene.rootNode.childNode(withName: "\(x)", recursively: false)
                if node != selectedNode {
                    
                    if let velocity = node?.physicsBody?.velocity {
                        
                        if (velocity.x < -0.2 || velocity.x > 0.2) || (velocity.y < -0.2 || velocity.y > 0.2) || (velocity.z < -0.2 || velocity.z > 0.2) {
                            
                            if multiPlayer {
                                
                                if isFirstPlaying {
                                    
                                    firstScore.transform = CGAffineTransform(scaleX: 1, y: 1)
                                    secondScore.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                                    imageView.isHidden = true
                                    firstScore.textColor = UIColor.groundColor
                                    secondScore.textColor = UIColor.white
                                    suggestionText.isHidden = false
                                    
                                } else {
                                    
                                    secondScore.transform = CGAffineTransform(scaleX: 1, y: 1)
                                    firstScore.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                                    secondScore.textColor = UIColor.groundColor
                                    firstScore.textColor = UIColor.white
                                    imageView.isHidden = true
                                    suggestionText.isHidden = false
                                    
                                }
                        
                                isFirstPlaying = !isFirstPlaying
                                firstMove = false
                                return
                                
                            } else {
                                
                                if isFirstPlaying {

                                    imageView.isHidden = true
                                    suggestionText.isHidden = false
                                    
                                }
                                for element in colorToothPick {
                                    
                                    if selectedNode.geometry?.firstMaterial!.diffuse.contents as! UIImage == element.image  {
                                        
                                        secondScoreValue = secondScoreValue - element.score/2
                                        secondScore.text = "     \(secondScoreValue)     "
                                        firstMove = false
                                        return
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

// MARK : Setup

extension ToothPickScene {
    
    /*
     * POSTCONDITION: the scene is correctly set up
     */
    open func setupScene() {
        
        if !multiPlayer {
            
            firstScore.isHidden = true
            secondScore.textColor = UIColor.white
            secondScore.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            suggestionText.text = "Oh no! You lose point"
            
        } else {
            
            firstScore.isHidden = false
            suggestionText.text = "Oh no! Give the iPad to the other one"
            
        }
        if scene != nil {
            
            for elem in scene.rootNode.childNodes {
                
                elem.removeFromParentNode()
                
            }
            
        }
        firstMove = false
        scene = SCNScene()
        sceneView.delegate = self
        if #available(iOS 11.0, *) {
            
            sceneView.defaultCameraController.interactionMode = .orbitTurntable
            sceneView.defaultCameraController.maximumVerticalAngle = 60.0
            sceneView.defaultCameraController.minimumVerticalAngle = 1.0
            
        } else {
            // Fallback on earlier versions
        }
        
        sceneView.autoenablesDefaultLighting = true
        scene.physicsWorld.gravity = SCNVector3(0, -9.81, 0)
        
        setupCamera()
        createFloor()
        
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.black
        
        sceneView.isPlaying = true
        sceneView.allowsCameraControl = true
        
        self.view.addSubview(sceneView)
        sceneView.showsStatistics = true
        setupConstraints()
        
    }
    /*
     * POSTCONDITION: The coinstraints are correctly set up
     */
    func setupConstraints() {
        firstScore.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        firstScore.textColor = UIColor.white
        sceneView.addSubview(imageView)
        sceneView.addSubview(firstScore)
        sceneView.addSubview(secondScore)
        sceneView.addSubview(restartButton)
        sceneView.addSubview(suggestionText)
        NSLayoutConstraint.activate([imageView.topAnchor.constraint(equalTo: sceneView.topAnchor, constant: 70),
                                     imageView.widthAnchor.constraint(equalToConstant: 70),
                                     imageView.heightAnchor.constraint(equalToConstant: 70),
                                     imageView.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
                                     firstScore.leftAnchor.constraint(equalTo: sceneView.leftAnchor, constant: 20),
                                     secondScore.rightAnchor.constraint(equalTo: sceneView.rightAnchor, constant: -20),
                                     firstScore.topAnchor.constraint(equalTo: sceneView.topAnchor, constant: 70),
                                     secondScore.topAnchor.constraint(equalTo: sceneView.topAnchor, constant: 70),
                                     restartButton.centerYAnchor.constraint(equalTo: sceneView.centerYAnchor),
                                     restartButton.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
                                     restartButton.widthAnchor.constraint(equalToConstant: 80),
                                     restartButton.heightAnchor.constraint(equalToConstant: 80),
                                     suggestionText.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: -100),
                                     suggestionText.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor)])
        
        imageView.isHidden = true
        
    }
    /*
     * POSTCONDITION: the camera position and orientation is correctly set up
     */
    func setupCamera() {
        
        camera.zFar = 100000
        cameraNode.camera = camera
        cameraNode.position = camPos
        cameraNode.rotation = camRot
        scene.rootNode.addChildNode(cameraNode)
    }
    
}

// MARK : Create

extension ToothPickScene {
    
    /*
     * POSTCONDITION: A certain number of toothpicks is added to the scene with a specific score and image
     */
    func createToothPick(with image: UIImage, number: Int, score: Int) {
        maxNumberOfToothPick = number + maxNumberOfToothPick
        
        for x in 0..<number {
            
            guard let toothPickScene = SCNScene(named: "toothpick_correct.scn") else {
                print("error 1 ")
                return
            }
            guard let toothPickNode = toothPickScene.rootNode.childNode(withName: "toothpick", recursively: false)
                else {
                    print("error")
                    return
            }
            toothPickNode.name = "\(x)"
            toothPickNode.position = SCNVector3(0, 0, 0)
            toothPickNode.orientation = SCNQuaternion(Double(x) * 0.01, Double(x) * 0.01, 0, 1)
            if #available(iOS 11.0, *) {
                toothPickNode.simdScale = simd_float3(0.2)
            } else {
                // Fallback on earlier versions
            }
            toothPickNode.physicsBody = SCNPhysicsBody.dynamic()
            toothPickNode.geometry?.firstMaterial?.diffuse.contents = image
            toothPickNode.physicsBody?.allowsResting = true
            toothPickNode.physicsBody?.friction = 5
            toothPickNode.physicsBody?.rollingFriction = 5
            toothPickNode.physicsBody?.mass = 3
            scene.rootNode.addChildNode(toothPickNode)
            
        }
        
    }
    
    /*
     * POSTCONDITION: the floor is correctly set up
     */
    func createFloor() {
        
        let floor = SCNFloor()
        floor.reflectivity = 0
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(x: 50, y: 0, z: 50)
        floor .firstMaterial?.diffuse.contents = UIColor.groundColor
        floorNode.physicsBody = SCNPhysicsBody.static()
        floorNode.name = "floor"
        scene.rootNode.addChildNode(floorNode)
        
    }
    
}
