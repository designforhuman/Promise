//
//  IntervalViewController.swift
//  Promise
//
//  Created by LeeDavid on 10/19/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import UIKit


protocol IntervalViewControllerDelegate: class {
    func intervalViewController(_ controller: IntervalViewController,
                                didFinishEditing interval: [Bool])
}

 

class IntervalViewController: UITableViewController, UINavigationControllerDelegate {
    
    weak var delegate: IntervalViewControllerDelegate?
    var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var intervals: [Bool]!
//    var intervalToDisplay: String!
    
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func done(_ sender: Any) {
        // set sunday's index to 6 again
//        for index in 0...6 {
//            intervals[
//            let index = ( index + 1 ) % 7
//        }
        
        delegate?.intervalViewController(self, didFinishEditing: intervals)
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
//        tableView.tableFooterView?.backgroundColor = UIColor.groupTableViewBackground

    }

//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//        delegate?.intervalViewController(self, didFinishEditing: intervals)
//    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return days.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IntervalItem", for: indexPath)
        cell.selectionStyle = .none
        
        // Set data and visual
        let label = cell.contentView.subviews[0] as! UILabel
        
        // sunday's index from 6 to 0
        let index = ( indexPath.row + 1 ) % 7
        label.text = days[index]
        
        if intervals[index] == true {
            label.textColor = UIColor.black
            if #available(iOS 8.2, *) {
                label.font = UIFont.systemFont(ofSize: 22, weight: UIFontWeightMedium)
            } else {
                // Fallback on earlier versions
            }
        } else {
            label.textColor = UIColor.lightGray
            if #available(iOS 8.2, *) {
                label.font = UIFont.systemFont(ofSize: 22, weight: UIFontWeightRegular)
            } else {
                // Fallback on earlier versions
            }
        }

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Change data and visual
        if let cell = tableView.cellForRow(at: indexPath) {
            let label = cell.contentView.subviews[0] as! UILabel
            
            // data: change sunday's number from 6 to 0
            let index = ( indexPath.row + 1 ) % 7
            intervals[index] = !intervals[index]
            
            label.textColor = (label.textColor == UIColor.black) ? UIColor.lightGray : UIColor.black
            if #available(iOS 8.2, *) {
                label.font = (label.font == UIFont.systemFont(ofSize: 22, weight: UIFontWeightMedium)) ? UIFont.systemFont(ofSize: 22, weight: UIFontWeightRegular) : UIFont.systemFont(ofSize: 22, weight: UIFontWeightMedium)
            } else {
                // Fallback on earlier versions
            }
        }
    }
 
    

}
