//
//  PromiseViewController.swift
//  Promise
//
//  Created by LeeDavid on 10/19/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import UIKit
import FBSDKShareKit
import Firebase
import UserNotifications


class PromiseViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate, IntervalViewControllerDelegate, DurationViewControllerDelegate, FBSDKSharingDelegate, CheckInViewControllerDelegate {
    
    let promiseNum = 0
    
    let comm = FCViewController()
    var helper: TableViewHelper!
    var dataModel: DataModel!
//    var promise = Promise()
    var intervalToDisplay = "Everyday"
    var durationSuffix = "s"
    var durationToDisplay = "4 Weeks"
    let goalLength: NSNumber = 13
    var data = [String: String]()
    let uid = AppState.sharedInstance.uid //"JWEFfYj52fVT4uCH3MUk6jgnSsK2"
    var textFieldGoal: UITextField?
    var tapGesture: UITapGestureRecognizer!
    var buttonCheckIn: UIButton!
    var blurView: UIView?
    var date = Date()
    var dateLabel: UILabel?

    
    
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func rewardToggle(_ rewardToggle: UIButton) {
        if rewardToggle.isTouchInside {
//            print("TOUCHTOUCH: \(rewardToggle.titleLabel!.text!)")
            let label = (rewardToggle.titleLabel!.text! == "succeed,") ? "fail," : "succeed,"
            rewardToggle.setTitle(label, for: .normal)
            dataModel.lists[promiseNum].rewardPrefix = "If I \(label)"
        }
    }
    
    @IBAction func reminderSwitch(_ switchControl: UISwitch) {
        if !helper.cellIsVisible("S0R8") && dateLabel?.text == "Reminder" {
            helper?.showCell("S0R8")
        } else {
            helper?.hideCell("S0R8")
        }
        
        if switchControl.isOn {
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.alert, .sound, .badge]) {
                    granted, error in /* do nothing */
                }
            } else {
                // Fallback on earlier versions
            }
            
            dataModel.lists[promiseNum].shouldRemind = true
            
            if dateLabel?.text == "Reminder" {
                updateDueDateLabel()
            }
            
        } else {
            dataModel.lists[promiseNum].shouldRemind = false
        }
    }
    
    @IBAction func dateChanged(_ datePicker: UIDatePicker) {
        date = datePicker.date
        updateDueDateLabel()
        
        // set reminder
        if dataModel.lists[promiseNum].shouldRemind {
            dataModel.lists[promiseNum].scheduleNotification()
        }
    }
    
    func updateDueDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        dateLabel?.text = "Reminder \(formatter.string(from: date))"
        dataModel.lists[promiseNum].date = date
    }
    
    
    
    @IBAction func showShareActionSheet(_ sender: AnyObject) {
        
        // remove gesture oberserver
        view.removeGestureRecognizer(tapGesture)
        
        let optionMenu = UIAlertController(title: "Share to Confirm", message: "Be sure to share your Promise to others to get motivated!", preferredStyle: .actionSheet)
        
        updateData()
        let content = prepareContent(uid: uid!)
        
        let deleteAction = UIAlertAction(title: "Facebook", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let shareDialog = FBSDKShareDialog()
//            shareDialog.fromViewController = self
            shareDialog.shareContent = content
            shareDialog.delegate = self
//            dialog.mode = FBSDKShareDialogMode.automatic
            shareDialog.show()
        })
        
        let saveAction = UIAlertAction(title: "FB Messenger", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in

            let shareDialog = FBSDKMessageDialog()
            shareDialog.shareContent = content
            shareDialog.delegate = self
            //            dialog.mode = FBSDKShareDialogMode.automatic
            shareDialog.show()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
//            print("ACTION CANCELLED")
            // add gesture oberserver1
            self.view.addGestureRecognizer(self.tapGesture)
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
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
        
        // set communication
        comm.configureDatabase()
        
        // set button and text
        buttonShare.isEnabled = false
        dateLabel?.text = "Reminder"
        
        // set initial data
//        promise = Promise()
//        dataModel.lists.append(promise)
        print("DATAMODEL: \(dataModel)")
        print("LISTS: \(dataModel.lists)")
        dataModel.lists[promiseNum].makeInitialDays()
        
        
        // keyboard observer
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
//        view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        
        helper = TableViewHelper(tableView: tableView)
        
        // bottom table view: clear lines
//        helper.tableView.tableHeaderView = UIView(frame: CGRect.zero)
//        helper.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R0")! as UITableViewCell, name: "S0R0")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R1")! as! DayTableRow, name: "S0R1")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R2")! as! SupporterYesTableRow, name: "S0R2")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R3")! as! SupporterNoTableRow, name: "S0R3")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R4")! as UITableViewCell, name: "S0R4")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R5")! as UITableViewCell, name: "S0R5")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R6")! as UITableViewCell, name: "S0R6")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R7")! as UITableViewCell, name: "S0R7")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R8")! as UITableViewCell, name: "S0R8")
        
        helper?.hideCell("S0R2")
        helper?.hideCell("S0R3")
        helper?.hideCell("S0R8")
        
        
        // set data
        let dayIndexPath = helper.indexPathForCellNamed("S0R1")
        let dayCell = helper.cellForRowAtIndexPath(dayIndexPath!) as! DayTableRow
        dayCell.promise = self.dataModel.lists[promiseNum]
        
        
        // if the user logged-in, download and show data
//        if FIRAuth.auth()?.currentUser != nil {
//            updateUserData()
//        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    
    
    
    
    func viewWillDisappear(animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self,  name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // remove the first separator and chage the color to black
        let cell = helper.cellForRowAtIndexPath(indexPath)
        let cellName = helper.cellNameAtIndexPath(indexPath)
        if cellName == "S0R0" {
            // UI
            cell.separatorInset = UIEdgeInsetsMake(0, tableView.bounds.width/2.0, 0, tableView.bounds.width/2.0)
            
            let bottomBorder = CALayer()
            bottomBorder.backgroundColor = UIColor.black.cgColor
            bottomBorder.frame = CGRect(x: 20, y: cell.frame.height - 1, width: cell.frame.width - 40, height: 1)
            cell.layer.addSublayer(bottomBorder)
        }
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = helper.cellForRowAtIndexPath(indexPath)
        let cellName = helper.cellNameAtIndexPath(indexPath)
        
        // goal
        if cellName == "S0R0" {
            // Data
            let goal = dataModel.lists[promiseNum].goal
            let textField = cell.viewWithTag(1000) as! UITextField
            textField.text = goal
        }
        
        // interval
        if cellName == "S0R4" {
            let label = cell.viewWithTag(1001) as! UILabel
            label.text = intervalToDisplay
        }
        // duration
        if cellName == "S0R5" {
            let label = cell.viewWithTag(1002) as! UILabel
            durationSuffix = (dataModel.lists[promiseNum].duration == 1) ? "" : "s"
            durationToDisplay = "\(dataModel.lists[promiseNum].duration) Week\(durationSuffix)"
            label.text = durationToDisplay
        }
//        if cellName == "S0R6" {
//            rewardToggleButton = cell.viewWithTag(1003) as! UIButton
//        }
        // text: reminder
//        if cellName == "S0R7" {
//            dateLabel = cell.viewWithTag(1005) as! UILabel
//        }
//        if cellName == "S0R7" {
//            let datePicker = cell.viewWithTag(1005) as! UIDatePicker
//            
//        }
        return helper.cellForRowAtIndexPath(indexPath)
    }
 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cellName = helper.cellNameAtIndexPath(indexPath) {
            switch cellName {
            case "S0R7":
                if !helper.cellIsVisible("S0R8") {
                    helper?.showCell("S0R8")
//                    tableView.frame.origin.y -= 216
                } else {
                    helper?.hideCell("S0R8")
//                    tableView.layer.frame.origin.y += 216
//                    tableView.contentOffset.y += 216
                }
                
            default:
                helper.hideCell("S0R8")
            }
            
            if cellName != "S0R7" {
                helper?.hideCell("S0R8")
            }
        }
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let cellName = helper.cellNameAtIndexPath(indexPath) {
            switch cellName {
                case "S0R0":
                    return 132
                
                case "S0R1":
                    let cellHeight = (self.view.frame.width - 24) / 7 + 4 // temp
                    return CGFloat(dataModel.lists[promiseNum].duration) * cellHeight + 20 // 20: top and bottom paddings
                    
                case "S0R2", "S0R3":
                    return 150
                
                case "S0R6":
                    return 110
                    
                case "S0R8":
                    return 216
                    
                default:
                    return 74
            }
        }
        
        return 74
    }
    
    
    
    func updateData() {
        data = ["goal": dataModel.lists[promiseNum].goal,
                "interval": intervalToDisplay,
                "duration": durationToDisplay,
                "reward": dataModel.lists[promiseNum].reward]
    }
    
    func prepareContent(uid: String) -> FBSDKShareLinkContent {
        
        let content = FBSDKShareLinkContent()
        let urlPrefix = "https://promise-1432d.firebaseapp.com/?promiseId="
        content.contentTitle = "I promise to \(dataModel.lists[promiseNum].goal). \(intervalToDisplay) for \(durationToDisplay.lowercased()). Do you think I can make it?"
        content.contentDescription = "\(dataModel.lists[promiseNum].rewardPrefix) \(dataModel.lists[promiseNum].reward)"
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
                self.comm.ref.child("users/\(uid)/promise\(self.dataModel.lists.count)").updateChildValues(data)
            } else {
                print("NEW PROMISE")
                self.dataModel.lists.append(self.dataModel.lists[self.promiseNum])
                print("LISTS: \(self.dataModel.lists)")
                self.comm.ref.child("users/\(uid)/promise\(self.dataModel.lists.count)").setValue(data)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        // scroll to top
        self.tableView.contentOffset = CGPoint(x: 0, y: 0 - self.tableView.contentInset.top)
    }
    
    
    
    
    func updateUserData() {
        
        let supporterYesIndexPath = self.helper.indexPathForCellNamed("S0R2")
        let supporterYesCell = self.helper.cellForRowAtIndexPath(supporterYesIndexPath!) as! SupporterYesTableRow
        
        let supporterNoIndexPath = self.helper.indexPathForCellNamed("S0R3")
        let supporterNoCell = self.helper.cellForRowAtIndexPath(supporterNoIndexPath!) as! SupporterNoTableRow
        
        comm.ref.child("users/\(uid!)/promise0/users").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
//            let value = snapshot.value as? NSDictionary
            var supporters = [NSDictionary]()
            
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let dict = child.value as! NSDictionary
                supporters.append(dict)
//                let reaction = supporters[0]["reaction"]
//                print("TEMPITEMS: \(reaction)")
            }
            
            for dict in supporters {
                var supporter = dict as! [String: String]
                if supporter["reaction"] == "yes" {
                    supporterYesCell.supporterNames.append(supporter["userName"]!)
                    supporterYesCell.supporterPhotoUrls.append(supporter["userPhoto"]!)
                } else {
                    supporterNoCell.supporterNames.append(supporter["userName"]!)
                    supporterNoCell.supporterPhotoUrls.append(supporter["userPhoto"]!)
                }
                
                self.dataModel.lists[self.promiseNum].supporters.append(Supporter(name: supporter["userName"]!, photoUrl: supporter["userPhoto"]!, reaction: supporter["reaction"]!))
//                print("INDEX: \(dict)")
            }
          
            supporterYesCell.collectionView.reloadData()
            supporterNoCell.collectionView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    

   
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        let heightThreshold: CGFloat = 30 // default is 64 because navigation bar reserves
        
        let tablePosY = tableView.contentOffset.y
//        print("POS: \(tablePosY)")
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if tablePosY > heightThreshold {
                tableView.frame.origin.y -= keyboardSize.height - buttonShare.frame.height
            }
        }
        
        // add gesture oberserver
        view.addGestureRecognizer(tapGesture)
        
//        let userInfo = sender.userInfo!
//        
//        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
//        let offset: CGSize = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
//        
//        if keyboardSize.height == offset.height {
//            if self.view.frame.origin.y > heightThreshold {
//                UIView.animate(withDuration: 0.1, animations: { () -> Void in
//                    self.view.frame.origin.y -= keyboardSize.height
//                })
//            }
//        } else {
//            UIView.animate(withDuration: 0.1, animations: { () -> Void in
//                self.view.frame.origin.y += keyboardSize.height - offset.height
//            })
//        }
//        print(self.view.frame.origin.y)
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if tableView.frame.origin.y != 0 {
                tableView.frame.origin.y += keyboardSize.height - buttonShare.frame.height
            }
        }
        
        // remove gesture oberserver
        view.removeGestureRecognizer(tapGesture)
        
//        let userInfo = sender.userInfo!
//        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size
//        self.view.frame.origin.y += keyboardSize.height
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 1000 {
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            if newLength > 2 {
                buttonShare.isEnabled = true
                buttonShare.applyGradient(colours: [UIColor.init(red: 216/255, green: 101/255, blue: 255/255, alpha: 1.0), UIColor.init(red: 86/255, green: 151/255, blue: 255/255, alpha: 1.0)])
            } else {
                buttonShare.backgroundColor = UIColor.lightGray
            }
            return newLength <= self.goalLength.intValue // Bool
        }
        return true
    }
    
    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        return true
//    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let text = textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        textField.resignFirstResponder()
//        print("TEXT: \(text)")
        
        if text != "" {
            if textField.tag == 1000 {
                // Goal
                dataModel.lists[promiseNum].goal = text
            } else if textField.tag == 1004 {
                // Reward
                dataModel.lists[promiseNum].reward = "\(text)"
            }
        }
        
        return true
    }
    
    
    func intervalViewController(_ controller: IntervalViewController, didFinishEditing interval: [Bool], days: String) {
        dataModel.lists[promiseNum].interval = interval
        intervalToDisplay = days
        tableView.reloadData()
        
        reloadCell(cellName: "S0R1")
    }
    
    
    func durationViewController(_ controller: DurationViewController, didFinishSelect duration: Int) {
        dataModel.lists[promiseNum].duration = duration
        tableView.reloadData()
        
        reloadCell(cellName: "S0R1")
    }
    
    
    func reloadCell(cellName: String) {
        let indexPath = helper.indexPathForCellNamed(cellName)
        let cell = helper.cellForRowAtIndexPath(indexPath!) as! DayTableRow
        cell.promise = self.dataModel.lists[promiseNum]
        cell.collectionView.reloadData()
        tableView.reloadRows(at: [indexPath!], with: .automatic)
    }
    
    
    func checkInViewController(_ controller: CheckInViewController, didSelect emoji: String) {
        
        // remove blur background
        blurView!.removeFromSuperview()
        self.navigationController?.isNavigationBarHidden = false
        
        // add emoji
        dataModel.lists[promiseNum].days[0].emojiName = emoji
        let indexPath = helper.indexPathForCellNamed("S0R1")
        let cell = helper.cellForRowAtIndexPath(indexPath!) as! DayTableRow
        cell.collectionView.reloadData()
        cell.curDay += 1
        
        // change button
        buttonCheckIn.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        buttonCheckIn.layer.sublayers?[0].removeFromSuperlayer()
        buttonCheckIn.setTitle("Done!", for: .normal)
        buttonCheckIn.isEnabled = false


        // button text animation (fade-in and out) // for animation reference
//        let delay = 0.06
//        UIView.animate(withDuration: delay, animations: { () -> Void in
//            button.titleLabel?.alpha = 0.4
//        }) { (Bool) -> Void in
//            UIView.animate(withDuration: delay, delay: delay, options: .curveEaseInOut, animations: { () -> Void in
//                button.titleLabel?.alpha = 1.0
//            }, completion: nil)
//        }
    }
    
    func checkInViewControllerDidCancel(_ controller: CheckInViewController) {
        
        blurView?.removeFromSuperview()
        self.navigationController?.isNavigationBarHidden = false
        
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
            
            
            // data
            // if the user logged-in, download and show data
            helper.showCell("S0R2")
            helper.showCell("S0R3")
            
            let supporterYesIndexPath = helper.indexPathForCellNamed("S0R2")
            let supporterYesCell = helper.cellForRowAtIndexPath(supporterYesIndexPath!) as! SupporterYesTableRow
            supporterYesCell.promise = self.dataModel.lists[promiseNum]
            
            let supporterNoIndexPath = helper.indexPathForCellNamed("S0R3")
            let supporterNoCell = helper.cellForRowAtIndexPath(supporterNoIndexPath!) as! SupporterNoTableRow
            supporterNoCell.promise = self.dataModel.lists[promiseNum]
            
            updateUserData()
            
            
            // UI
            buttonShare.isHidden = true
            
            buttonCheckIn = UIButton()
            buttonCheckIn.setTitle("Check-In", for: .normal)
            if #available(iOS 8.2, *) {
                buttonCheckIn.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: UIFontWeightRegular)
            } else {
                // Fallback on earlier versions
            }
            buttonCheckIn.setTitleColor(UIColor.white, for: .normal)
            buttonCheckIn.setTitleColor(UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5), for: .highlighted)
            buttonCheckIn.frame = CGRect(x: 0, y: self.view.frame.height - 70, width: self.view.frame.width, height: 70)
            buttonCheckIn.backgroundColor = UIColor.yellow
            buttonCheckIn.addTarget(self, action: #selector(self.checkIn), for: .touchUpInside)
            self.view.addSubview(buttonCheckIn)
            buttonCheckIn.applyGradient(colours: [UIColor.init(red: 255/255, green: 205/255, blue: 44/255, alpha: 1.0), UIColor.init(red: 255/255, green: 142/255, blue: 44/255, alpha: 1.0)])
            
            
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
    
    
    func checkIn() {
        performSegue(withIdentifier: "ShowCheckIn", sender: nil)
    }
    
    
    func backgroundBlur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView?.frame = view.bounds
        blurView?.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        view.addSubview(blurView!)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowInterval" {
            //            print("SHOWINTERVAL")
            let controller = segue.destination as! IntervalViewController
            controller.delegate = self
            controller.intervals = dataModel.lists[promiseNum].interval
            controller.intervalToDisplay = self.intervalToDisplay
            
        } else if segue.identifier == "ShowDuration" {
            //            print("SHOWDURATION")
            let controller = segue.destination as! DurationViewController
            controller.delegate = self
            controller.selectedWeeks = dataModel.lists[promiseNum].duration
            
        } else if segue.identifier == "ShowCheckIn" {
//            print("SHOWCHECKIN")
            backgroundBlur()
            let controller = segue.destination as! CheckInViewController
            controller.delegate = self
            
            // hid nav bar
            self.navigationController?.isNavigationBarHidden = true
        }
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




