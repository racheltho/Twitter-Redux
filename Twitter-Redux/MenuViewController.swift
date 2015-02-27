//
//  MenuViewController.swift
//  Twitter-Redux
//
//  Created by Rachel Thomas on 2/25/15.
//  Copyright (c) 2015 Rachel Thomas. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    var timelineController: TimelineViewController!
    let menuOffset: CGFloat = 60

    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let timelineStoryboard = UIStoryboard(name: "Timeline", bundle: nil)
        let navController = timelineStoryboard.instantiateInitialViewController() as UINavigationController
        timelineController = navController.topViewController as TimelineViewController
        addChildViewController(timelineController)
        timelineController.view.frame = CGRectMake(270, 22, timelineController.view.frame.size.width, timelineController.view.frame.size.height);
        
        containerView.addSubview(timelineController.view)
        
        showShadowForTimelineController(true)
        timelineController.didMoveToParentViewController(self)
        
        // Do any additional setup after loading the view.
    }
    
    func animateMainXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.timelineController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }

    
//    func animate(#shouldExpand: Bool) {
//        if (shouldExpand) {
//            currentState = .MenuVisible
//            
//            animateMainXPosition(targetPosition: CGRectGetWidth(timelineController.view.frame) - menuOffset)
//        } else {
//            animateMainXPosition(targetPosition: 0) { finished in
//                self.currentState = .MenuHidden
//                
//                self.Controller!.view.removeFromSuperview()
//                self.leftViewController = nil;
//            }
//        }
//    }

    func showShadowForTimelineController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            println(timelineController.view)
            println(timelineController.view.layer)
            timelineController.view.layer.shadowOpacity = 0.8
        } else {
            timelineController.view.layer.shadowOpacity = 0.0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
