//
//  AbstractUIChessPiece.swift
//  MammothChess
//
//  Created by Brandon Dinh on 1/2/19.
//  Copyright © 2019 htdsoft. All rights reserved.
//

import Foundation
import UIKit

class UIChessPiece: ExtensionUIChessPiece {
    init(frame: CGRect, color: UIColor, vc: ViewController, blackPieceName: String, whitePieceName: String) {
        super.init(frame: frame);
        if color == #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) {
            self.text = blackPieceName;
        } else {
            self.text = whitePieceName;
        }
        self.isOpaque = false;
        self.textColor = color;
        self.isUserInteractionEnabled = true;
        self.textAlignment = .center;
        self.font = self.font.withSize(34);
        self.lineBreakMode = .byClipping;
        vc.chessPieces.append(self);
        vc.view.addSubview(self);
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    func isMoveValid(fromIndex sourceIndex: BoardIndex, toIndex destIndex: BoardIndex, forGame chessGame: ChessGame) -> Bool {
        return true;
    }
    
    func isThereMiddlePiece(fromIndex sourceIndex: BoardIndex, toIndex destIndex: BoardIndex, forGame chessGame: ChessGame) -> Bool{
        let diffRow = destIndex.row - sourceIndex.row
        let diffCol = destIndex.col - sourceIndex.col
        // Is there any piece in the middle
        let rowSign = diffRow == 0 ? 0 : (diffRow < 0 ? -1 : 1);
        let colSign = diffCol == 0 ? 0 : (diffCol < 0 ? -1 : 1);
        
        var rowIdx = sourceIndex.row;
        var colIdx = sourceIndex.col;
        rowIdx += rowSign;
        colIdx += colSign;
        while ((rowIdx != destIndex.row || diffRow == 0) && (colIdx != destIndex.col || diffCol == 0)) {
            if !(chessGame.theChessBoard.board[rowIdx][colIdx] is Dummy) {
                return true;
            }
            rowIdx += rowSign;
            colIdx += colSign;
        }
        return false;
    }
    
}
