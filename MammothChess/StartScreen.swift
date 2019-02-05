//
//  StartScreen.swift
//  MammothChess
//
//  Created by Brandon Dinh on 1/2/19.
//  Copyright © 2019 htdsoft. All rights reserved.
//

import Foundation
import UIKit

class StartScreen: UIViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! ViewController
        if segue.identifier == "singleplayer" {
            destVC.isAgainstAI = true
        } else if segue.identifier == "multiplayer" {
            destVC.isAgainstAI = false
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        
    }
}
