//
//  ChessGame.swift
//  MammothChess
//
//  Created by Brandon Dinh on 1/2/19.
//  Copyright © 2019 htdsoft. All rights reserved.
//

import Foundation
import UIKit

class ChessGame: NSObject {
    var theChessBoard: ChessBoard!
    var isWhiteTurn: Bool = true
    
    init(viewController: ViewController) {
        theChessBoard = ChessBoard(viewController: viewController);
    }
    
    func move(piece chessPieceToMove:  UIChessPiece, fromIndex sourceIndex: BoardIndex, toIndex destIndex: BoardIndex, toOrigin destOrgin: CGPoint) {
        let initialChessPieceFrame = chessPieceToMove.frame
        
        let pieceToRemove = theChessBoard.board[destIndex.row][destIndex.col]
        theChessBoard.remove(piece: pieceToRemove)
        
        theChessBoard.place(chessPiece: chessPieceToMove, toIndex: destIndex, toOrigin: destOrgin)
        
        theChessBoard.board[sourceIndex.row][sourceIndex.col] = Dummy(frame: initialChessPieceFrame)
    }
    
    
    func isMoveValid(piece: UIChessPiece, fromIndex sourceIndex: BoardIndex, toIndex destIndex: BoardIndex) -> Bool {
        guard isMoveOnBoard(forPieceFrom: sourceIndex, thatGoesTo: destIndex) else {
            print("MOVE IS NOT ON BOARD");
            return false;
        }
        guard isTurnColor(sameAsPiece: piece) else {
            print("WRONG TURN");
            return false;
        }
        return isNormalMoveValid(forPiece: piece, fromIndex: sourceIndex, toIndex:destIndex);
    }
    
    func makeAIMove() {
        // Assume Black is AI
        // Check if the Black is checked
        //get the white king, if possible
        if getPlayerChecked() == "White"{
            for aChessPiece in theChessBoard.vc.chessPieces{
                if aChessPiece.color == #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1){
                    
                    guard let source = theChessBoard.getIndex(forChessPiece: aChessPiece) else{
                        continue
                    }
                    
                    guard let dest = theChessBoard.getIndex(forChessPiece: theChessBoard.whiteKing) else{
                        continue
                    }
                    
                    if isNormalMoveValid(forPiece: aChessPiece, fromIndex: source, toIndex: dest){
                        move(piece: aChessPiece, fromIndex: source, toIndex: dest, toOrigin: theChessBoard.whiteKing.frame.origin)
                        print("AI: ATTACK WHITE KING")
                        return
                    }
                }
            }
        }
        
        //attack undefended white piece, if there's no check on the black king
        if getPlayerChecked() == nil{
            if didAttackUndefendedPiece(){
                print("AI: ATTACK UNDEFENDED PIECE")
                return
            }
        }
        
        var moveFound = false
        var numberOfTriesToEscapeCheck = 0
        
        searchForMoves: while moveFound == false {
            
            //get rand piece
            let randChessPiecesArrayIndex = Int(arc4random_uniform(UInt32(theChessBoard.vc.chessPieces.count)))
            let chessPieceToMove = theChessBoard.vc.chessPieces[randChessPiecesArrayIndex]
            
            guard chessPieceToMove.color == #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) else {
                continue searchForMoves
            }
            
            //get rand move
            let movesArray = getPossibleMoves(forPiece: chessPieceToMove)
            guard movesArray.isEmpty == false else {
                continue searchForMoves
            }
            
            let randMovesArrayIndex = Int(arc4random_uniform(UInt32(movesArray.count)))
            let randDestIndex = movesArray[randMovesArrayIndex]
            let destOrigin = ChessBoard.getFrame(forRow: randDestIndex.row, forCol: randDestIndex.col).origin
            
            guard let sourceIndex = theChessBoard.getIndex(forChessPiece: chessPieceToMove) else {
                continue searchForMoves
            }
            
            //simulate the move on board matrix
            let pieceTaken = theChessBoard.board[randDestIndex.row][randDestIndex.col]
            theChessBoard.board[randDestIndex.row][randDestIndex.col] = theChessBoard.board[sourceIndex.row][sourceIndex.col]
            theChessBoard.board[sourceIndex.row][sourceIndex.col] = Dummy()
            
            if numberOfTriesToEscapeCheck < 1000{
                guard getPlayerChecked() != "Black" else {
                    //undo move
                    theChessBoard.board[sourceIndex.row][sourceIndex.col] = theChessBoard.board[randDestIndex.row][randDestIndex.col]
                    theChessBoard.board[randDestIndex.row][randDestIndex.col] = pieceTaken
                    
                    numberOfTriesToEscapeCheck += 1
                    continue searchForMoves
                }
            }
            
            //undo move
            theChessBoard.board[sourceIndex.row][sourceIndex.col] = theChessBoard.board[randDestIndex.row][randDestIndex.col]
            theChessBoard.board[randDestIndex.row][randDestIndex.col] = pieceTaken
            
            //try best move, if any good one
            if didBestMoveForAI(forScoreOver: 2){
                print("AI: BEST MOVE")
                return
            }
            
            if numberOfTriesToEscapeCheck == 0 || numberOfTriesToEscapeCheck == 1000{
                print("AI: SIMPLE RANDOM MOVE")
            }
            else{
                print("AI: RANDOM MOVE TO ESCAPE CHECK")
            }
            
            move(piece: chessPieceToMove, fromIndex: sourceIndex, toIndex: randDestIndex, toOrigin: destOrigin)
            
            moveFound = true
        }
    }
    
    func getScoreForLocation(ofPiece aChessPiece: UIChessPiece) -> Int{
        
        var locationScore = 0
        
        guard let source = theChessBoard.getIndex(forChessPiece: aChessPiece) else{
            return 0
        }
        
        for row in 0..<theChessBoard.ROWS{
            for col in 0..<theChessBoard.COLS{
                if theChessBoard.board[row][col] is UIChessPiece{
                    
                    let dest = BoardIndex(row: row, col: col)
                    
                    if isNormalMoveValid(forPiece: aChessPiece, fromIndex: source, toIndex: dest, canAttackAllies: true){
                        locationScore += 1
                    }
                }
            }
        }
        
        return locationScore
    }
    
    func didBestMoveForAI(forScoreOver limit: Int) -> Bool{
        
        guard getPlayerChecked() != "Black" else {
            return false
        }
        
        var bestNetScore = -10
        var bestPiece: UIChessPiece!
        var bestDest: BoardIndex!
        var bestSource: BoardIndex!
        var bestOrigin: CGPoint!
        
        for aChessPiece in theChessBoard.vc.chessPieces{
            
            guard aChessPiece.color == #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) else {
                continue
            }
            
            guard let source = theChessBoard.getIndex(forChessPiece: aChessPiece) else {
                continue
            }
            
            let actualLocationScore = getScoreForLocation(ofPiece: aChessPiece)
            let possibleDestinations = getPossibleMoves(forPiece: aChessPiece)
            
            for dest in possibleDestinations{
                
                var nextLocationScore = 0
                
                //simulate move
                let pieceTaken = theChessBoard.board[dest.row][dest.col]
                theChessBoard.board[dest.row][dest.col] = theChessBoard.board[source.row][source.col]
                theChessBoard.board[source.row][source.col] = Dummy()
                
                nextLocationScore = getScoreForLocation(ofPiece: aChessPiece)
                
                let netScore = nextLocationScore - actualLocationScore
                
                if netScore > bestNetScore{
                    bestNetScore = netScore
                    bestPiece = aChessPiece
                    bestDest = dest
                    bestSource = source
                    bestOrigin = ChessBoard.getFrame(forRow: bestDest.row, forCol: bestDest.col).origin
                }
                
                //undo move
                theChessBoard.board[source.row][source.col] = theChessBoard.board[dest.row][dest.col]
                theChessBoard.board[dest.row][dest.col] = pieceTaken
            }
        }
        
        if bestNetScore > limit{
            move(piece: bestPiece, fromIndex: bestSource, toIndex: bestDest, toOrigin: bestOrigin)
            print("AI: BEST NET SCORE: \(bestNetScore)")
            return true
        }
        
        return false
    }
    
    func didAttackUndefendedPiece() -> Bool{
        
        loopThatTraversesChessPieces: for attackingChessPiece in theChessBoard.vc.chessPieces{
            
            guard attackingChessPiece.color == #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) else {
                continue loopThatTraversesChessPieces
            }
            
            guard let source = theChessBoard.getIndex(forChessPiece: attackingChessPiece) else {
                continue loopThatTraversesChessPieces
            }
            
            let possibleDestinations = getPossibleMoves(forPiece: attackingChessPiece)
            
            searchForUndefendedWhitePieces: for attackedIndex in possibleDestinations{
                
                guard let attackedChessPiece = theChessBoard.board[attackedIndex.row][attackedIndex.col] as? UIChessPiece else {
                    continue searchForUndefendedWhitePieces
                }
                
                for row in 0..<theChessBoard.ROWS{
                    for col in 0..<theChessBoard.COLS{
                        
                        guard let defendingChessPiece = theChessBoard.board[row][col] as? UIChessPiece, defendingChessPiece.color == #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) else {
                            continue
                        }
                        
                        let defendingIndex = BoardIndex(row: row, col: col)
                        
                        if isNormalMoveValid(forPiece: defendingChessPiece, fromIndex: defendingIndex, toIndex: attackedIndex, canAttackAllies: true){
                            continue searchForUndefendedWhitePieces
                        }
                    }
                }
                
                move(piece: attackingChessPiece, fromIndex: source, toIndex: attackedIndex, toOrigin: attackedChessPiece.frame.origin)
                return true
            }
        }
        return false
    }
    
    func getPossibleMoves(forPiece piece: UIChessPiece) -> [BoardIndex] {
        var arrayOfMoves: [BoardIndex] = []
        let source = theChessBoard.getIndex(forChessPiece: piece)!
        
        for row in 0..<theChessBoard.ROWS {
            for col in 0..<theChessBoard.COLS {
                let dest = BoardIndex(row: row, col: col)
                if isNormalMoveValid(forPiece: piece, fromIndex: source, toIndex: dest) {
                    arrayOfMoves.append(dest)
                }
            }
        }
        return arrayOfMoves
    }
    
    func isGameOver() -> Bool{
        return false;
    }
    
    func getPawnToBePromoted() -> Pawn? {
        for chessPiece in theChessBoard.vc.chessPieces {
            if let pawn = chessPiece as? Pawn {
                let pawnIndex = ChessBoard.indexOf(origin: pawn.frame.origin)
                if pawnIndex.row == 0 || pawnIndex.row == 7 {
                    return pawn
                }
            }
        }
        return nil
    }
    
    func getPlayerChecked() -> String? {
        if(self.isThereThreatForPiece(piece: self.theChessBoard.whiteKing)) {
            return "White"
        }
        if(self.isThereThreatForPiece(piece: self.theChessBoard.blackKing)) {
            return "Black"
        }
        return nil
    }
    
    func isNormalMoveValid(forPiece piece: UIChessPiece, fromIndex sourceIndex: BoardIndex, toIndex destIndex: BoardIndex, canAttackAllies: Bool = false) -> Bool {
        guard sourceIndex != destIndex else {
            print("MOVING PIECE ON ITS CURRENT POSITION");
            return false;
        }
        if(!canAttackAllies) {
            guard !isAttackingAlliedPiece(sourceChessPiece: piece, destIndex: destIndex) else {
                print("ATTACKING ALLIED PIECE");
                return false;
            }
        }
        guard piece.isMoveValid(fromIndex: sourceIndex, toIndex: destIndex, forGame: self) else {
            print("INVALID MOVE");
            return false;
        }
        
        let theKing: King! = piece.color == #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) ? self.theChessBoard.blackKing : self.theChessBoard.whiteKing;
        let dummyPiece = Dummy(frame: ChessBoard.getFrame(forRow: sourceIndex.row, forCol: sourceIndex.col))
        
        //backup dest
        let destPiece = self.theChessBoard.board[destIndex.row][destIndex.col]
        
        //simulate situation after the move
        self.theChessBoard.board[sourceIndex.row][sourceIndex.col] = dummyPiece
        self.theChessBoard.board[destIndex.row][destIndex.col] = piece;
        
        let result = !self.isThereThreatForPiece(piece: theKing)
        
        //restore the data before the simulation
        self.theChessBoard.board[sourceIndex.row][sourceIndex.col] = piece
        self.theChessBoard.board[destIndex.row][destIndex.col] = destPiece;
        
        return result
    }
    
    func isThereThreatForPiece(piece: UIChessPiece) -> Bool{
        let pieceIndex = self.theChessBoard.getIndex(forChessPiece: piece)
        if(pieceIndex == nil) {
            print("Something Wrong")
            return false;
        }
        for row in 0 ..< theChessBoard.ROWS{
            for col in 0 ..< theChessBoard.COLS{
                if let anotherPiece = self.theChessBoard.board[row][col] as? UIChessPiece {
                    if(anotherPiece.color != piece.color && anotherPiece.isMoveValid(fromIndex: BoardIndex(row: row, col: col), toIndex: pieceIndex!, forGame: self)) {
                        return true;
                    }
                }
            }
        }
        return false;
    }
    
    
    func isAttackingAlliedPiece(sourceChessPiece: UIChessPiece, destIndex: BoardIndex) -> Bool {
        let destPiece: Piece = theChessBoard.board[destIndex.row][destIndex.col]
        guard !(destPiece is Dummy) else {
            return false
        }
        
        let destChessPiece = destPiece as! UIChessPiece;
        return sourceChessPiece.color == destChessPiece.color;
    }
    
    func nextTurn() {
        isWhiteTurn = !isWhiteTurn;
    }
    
    func isTurnColor(sameAsPiece piece: UIChessPiece) -> Bool{
        if piece.color == #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) {
            if !isWhiteTurn {
                return true;
            }
        } else if isWhiteTurn {
            return true;
        }
        return false;
    }
    
    func isMoveOnBoard(forPieceFrom sourceIndex: BoardIndex, thatGoesTo destIndex: BoardIndex) -> Bool {
        if case 0 ..< theChessBoard.ROWS = sourceIndex.row {
            if case 0 ..< theChessBoard.COLS = sourceIndex.col {
                if case 0..<theChessBoard.ROWS = destIndex.row {
                    if case 0..<theChessBoard.COLS = destIndex.col {
                        return true;
                    }
                }
            }
        }
        return false;
    }
}
