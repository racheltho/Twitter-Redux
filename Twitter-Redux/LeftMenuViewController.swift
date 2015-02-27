//
//  LeftMenuViewController.swift
//  Twitter-Redux
//
//  Created by Rachel Thomas on 2/26/15.
//  Copyright (c) 2015 Rachel Thomas. All rights reserved.
//

import UIKit

protocol LeftMenuViewControllerDelegate {
    func cellSelected(menuItem: NSString)
}

class LeftMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var delegate: LeftMenuViewControllerDelegate?
    
    let menuItems: NSArray = ["Timeline", "Profile", "Settings"]
    
    override func viewDidLoad() {
        println("leftmenu loaded")
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.reloadData()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menucell") as MenuCell
        cell.itemLabel.text = menuItems[indexPath.row] as NSString
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.cellSelected(menuItems[indexPath.row] as NSString)
        println(menuItems[indexPath.row])
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
