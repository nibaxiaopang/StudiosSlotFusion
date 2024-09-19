//
//  GameScene.swift
//  StudiosSlotFusion
//
//  Created by jin fu on 2024/9/19.
//

import Foundation
import UIKit
import SceneKit

enum CollisionCategory: Int {
    case none = 0
    case bullet = 1
    case enemy = 2
    case tank = 3
}

class StuFlyGameScene: SCNScene, SCNPhysicsContactDelegate {
    
    var tankNode: SCNNode!
    var enemies: [SCNNode] = []
    
    weak var delegate: GameSceneDelegate?
    var smokeParticleSystem: SCNParticleSystem?
    
    //MARK: - init
    
    override init() {
        super.init()
        setupScene()
        setupTank()
        startEnemySpawnTimer()
        physicsWorld.contactDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - setup scene
    
    func setupScene() {
        // Create and position the camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 15)
        cameraNode.look(at: SCNVector3Zero)
        rootNode.addChildNode(cameraNode)
        
        // Create and position the omni light
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        rootNode.addChildNode(lightNode)
        
        // Create and position the ambient light
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        rootNode.addChildNode(ambientLightNode)
        
        // Create the floor
        let floor = SCNFloor()
        let floorNode = SCNNode(geometry: floor)
        
        // Set the floor position to 3 units below the scene
        floorNode.position = SCNVector3(x: 0, y: -3, z: 0)
        
        // Create the material for the floor
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIImage(named: "universeTexture") // Texture image
        floorMaterial.diffuse.wrapS = .repeat
        floorMaterial.diffuse.wrapT = .repeat
        floorMaterial.specular.contents = nil // No specular reflection
        floorMaterial.shininess = 0.0 // No shininess
        floorMaterial.transparency = 0.1
        
        // Apply the material to the floor
        floor.materials = [floorMaterial]
        floor.reflectivity = 0
        // Add the floor node to the scene
        rootNode.addChildNode(floorNode)
        
        // Set gravity to zero to prevent downward movement
        physicsWorld.gravity = SCNVector3(x: 0, y: 0, z: 0)
    }


    
    //MARK: - setup tank
    
    func setupTank(){
        
        guard let modelScene = SCNScene(named: "Jet.obj") else {
            print("Unable to load 3D model.")
            return
        }
        
        // Find the root node of the 3D model
        let modelNode = modelScene.rootNode.childNodes.first ?? SCNNode()
        
        // Set up model node position
        modelNode.position = SCNVector3(x: 0, y: 0.28, z: 0) // Adjust the position as necessary
        
        let grayMaterial = SCNMaterial()
        grayMaterial.diffuse.contents = UIColor.gray
        modelNode.geometry?.materials = [grayMaterial]
        
        let jetTextureMaterial = SCNMaterial()
            jetTextureMaterial.diffuse.contents = UIImage(named: "E-45 _col_3") // Replace with your texture image file name
            modelNode.geometry?.materials = [jetTextureMaterial]
            
        
        // Add physics body to the model node if needed
        modelNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: modelNode, options: nil))
        modelNode.physicsBody?.categoryBitMask = CollisionCategory.tank.rawValue
        modelNode.physicsBody?.contactTestBitMask = CollisionCategory.bullet.rawValue
        modelNode.physicsBody?.collisionBitMask = CollisionCategory.tank.rawValue
        
        // Adjust the model's scale
        modelNode.scale = SCNVector3(0.8, 0.8, 0.8) // Adjust as needed
        
        // Replace the old jet node with the new model
        tankNode = modelNode
        rootNode.addChildNode(tankNode)
        
        // Add blue exhaust effect to the back of the jet
        addBlueExhaustEffect(to: modelNode)
    }

    //MARK: Exhauste
    
    func addBlueExhaustEffect(to node: SCNNode) {
        let exhaustParticleSystem = createBlueExhaustParticleSystem()
        
        // Create a new node for the exhaust and attach it to the model
        let exhaustNode = SCNNode()
        exhaustNode.name = "exhaustNode" // Name the node to easily find it later
        
        // Adjust position to the back of the jet
        exhaustNode.position = SCNVector3(x: 0, y: 0.6, z: 2.7)
        
        // Rotate the particle system 90 degrees to face backward
        exhaustNode.eulerAngles = SCNVector3(x: .pi / 2, y: 0, z: 0) // Rotate 90 degrees along the X-axis

        exhaustNode.addParticleSystem(exhaustParticleSystem)
        
        // Add the exhaust node as a child of the jet node
        node.addChildNode(exhaustNode)
    }

    func createBlueExhaustParticleSystem() -> SCNParticleSystem {
        let particleSystem = SCNParticleSystem()
        
        particleSystem.particleLifeSpan = 0.1 // Shorter lifespan for fast exhaust
        particleSystem.birthRate = 300 // High birth rate for intense exhaust
        particleSystem.particleSize = 0.2 // Larger particles for visible exhaust
        particleSystem.particleVelocity = 20.0 // Fast particle speed for realistic exhaust effect
        particleSystem.particleVelocityVariation = 20.0 // Slight variation in velocity
        particleSystem.acceleration = SCNVector3(0, 100, 0) // Simulate exhaust pushing backward

        // Set up color and transparency for a blue exhaust effect
        particleSystem.particleColor = UIColor.blue // Base color of the exhaust
        particleSystem.particleColorVariation = SCNVector4(0.2, 0.2, 0.9, 0.0) // Color variation for realism
//        particleSystem.particleBlendMode = .additive // Makes the exhaust effect glow
        
        // Fade out particles as they move away from the jet
        particleSystem.particleSizeVariation = 0.05

        return particleSystem
    }



    
    //MARK: - enemy
    
    func startEnemySpawnTimer() {
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(spawnEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func spawnEnemy() {
        let enemyNode = createEnemy()
        enemies.append(enemyNode)
        rootNode.addChildNode(enemyNode)
        
        // Start enemy movement
        moveEnemy(enemyNode)
    }
    
    //MARK: - bullet
    
    func createBullet() -> SCNNode {
        // Create the bullet geometry as a sphere
        let bulletGeometry = SCNSphere(radius: 0.2)
        
        // Create the material for the bullet
        let bulletMaterial = SCNMaterial()
        bulletMaterial.diffuse.contents = UIColor.white // Base color
        bulletMaterial.emission.contents = UIColor.blue // Emission for the glowing effect
        
        // Apply the material to the bullet geometry
        bulletGeometry.firstMaterial = bulletMaterial
        
        // Create the bullet node
        let bulletNode = SCNNode(geometry: bulletGeometry)
        bulletNode.position = SCNVector3(x: tankNode.position.x, y: tankNode.position.y + 0.37, z: tankNode.position.z) // Adjust position
        
        // Add a physics body to the bullet
        bulletNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        bulletNode.physicsBody?.categoryBitMask = CollisionCategory.bullet.rawValue
        bulletNode.physicsBody?.contactTestBitMask = CollisionCategory.enemy.rawValue
        bulletNode.physicsBody?.collisionBitMask = CollisionCategory.none.rawValue
        
        // Add a fire effect to the back of the bullet
        addFireEffect(to: bulletNode)
        
        // Add a smoke trail to the back of the bullet
        addSmokeTrail(to: bulletNode)
        
        return bulletNode
    }

    // Function to add fire effect to the back of the bullet
    func addFireEffect(to node: SCNNode) {
        let fireParticleSystem = SCNParticleSystem(named: "FireEffect", inDirectory: nil) ?? createFireParticleSystem()
        
        let fireNode = SCNNode()
        fireNode.position = SCNVector3(x: 0, y: 0, z: 0.5) // Fire at the back of the bullet
        fireNode.addParticleSystem(fireParticleSystem)
        
        node.addChildNode(fireNode)
    }

    //MARK: Bullete smoke
    
    func createFireParticleSystem() -> SCNParticleSystem {
        let fireParticleSystem = SCNParticleSystem()
        fireParticleSystem.particleLifeSpan = 0.05
        fireParticleSystem.birthRate = 100
        fireParticleSystem.particleVelocity = 1
        fireParticleSystem.particleSize = 0.1
        fireParticleSystem.particleColor = #colorLiteral(red: 0.2766335227, green: 0.9929999709, blue: 1, alpha: 1)
        fireParticleSystem.particleColorVariation = SCNVector4(0.1, 0.1, 0.1, 0.0)
        fireParticleSystem.emissionDuration = 1.0
        fireParticleSystem.spreadingAngle = 10
        fireParticleSystem.acceleration = SCNVector3(0, 0, -5) // Move backward with the bullet
        
        return fireParticleSystem
    }

    // Function to add smoke trail to the back of the bullet
    func addSmokeTrail(to node: SCNNode) {
        let smokeParticleSystem = SCNParticleSystem(named: "SmokeEffect", inDirectory: nil) ?? createSmokeParticleSystem()
        
        let smokeNode = SCNNode()
        smokeNode.position = SCNVector3(x: 0, y: 0, z: 0.5) // Smoke at the back of the bullet
        smokeNode.addParticleSystem(smokeParticleSystem)
        
        node.addChildNode(smokeNode)
    }

    func createSmokeParticleSystem() -> SCNParticleSystem {
        let smokeParticleSystem = SCNParticleSystem()
        smokeParticleSystem.particleLifeSpan = 0.1
        smokeParticleSystem.birthRate = 50
        smokeParticleSystem.particleVelocity = 5
        smokeParticleSystem.particleSize = 0.05
        smokeParticleSystem.particleColor = #colorLiteral(red: 0.2766335227, green: 0.9929999709, blue: 1, alpha: 1)
        smokeParticleSystem.particleColorVariation = SCNVector4(0.1, 0.1, 0.1, 0.0)
        smokeParticleSystem.emissionDuration = 1.0
        smokeParticleSystem.spreadingAngle = 100
        smokeParticleSystem.acceleration = SCNVector3(0, 0, 0) // Move backward with the bullet
        
        return smokeParticleSystem
    }

    
    //MARK: - enemy
    
    func createEnemy() -> SCNNode {
        // Create the enemy geometry as a sphere
        let bodyGeometry = SCNSphere(radius: 1.0)
        
        // Apply an asteroid texture to the sphere
        let asteroidMaterial = SCNMaterial()
        asteroidMaterial.diffuse.contents = UIImage(named: "asteroidTexture") // Replace with your asteroid texture image
        asteroidMaterial.emission.contents = UIImage(named: "asteroidEmission") // Optional: Emission texture for glowing effect (if you have it)
        
        bodyGeometry.firstMaterial = asteroidMaterial
        
        // Create the enemy node
        let shipNode = SCNNode(geometry: bodyGeometry)
        
        // Set random position
        let randomX = Float.random(in: -50...50)
        let randomZ = Float.random(in: -50...50)
        shipNode.position = SCNVector3(randomX, 0.5, randomZ)
        
        // Add physics body
        shipNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        shipNode.physicsBody?.categoryBitMask = CollisionCategory.enemy.rawValue
        shipNode.physicsBody?.contactTestBitMask = CollisionCategory.bullet.rawValue
        shipNode.physicsBody?.collisionBitMask = CollisionCategory.none.rawValue
        shipNode.physicsBody?.isAffectedByGravity = false
        
        // Add alien ship details (wings and lights)
        addAlienShipDetails(to: shipNode)
        
        // Add fire effect to the asteroid/enemy
        
        addFireEffectNew(to: shipNode)
        
        return shipNode
    }
    
    //MARK: enemy animation
    
    func addFireEffectNew(to node: SCNNode) {
        let fireParticleSystem = createFireParticleSystemNew()
        
        let fireNode = SCNNode()
        fireNode.position = SCNVector3(0, 0, 0) // Position behind the enemy
        fireNode.addParticleSystem(fireParticleSystem)
        
        node.addChildNode(fireNode)
    }
    
    func createFireParticleSystemNew() -> SCNParticleSystem {
        let fireParticleSystem = SCNParticleSystem()
        fireParticleSystem.particleLifeSpan = 0.2
        fireParticleSystem.birthRate = 200
        fireParticleSystem.particleVelocity = 10
        fireParticleSystem.particleSize = 0.1
        fireParticleSystem.particleColor = UIColor.orange
        fireParticleSystem.particleColorVariation = SCNVector4(0.2, 0.1, 0.0, 0.0)
        fireParticleSystem.spreadingAngle = 150
        fireParticleSystem.acceleration = SCNVector3(0, 0, 0) // Simulate backward exhaust movement
        
        return fireParticleSystem
    }
    
    func addAlienShipDetails(to shipNode: SCNNode) {
        let wingGeometry = SCNBox(width: 0.1, height: 0.02, length: 1.0, chamferRadius: 0)
        wingGeometry.firstMaterial?.diffuse.contents = UIColor.gray
        
        let wingNodeLeft = SCNNode(geometry: wingGeometry)
        wingNodeLeft.position = SCNVector3(-1.0, 0, 0)
        shipNode.addChildNode(wingNodeLeft)
        
        let wingNodeRight = SCNNode(geometry: wingGeometry)
        wingNodeRight.position = SCNVector3(1.0, 0, 0)
        shipNode.addChildNode(wingNodeRight)
        
        let lightNode = SCNNode()
        let light = SCNLight()
        light.type = .omni
        light.color = UIColor.cyan
        light.intensity = 1000
        lightNode.light = light
        lightNode.position = SCNVector3(0, 1.2, 0)
        shipNode.addChildNode(lightNode)
    }
    
    
    func moveEnemy(_ enemyNode: SCNNode) {
        guard let tankNode = tankNode else { return }
        
        // Calculate direction vector from enemy to tank
        let direction = SCNVector3(
            tankNode.position.x - enemyNode.position.x,
            tankNode.position.y - enemyNode.position.y,
            tankNode.position.z - enemyNode.position.z
        )
        
        // Normalize direction vector
        let length = sqrt(direction.x * direction.x + direction.y * direction.y + direction.z * direction.z)
        let normalizedDirection = SCNVector3(
            direction.x / length,
            direction.y / length,
            direction.z / length
        )
        
        // Randomize the speed of each enemy for more variety
        let speed = Float.random(in: 0.05...0.2)
        
        // Create movement action based on direction and speed
        let moveAction = SCNAction.move(by: normalizedDirection * speed, duration: 0.1)
        let repeatAction = SCNAction.repeatForever(moveAction)
        
        enemyNode.runAction(repeatAction)
    }

    //MARK: - fire bullete
    
    func fireBullet() {
        let bulletNode = createBullet()
        rootNode.addChildNode(bulletNode)
        
        let bulletDirection = SCNVector3(
            -sin(tankNode.eulerAngles.y) * 50,
            0,
            -cos(tankNode.eulerAngles.y) * 50
        )
        
        let moveBulletAction = SCNAction.move(by: bulletDirection, duration: 3.0)
        
        // Automatically remove the bullet after it has traveled its path or collides
        bulletNode.runAction(moveBulletAction) {
            bulletNode.removeFromParentNode()
        }
    }

    
    // MARK: - collition
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let (nodeA, nodeB) = (contact.nodeA, contact.nodeB)
        
        if (nodeA.physicsBody?.categoryBitMask == CollisionCategory.tank.rawValue &&
            nodeB.physicsBody?.categoryBitMask == CollisionCategory.enemy.rawValue){
            
            nodeB.removeFromParentNode()
            
            delegate?.healthSet(-1)
            
        }else if (nodeA.physicsBody?.categoryBitMask == CollisionCategory.enemy.rawValue &&
                  nodeB.physicsBody?.categoryBitMask == CollisionCategory.tank.rawValue){
            
            nodeA.removeFromParentNode()
            
            delegate?.healthSet(-1)
            
        }
        
        if (nodeA.physicsBody?.categoryBitMask == CollisionCategory.bullet.rawValue &&
            nodeB.physicsBody?.categoryBitMask == CollisionCategory.enemy.rawValue) ||
            (nodeB.physicsBody?.categoryBitMask == CollisionCategory.bullet.rawValue &&
             nodeA.physicsBody?.categoryBitMask == CollisionCategory.enemy.rawValue) {
            
            nodeA.removeFromParentNode()
            nodeB.removeFromParentNode()
            
            delegate?.didAddScore()
            
        }
    }
    
    // MARK: - Tank Control
    
    func rotateTank(to angle: Float) {
        tankNode.eulerAngles.y = angle
    }
    
}

extension SCNVector3 {
    static func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
        return SCNVector3(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }
}

protocol GameSceneDelegate: AnyObject {
    
    func didAddScore()
    func healthSet(_ h: Int)
    
}
