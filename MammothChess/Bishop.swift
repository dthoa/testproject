//
//  Bishop.swift
//  MammothChess
//
//  Created by Brandon Dinh on 1/2/19.
//  Copyright © 2019 htdsoft. All rights reserved.
//

import Foundation
import UIKit

class Bishop: UIChessPiece {
    init(frame: CGRect, color: UIColor, vc: ViewController) {
        super.init(frame:frame, color:color, vc:vc, blackPieceName:"♝", whitePieceName:"♗");
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func isMoveValid(fromIndex sourceIndex: BoardIndex, toIndex destIndex: BoardIndex, forGame chessGame: ChessGame) -> Bool {
        if(abs(sourceIndex.row - destIndex.row) == abs(sourceIndex.col - destIndex.col)) {
            if(abs(sourceIndex.row - destIndex.row) >= 2) {
                return !self.isThereMiddlePiece(fromIndex: sourceIndex, toIndex:destIndex, forGame: chessGame);
            }
            return true
        }
        return false;
    }
    
    
}
