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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user != nil {
//        if User.currentUser != nil {
//            let user = User.currentUser! as User
            nameLabel.text = user.name
            profileImage.setImageWithURL(NSURL(string: user.profileImageURL!))
            backgroundImage.setImageWithURL(NSURL(string: user.backgroundImageURL!))
            handleLabel.text = "@\(user.screenname!)"
            taglineLabel.text = user.tagline
            location.text = user.location
            following.text = "\(user.following!) Following"
            followers.text = "\(user.followers!) Followers"
        }

        // Do any additional setup after loading the view.
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
