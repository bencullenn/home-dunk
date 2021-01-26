//
//  LiveGameViewController.swift
//  Home-Dunk
//
//  Created by Ben Cullen on 1/23/21.
//

import UIKit

class LiveGameViewController: UIViewController {
    var opponent = ""
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var opponentScoreLabel: UILabel!
    @IBOutlet weak var userScoreLabel: UILabel!
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var startButtonLabel: UIButton!
    
    var timer = Timer()
    var activeGame: Bool = false
    let timerLength: Double = 30
    var seconds: Int
    var userScore: Int = 0
    var opponentScore: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        opponentLabel.text = "\(opponent)'s Score"
    }

    
    required init?(coder: NSCoder) {
        self.seconds = Int(timerLength)
        super.init(coder: coder)
    }
    
    
    @IBAction func startGame(_ sender: Any) {
        if(activeGame == true){
            endGame()
        } else {
            startGame()
        }
    }
    
    func updateInterface(timer:Timer){
        //Decrement seconds
        seconds -= 1
        //Update seconds label
        timerLabel.text = String(seconds)
        
        //Simulate the opponent's score
        //FIXME so that doesn't update the score less than 1 second apart
        if(seconds % 3 == 0){
            updateOpponentScore()
        }
        
        if(seconds <= 0){
            endGame()
            //Show score
            displayScore()
        }
        
        userScore = hoopBot?.getScore() ?? 0
        userScoreLabel.text = String(userScore)
    }
    
    func updateOpponentScore(){
        // Randomly updates score of opponent
        if(Bool.random()){
            opponentScore += 1
            opponentScoreLabel.text = String(opponentScore)
        }
    }
    
    func endGame(){
        //If game is actively running
        print("Stopping Game...")
        startButtonLabel.setTitle("Start Game", for: .normal)
        //Invalidates timer
        timer.invalidate()
        //Resets timer label to length
        timerLabel.text = String(Int(timerLength))
        //Reset score label
        userScoreLabel.text = "0"
        
        //End game on robot
        hoopBot?.endGame()
        
        activeGame = false;
    }
    
    func startGame(){
        //If game is not actively running
        print("Starting Game...")
        startButtonLabel.setTitle("End Game", for: .normal)
        seconds = Int(timerLength)
        
        //Starts timer on device
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: updateInterface(timer:))
        //Sends signal to robot to start motion
        hoopBot?.startGame()
        //Starts listening for and computing score
        activeGame = true;
    }
    
    func displayScore(){
        let message = "Tap share to share your score with friends!"
        
        var title = ""
        
        if (userScore > opponentScore){
            // User Won
            title = "You beat \(opponent) with your score of \(userScore)"
        } else if (userScore == opponentScore) {
            // User tied
            title = "You and \(opponent) tied with a score of \(userScore)"
        } else {
            // User Lost
            title = "Final Score:\(userScore)"
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let shareAction = UIAlertAction(title: "Share", style: .default, handler: { x -> Void in

            let firstActivityItem = "I just scored \(self.userScore) on Home Dunk!"
             //let secondActivityItem : NSURL = NSURL(string: "http//:urlyouwant")!

             // If you want to put an image
             //let image : UIImage = UIImage(named: "Home_Dunk_Logo.jpg")!

             let activityViewController : UIActivityViewController = UIActivityViewController(
                        activityItems: [firstActivityItem], applicationActivities: nil)

             // Anything you want to exclude
             activityViewController.excludedActivityTypes = [
                UIActivity.ActivityType.postToWeibo,
                UIActivity.ActivityType.print,
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.addToReadingList,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToTencentWeibo
              ]

            self.present(activityViewController, animated: true, completion: nil)
         })

        alertController.addAction(shareAction)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
