//
//  SlidingUITabBarController.swift
//  SlidingTabBar
//
//  Created by Mike on 6/19/15.
//  Copyright © 2015 Mike Perry. All rights reserved.
//

import UIKit

class SlidingUITabBarController: UITabBarController {
    enum PaneState {
        case Open
        case Closed
    }
    var paneState: PaneState = PaneState.Closed
    private var originalBounds = CGRect.zeroRect
    private var originalCenter = CGPoint.zeroPoint
    
    private var animator: UIDynamicAnimator!
    private var attachmentBehavior: UIAttachmentBehavior!
    private var pushBehavior: UIPushBehavior!
    private var paneBehavior: PaneBehavior?
    private var panGesture: UIPanGestureRecognizer!
    
    private var targetPoint: CGPoint {
        get {
            let size = self.view.bounds.size
            let ret = self.paneState == PaneState.Open ? CGPoint(x: size.width / 2, y: 300) : CGPoint(x: size.width / 2, y: size.height - tabBar.frame.size.height / 2)
            return ret
        }
    }
    
    private var menuContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        panGesture = UIPanGestureRecognizer(target: self, action: "handleTabBarDrag:")
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = true
        self.tabBar.addGestureRecognizer(panGesture)

        
        animator = UIDynamicAnimator(referenceView: view)
        originalBounds = tabBar.frame
        originalCenter = tabBar.center
        
        let frame = CGRect(origin: CGPoint(x: 0, y: view.frame.size.height), size: view.frame.size)
        menuContainer = UIView(frame: frame)
        
        let tableViewController = MenuTableViewController()
        tableViewController.view.frame = menuContainer.bounds
        menuContainer.addSubview(tableViewController.view)
        tableViewController.didMoveToParentViewController(self)
        view.addSubview(menuContainer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func animatePanelWithInitialVelocity(initialVelocity: CGPoint) {
        if paneBehavior == nil {
            paneBehavior = PaneBehavior(item: tabBar)
        }
        paneBehavior!.targetPoint = targetPoint
        paneBehavior!.velocity = initialVelocity
        //attach the menu container to the tab bar
        let menuBehavior = UIAttachmentBehavior(item: tabBar, attachedToItem: menuContainer)
        animator.addBehavior(menuBehavior)
        animator.addBehavior(paneBehavior!)
    }
    
    func handleTabBarDrag(sender: UIPanGestureRecognizer) {
        let point = sender.translationInView(tabBar.superview!)
        tabBar.center = CGPoint(x: tabBar.center.x, y: tabBar.center.y + point.y)
        sender.setTranslation(CGPoint.zeroPoint, inView: tabBar.superview)
        if sender.state == UIGestureRecognizerState.Ended {
            print("pan gesture ended")
            var velocity = sender.velocityInView(view)
            velocity.x = 0
            //endedDragging with velocity
            let targetState: PaneState = velocity.y >= 0 ? PaneState.Closed : PaneState.Open
            paneState = targetState
            animatePanelWithInitialVelocity(velocity)
        } else if sender.state == UIGestureRecognizerState.Began {
            //began dragging
            print("pan gesture began")
            self.animator.removeAllBehaviors()
        } else if sender.state == UIGestureRecognizerState.Changed {
            print("pan gesture changed")
            menuContainer.frame = CGRect(x: 0, y: tabBar.frame.origin.y + tabBar.frame.size.height, width: menuContainer.frame.width, height: menuContainer.frame.height)
        }
        
    }
}

extension SlidingUITabBarController : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture && otherGestureRecognizer is UITapGestureRecognizer {
            return false
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
