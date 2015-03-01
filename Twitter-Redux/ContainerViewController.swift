//
//  ContainerViewController.swift
//  Twitter-Redux
//
//  Created by Rachel Thomas on 2/26/15.
//  Copyright (c) 2015 Rachel Thomas. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case MenuCollapsed
    case LeftMenuExpanded
}

class ContainerViewController: UIViewController, CenterViewControllerDelegate, LeftMenuViewControllerDelegate , UIGestureRecognizerDelegate {

    //var mainNavigationController: UINavigationController!
    var timelineViewController: TimelineViewController!
    var composerViewController: ComposerViewController!
    var profileViewController: ProfileViewController!
    var leftMenuViewController: LeftMenuViewController?
    var centerNavigationController: UINavigationController!
    var centerViewController: CenterViewController!
    
    let twitterBlue: UIColor = UIColor(red: 85/255.0, green: 172/255.0, blue: 238/255.0, alpha: 1.0)
    
    var currentState: SlideOutState = .MenuCollapsed {
        didSet {
            let shouldShowShadow = currentState != .MenuCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    let centerPanelExpandedOffset: CGFloat = 80
    
    
    //   let menuItems: NSArray = ["Timeline", "Profile", "Compose Tweet", "Settings"]
    func cellSelected(menuItem: NSString){
        println("\(menuItem)")
        switch(menuItem){
        case "Timeline":
            timelineViewController.navItem.title = "Timeline"
            timelineViewController.loadTweets()
            setCenterNavigationController(timelineViewController)
        case "Mentions":
            timelineViewController.navItem.title = "Mentions"
            timelineViewController.loadTweets()
            setCenterNavigationController(timelineViewController)
        case "Compose Tweet":
            setCenterNavigationController(composerViewController)
        case "Profile":
            let profileVCtypecast = profileViewController as ProfileViewController
            profileVCtypecast.user = User.currentUser
            
            setCenterNavigationController(profileViewController)
        default:
            break
        }
        collapseSidePanels()
    }

        
    func setCenterNavigationController(controller: CenterViewController){
        if centerViewController != nil {
            centerViewController!.view.removeFromSuperview()
            centerViewController = nil;
        }
        centerViewController = controller
        // centerViewController.delegate = self
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        centerNavigationController.navigationBar.barTintColor = twitterBlue
        centerNavigationController.navigationBar.tintColor = UIColor.whiteColor()
        centerNavigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        centerNavigationController.navigationBar.translucent = false
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        centerNavigationController.didMoveToParentViewController(self)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("container view loaded")
        composerViewController = UIStoryboard.composeController()
        timelineViewController = UIStoryboard.timelineController()
        profileViewController = UIStoryboard.profileViewController()
        setCenterNavigationController(timelineViewController)
        
    }
    
    // MARK: CenterViewController delegate methods
    
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftMenuExpanded)
        
        if notAlreadyExpanded {
            addLeftMenuViewController()
        }
        animateLeftMenu(shouldExpand: notAlreadyExpanded)
    }
   
    
    func collapseSidePanels() {
        switch (currentState) {
        case .LeftMenuExpanded:
            toggleLeftPanel()
        default:
            break
        }
    }
    
    func addLeftMenuViewController() {
        if (leftMenuViewController == nil) {
            leftMenuViewController = UIStoryboard.leftMenuViewController()! as LeftMenuViewController
            leftMenuViewController?.delegate = self //centerViewController
            println("left menu delegate: \(leftMenuViewController?.delegate)")
            view.insertSubview(leftMenuViewController!.view, atIndex: 0)
            addChildViewController(leftMenuViewController!)
            leftMenuViewController!.didMoveToParentViewController(self)
        }
    }

    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func snapToRight(){
        // animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame))
        animateCenterPanelXPosition(targetPosition: 0) { _ in
            self.currentState = .MenuCollapsed
        }
    }
    
    
    func animateLeftMenu(#shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .LeftMenuExpanded
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .MenuCollapsed
                self.leftMenuViewController!.view.removeFromSuperview()
                self.leftMenuViewController = nil;
            }
        }
    }
    
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
    // MARK: Gesture recognizer
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        // we can determine whether the user is revealing the left or right
        // panel by looking at the velocity of the gesture
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        
        switch(recognizer.state) {
        case .Began:
            if (currentState == .MenuCollapsed) {
                // If the user starts panning, and neither panel is visible
                // then show the correct panel based on the pan direction
                
                if (gestureIsDraggingFromLeftToRight) {
                    addLeftMenuViewController()
                } else {
                    snapToRight()
                }
                
                showShadowForCenterViewController(true)
            }
        case .Changed:
            // If the user is already panning, translate the center view controller's
            // view by the amount that the user has panned
            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
            // When the pan ends, check whether the left or right view controller is visible
            if (leftMenuViewController != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftMenu(shouldExpand: hasMovedGreaterThanHalfway)
            } else {
                snapToRight()
            }
        default:
            break
        }
    }
}

private extension UIStoryboard {
    
    class func leftMenuViewController() -> LeftMenuViewController? {
        let storyboard = UIStoryboard(name: "LeftMenu", bundle: nil)
        return storyboard.instantiateInitialViewController() as? LeftMenuViewController
    }

    class func profileViewController() -> ProfileViewController? {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        return storyboard.instantiateInitialViewController() as? ProfileViewController
    }
    
    class func timelineController() -> TimelineViewController? {
        let storyboard = UIStoryboard(name: "Timeline", bundle: nil)
        let navController = storyboard.instantiateInitialViewController() as UINavigationController
        return navController.topViewController as? TimelineViewController
    }
    
    class func composeController() -> ComposerViewController? {
        let storyboard = UIStoryboard(name: "Compose", bundle: nil)
        let navController = storyboard.instantiateInitialViewController() as UINavigationController
        return navController.topViewController as? ComposerViewController
    }
}
