//
//  SlidingTabbedMenuView.swift
//  SlidingTabBar
//
//  Created by Mike on 6/24/15.
//  Copyright © 2015 Mike Perry. All rights reserved.
//

import UIKit

protocol SlidingTabbedMenuViewDelegate : NSObjectProtocol {
    func tabbedMenuView(tabbedMenu: SlidingTabbedMenuView, didEndDragging velocity: CGPoint)
    func tabbedMenuViewDidBeginDragging(tabbedMenu: SlidingTabbedMenuView)
}

class SlidingTabbedMenuView: UIView {

    weak var delegate: SlidingTabbedMenuViewDelegate?
    private var tracker: CGFloat!
    
    var tabBar: UITabBar = UITabBar()
    var tableView: UITableView = UITableView()
    

    private var panGesture: UIPanGestureRecognizer!
    
    var verticalLimit: CGFloat {
        get {
            guard let superViewHeight = superview?.frame.height else {
                return CGFloat.max
            }
            return superViewHeight * 0.55
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    func setUp() {
        panGesture = UIPanGestureRecognizer(target: self, action: "didPan:")
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = true
        addGestureRecognizer(panGesture)
        configureSubViews()
        
    }
    
    func configureSubViews() {
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tabBar)
        let tabBarLeadingConstraint = NSLayoutConstraint(item: tabBar, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        let tabBarTrailingConstraint = NSLayoutConstraint(item: tabBar, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        let tabBarTopConstraint = NSLayoutConstraint(item: tabBar, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        
        addConstraints([tabBarLeadingConstraint, tabBarTrailingConstraint, tabBarTopConstraint])
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        let tableViewTopConstaint = NSLayoutConstraint(item: tableView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: tabBar, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let tableViewLeadingConstraint = NSLayoutConstraint(item: tableView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        let tableViewTrailingConstraint = NSLayoutConstraint(item: tableView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        let tableViewBottomConstraint = NSLayoutConstraint(item: tableView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        
        addConstraints([tableViewTopConstaint, tableViewLeadingConstraint, tableViewTrailingConstraint, tableViewBottomConstraint])
        
        
    }
    
    func didPan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(superview)
        
        switch recognizer.state {
            case .Began:
                tracker = frame.origin.y
                delegate?.tabbedMenuViewDidBeginDragging(self)
            case .Changed:
                if hasExceededVerticalLimit(frame.origin.y) {
                    tracker! += translation.y
                    let logValue = logValueForYPosition(tracker)
                    frame.origin.y = verticalLimit * logValue
                } else {
                    frame.origin.y += translation.y
                }
                print("Top is at \(frame.origin.y)")
            case .Ended:
                var velocity = recognizer.velocityInView(superview)
                velocity.x = 0
                delegate?.tabbedMenuView(self, didEndDragging: velocity)
            default:
                break
        }
        recognizer.setTranslation(CGPointZero, inView: superview)
    }
    
    func hasExceededVerticalLimit(yPosition: CGFloat) -> Bool {
        return yPosition < verticalLimit
    }
    
    func logValueForYPosition(yPosition: CGFloat) -> CGFloat {
        let difference = verticalLimit - yPosition //how far past the vertical limit is yPosition?
        let position = verticalLimit + difference //calculate the exact position
        let ratio = position / verticalLimit //a value greater than zero, assuming the user has pulled the pane above the vertical limit
        let log10Value = log10(ratio)
        return 1 - log10Value
    }
}

extension SlidingTabbedMenuView : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //allow tab bar and tableview gestures priority
        if gestureRecognizer == panGesture && (otherGestureRecognizer is UITapGestureRecognizer || otherGestureRecognizer is UIPanGestureRecognizer) {
            return false
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
