//
//  SlidingUITabBarController.swift
//  SlidingTabBar
//
//  Created by Mike on 6/19/15.
//  Copyright © 2015 Mike Perry. All rights reserved.
//

import UIKit

//Custom segue for setting up tab controllers in storyboard
class SlidingTabBarSegue : UIStoryboardSegue {
    override func perform() {}
}

private protocol MenuTableViewControllerDelegate: NSObjectProtocol {
    func menuTableViewController(menuViewController: UIViewController, didSelectMenuItemAtIndexPath indexPath: NSIndexPath)
}

/**
* @discussion: A custom tab bar controller, which manages a tab bar as well as a hidden
*menu below the tab bar for when there are more than 5 view controllers to display.
*The menu is accessible via a pan gesture on the tab bar
*/
class SlidingTabBarController: UIViewController {
    
    enum PaneState {
        case Open
        case Closed
    }
    
    var paneState: PaneState = PaneState.Closed
    private(set) var tabBar: UITabBar = UITabBar()
    private(set) var viewControllers: [UIViewController]? //up to 5 view controllers can be stored here
    private var moreViewControllers: [UIViewController]? //the rest will be stored here
    
    private var originalBounds: CGRect!
    private var originalCenter: CGPoint!
    
    private var animator: UIDynamicAnimator!
    private var attachmentBehavior: UIAttachmentBehavior!
    private var paneBehavior: PaneBehavior?
    
    private var panGesture: UIPanGestureRecognizer!
    
    
    private var contentView: UIView = UIView()
    private var menuTableViewController: MenuTableViewController = MenuTableViewController()
    
    private var currentViewController: UIViewController! {
        didSet {
            //if the old value is equal to the new value, just return
            if let oldValue = oldValue where currentViewController == oldValue {
                return
            }
            
            //a new view controller has been set so swap out the content view
            let newView = currentViewController.view
            addChildViewController(currentViewController)
            newView.frame = contentView.frame
            contentView.addSubview(newView)
            currentViewController.didMoveToParentViewController(self)
            
            
            let oldViewController = oldValue
            guard let viewControllerToRemove = oldViewController else {
                return
            }
            //remove the previous view from the content view
            viewControllerToRemove.willMoveToParentViewController(nil)
            viewControllerToRemove.view.removeFromSuperview()
            viewControllerToRemove.removeFromParentViewController()
        }
    }
    
    
    private var targetPoint: CGPoint {
        get {
            let size = view.bounds.size
            let ret = paneState == PaneState.Open ? CGPoint(x: size.width / 2, y: verticalLimit + CGRectGetHeight(tabBar.frame)) : CGPoint(x: size.width / 2, y: size.height - tabBar.frame.size.height / 2)
            return ret
        }
    }
    
    private var verticalLimit: CGFloat {
        get {
            return view.frame.height * 0.55
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func setViewControllers(viewControllers: [UIViewController]!, animated: Bool ) {
        self.viewControllers = Array(viewControllers[0 ..< (viewControllers.count >= 5 ? 5 : viewControllers.count)]) //we only ever show 5 tabs in the tab bar
        if viewControllers.count > 5 {
            moreViewControllers = Array(viewControllers[5 ..< viewControllers.count])
        }
        tabBar.setItems(tabBarItemsForViewControllers(), animated: animated)
        
        let viewController = self.viewControllers!.first
        currentViewController = viewController
        menuTableViewController.menuItems = moreViewControllers
        if moreViewControllers?.count > 0 {
            configureDraggableTabBar()
        }
    }
    
    func addViewController(viewController: UIViewController, animated: Bool) {
        guard let _ = viewControllers else {
            self.setViewControllers([viewController], animated: animated)
            return
        }
        if viewControllers?.count < 5 {
            self.viewControllers?.append(viewController)
        } else {
            if let _ = moreViewControllers {
                self.moreViewControllers?.append(viewController)
            } else {
                self.moreViewControllers = [viewController]
                menuTableViewController.menuItems = self.moreViewControllers
                configureDraggableTabBar()
            }
        }
        
        tabBar.setItems(tabBarItemsForViewControllers(), animated: animated)
        
        guard let _ = tabBar.selectedItem else {
            
            return
        }
    }
    
    private func tabBarItemsForViewControllers() -> [UITabBarItem] {
        var tabBarItems: [UITabBarItem] = []
        for viewController in self.viewControllers! {
            if let vcTabBarItem = viewController.tabBarItem {
                tabBarItems.append(vcTabBarItem)
            } else {
                let tabBarItem = UITabBarItem(title: viewController.title, image: nil, selectedImage: nil)
                tabBarItems.append(tabBarItem)
            }
        }
        return tabBarItems
    }
    
    private func loadStoryboardControllers() {
        guard let _ = storyboard else {
            return
        }
        TryCatch.tryIt({ () -> Void in
            //try
                var counter = 0
                while (true) {
                    self.performSegueWithIdentifier("tab\(counter)", sender: self)
                    counter++
                }
            }, catchIt: { (exception) -> Void in
                //catch
                print("Caught \(exception) performingSegue")
            }) { () -> Void in
                //finally
        }
    }
}

//MARK: ViewController LifeCycle
extension SlidingTabBarController {
    
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
        
        loadStoryboardControllers()
        
        self.tabBar.selectedItem = self.tabBar.items?.first
        
        configureConstraints()
        
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
            
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier?.rangeOfString("tab") != nil {
            let destinationViewController = segue.destinationViewController
            addViewController(destinationViewController, animated: false)
        }
    }
    
    private func setup() {
        contentView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height - 49)
        contentView.backgroundColor = UIColor.blackColor()
        view.addSubview(contentView)
        
        view.backgroundColor = UIColor.whiteColor()
        tabBar.frame = CGRectMake(0, view.frame.size.height - 49, view.frame.size.width, 49)
        tabBar.delegate = self
        
        view.addSubview(tabBar)
    }
    
    private func configureDraggableTabBar() {
        animator = UIDynamicAnimator(referenceView: view)
        
        panGesture = UIPanGestureRecognizer(target: self, action: "handleTabBarDrag:")
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = true
        tabBar.addGestureRecognizer(panGesture)
    }
}

//MARK: Layout
private extension SlidingTabBarController {
    private func configureConstraints() {
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        let tabBarLeadingConstraint = NSLayoutConstraint(item: tabBar, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        let tabBarTrailingConstraint = NSLayoutConstraint(item: tabBar, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        let tabBarBottomConstraint = NSLayoutConstraint(item: tabBar, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        
        view.addConstraints([tabBarLeadingConstraint, tabBarTrailingConstraint, tabBarBottomConstraint])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let contentViewTopConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let contentViewLeadingConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        let contentViewTrailingConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        let contentViewBottomConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        
        view.addConstraints([contentViewTopConstraint, contentViewLeadingConstraint, contentViewTrailingConstraint, contentViewBottomConstraint])
        
        let menuView = menuTableViewController.view
        menuView.translatesAutoresizingMaskIntoConstraints = false
        let menuViewTopConstaint = NSLayoutConstraint(item: menuView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: tabBar, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let menuViewLeadingConstraint = NSLayoutConstraint(item: menuView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        let menuViewTrailingConstraint = NSLayoutConstraint(item: menuView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        let menuViewHeightConstraint = NSLayoutConstraint(item: menuView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        
        view.addConstraints([menuViewTopConstaint, menuViewLeadingConstraint, menuViewTrailingConstraint, menuViewHeightConstraint])
        
        
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
        currentViewController = viewController
    }
}

//MARK: MenuTableViewController delegate
extension SlidingTabBarController : MenuTableViewControllerDelegate {
    private func menuTableViewController(menuViewController: UIViewController, didSelectMenuItemAtIndexPath indexPath: NSIndexPath) {
        let viewController = self.moreViewControllers![indexPath.row]
        currentViewController = viewController
        
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
        if hasExceededVerticalLimit(tabBar.center.y) {
            tabBar.center.y = verticalLimit * logValueForYPosition(sender.locationInView(view).y)
        } else {
            tabBar.center.y += point.y
        }
        
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
    
    func hasExceededVerticalLimit(yPosition: CGFloat) -> Bool {
        return yPosition < verticalLimit
    }
    
    func logValueForYPosition(yPosition: CGFloat) -> CGFloat {
        let difference = verticalLimit - yPosition
        let position = verticalLimit + difference
        let ratio = position / verticalLimit
        let log10Value = log10(ratio)
        return 1 - log10Value
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

private extension SlidingTabBarController {
    private class MenuTableViewController: UITableViewController {
        
        var menuItems: [UIViewController]? {
            didSet {
                tableView.reloadData()
            }
        }
        
        private weak var delegate: MenuTableViewControllerDelegate?
        
        override func viewDidLoad() {
            super.viewDidLoad()
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


