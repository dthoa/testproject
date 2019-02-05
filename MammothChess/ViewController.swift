//
//  ViewController.swift
//  MammothChess
//
//  Created by Brandon Dinh on 1/2/19.
//  Copyright © 2019 htdsoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lblDisplayTurnOUTLET: UILabel!
    
    @IBOutlet weak var lblDisplayCheckOUTLET: UILabel!
    
    @IBOutlet var panOUTLET: UIPanGestureRecognizer!
    
    var pieceDragged: UIChessPiece!
    var sourceOrigin: CGPoint!
    var destOrigin: CGPoint!
    var preOrigin: CGPoint!
    
    static var SPACE_FROM_LEFT_EDGE: Int = 36;
    static var SPACE_FROM_TOP_EDGE: Int = 114;
    static var TILE_SIZE: Int = 38;
    var myChessGame: ChessGame!
    var chessPieces: [UIChessPiece]!
    var isAgainstAI: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        chessPieces = []
        myChessGame = ChessGame(viewController: self);
        print("SINGLE PLAYER: \(isAgainstAI)")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pieceDragged = touches.first!.view as? UIChessPiece;
        if pieceDragged != nil {
            sourceOrigin = pieceDragged.frame.origin;
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if pieceDragged != nil {
            drag(piece: pieceDragged, usingGestureRecognizer: panOUTLET)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(pieceDragged != nil) {
            pieceDragged.frame.origin = sourceOrigin;
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if pieceDragged != nil {
            let touchLocation = touches.first!.location(in: view);
            var x = Int(touchLocation.x) - ViewController.SPACE_FROM_LEFT_EDGE;
            var y = Int(touchLocation.y) - ViewController.SPACE_FROM_TOP_EDGE;
            
            x = (x/ViewController.TILE_SIZE) * ViewController.TILE_SIZE;
            y = (y/ViewController.TILE_SIZE) * ViewController.TILE_SIZE;
            
            x += ViewController.SPACE_FROM_LEFT_EDGE;
            y += ViewController.SPACE_FROM_TOP_EDGE;
            
            destOrigin = CGPoint(x: x, y: y);
            let sourceIndex = ChessBoard.indexOf(origin: sourceOrigin);
            let destIndex = ChessBoard.indexOf(origin: destOrigin);
            
            if myChessGame.isMoveValid(piece: pieceDragged, fromIndex: sourceIndex, toIndex: destIndex ) {
                myChessGame.move(piece: pieceDragged, fromIndex: sourceIndex, toIndex: destIndex, toOrigin: destOrigin);
                
                if myChessGame.isGameOver() {
                    displayWinner()
                    return
                }
                
                if shouldPromotePawn() {
                    promptForPawnPromotion()
                } else {
                    resumeGame()
                }

                
                
            } else {
                pieceDragged.frame.origin = sourceOrigin;
            }
        }
    }
    
    func resumeGame() {
        //Display Checks, if any
        displayCheck();
        //change the turn
        myChessGame.nextTurn();
        //display turn
        updateTurnOnScreen();
        
        // make AI move if necessary
        if isAgainstAI && !myChessGame.isWhiteTurn {
            myChessGame.makeAIMove();
            
            if myChessGame.isGameOver() {
                displayWinner()
                return
            }
            if shouldPromotePawn() {
                promote(pawn: myChessGame.getPawnToBePromoted()!, into: "Queen")
            }
            
            displayCheck()
            myChessGame.nextTurn()
            updateTurnOnScreen()
        }
        
        
        
        
        
    }
    
    func displayWinner() {
        
    }
    
    func promote(pawn pawnToBePromoted: Pawn, into pieceName: String) {
        let pawnColor = pawnToBePromoted.color
        let pawnFrame = pawnToBePromoted.frame
        let pawnIndex = ChessBoard.indexOf(origin: pawnToBePromoted.frame.origin)
        myChessGame.theChessBoard.remove(piece: pawnToBePromoted)
        
        switch pieceName.lowercased() {
        case "queen":
            myChessGame.theChessBoard.board[pawnIndex.row][pawnIndex.col] = Queen(frame: pawnFrame, color: pawnColor, vc: self)
            break;
        case "knight":
            myChessGame.theChessBoard.board[pawnIndex.row][pawnIndex.col] = Knight(frame: pawnFrame, color: pawnColor, vc: self)
            break;
        case "rook":
            myChessGame.theChessBoard.board[pawnIndex.row][pawnIndex.col] = Rook(frame: pawnFrame, color: pawnColor, vc: self)
            break;
        case "bishop":
            myChessGame.theChessBoard.board[pawnIndex.row][pawnIndex.col] = Bishop(frame: pawnFrame, color: pawnColor, vc: self)
            break;

        default:
            break;
        }
    }
    
    func promptForPawnPromotion() {
        if let pawnToPromote = myChessGame.getPawnToBePromoted() {
            let box = UIAlertController(title: "Pawn Promotion", message: "Choose a Piece", preferredStyle: UIAlertController.Style.alert)
            
            //typealias handler = (action action: UIAlertAction) -> Void
            
            box.addAction(UIAlertAction(title: "Queen", style: UIAlertAction.Style.default, handler: { action in
                self.promote(pawn: pawnToPromote, into: action.title!)
                self.resumeGame()
            }))
            box.addAction(UIAlertAction(title: "Knight", style: UIAlertAction.Style.default, handler: { action in
                self.promote(pawn: pawnToPromote, into: action.title!)
                self.resumeGame()
            }))
            box.addAction(UIAlertAction(title: "Rook", style: UIAlertAction.Style.default, handler: { action in
                self.promote(pawn: pawnToPromote, into: action.title!)
                self.resumeGame()
            }))
            box.addAction(UIAlertAction(title: "Bishop", style: UIAlertAction.Style.default, handler: { action in
                self.promote(pawn: pawnToPromote, into: action.title!)
                self.resumeGame()
            }))
            
            self.present(box, animated:  true, completion: nil)
            
        }
    }
    

    func shouldPromotePawn() -> Bool {
        return (myChessGame.getPawnToBePromoted() != nil)
    }
    
    func displayCheck() {
        let playerChecked = myChessGame.getPlayerChecked()
        if playerChecked != nil {
            lblDisplayCheckOUTLET.text = playerChecked! +  " is in check!"
        } else {
            lblDisplayCheckOUTLET.text = "";
        }
    }
    
    func updateTurnOnScreen() {
        lblDisplayTurnOUTLET.text = myChessGame.isWhiteTurn ? "White's Turn" : "Black's Turn";
        lblDisplayTurnOUTLET.textColor = myChessGame.isWhiteTurn ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) ;
    }

    func drag(piece: UIChessPiece, usingGestureRecognizer gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)
        
        piece.center = CGPoint(x: translation.x + piece.center.x, y: translation.y + piece.center.y)
        
        gestureRecognizer.setTranslation(CGPoint.zero, in: view);
    }

}

