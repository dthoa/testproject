//
//  ExtensionUIChessPiece.swift
//  MammothChess
//
//  Created by Brandon Dinh on 1/2/19.
//  Copyright © 2019 htdsoft. All rights reserved.
//

import UIKit

typealias ExtensionUIChessPiece = UILabel

extension ExtensionUIChessPiece: Piece {
    var x: CGFloat {
        get {
            return self.frame.origin.x;
        }
        set {
            self.frame.origin.x = newValue;
        }
    }
    var y: CGFloat {
        get {
            return self.frame.origin.y;
        }
        set {
            self.frame.origin.y = newValue;
        }
    }
    
    var color: UIColor {
        get {
            return self.textColor;
        }
        set {
            self.textColor = newValue;
        }
    }
    

}
