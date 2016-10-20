//
//  PromiseViewController.swift
//  Promise
//
//  Created by LeeDavid on 10/19/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import UIKit
import FacebookShare
import FBSDKShareKit


class PromiseViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate, IntervalViewControllerDelegate, DurationViewControllerDelegate {
    
    let comm = FCViewController()
    var helper: TableViewHelper!
    var promises = [Promise]()
    var promise = Promise()
    var intervalToDisplay = "Everyday"
    var durationSuffix = "s"
    var reward = ""
    
    var textFieldGoal: UITextField?
    
    
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
//    @IBAction func textFieldGoalDone(_ sender: AnyObject) {
//        print("goal set")
//    }
    
    @IBAction func textFieldRewardDone(_ sender: AnyObject) {
        print("reward set")
    }
    
    @IBAction func share(_ sender: AnyObject) {
        // SAVE TO DB
        comm.configureDatabase()
        let goal = promise.goal
        let data = ["goal": goal]
//        let uid = AppState.sharedInstance.uid
//        let uid = "JWEFfYj52fVT4uCH3MUk6jgnSsK2" // temp
//        print("THIS: " + "users/\(uid!)/promise0")
//        comm.ref.child("promises").childByAutoId().setValue(data)
        
        
        // SHARE
        let link = "https://promise-1432d.firebaseapp.com/?promiseId="
        if let uid = AppState.sharedInstance.uid {
            var content = LinkShareContent(url: URL(string: link + uid)!)
        
//        var content = LinkShareContent(url: URL(string: link + uid!)!)
            content.title = "I promise to \(promise.goal). everyday for \(promise.duration) week\(durationSuffix). Do you think I can make it? \(reward)"
    //        myContent.description = ""
            content.imageURL = URL(string: "https://promise-1432d.firebaseapp.com/static/images/defaultShare@2x.jpg")
    //        let photo = Photo(image: #imageLiteral(resourceName: "defaultShare"), userGenerated: false)
            let shareDialog = ShareDialog(content: content)
            shareDialog.mode = .automatic
            shareDialog.failsOnInvalidData = true
            shareDialog.completion = { result in
                // Handle share results
                print("SHARE: \(result)")
                // Write Data
                self.comm.ref.child("users/\(uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.hasChild("promise0")
    //                print("HASCHILD: \(value)")
                    if(value) {
                        print("UPDATE PROMISE")
                        self.comm.ref.child("users/\(uid)/promise\(self.promises.count)").updateChildValues(data)
                    } else {
                        print("NEW PROMISE")
                        self.promises.append(self.promise)
                        self.comm.ref.child("users/\(uid)/promise\(self.promises.count)").setValue(data)
                    }
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
//            try! ShareDialog.show(from: self, content: content)
            try! shareDialog.show()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        helper = TableViewHelper(tableView: tableView)
        
        // bottom table view: clear lines
        tableView.tableHeaderView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R0")! as UITableViewCell, name: "S0R0")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R1")! as UITableViewCell, name: "S0R1")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R2")! as UITableViewCell, name: "S0R2")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R3")! as UITableViewCell, name: "S0R3")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R4")! as UITableViewCell, name: "S0R4")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R5")! as UITableViewCell, name: "S0R5")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let count = helper.numberOfSections()
        return count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return helper.numberOfRowsInSection(section)
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
//        return cell
        let cell = helper.cellForRowAtIndexPath(indexPath)
        
        let cellName = helper.cellNameAtIndexPath(indexPath)
        if cellName == "S0R1" {
            // auto focus on the goal textfield
            textFieldGoal = cell.viewWithTag(1000) as! UITextField
            textFieldGoal?.delegate = self
//            textFieldGoal.becomeFirstResponder()
        }
        if cellName == "S0R2" {
            let label = cell.viewWithTag(1001) as! UILabel
            label.text = intervalToDisplay
        }
        if cellName == "S0R3" {
            let label = cell.viewWithTag(1002) as! UILabel
            durationSuffix = (promise.duration == 1) ? "" : "s"
            label.text = "\(promise.duration) Week\(durationSuffix)"
        }
        return helper.cellForRowAtIndexPath(indexPath)
    }
 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let i = indexPath.row
            if (i == 0) {
                return 205
            }
            if (i == 1) {
                return 140
            }
        }
        
        return tableView.rowHeight
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

   
    
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if tableView.frame.origin.y == 0{
                tableView.frame.origin.y -= keyboardSize.height - buttonShare.frame.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if tableView.frame.origin.y != 0{
                tableView.frame.origin.y += keyboardSize.height - buttonShare.frame.height
            }
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        promise.goal = textField.text!
        textField.resignFirstResponder()
        return true
    }
    
    
    func intervalViewController(_ controller: IntervalViewController, didFinishEditing interval: [Bool], days: String) {
        promise.intervals = interval
        intervalToDisplay = days
        tableView.reloadData()
    }
    
    
    func durationViewController(_ controller: DurationViewController, didFinishSelect duration: Int) {
        promise.duration = duration
        tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowInterval" {
//            print("SHOWINTERVAL")
            let controller = segue.destination as! IntervalViewController
            controller.delegate = self
            controller.intervals = promise.intervals
            
        } else if segue.identifier == "ShowDuration" {
//            print("SHOWDURATION")
            let controller = segue.destination as! DurationViewController
            controller.delegate = self
            controller.selectedWeeks = promise.duration
        }
    }
    
    
}






