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

class ContainerViewController: UIViewController, LeftMenuViewControllerDelegate, UIGestureRecognizerDelegate {

    var mainNavigationController: UINavigationController!
    var timelineViewController: TimelineViewController!
    var composerViewController: ComposerViewController!
    
    var currentState: SlideOutState = .MenuCollapsed {
        didSet {
            let shouldShowShadow = currentState != .MenuCollapsed
            showShadowForMainViewController(shouldShowShadow)
        }
    }
    
    var leftMenuViewController: LeftMenuViewController?
    
    let centerPanelExpandedOffset: CGFloat = 60
    
    func cellSelected(menuItem: NSString){
        println("\(menuItem)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("container view loaded")
        
        composerViewController = UIStoryboard.composeController()
        timelineViewController = UIStoryboard.timelineController()
        
        let storyboard = UIStoryboard(name: "Timeline", bundle: nil)
        mainNavigationController = storyboard.instantiateInitialViewController() as UINavigationController
        // composerViewController.delegate = self
        
        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        // centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(timelineViewController.view)
        addChildViewController(timelineViewController)
        
        timelineViewController.didMoveToParentViewController(self)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        timelineViewController.view.addGestureRecognizer(panGestureRecognizer)
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
            leftMenuViewController!.delegate = self
            
            view.insertSubview(leftMenuViewController!.view, atIndex: 0)
            addChildViewController(leftMenuViewController!)
            leftMenuViewController!.didMoveToParentViewController(self)
        }
    }

    func snapToRight(){
        animateCenterPanelXPosition(targetPosition: CGRectGetWidth(mainNavigationController.view.frame))
    }
    
    func animateLeftMenu(#shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .LeftMenuExpanded
            
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(mainNavigationController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .MenuCollapsed
                
                self.leftMenuViewController!.view.removeFromSuperview()
                self.leftMenuViewController = nil;
            }
        }
    }
    
    
    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.mainNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForMainViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            println("showing shadow")
            mainNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            mainNavigationController.view.layer.shadowOpacity = 0.0
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
                
                showShadowForMainViewController(true)
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
