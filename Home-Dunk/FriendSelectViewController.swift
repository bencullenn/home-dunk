//
//  FriendSelectViewController.swift
//  Home-Dunk
//
//  Created by Ben Cullen on 1/23/21.
//

import Foundation
import UIKit

class FriendSelectViewController: UITableViewController {

    private var friends: [String] = ["Andre", "Austin", "Bradley", "Daniel", "Tim"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell")!
        let friend = friends[indexPath.row]
        cell.textLabel?.text = "Play \(friend)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = friends[indexPath.row]
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "LiveGameVC") as! LiveGameViewController
        vc.opponent = friend
        show(vc, sender: self)
    }

}
