//
//  CompletionViewController.swift
//  Promise
//
//  Created by LeeDavid on 11/19/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import UIKit

class CompletionViewController: UIViewController {
    
    var totalDays: Int!
    var checkedInDays: Int!
    
    
    @IBOutlet weak var completionMsg: UILabel!
    
    
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        completionMsg.text = "You've done \(checkedInDays!) of \(totalDays!) days."
    }
    
    


    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
