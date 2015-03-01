//
//  ProfileViewController.swift
//  Twitter-Redux
//
//  Created by Rachel Thomas on 2/27/15.
//  Copyright (c) 2015 Rachel Thomas. All rights reserved.
//

import UIKit

class ProfileViewController: CenterViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var followers: UILabel!
    
    var user: User!
    var sender: NSString!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user != nil {
            nameLabel.text = user.name
            profileImage.setImageWithURL(NSURL(string: user.profileImageURL!))
            backgroundImage.setImageWithURL(NSURL(string: user.backgroundImageURL!))
            handleLabel.text = "@\(user.screenname!)"
            taglineLabel.text = user.tagline
            location.text = user.location
            following.text = "\(user.following!) Following"
            followers.text = "\(user.followers!) Followers"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func backButton(sender: AnyObject) {
        returnToMenu()
    }

    
    func returnToMenu(){
        let containerViewController = ContainerViewController()
        self.presentViewController(containerViewController, animated: true, completion: nil)
    }


}