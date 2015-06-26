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

    private(set) var viewControllers: [UIViewController]? //up to 5 view controllers can be stored here
    private var moreViewControllers: [UIViewController]? { //the rest will be stored here
        didSet {
            tableView.reloadData()
        }
    }
    
    private var animator: UIDynamicAnimator!
    private var attachmentBehavior: UIAttachmentBehavior!
    private var paneBehavior: PaneBehavior?
    
    private var contentView: UIView = UIView()
    private var containerForTabAndMenu = SlidingTabbedMenuView()
    
    private var tabBar: UITabBar {
        get {
            return containerForTabAndMenu.tabBar
        }
    }
    private var tableView: UITableView {
        get {
            return containerForTabAndMenu.tableView
        }
    }
    
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
            var ret: CGPoint
            if paneState == PaneState.Open {
                ret = CGPoint(x: size.width / 2, y: containerForTabAndMenu.verticalLimit + CGRectGetHeight(containerForTabAndMenu.frame) / 2.0)
            } else {
                ret = CGPoint(x: size.width / 2, y: size.height / 2 + CGRectGetHeight(containerForTabAndMenu.frame) - 49)
            }
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
        self.viewControllers = Array(viewControllers[0 ..< (viewControllers.count >= 5 ? 5 : viewControllers.count)]) //we only ever show 5 tabs in the tab bar
        if viewControllers.count > 5 {
            moreViewControllers = Array(viewControllers[5 ..< viewControllers.count])
        }
        tabBar.setItems(tabBarItemsForViewControllers(self.viewControllers), animated: animated)
        
        let viewController = self.viewControllers!.first
        currentViewController = viewController
        if moreViewControllers?.count > 0 {
            animator = UIDynamicAnimator(referenceView: view)
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
                animator = UIDynamicAnimator(referenceView: view)
            }
        }
        
        tabBar.setItems(tabBarItemsForViewControllers(self.viewControllers), animated: animated)
        
        guard let _ = tabBar.selectedItem else {
            
            return
        }
    }
    
    private func tabBarItemsForViewControllers(viewControllers: [UIViewController]!) -> [UITabBarItem] {
        var tabBarItems: [UITabBarItem] = []
        for viewController in viewControllers {
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
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        loadStoryboardControllers()
        
        tabBar.selectedItem = self.tabBar.items?.first
        
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
        tabBar.frame = CGRectMake(0, 0, view.frame.size.width, 49)
        tabBar.delegate = self
        
        containerForTabAndMenu.frame = CGRect(x: 0, y: view.frame.size.height - 49, width: view.frame.size.height, height: view.frame.size.height)
        containerForTabAndMenu.delegate = self
        view.addSubview(containerForTabAndMenu)
    }
}

//MARK: Layout
private extension SlidingTabBarController {
    private func configureConstraints() {
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let contentViewTopConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let contentViewLeadingConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        let contentViewTrailingConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        let contentViewBottomConstraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        
        view.addConstraints([contentViewTopConstraint, contentViewLeadingConstraint, contentViewTrailingConstraint, contentViewBottomConstraint])
        
        containerForTabAndMenu.translatesAutoresizingMaskIntoConstraints = false
        let tabBarMenuContainerLeadingConstraint = NSLayoutConstraint(item: containerForTabAndMenu, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0)
        let tabBarMenuContainerTrailingConstraint = NSLayoutConstraint(item: containerForTabAndMenu, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0)
        let tabBarMenuContainerHeightConstraint = NSLayoutConstraint(item: containerForTabAndMenu, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        let tabBarMenuContainerYConstraint = NSLayoutConstraint(item: containerForTabAndMenu, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -49)
        
        view.addConstraints([tabBarMenuContainerHeightConstraint, tabBarMenuContainerLeadingConstraint, tabBarMenuContainerTrailingConstraint, tabBarMenuContainerYConstraint])
        
        
    }
}

//MARK: UITabBarDelegate
extension SlidingTabBarController : UITabBarDelegate {
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
//        if paneState == .Open {
//            paneState = .Closed
//            animatePanelWithInitialVelocity(CGPointZero)
//        }
//        guard let selectedIndex = tabBar.items?.indexOf(item)! else {
//            return
//        }
//        
//        guard let viewController = viewControllers?[selectedIndex] else {
//            return
//        }
//        currentViewController = viewController
//        guard let tabCount = tabBar.items?.count else {
//            return
//        }
//        if tabCount >= 5 {
//            tabBar.setItems(tabBarItemsForViewControllers(self.viewControllers), animated: true)
//        }
    }
}

extension SlidingTabBarController : SlidingTabbedMenuViewDelegate {
    func tabbedMenuViewDidBeginDragging(tabbedMenu: SlidingTabbedMenuView) {
        animator.removeAllBehaviors()
    }
    
    func tabbedMenuView(tabbedMenu: SlidingTabbedMenuView, didEndDragging velocity: CGPoint) {
        //endedDragging with velocity
        let targetState: PaneState = velocity.y >= 0 ? PaneState.Closed : PaneState.Open
        paneState = targetState
        animatePanelWithInitialVelocity(velocity)
    }
}

//MARK: UIKit Dynamics

extension SlidingTabBarController {
    func animatePanelWithInitialVelocity(initialVelocity: CGPoint) {
        if paneBehavior == nil {
            paneBehavior = PaneBehavior(item: containerForTabAndMenu)
        }
        paneBehavior!.targetPoint = targetPoint
        paneBehavior!.velocity = initialVelocity
        animator.addBehavior(paneBehavior!)
    }
}

extension SlidingTabBarController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = moreViewControllers?.count else {
            return 0
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let vc = moreViewControllers![indexPath.row]
        cell.textLabel?.text = vc.title
        
        return cell
    }
}

extension SlidingTabBarController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let viewController = self.moreViewControllers![indexPath.row]
        currentViewController = viewController
        var allItems = viewControllers
        allItems!.append(currentViewController)
        tabBar.setItems(tabBarItemsForViewControllers(allItems), animated: true)
        
        tabBar.selectedItem = tabBar.items?.last
        if paneState == .Open {
            paneState = .Closed
            animatePanelWithInitialVelocity(CGPointZero)
        }
    }
}
