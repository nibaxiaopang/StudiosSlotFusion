//
//  SlotGameVC.swift
//  StudiosSlotFusion
//
//  Created by jin fu on 2024/9/19.
//

import Foundation
import UIKit
import Lottie

class StuSlotGameViewController: UIViewController {
    
    @IBOutlet weak var pickrSlot: UIPickerView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var spinButton: UIButton!
    let starAnimationView = LottieAnimationView(name: "win")

    let images = [
        UIImage(named: "fire"),
        UIImage(named: "rain"),
        UIImage(named: "snow"),
        UIImage(named: "wind"),
        UIImage(named: "rivr"),
        UIImage(named: "logo"),
        UIImage(named: "roc"),
        UIImage(named: "nat"),
    ]
    
    var score: Int = 0{
        didSet{
            scoreLabel.text = "\(score) 🎃"
        }
    }
    
    var slots: [[UIImage?]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickrSlot.delegate = self
        pickrSlot.dataSource = self
        
        for _ in 0..<3 {
            slots.append(images.shuffled())
        }
        
        score = 20
        
        starAnimationView.loopMode = .playOnce
        starAnimationView.alpha = 0
        view.addSubview(starAnimationView)
        starAnimationView.frame = UIScreen.main.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(starAnimationView)
    }
    
    func playWinAnimation() {
        starAnimationView.alpha = 1
        starAnimationView.play { completed in
            UIView.animate(withDuration: 0.5) {
                self.starAnimationView.alpha = 0
            }
        }
    }
    
    @IBAction func spinTapped(_ sender: UIButton) {
        
        var results: [UIImage?] = []
        
        for component in 0..<3 {
            let randomRow = Int.random(in: 0..<images.count * 1000)
            pickrSlot.selectRow(randomRow, inComponent: component, animated: true)
            let selectedImage = slots[component][randomRow % images.count]
            results.append(selectedImage)
        }
        
        checkForWin(results: results)
    }
    
    private func checkForWin(results: [UIImage?]) {
        
        let first = results[0]
        let second = results[1]
        let third = results[2]
        
        if first == second && second == third {
            score += 50
            showWinAnimation()
            playSound(name: "bigWin", type: "mp3")
        } else if first == second || second == third || first == third {
            score += 20
            showWinAnimation()
            playSound(name: "bigWin", type: "mp3")
        } else {
            score -= 10
        }
        
    }
    
    private func showWinAnimation() {
        
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1.0
        animation.toValue = 1.2
        animation.duration = 0.2
        animation.autoreverses = true
        animation.repeatCount = 2
        
        pickrSlot.layer.add(animation, forKey: nil)
        
        playWinAnimation()
    }
    
}


extension StuSlotGameViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return images.count * 1000
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let imageView = UIImageView(image: slots[component][row % images.count])
        
        imageView.frame.size = CGSize(width: 60, height: 60)
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        60
    }
    
}
