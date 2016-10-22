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


class PromiseViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate, IntervalViewControllerDelegate, DurationViewControllerDelegate, FBSDKSharingDelegate {
    

    let comm = FCViewController()
    var helper: TableViewHelper!
    var promises = [Promise]()
    var promise = Promise()
    var intervalToDisplay = "Everyday"
    var durationSuffix = "s"
    var durationToDisplay = "4 Weeks"
    var reward = ""
    let goalLength: NSNumber = 13
    var data = [String: String]()
    let uid = AppState.sharedInstance.uid //"JWEFfYj52fVT4uCH3MUk6jgnSsK2"
    var textFieldGoal: UITextField?
    
    
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func showShareActionSheet(_ sender: AnyObject) {
        let optionMenu = UIAlertController(title: "Share to Confirm", message: "Be sure to share your Promise to others to get motivated!", preferredStyle: .actionSheet)
        
        updateData()
        let content = prepareContent(uid: uid!)
        
        let deleteAction = UIAlertAction(title: "Facebook", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let shareDialog = FBSDKShareDialog()
            shareDialog.fromViewController = self
            shareDialog.shareContent = content
            shareDialog.delegate = self
//            dialog.mode = FBSDKShareDialogMode.automatic
            shareDialog.show()
            
//            self.shareFacbook(comm, uid, data, content)
        })
        
        let saveAction = UIAlertAction(title: "FB Messenger", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
//            self.shareFBMessenger(comm, uid, data, content)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    
    func updateData() {
        data = ["goal": promise.goal,
                "interval": intervalToDisplay,
                "duration": durationToDisplay,
                "reward": promise.reward]
    }
    
    func prepareContent(uid: String) -> FBSDKShareLinkContent {
        
        let content = FBSDKShareLinkContent()
        let urlPrefix = "https://promise-1432d.firebaseapp.com/?promiseId="
        content.contentTitle = "I promise to \(promise.goal). \(intervalToDisplay) for \(durationToDisplay.lowercased()). Do you think I can make it?"
        content.contentDescription = "\(promise.reward)"
        content.contentURL = URL(string: urlPrefix + uid)
        content.imageURL = URL(string: "https://promise-1432d.firebaseapp.com/static/images/defaultShare@2x.jpg")
        
        return content
    }
    
    
    func handleCompletion(_ uid: String, _ data: Dictionary<String, String>) {
        // Write Data
        comm.ref.child("users/\(uid)").observeSingleEvent(of: .value, with: { (snapshot) in
            let hasChild = snapshot.hasChild("promise0")
            // print("HASCHILD: \(value)")
            if hasChild {
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
        // scroll to top
        self.tableView.contentOffset = CGPoint(x: 0, y: 0 - self.tableView.contentInset.top)
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
        
        comm.configureDatabase()
        
        buttonShare.isEnabled = false
        
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
//        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R6")! as UITableViewCell, name: "S0R6")
//        
//        helper.hideCell("S0R6")

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
        if cellName == "S0R0" {
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
            let photo = cell.viewWithTag(999) as! UIImageView
            photo.layer.cornerRadius = 3
        }
        if cellName == "S0R1" {
            // remove the first separator
            // auto focus on the goal textfield
//            textFieldGoal = cell.viewWithTag(1000) as? UITextField
//            textFieldGoal?.delegate = self
//            textFieldGoal?.becomeFirstResponder()
        }
        if cellName == "S0R2" {
            let label = cell.viewWithTag(1001) as! UILabel
            label.text = intervalToDisplay
        }
        if cellName == "S0R3" {
            let label = cell.viewWithTag(1002) as! UILabel
            durationSuffix = (promise.duration == 1) ? "" : "s"
            durationToDisplay = "\(promise.duration) Week\(durationSuffix)"
            label.text = durationToDisplay
        }
        return helper.cellForRowAtIndexPath(indexPath)
    }
 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        if let name = helper.cellNameAtIndexPath(indexPath) {
//            switch name {
//            case "S0R5":
//                if !helper.cellIsVisible("S0R6") {
//                    helper?.showCell("S0R6")
//                } else {
//                    helper?.hideCell("S0R6")
//                }
//                
//            case "S0R6":
//                helper?.hideCell(name)
//                
//            default:
//                helper.hideCell(name)
//                helper.showCell("S1R0")
//            }
//        }
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let i = indexPath.row
            if (i == 0) {
                return 215
            }
            if (i == 1) {
                return 135
            }
            if (i == 6) {
                return 216
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
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 1000 {
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            if newLength > 2 {
                buttonShare.isEnabled = true
                buttonShare.applyGradient(colours: [UIColor.init(red: 216/255, green: 101/255, blue: 1, alpha: 1.0), UIColor.init(red: 86/255, green: 151/255, blue: 1, alpha: 1.0)])
            } else {
                buttonShare.backgroundColor = UIColor.lightGray
            }
            return newLength <= self.goalLength.intValue // Bool
        }
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        textField.resignFirstResponder()
        print("TEXT: \(text)")
        
        if textField.tag == 1000 {
            // Goal
            promise.goal = text
        } else if textField.tag == 1003 {
            // Reward
            promise.reward = text
        }
        
        return true
    }
    
    
    func intervalViewController(_ controller: IntervalViewController, didFinishEditing interval: [Bool], days: String) {
        promise.interval = interval
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
            controller.intervals = promise.interval
            controller.intervalToDisplay = self.intervalToDisplay
            
        } else if segue.identifier == "ShowDuration" {
//            print("SHOWDURATION")
            let controller = segue.destination as! DurationViewController
            controller.delegate = self
            controller.selectedWeeks = promise.duration
        }
    }
    
    /*!
     @abstract Sent to the delegate when the share completes without error or cancellation.
     @param sharer The FBSDKSharing that completed.
     @param results The results from the sharer.  This may be nil or empty.
     */
    public func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        if !results.isEmpty {
            print("successfully posted!")
            //        print("ISEMPTY: \(results.isEmpty)")
            //        print("POST ID: \(results.index(forKey: "postId")!)")
            //        print("DESCRIPTION: \(results[AnyHashable("postId")]!)")
            //        print("KEYFIRST: \(results.keys.first!)")
            //        print("VALUEFIRST: \(results.values.first!)")
            handleCompletion(uid!, data)
        } else {
            print("post canceled")
        }
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        print(error.localizedDescription)
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        //        print("share canceled!")
    }
    
    
}





extension UIView {
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        self.layer.insertSublayer(gradient, at: 0)
    }
}






