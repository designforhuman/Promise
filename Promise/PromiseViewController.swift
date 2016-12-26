//
//  PromiseViewController.swift
//  Promise
//
//  Created by LeeDavid on 10/19/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import UIKit
import Firebase
import FBSDKShareKit
import UserNotifications


class PromiseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, FBSDKSharingDelegate {
    
    var dataModel: DataModel!
    
    var comm: FCViewController!
    let uid = AppState.sharedInstance.uid
    
    var helper: TableViewHelper!
    
    var intervalToDisplay = "Everyday"
    var durationToDisplay = "4 Weeks"
    let goalLength: NSNumber = 15
    let minGoalTextLength = 2
    var data = [String: String]()
    var textFieldGoal: UITextField?
    var tapGesture: UITapGestureRecognizer!
    var isKeyboardUp = false
    var today = Date()
    var startDate = Date()
    var startDateString = ""
    var endDate = Date()
    var endDateString = ""
    var reminderLabel: UILabel!
    var reminderSwitch: UISwitch!
    var remindDate = Date()
    
    
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonShadow: UIImageView!
    
    
    @IBAction func rewardToggle(_ rewardToggle: UIButton) {
        if rewardToggle.isTouchInside {
//            print("TOUCHTOUCH: \(rewardToggle.titleLabel!.text!)")
            let label = (rewardToggle.titleLabel!.text! == "If I succeed, I will") ? "If I fail, I will" : "If I succeed, I will"
            rewardToggle.setTitle(label, for: .normal)
            dataModel.lists[dataModel.promiseNum].rewardPrefix = label
        }
    }
    
    
    @IBAction func startDateChanged(_ datePicker: UIDatePicker) {
        self.startDate = datePicker.date
        var todayIndicator = ""
        let calendar = Calendar.current
        if calendar.isDateInToday(datePicker.date) {
            todayIndicator = " (Today)"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.autoupdatingCurrent
        self.startDateString = formatter.string(from: self.startDate) + todayIndicator
        
//        let duration = " (\(calcDayDifference()) Days)"
//        self.endDateString = formatter.string(from: self.endDate) + duration
        
        updateStartEndDates()
        
        tableView.reloadData()
    }
    
    @IBAction func endDateChanged(_ datePicker: UIDatePicker) {
        self.endDate = datePicker.date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.autoupdatingCurrent
//        let duration = " (\(calcDayDifference()) Days)"
        self.endDateString = formatter.string(from: self.endDate)
        formatter.locale = Locale.current
        
        updateStartEndDates()
        
        tableView.reloadData()
    }
    
    
    @IBAction func reminderSwitchChanged(_ switchControl: UISwitch) {
        if !helper.cellIsVisible("ReminderPicker") && reminderLabel?.text == "Reminder" {
            helper?.showCell("ReminderPicker")
        } else {
            helper?.hideCell("ReminderPicker")
        }
        
        // set notification
        if switchControl.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) {
                granted, error in /* do nothing */
            }
            
            // data
            updateReminder()
            dataModel.lists[dataModel.promiseNum].shouldRemind = true
            dataModel.lists[dataModel.promiseNum].scheduleNotification()
            
        } else {
            dataModel.lists[dataModel.promiseNum].shouldRemind = false
            dataModel.lists[dataModel.promiseNum].removeNotification()
        }

    }
    
    
    @IBAction func reminderDateChanged(_ datePicker: UIDatePicker) {
        remindDate = datePicker.date
        updateReminder()
        let currentPromise = dataModel.lists[dataModel.promiseNum]
        if currentPromise.shouldRemind {
            currentPromise.scheduleNotification()
        }
    }
    
    
    
    
    @IBAction func showShareActionSheet(_ sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: "Share to Confirm", message: "Be sure to share your Promise to others to get motivated!", preferredStyle: .actionSheet)
        
        updateData()
        let content = prepareContent()
        
        let deleteAction = UIAlertAction(title: "Facebook", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let shareDialog = FBSDKShareDialog()
//            shareDialog.fromViewController = self
            shareDialog.shareContent = content
            shareDialog.delegate = self
//            shareDialog.mode = FBSDKShareDialogMode.browser
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
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set communication
        comm.configureDatabase()
        
        // set initial status
        disableButtonShare()
        
        // set initial data
//        print("DATAMODEL2: \(dataModel)")
//        print("LISTS2: \(dataModel.lists)")
        setInitialDates()
        dataModel.lists[dataModel.promiseNum].rewardPrefix = "If I fail, I will"
        
//        print("PROMISENUM1: \(self.dataModel.lists.count)")
        
        // style
        buttonShare.layer.cornerRadius = 2
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0)
        
        // keyboard observer
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
//        view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        
        // bottom table view: clear lines
//        helper.tableView.tableHeaderView = UIView(frame: CGRect.zero)
//        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        helper = TableViewHelper(tableView: tableView)
        
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "Goal")! as UITableViewCell, name: "Goal")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "Reward")! as UITableViewCell, name: "Reward")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "StartDate")! as UITableViewCell, name: "StartDate")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "StartDatePicker")! as UITableViewCell, name: "StartDatePicker")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "EndDate")! as UITableViewCell, name: "EndDate")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "EndDatePicker")! as UITableViewCell, name: "EndDatePicker")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "Interval")! as UITableViewCell, name: "Interval")
//        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "Duration")! as UITableViewCell, name: "Duration")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "Reminder")! as UITableViewCell, name: "Reminder")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "ReminderPicker")! as UITableViewCell, name: "ReminderPicker")
        
//        helper?.hideCell("Duration") // permanent?
        helper?.hideCell("StartDatePicker")
        helper?.hideCell("EndDatePicker")
        helper?.hideCell("ReminderPicker")
        
        
        // set data
//        let dayIndexPath = helper.indexPathForCellNamed("S0R1")
//        let dayCell = helper.cellForRowAtIndexPath(dayIndexPath!) as! DayTableRow
//        dayCell.promise = self.dataModel.lists[promiseNum]
        
        
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
    
    
    
    func setInitialDates() {
        // start date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale.autoupdatingCurrent
        let convertedStartDate = formatter.string(from: self.startDate)
        self.startDateString = "\(convertedStartDate) (Today)"
        
        // end date
        let calendar = Calendar.current
        let newEndDate = calendar.date(byAdding: .day, value: 30, to: self.endDate)
        self.endDate = newEndDate!
        let convertedEndDate = formatter.string(from: self.endDate)
        self.endDateString = "\(convertedEndDate)"
        
        // data
        updateStartEndDates()
    }
    
    
    func updateStartEndDates() {
        dataModel.lists[dataModel.promiseNum].startDate = self.startDate
        dataModel.lists[dataModel.promiseNum].endDate = self.endDate
    }
    
    
    func calcDayDifference() -> Int {
        var calendar = Calendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: self.startDate)
        let date2 = calendar.startOfDay(for: self.endDate)
        
        let unitFlags = Set<Calendar.Component>([.day])
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = calendar.dateComponents(unitFlags, from: date1, to: date2)
        
        // This will return the number of day(s) between dates
        return components.day!
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
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = helper.cellForRowAtIndexPath(indexPath)
        let cellName = helper.cellNameAtIndexPath(indexPath)

        // goal
        if cellName == "Goal" {
            let label = cell.viewWithTag(999) as! UILabel
            label.adjustTextSpacing(-1.5)
            
            let textField = cell.viewWithTag(1000) as! UITextField
            textField.text = dataModel.lists[dataModel.promiseNum].goal
            textField.adjustTextSpacing(-1.5)
            if dataModel.lists[dataModel.promiseNum].goal.characters.count > minGoalTextLength {
                enableButtonShare()
            }
        }
        
        if cellName == "Interval" {
            let label = cell.viewWithTag(1001) as! UILabel
            label.text = dataModel.lists[dataModel.promiseNum].intervalToDisplay
        }
        
//        if cellName == "Duration" {
//            let label = cell.viewWithTag(1002) as! UILabel
//            label.text = durationToDisplay
//        }
        
        if cellName == "StartDate" {
            let label = cell.viewWithTag(1010) as! UILabel
            label.text = startDateString
        }
        
        if cellName == "EndDate" {
            let label = cell.viewWithTag(1020) as! UILabel
            label.text = endDateString
        }
        
        if cellName == "EndDatePicker" {
            let picker = cell.viewWithTag(1030) as! UIDatePicker
//            print("ENDDATE: \(self.endDate)")
            picker.setDate(self.endDate, animated: false)
        }
        
        if cellName == "Reminder" {
            reminderLabel = cell.viewWithTag(1005) as! UILabel
            if reminderLabel?.text != "Reminder" {
                updateReminder()
            }
            
            reminderSwitch = cell.viewWithTag(10055) as! UISwitch
            if dataModel.lists[dataModel.promiseNum].shouldRemind {
                self.reminderSwitch.setOn(true, animated: false)
                showReminderTime()
            }
        }

        return helper.cellForRowAtIndexPath(indexPath)
    }
    
    func showReminderTime() {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        reminderLabel?.text = "Reminder \(formatter.string(from: dataModel.lists[dataModel.promiseNum].remindDate))"
    }
    
    
//    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        
//        let cell = helper.cellForRowAtIndexPath(indexPath)
//        cell.selectionStyle = .none
//        
//        return nil
//    }
 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cellName = helper.cellNameAtIndexPath(indexPath) {
            switch cellName {
                
            case "StartDate":
                if !helper.cellIsVisible("StartDatePicker") {
                    helper?.showCell("StartDatePicker")
                } else {
                    helper?.hideCell("StartDatePicker")
                }
                
            case "EndDate":
                if !helper.cellIsVisible("EndDatePicker") {
                    helper?.showCell("EndDatePicker")
                } else {
                    helper?.hideCell("EndDatePicker")
                }
                
            case "Reminder":
                if !helper.cellIsVisible("ReminderPicker") {
                    helper?.showCell("ReminderPicker")
                } else {
                    helper?.hideCell("ReminderPicker")
                }
                
            default:
                helper.hideCell("StartDatePicker")
                helper.hideCell("EndDatePicker")
                helper.hideCell("ReminderPicker")
            }
            
            if cellName != "StartDate" {
                helper?.hideCell("StartDatePicker")
            } else if cellName != "EndDate" {
                helper?.hideCell("EndDatePicker")
            }
        }
        
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let cellName = helper.cellNameAtIndexPath(indexPath) {
            switch cellName {
                case "Goal":
                    return 136

                case "Reward":
                    return 114
                
                case "StartDatePicker", "EndDatePicker", "ReminderPicker":
                    return 217
                
                default:
                    return 74
            }
        }
        
        return 74
    }
    
    
    
    func updateReminder() {
        dataModel.lists[dataModel.promiseNum].remindDate = remindDate
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        reminderLabel?.text = "Reminder \(formatter.string(from: remindDate))"
//        print("REMINDER: \(remindDate)")
    }
    
    
    func updateData() {
        data = ["goal": dataModel.lists[dataModel.promiseNum].goal,
                "interval": intervalToDisplay,
                "reward": dataModel.lists[dataModel.promiseNum].reward]
    }
    
    func prepareContent() -> FBSDKShareLinkContent {
        
        let content = FBSDKShareLinkContent()
        let urlPrefix = "https://promise-1432d.firebaseapp.com/?promiseId="
        let goal = dataModel.lists[dataModel.promiseNum].goal
        content.contentTitle = "I promise to \(goal.lowercased()), \(intervalToDisplay.lowercased()) until \(endDateString). Do you think I can make it?"
        content.contentDescription = "\(dataModel.lists[dataModel.promiseNum].rewardPrefix) \(dataModel.lists[dataModel.promiseNum].reward)"
        content.contentURL = URL(string: urlPrefix + self.uid!)
        content.imageURL = URL(string: "https://promise-1432d.firebaseapp.com/static/images/defaultShareImage@2x.jpg")
        
        return content
    }
    
    
    
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    
    
    func keyboardWillShow(sender: NSNotification) {
        
        let indexPath = helper.indexPathForCellNamed("Reward")
        let cell = helper.cellForRowAtIndexPath(indexPath!)
        if let textField = cell.viewWithTag(10033) {
            if textField.isFirstResponder {
                if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                    let threshold = view.frame.height - keyboardSize.height // 451 on iPhone7
//                    print("THRESHOLD: \(threshold)")
                    let textPos = textField.superview?.convert(textField.frame, to: nil)
                    let textPosY = (textPos?.origin.y)! + textField.frame.height
//                    print("TEXTPOSY: \(textPosY)")
                    if textPosY > threshold {
                        isKeyboardUp = true
                        tableView.frame.origin.y -= keyboardSize.height - buttonShare.frame.height
                    }
                }
            }
        }
        
        // add gesture oberserver
        view.addGestureRecognizer(tapGesture)
  
    }
    
    
    func keyboardWillHide(sender: NSNotification) {
        
        if isKeyboardUp {
            isKeyboardUp = false
            
            if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                tableView.frame.origin.y += keyboardSize.height - buttonShare.frame.height
            }
        }
        
        // remove gesture oberserver
        view.removeGestureRecognizer(tapGesture)

    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 1000 {
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            if newLength > minGoalTextLength {
                enableButtonShare()
            } else {
                disableButtonShare()
            }
            return newLength <= self.goalLength.intValue // Bool
        }
        return true
    }
    
    func enableButtonShare() {
        buttonShare.isEnabled = true
        buttonShare.backgroundColor = Constants.Colors.mainColor
        buttonShadow.isHidden = false
//        buttonShare.applyGradient(colors: [UIColor.init(red: 216/255, green: 101/255, blue: 255/255, alpha: 1.0), UIColor.init(red: 255/255, green: 142/255, blue: 19/255, alpha: 1.0)], direction: "horizontal")
    }
    
    func disableButtonShare() {
        buttonShare.isEnabled = false
        buttonShare.backgroundColor = Constants.Colors.disabledColor
        buttonShadow.isHidden = true
    }

    
    func saveTextFieldData(textField: UITextField) {
        let text = textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        textField.resignFirstResponder()
        //        print("TEXT: \(text)")
        
        if text != "" {
            if textField.tag == 1000 {
                // Goal
                dataModel.lists[dataModel.promiseNum].goal = text
            } else if textField.tag == 10033 {
                // Reward
                dataModel.lists[dataModel.promiseNum].reward = text
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveTextFieldData(textField: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveTextFieldData(textField: textField)
        return true
    }
    
    
    
    
    
    
    /*!
     @abstract Sent to the delegate when the share completes without error or cancellation.
     @param sharer The FBSDKSharing that completed.
     @param results The results from the sharer.  This may be nil or empty.
     */
    public func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        if !results.isEmpty {
            print("successfully posted!")
            
            // data
            let calendar = Calendar.current
            let formatter = DateFormatter()
            formatter.calendar = calendar
            formatter.dateFormat = "yyyy-MM-dd"
            let unitFlags = Set<Calendar.Component>([.day])
            var duration = calendar.dateComponents(unitFlags, from: self.startDate, to: self.endDate)
            //            duration.day! += 1
            print("START_DATE: \(self.startDate)")
            print("END_DATE: \(self.endDate)")
            print("WEEKDAY: \(duration.day!)")
            
            // for loop
            let dataUrl = dataModel.lists[dataModel.promiseNum]
            var startDateTemp = self.startDate
            var datesToCheckIn = [DateToCheckIn]()
            if let indices = duration.day {
                for index in 0...indices {
                    let day = calendar.component(.day, from: startDateTemp)
                    //                  let month = calendar.component(.month, from: self.startDate)
                    //                  let year = calendar.component(.year, from: self.startDate)
                    let weekday = calendar.component(.weekday, from: startDateTemp)
                    let weekOfYear = calendar.component(.weekOfYear, from: self.startDate)
                    print("\(day), \(index), \(weekday), \(weekOfYear), \(dataUrl.interval[(weekday - 1) % 7])")
                    let availability = dataUrl.interval[(weekday - 1) % 7]
                    let formattedDate = formatter.string(from: startDateTemp)
                    datesToCheckIn.append(DateToCheckIn(active: availability, count: index, formattedDate: formattedDate, day: day, weekday: weekday, weekOfYear: weekOfYear))
                    dataUrl.datesToCheckIn = datesToCheckIn
                    //                    dataUrl.datesToCheckIn.append(DateToCheckIn(active: availability, count: index, formattedDate: formattedDate, day: day, weekday: weekday, weekOfYear: weekOfYear))
                    dataUrl.datesToCheckIn[index].count = index
                    
                    // add a day
                    if let date = calendar.date(byAdding: .day, value: 1, to: startDateTemp) {
                        startDateTemp = date
                    }
                }
            }
            
            //            var count = 0
            //            for test in dataUrl.datesToCheckIn {
            //                if test.active {
            //                    count += 1
            //                }
            //            }
            //            print("ACTIVE_DAYS: \(count)")
            
            
            // data
            dataModel.lists[dataModel.promiseNum].isMade = true
            updateStartEndDates()
            
            // segue
            performSegue(withIdentifier: "ShowCheckIn", sender: nil)
            
            
            //            // if the user logged-in, download and show data
            //            helper.showCell("S0R3")
            //            helper.showCell("S0R4")
            //
            //            let competitorIndexPath = helper.indexPathForCellNamed("S0R2")
            //            let competitorCell = helper.cellForRowAtIndexPath(competitorIndexPath!) as! CompetitorTableRow
            //            competitorCell.promise = self.dataModel.lists[promiseNum]
            //
            //            let supporterYesIndexPath = helper.indexPathForCellNamed("S0R3")
            //            let supporterYesCell = helper.cellForRowAtIndexPath(supporterYesIndexPath!) as! SupporterYesTableRow
            //            supporterYesCell.promise = self.dataModel.lists[promiseNum]
            //
            //            let supporterNoIndexPath = helper.indexPathForCellNamed("S0R4")
            //            let supporterNoCell = helper.cellForRowAtIndexPath(supporterNoIndexPath!) as! SupporterNoTableRow
            //            supporterNoCell.promise = self.dataModel.lists[promiseNum]
            //            
            ////            updateUserData()
            //            
            handleCompletion(data)
            
            
        } else {
            print("post canceled")
            
        }
    }
    
    
    func handleCompletion(_ data: Dictionary<String, String>) {
        // Write Data
        let uid = self.uid!
        comm.ref.child("users/\(uid)").observeSingleEvent(of: .value, with: { (snapshot) in
            let hasChild = snapshot.hasChild("promise\(self.dataModel.promiseNum)")
            // print("HASCHILD: \(value)")
            if hasChild {
                print("UPDATE PROMISE")
//                print("UID--: \(self.uid!)")
//                print("COMM--: \(self.comm!)")
                self.comm.ref.child("users/\(uid)/promise\(self.dataModel.promiseNum)").updateChildValues(data)
                
                // register self as a competitor
                let userSelfData = ["name": "You",
                                    "photoURL": "\(AppState.sharedInstance.photoURL!)"]
                self.comm.ref.child("users/\(uid)/promise\(self.dataModel.promiseNum)/competitors/\(uid)").setValue(userSelfData)
                
            } else {
                print("NEW PROMISE")
                self.dataModel.lists.append(self.dataModel.lists[self.dataModel.promiseNum])
                self.comm.ref.child("users/\(uid)/promise\(self.dataModel.promiseNum)").setValue(data)
                
                // register self as a competitor
                let userSelfData = ["name": "You",
                                    "photoURL": "\(AppState.sharedInstance.photoURL!)"]
                self.comm.ref.child("users/\(uid)/promise\(self.dataModel.promiseNum)/competitors/\(uid)").setValue(userSelfData)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        // scroll to top
        self.tableView.contentOffset = CGPoint(x: 0, y: 0 - self.tableView.contentInset.top)
    }
    
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        print(error.localizedDescription)
    }
    
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        print("share canceled!")
    }
    

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowInterval" {
//            print("SHOWINTERVAL")
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! IntervalViewController
            controller.delegate = self
            controller.intervals = dataModel.lists[dataModel.promiseNum].interval
//            controller.intervalToDisplay = self.intervalToDisplay
            
        } else if segue.identifier == "ShowCheckIn" {
//            print("SHOWCHECKIN")
            let controller = segue.destination as! CheckInViewController
//            controller.promiseNum = self.promiseNum
            controller.dataModel = self.dataModel
//            controller.uid = self.uid
            controller.comm = self.comm
//            controller.intervalToDisplay = self.intervalToDisplay
//            controller.durationToDisplay = self.durationToDisplay
//            controller.startDate = self.startDate
        }
    }
    
    
//    func reloadCell(cellName: String) {
//        let indexPath = helper.indexPathForCellNamed(cellName)
////        let cell = helper.cellForRowAtIndexPath(indexPath!) as! DayTableRow
//        cell.promise = self.dataModel.lists[promiseNum]
//        cell.collectionView.reloadData()
//        tableView.reloadRows(at: [indexPath!], with: .automatic)
//    }
    
    
}







extension PromiseViewController: IntervalViewControllerDelegate {
    
    func intervalViewController(_ controller: IntervalViewController, didFinishEditing interval: [Bool]) {
        
        dataModel.lists[dataModel.promiseNum].interval = interval
        self.intervalToDisplay = dataModel.lists[dataModel.promiseNum].getIntervalToDisplay()
    }
    
    
//    func durationViewController(_ controller: DurationViewController, didFinishSelect duration: Int, durationToDisplay: String) {
//        
//        dataModel.lists[dataModel.promiseNum].duration = duration
//        self.durationToDisplay = dataModel.lists[dataModel.promiseNum].durationToDisplay()
////        let durationSuffix = (duration == 1) ? "" : "s"
////        self.durationToDisplay = "\(duration) Week\(durationSuffix)"
//        
//    }

}














