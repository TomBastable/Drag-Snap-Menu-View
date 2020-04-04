//
//  DraggableView.swift
//  Draggable View
//
//  Created by Tom Bastable on 03/04/2020.
//  Copyright © 2020 Tom Bastable. All rights reserved.
//

import UIKit

class DraggableView: UIView {
    
    //MARK: - Properties
    @IBOutlet var draggablePoint: UIView!
    //set the margin for the draggable point of the view when it's in its closed state
    private let margin:CGFloat = 30.0
    //after initialisation this will contain the closed state frame.
    private var closedFrame:CGRect?
    //after initialisation this will contain the open state frame.
    private var openFrame:CGRect?
    //boolean value that contains the current state of the draggable view
    var isOpen:Bool = false
        
    //MARK: - Init DraggableView
    ///This initialises your draggable view, and sets its frame to the bottom of the screen leaving the draggable point visible.
    func initView (){
        
        // pan gesture recogniser
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        draggablePoint.addGestureRecognizer(panGesture)
        
        //set frame of the draggable view to be at the bottom of the device screen
        //with a margin so that the draggable point of the view is visible.
        self.frame = CGRect(x: 0, y: self.superview!.bounds.height - self.draggablePoint.frame.height - margin, width: self.superview!.bounds.width, height: self.superview!.bounds.height)
        
        //set the current frame of the draggable view to the stored property 'closedFrame'
        //for easy revert
        closedFrame = self.frame
        
        //set open frame to property 'openFrame'
        openFrame = CGRect(x: 0, y: 60, width: self.frame.width, height: self.frame.height)
    }
    
    //MARK: - Handle Pan Gesture
    ///Handles the touches within the draggable view and handles the showing or closing of the draggable view.
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        
        //set the current y postion to a property
        let currentYPosition = sender.location(in: self.superview).y
        
        //safely unwrap the openframe and closedframe optionals
        guard let openFrame = self.openFrame, let closedFrame = closedFrame else{
            return
        }
        
        //while the pan gesture is active, change the current frame of the view to reflect the gestures y value
        self.frame = CGRect(x: 0, y: currentYPosition, width: self.frame.width, height: self.frame.height)
        
        //switch the gesture current state
        switch sender.state{
        
        //only interested in the ended state
        case .ended:
            //if view is open and the drag has been below the open y value, close the view, but check direction first or if idle.
            if isOpen && currentYPosition >= openFrame.origin.y{
                openOrCloseViewBasedOnDirection(sender)
            }
            //else if the view is open and the drag has been left above the open state, revert to open frame.
            else if isOpen && currentYPosition <= openFrame.origin.y{
                //return to open state
                openDraggableView()
            }
            //else if view is not open, and the current drag is higher than the closed frame, close the view - but check direction first.
            else if !isOpen && currentYPosition <= closedFrame.origin.y{
                openOrCloseViewBasedOnDirection(sender)
            }
            //else if is below the closed frame, revert to closed state
            else if !isOpen && currentYPosition >= closedFrame.origin.y{
                //return to closed state
                closeDraggableView()
            }
        default:
            print("Other state detected.")
        }
    }
    //MARK: - Open Draggable View
    ///Call this function to open the draggable view
    func openDraggableView(){
        //animate with spring, for a bit of bounce
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: UIView.AnimationOptions.curveEaseInOut, animations: { () -> Void in
            //unwrap optional openframe property
            guard let openFrame = self.openFrame else{
                return
            }
            //set the frame
            self.frame = openFrame
        }, completion: { (finished) -> Void in
            //once finished, change the isOpen bool to reflect
            self.isOpen = true
        })
    }
    
    //MARK: - Close Draggable View
    ///Call this function to close the draggable view
    func closeDraggableView(){
        //animate with spring, for a bit of bounce
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: UIView.AnimationOptions.curveEaseInOut, animations: { () -> Void in
            //unwrap optional openframe property
            guard let closedFrame = self.closedFrame else{
                return
            }
            //set the frame
            self.frame = closedFrame
        }, completion: { (finished) -> Void in
            //once finished, change the isOpen bool to reflect
            self.isOpen = false
        })
    }
    
    //MARK: - Open / Close View Based On Direction
    ///Private function only used internally in the draggableview. Determines if the view should open or close based on  direction or inactivity (If the gesture was inactive when released, it will close if the view was below half way or open if it was above..
    private func openOrCloseViewBasedOnDirection(_ gestureRecogniser: UIPanGestureRecognizer){
        
        //set the y position of the gesture
        let currentYPosition = gestureRecogniser.location(in: self.superview).y
        
        //switch between the possible vertical direction states
        switch gestureRecogniser.verticalDirection(target: self) {
           
            
        case .Down:
            closeDraggableView()
        case .Up:
            openDraggableView()
        case .None:
            //no activity, determine if the view was above or below the center and close / open accordingly. allow for draggable zone.
            if currentYPosition + draggablePoint.frame.height > self.superview!.center.y{
                closeDraggableView()
            }else{
                openDraggableView()
            }
        }
    }
}

extension UIPanGestureRecognizer {

    enum GestureDirection {
        case Up
        case Down
        case None
    }

    func verticalDirection(target: UIView) -> GestureDirection {
        if self.velocity(in: target).y == 0{
            return .None
        }
        return self.velocity(in: target).y > 0 ? .Down : .Up
    }


}
