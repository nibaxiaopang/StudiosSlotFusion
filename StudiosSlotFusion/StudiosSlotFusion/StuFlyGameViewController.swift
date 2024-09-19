//
//  GameVC.swift
//  StudiosSlotFusion
//
//  Created by jin fu on 2024/9/19.
//

import UIKit
import SceneKit
import AudioToolbox

class StuFlyGameViewController: UIViewController {
    
    @IBOutlet weak var fireButton: UIButton!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var progHealth: UIProgressView!
    @IBOutlet weak var sldr: UISlider!
    @IBOutlet weak var lblHealth: UILabel!
    
    var scnView: SCNView!
    var gameScene: StuFlyGameScene!
    
    var timr: Timer?
    
    var health = 100.0{
        
        didSet{
            
            guard health > 1 else{
                return
            }
            
            DispatchQueue.main.async {
                
                self.progHealth.progress = Float(self.health/100)
                self.lblHealth.text = "\(self.health)"
            }
            
        }
    }
    
    var score = 0{
        
        didSet{
            
            DispatchQueue.main.async {
                
                self.lblScore.text = "COLLECTED: ♦️ \(self.score)"
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        score = 0
        health = 100
        
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3){
            
            self.scnView = SCNView(frame: self.viewMain.bounds)
            self.viewMain.addSubview(self.scnView)
            self.scnView.backgroundColor = .clear
            
            self.gameScene = StuFlyGameScene()
            
            self.gameScene.delegate = self
            
            self.scnView.scene = self.gameScene
            
            self.scnView.allowsCameraControl = true
            self.scnView.autoenablesDefaultLighting = true
            
            self.fireButton.addTarget(self, action: #selector(self.fireBullet), for: .touchUpInside)
            
            let i = UIImage(named: "steering")?.resize(toWidth: 60, height: 60)
            self.sldr.setThumbImage(i, for: .normal)
            self.sldr.setThumbImage(i, for: .highlighted)
            
            self.timr = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true, block: { _ in
                
                self.gameScene.fireBullet()
                
            })
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        timr?.invalidate()
        
    }
    
    @objc func fireBullet() {
        
        playSound(name: "fire", type: ".mp3")
        
        let numberOfBullets = 50
        let bulletInterval: TimeInterval = 0.003
        
        for i in 0..<numberOfBullets {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (bulletInterval * Double(i))) {
                
                self.gameScene.fireBullet()
                
            }
        }
    }
    
    func createThumbImage(size: CGSize, color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    @IBAction func sldrChange(_ sender: UISlider) {
        
        let val = sender.value
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
            if sender.value == val{
                self.animateSlider(to: 0.5)
            }
        }
        
        gameScene.rotateTank(to: gameScene.tankNode.eulerAngles.y - 0.5 + sender.value)
        
    }
    
    func animateSlider(to newValue: Float) {
        
        UIView.animate(withDuration: 0.4) {
            self.sldr.setValue(newValue, animated: true)
        }
    }
    
}

extension StuFlyGameViewController: GameSceneDelegate{
    
    func healthSet(_ h: Int) {
        
        health += Double(h*5)
//        playSound(name: "hit", type: ".mp3")
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
    }
    
    func didAddScore() {
        
        score += 1
        playSound(name: "scr", type: ".mp3")
        
    }
    
}
