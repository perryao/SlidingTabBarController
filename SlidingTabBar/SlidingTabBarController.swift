//
//  SlidingUITabBarController.swift
//  SlidingTabBar
//
//  Created by Mike on 6/19/15.
//  Copyright © 2015 Mike Perry. All rights reserved.
//

import UIKit

private protocol MenuTableViewControllerDelegate: NSObjectProtocol {
    func menuTableViewController(menuViewController: UIViewController, didSelectMenuItemAtIndexPath indexPath: NSIndexPath)
}

class SlidingTabBarController: UIViewController {
    
    enum PaneState {
        case Open
        case Closed
    }
    
    var paneState: PaneState = PaneState.Closed
    var tabBar: UITabBar = UITabBar()
    private(set) var viewControllers: [UIViewController]?
    private var moreViewControllers: [UIViewController]?
    
    private var originalBounds: CGRect!
    private var originalCenter: CGPoint!
    
    private var animator: UIDynamicAnimator!
    private var attachmentBehavior: UIAttachmentBehavior!
    private var paneBehavior: PaneBehavior?
    
    private var panGesture: UIPanGestureRecognizer!
    
    
    private var contentView: UIView = UIView()
    private var menuTableViewController: MenuTableViewController = MenuTableViewController()
    
    
    private var targetPoint: CGPoint {
        get {
            let size = view.bounds.size
            let ret = paneState == PaneState.Open ? CGPoint(x: size.width / 2, y: 300) : CGPoint(x: size.width / 2, y: size.height - tabBar.frame.size.height / 2)
            return ret
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func setViewControllers(viewControllers: [UIViewController]!, animated: Bool ) {
        self.viewControllers = Array(viewControllers[0 ..< 5]) //we only ever show 5 tabs in the tab bar
        moreViewControllers = Array(viewControllers[5 ..< viewControllers.count])
        var tabBarItems: [UITabBarItem] = []
        for viewController in self.viewControllers! {
            if let vcTabBarItem = viewController.tabBarItem {
                tabBarItems.append(vcTabBarItem)
            } else {
                let tabBarItem = UITabBarItem(title: viewController.title, image: nil, selectedImage: nil)
                tabBarItems.append(tabBarItem)
            }
        }
        tabBar.setItems(tabBarItems, animated: animated)
        
        let viewController = self.viewControllers!.first
        viewController?.view.frame = contentView.frame
        contentView.addSubview(viewController!.view!)
        viewController?.didMoveToParentViewController(self)
        menuTableViewController.menuItems = moreViewControllers
        if moreViewControllers?.count > 0 {
            configureDraggableTabBar()
        }
    }
}

//MARK: ViewController LifeCycle
extension SlidingTabBarController {
    
    func setup() {
        contentView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height - 49)
        contentView.backgroundColor = UIColor.blackColor()
        view.addSubview(contentView)
        
        view.backgroundColor = UIColor.whiteColor()
        tabBar.frame = CGRectMake(0, view.frame.size.height - 49, view.frame.size.width, 49)
        tabBar.delegate = self
        
        view.addSubview(tabBar)
    }
    
    func configureDraggableTabBar() {
        animator = UIDynamicAnimator(referenceView: view)
        
        panGesture = UIPanGestureRecognizer(target: self, action: "handleTabBarDrag:")
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = true
        tabBar.addGestureRecognizer(panGesture)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        originalBounds = tabBar.frame
        originalCenter = tabBar.center
        
        let menuFrame = CGRect(origin: CGPoint(x: 0, y: view.frame.size.height), size: view.frame.size)
        
        menuTableViewController.delegate = self
        view.addSubview(menuTableViewController.view)
        menuTableViewController.view.frame = menuFrame
        menuTableViewController.didMoveToParentViewController(self)
        
        self.tabBar.selectedItem = self.tabBar.items?.first
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillTransitionToSize(size: CGSize,
        withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        UIView.animateWithDuration(0.3) { () -> Void in
            self.tabBar.frame = CGRectMake(0, size.height - 49, size.width, 49)
            self.contentView.frame = CGRectMake(0, 0, size.width, size.height - self.tabBar.frame.size.height)
        }
    }
}

//MARK: UITabBarDelegate
extension SlidingTabBarController : UITabBarDelegate {
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if paneState == .Open {
            paneState = .Closed
            animatePanelWithInitialVelocity(CGPointZero)
        }
        guard let selectedIndex = tabBar.items?.indexOf(item)! else {
            return
        }
        
        guard let viewController = viewControllers?[selectedIndex] else {
            return
        }
        
        
        viewController.view.frame = contentView.bounds
        contentView.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
    }
}

//MARK: MenuTableViewController delegate
extension SlidingTabBarController : MenuTableViewControllerDelegate {
    func menuTableViewController(menuViewController: UIViewController, didSelectMenuItemAtIndexPath indexPath: NSIndexPath) {
        let viewController = self.moreViewControllers![indexPath.row]
        viewController.view.frame = contentView.frame
        contentView.addSubview(viewController.view!)
        viewController.didMoveToParentViewController(self)
        
        tabBar.selectedItem = nil
        if paneState == .Open {
            paneState = .Closed
            animatePanelWithInitialVelocity(CGPointZero)
        }
    }
}

//MARK: UIKit Dynamics

extension SlidingTabBarController {
    func animatePanelWithInitialVelocity(initialVelocity: CGPoint) {
        if paneBehavior == nil {
            paneBehavior = PaneBehavior(item: tabBar)
        }
        paneBehavior!.targetPoint = targetPoint
        paneBehavior!.velocity = initialVelocity
        //attach the menu container to the tab bar
        let menuBehavior = UIAttachmentBehavior(item: tabBar, attachedToItem: menuTableViewController.view)
        animator.addBehavior(menuBehavior)
        animator.addBehavior(paneBehavior!)
    }
    
    func handleTabBarDrag(sender: UIPanGestureRecognizer) {
        let point = sender.translationInView(tabBar.superview!)
        tabBar.center = CGPoint(x: tabBar.center.x, y: tabBar.center.y + point.y)
        sender.setTranslation(CGPoint.zeroPoint, inView: tabBar.superview)
        if sender.state == UIGestureRecognizerState.Ended {
            //            print("pan gesture ended")
            var velocity = sender.velocityInView(view)
            velocity.x = 0
            //endedDragging with velocity
            let targetState: PaneState = velocity.y >= 0 ? PaneState.Closed : PaneState.Open
            paneState = targetState
            animatePanelWithInitialVelocity(velocity)
        } else if sender.state == UIGestureRecognizerState.Began {
            //began dragging
            //            print("pan gesture began")
            animator.removeAllBehaviors()
        } else if sender.state == UIGestureRecognizerState.Changed {
            //            print("pan gesture changed")
            menuTableViewController.view.frame = CGRect(x: 0, y: tabBar.frame.origin.y + tabBar.frame.size.height, width: menuTableViewController.view.frame.width, height: menuTableViewController.view.frame.height)
        }
    }

}

extension SlidingTabBarController : UIGestureRecognizerDelegate {
    
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

extension SlidingTabBarController {
    private class MenuTableViewController: UITableViewController {
        
        var menuItems: [UIViewController]? {
            didSet {
                tableView.reloadData()
            }
        }
        
        private weak var delegate: MenuTableViewControllerDelegate?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Uncomment the following line to preserve selection between presentations
            // self.clearsSelectionOnViewWillAppear = false
            
            // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
            // self.navigationItem.rightBarButtonItem = self.editButtonItem()
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
            
        }
        
        override func viewDidDisappear(animated: Bool) {
            super.viewDidDisappear(animated)
            print("tableview did disappear")
        }
        
        // MARK: - Table view data source
        
        override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let count = menuItems?.count else {
                return 0
            }
            return count
        }
        
        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            let vc = menuItems![indexPath.row]
            cell.textLabel?.text = vc.title
            
            return cell
        }
        
        //MARK: Table view delegate
        
        override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.delegate?.menuTableViewController(self, didSelectMenuItemAtIndexPath: indexPath)
        }
    }
}


