//
//  Dummy.swift
//  MammothChess
//
//  Created by Brandon Dinh on 1/2/19.
//  Copyright © 2019 htdsoft. All rights reserved.
//

import Foundation
import UIKit

class Dummy: Piece {
    private var xStorage: CGFloat!;
    private var yStorage: CGFloat!;
    var x: CGFloat {
        get{
            return self.xStorage
        }
        set {
            self.xStorage = newValue;
        }
    }
    var y: CGFloat {
        get{
            return self.yStorage;
        }
        set{
            self.yStorage = newValue;
        }
    }
    init(frame: CGRect) {
        self.xStorage = frame.origin.x;
        self.yStorage = frame.origin.y;
    }
    
    init() {
        
    }
}
