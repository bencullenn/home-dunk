//
//  LBGameViewController.swift
//  Home-Dunk
//
//  Created by Ben Cullen on 1/23/21.
//

import UIKit

class LBGameViewController: UIViewController {
    @IBOutlet weak var startButtonLabel: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var currentScoreLabel: UILabel!
    
    var timer = Timer()
    var activeGame: Bool = false
    let timerLength: Double = 30
    var seconds: Int
    var currentScore: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    required init?(coder: NSCoder) {
        self.seconds = Int(timerLength)
        super.init(coder: coder)
    }
    
    @IBAction func startGame(_ sender: Any) {
        if(activeGame == true){
            //If game is actively running
            print("Stopping Game...")
            startButtonLabel.setTitle("Start Game", for: .normal)
            //Invalidates timer
            timer.invalidate()
            //Resets timer label to length
            timerLabel.text = String(Int(timerLength))
            
            activeGame = false;
        } else {
            //If game is not actively running
            print("Starting Game...")
            startButtonLabel.setTitle("End Game", for: .normal)
            seconds = Int(timerLength)
            
            //Starts timer on device
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: updateSeconds(timer:))
            //Sends signal to robot to start motion
            //Starts listening for and computing score
            activeGame = true;
        }
    }
    
    func updateSeconds(timer:Timer){
        //Decrement seconds
        seconds -= 1
        //Update seconds label
        timerLabel.text = String(seconds)
        if(seconds <= 0){
            //Invalidate timer
            timer.invalidate()
            //Show score
            displayScore()
        }
    }
    
    func displayScore(){
        let alert = UIAlertController(title: "Final Score:\(currentScore)", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(alert, animated: true)
    }
    

}