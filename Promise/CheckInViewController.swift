//
//  CheckInViewController.swift
//  Promise
//
//  Created by LeeDavid on 11/4/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications


class CheckInViewController: UIViewController {
    
    // Variables
    var helper: TableViewHelper!
    
    var comm: FCViewController!
    var uid = AppState.sharedInstance.uid
    
    var dataModel: DataModel!
//    var promiseNum = 0
//    var intervalToDisplay: String!
//    var durationToDisplay: String!
    var remindDate = Date()
    var reminderLabel: UILabel?
    var reminderSwitch: UISwitch!
//    var blurView: UIView?
//    var startDate: Date!
    var currentDate: Int!
    var nthDayIndex = 0
    
    
    // IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonCheckIn: UIButton!
    @IBOutlet weak var buttonShadow: UIImageView!
    
    
    
    // IBActions
    @IBAction func checkIn(_ button: UIButton) {
//        print("CHECKIN---")
        disableCheckInButton()
        button.setTitle("DONE", for: .normal)
        
        // change today's check-in status
        dataModel.lists[dataModel.promiseNum].datesToCheckIn[nthDayIndex].isCheckedIn = true
        let calendar = Calendar.current
//        let newStartDate = calendar.date(byAdding: .day, value: 1, to: dataModel.lists[dataModel.promiseNum].startDate)
//        print("OLD_STARTDATE: \(dataModel.lists[dataModel.promiseNum].startDate)")
//        print("NEW_STARTDATE: \(newStartDate!)")
//        dataModel.lists[dataModel.promiseNum].startDate = newStartDate!
        
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "yyyy-MM-dd"
        let startDateString = formatter.string(from: dataModel.lists[dataModel.promiseNum].startDate)
        let endDateString = formatter.string(from: dataModel.lists[dataModel.promiseNum].endDate)
        if startDateString == endDateString {
            print("Congrats!!!")
            performSegue(withIdentifier: "ShowCompletion", sender: nil)
        }
    }
    
    
    @IBAction func reminderSwitchChanged(_ switchControl: UISwitch) {
        if !helper.cellIsVisible("S0R6") && reminderLabel?.text == "Reminder" {
            helper?.showCell("S0R6")
        } else {
            helper?.hideCell("S0R6")
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
    }
    
    func updateReminder() {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        reminderLabel?.text = "Reminder \(formatter.string(from: remindDate))"
        dataModel.lists[dataModel.promiseNum].remindDate = remindDate
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        tableView.reloadData()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.isNavigationBarHidden = true
        
        comm.configureDatabase()
        
        buttonCheckIn.layer.cornerRadius = 2
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0)
        
        helper = TableViewHelper(tableView: tableView)

        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R0")! as UITableViewCell, name: "S0R0")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R1")! as! CompetitorTableRow, name: "S0R1")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R2")! as UITableViewCell, name: "S0R2")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R3")! as! SupporterYesTableRow, name: "S0R3")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R4")! as! SupporterNoTableRow, name: "S0R4")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R5")! as UITableViewCell, name: "S0R5")
        helper.addCell(0, cell: tableView.dequeueReusableCell(withIdentifier: "S0R6")! as UITableViewCell, name: "S0R6")
        
        helper?.hideCell("S0R6")
        
//        print("UID: \(self.uid!)")
//        print("COMM: \(self.comm!)")
        updateUserData()
        
        // Check-In Button
        disableCheckInButton()
        let today = Date()
//        let startDate = dataModel.lists[dataModel.promiseNum].startDate
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "yyyy-MM-dd"
        
//        let startDateString = formatter.string(from: startDate)
        let todayString = formatter.string(from: today)
        print("TODAY: \(todayString)")
//        print("STARTDATE: \(startDateString)")
        
        // look if there's a match between today and a day in DatesToCheckIn array.
        for day in dataModel.lists[dataModel.promiseNum].datesToCheckIn {
            print("FORMATTED_STRING: \(day.formattedDate)")
            print("ISACTIVE: \(day.active)")
            if day.active && day.formattedDate == todayString {
                print("MATCH DATES")
                enableCheckInButton()
            }
        }
        
    }
    
    
    func enableCheckInButton() {
        buttonCheckIn.isEnabled = true
        buttonCheckIn.backgroundColor = Constants.Colors.mainColor
        buttonShadow.isHidden = false
    }
    
    func disableCheckInButton() {
        buttonCheckIn.isEnabled = false
        buttonCheckIn.backgroundColor = Constants.Colors.disabledColor
        buttonShadow.isHidden = true
    }
    
    
    
    func updateUserData() {
        
        let competitorIndexPath = self.helper.indexPathForCellNamed("S0R1")
        let competitorCell = self.helper.cellForRowAtIndexPath(competitorIndexPath!) as! CompetitorTableRow
        
        let supporterYesIndexPath = self.helper.indexPathForCellNamed("S0R3")
        let supporterYesCell = self.helper.cellForRowAtIndexPath(supporterYesIndexPath!) as! SupporterYesTableRow
        
        let supporterNoIndexPath = self.helper.indexPathForCellNamed("S0R4")
        let supporterNoCell = self.helper.cellForRowAtIndexPath(supporterNoIndexPath!) as! SupporterNoTableRow
        
        // Competitors
        comm.ref.child("users/\(uid!)/promise1/competitors").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            var competitors = [NSDictionary]()
//            print("SNAPSHOT: \(snapshot)")
//            print("SNAPSHOT_CHILDREN: \(snapshot.children)")
            
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let dict = child.value as! NSDictionary
                competitors.append(dict)
            }
            
            for dict in competitors {
                var competitor = dict as! [String: String]
                let userName = competitor["name"]!
                let userPhoto = competitor["photoUrl"]!
                competitorCell.competitorNames.append(userName)
                competitorCell.competitorPhotoUrls.append(userPhoto)
                
                self.dataModel.lists[self.dataModel.promiseNum].competitors.append(Competitor(name: userName, photoUrl: userPhoto))
            }
            
            competitorCell.collectionView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        // Supporters
        comm.ref.child("users/\(uid!)/promise1/users").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
//            let value = snapshot.value as? NSDictionary
            var supporters = [NSDictionary]()
            
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let dict = child.value as! NSDictionary
                supporters.append(dict)
            }
            
            for dict in supporters {
                var supporter = dict as! [String: String]
                let userName = supporter["userName"]!
                let userPhoto = supporter["userPhoto"]!
                if supporter["reaction"] == "yes" {
                    supporterYesCell.supporterNames.append(userName)
                    supporterYesCell.supporterPhotoUrls.append(userPhoto)
                } else {
                    supporterNoCell.supporterNames.append(userName)
                    supporterNoCell.supporterPhotoUrls.append(userPhoto)
                }
                self.dataModel.lists[self.dataModel.promiseNum].supporters.append(Supporter(name: userName, photoUrl: userPhoto, reaction: supporter["reaction"]!))
            }
            
            supporterYesCell.collectionView.reloadData()
            supporterNoCell.collectionView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    
    
    
    
    
    
//    func checkInViewController(_ controller: CheckInViewController, didSelect emoji: String) {
//        
//        // remove blur background
////        blurView!.removeFromSuperview()
//        self.navigationController?.isNavigationBarHidden = false
//        
//        // add emoji
////        dataModel.lists[promiseNum].days[0].emojiName = emoji
////        let indexPath = helper.indexPathForCellNamed("S0R1")
////        let cell = helper.cellForRowAtIndexPath(indexPath!) as! DayTableRow
////        cell.collectionView.reloadData()
////        cell.curDay += 1
//        
//        // change button
////        buttonCheckIn.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
////        buttonCheckIn.layer.sublayers?[0].removeFromSuperlayer()
////        buttonCheckIn.setTitle("Done!", for: .normal)
////        buttonCheckIn.isEnabled = false
//        
//        
//        // button text animation (fade-in and out) // for animation reference
//        //        let delay = 0.06
//        //        UIView.animate(withDuration: delay, animations: { () -> Void in
//        //            button.titleLabel?.alpha = 0.4
//        //        }) { (Bool) -> Void in
//        //            UIView.animate(withDuration: delay, delay: delay, options: .curveEaseInOut, animations: { () -> Void in
//        //                button.titleLabel?.alpha = 1.0
//        //            }, completion: nil)
//        //        }
//    }
//    
//    func checkInViewControllerDidCancel(_ controller: CheckInViewController) {
//        
////        blurView?.removeFromSuperview()
//        self.navigationController?.isNavigationBarHidden = false
//        
//    }
    
//    func backgroundBlur() {
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
//        blurView = UIVisualEffectView(effect: blurEffect)
//        blurView?.frame = view.bounds
//        blurView?.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
//        view.addSubview(blurView!)
//    }
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCompletion" {
            let controller = segue.destination as! CompletionViewController
            controller.totalDays = dataModel.lists[dataModel.promiseNum].datesToCheckIn.count
            var checkedInDays = 0
            for day in dataModel.lists[dataModel.promiseNum].datesToCheckIn {
                if day.isCheckedIn {
                    checkedInDays += 1
                }
            }
            controller.checkedInDays = checkedInDays
        }
    }
 

}





extension CheckInViewController: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return helper.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helper.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = helper.cellForRowAtIndexPath(indexPath)
        cell.selectionStyle = .none
        let cellName = helper.cellNameAtIndexPath(indexPath)
        
        if cellName == "S0R0" {
            // goal
            let goal = dataModel.lists[dataModel.promiseNum].goal
            let goalLabel = cell.viewWithTag(1000) as! UILabel
            goalLabel.text = goal
            
            // interval
            let intervalLabel = cell.viewWithTag(10000) as! UILabel
            intervalLabel.text = dataModel.lists[dataModel.promiseNum].getIntervalToDisplay()
            
            // duration
//            let durationLabel = cell.viewWithTag(100000) as! UILabel
//            durationLabel.text = dataModel.lists[dataModel.promiseNum].durationToDisplay()
        }
        
        if cellName == "S0R1" {
            let competitorLabel = cell.viewWithTag(1001) as! UILabel
            competitorLabel.text = "1ST DAY (0%)"
        }
        
        if cellName == "S0R2" {
            let rewardLabel = cell.viewWithTag(1002) as! UILabel
            rewardLabel.text = dataModel.lists[dataModel.promiseNum].reward
        }
        
        if cellName == "S0R5" {
            reminderLabel = cell.viewWithTag(1005) as! UILabel
            if reminderLabel?.text != "Reminder" {
                updateReminder()
            }
            
            reminderSwitch = cell.viewWithTag(10055) as! UISwitch
            if dataModel.lists[dataModel.promiseNum].shouldRemind {
                reminderSwitch.setOn(true, animated: false)
                let formatter = DateFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                reminderLabel?.text = "Reminder \(formatter.string(from: dataModel.lists[dataModel.promiseNum].remindDate))"
            }
        }
        
        return helper.cellForRowAtIndexPath(indexPath)
        
    }
    
}





extension CheckInViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        
//        if let cellName = helper.cellNameAtIndexPath(indexPath) {
//            let cell = helper.cellForRowAtIndexPath(indexPath)
//            if cellName != "S0R6" {
//                cell.selectionStyle = .none
//            }
//        }
//        
//        return indexPath
//    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cellName = helper.cellNameAtIndexPath(indexPath) {
            switch cellName {
                
            case "S0R5":
                if !helper.cellIsVisible("S0R6") {
                    helper?.showCell("S0R6")
                } else {
                    helper?.hideCell("S0R6")
                }
                
            default:
                helper.hideCell("S0R6")
            }
            
            if cellName != "S0R5" {
                helper?.hideCell("S0R6")
            }
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let cellName = helper.cellNameAtIndexPath(indexPath) {
            switch cellName {
            // goal
            case "S0R0":
                return 145
                
            // competitors
            case "S0R1":
                return 156
//                let cellHeight = (self.view.frame.width - 24) / 7 + 4 // temp
//                return CGFloat(dataModel.lists[promiseNum].duration) * cellHeight + 20 // 20: top and bottom paddings
                
            // supporters
            case "S0R3", "S0R4":
                return 150
                
            // picker view
            case "S0R6":
                return 217
                
            default:
                return 74
            }
        }
        
        return 74
        
    }
    
}














