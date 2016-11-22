//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookCore
import FacebookLogin




@objc(SignInViewController)
class SignInViewController: UIViewController {
    
    
    let comm = FCViewController()
    var dataModel: DataModel!
    
    
    
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var introText: UILabel!
    @IBOutlet weak var emailLoginButton: UIButton!
    
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        if let user = FIRAuth.auth()?.currentUser {
            
            // make a list if there isn't any.
            if dataModel.lists.count == 0 {
                let promise = Promise()
                self.dataModel.lists.append(promise)
            }
//            print("DATAMDEL: \(dataModel)")
//            print("LISTS: \(dataModel.lists)")
            
//            self.signedIn(user) // temp
            
            if dataModel.lists[dataModel.promiseNum].isMade {
                print("SIGNEDIN------1")
                self.promiseMade(user)
            } else {
                print("SIGNEDIN------2")
                self.signedIn(user)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TEMP
        emailLoginButton.isEnabled = false
        
        // Handle clicks on the button
        facebookLoginButton.layer.cornerRadius = 2
        facebookLoginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .touchUpInside)
        
        // intro paragraph style - character spacing need work
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        let attributedString = NSMutableAttributedString(attributedString: introText.attributedText!)
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        introText.attributedText = attributedString
        introText.sizeToFit()
        
//        if let user = FIRAuth.auth()?.currentUser {
//            self.user.name = user.displayName!
//
//            self.user.photoURL = user.photoURL!
//            let photoURL = user.photoURL!
//            let photoData = try! Data.init(contentsOf: photoURL)
//            self.user.photo = UIImage(data: photoData)!
//
//            performSegue(withIdentifier: "ShowMain", sender: user)
//        } else {
//            loginButton()
//        }
    }
    
    
    // Once the button is clicked, show the login dialog
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn([.publicProfile, .email, .userFriends], viewController: self) { loginResult in
            switch loginResult {
                
            case .failed(let error):
                print(error)
                
            case .cancelled:
                print("User cancelled login.")
                
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
            
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
                FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    if let user = user {
                        print("SIGNEDIN------0")
                        self.signedIn(user)
                    } else {
                        
                    }
                    
                })
                
//        FIRAuth.auth()?.addStateDidChangeListener({ auth, user in
//            if let user = user {
//                self.user.name = user.displayName!
//
//                self.user.photoURL = user.photoURL!
//                let photoURL = user.photoURL!
//                let photoData = try! Data.init(contentsOf: photoURL)
//                self.user.photo = UIImage(data: photoData)!
//            } else {
//
//            }
//        })
                
            }
        }
    }
    
    
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        try! FIRAuth.auth()!.signOut()
    }
        
    
        

//  func setDisplayName(_ user: FIRUser?) {
//    let changeRequest = user?.profileChangeRequest()
//    changeRequest?.displayName = user?.email!.components(separatedBy: "@")[0]
//    changeRequest?.commitChanges(){ (error) in
//        if let error = error {
//            print(error.localizedDescription)
//            return
//        }
//        print("SIGNEDIN------3")
//        signedIn(FIRAuth.auth()?.currentUser)
//    }
//  }

  

    func signedIn(_ user: FIRUser?) {
        MeasurementHelper.sendLoginEvent()

        AppState.sharedInstance.uid = user?.uid
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.photoURL = user?.photoURL
        AppState.sharedInstance.signedIn = true
        
        self.comm.configureDatabase()
        let userSelfData = ["name": AppState.sharedInstance.displayName!,
                            "photoURL": "\(AppState.sharedInstance.photoURL!)"]
        self.comm.ref.child("users/\(AppState.sharedInstance.uid!)/info").setValue(userSelfData)
        
        let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.SignedIn)
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
        
        performSegue(withIdentifier: "ShowPromise", sender: nil)
    }
    
    func promiseMade(_ user: FIRUser?) {
        MeasurementHelper.sendLoginEvent()
        
        AppState.sharedInstance.uid = user?.uid
        print("UIDUID: \(AppState.sharedInstance.uid)")
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.photoURL = user?.photoURL
        AppState.sharedInstance.signedIn = true
        let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.SignedIn)
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
        //    performSegue(withIdentifier: Constants.Segues.SignInToFp, sender: nil)
        performSegue(withIdentifier: "ShowCheckIn", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPromise" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! PromiseViewController
//            let controller = segue.destination as! PromiseViewController
//            print("CONTROLLER: \(controller)")
//            print("COMM1: \(self.comm)")
//            print("DATAMODEL1: \(dataModel)")
            controller.dataModel = dataModel
            controller.comm = self.comm
            
        } else if segue.identifier == "ShowCheckIn" {
            let controller = segue.destination as! CheckInViewController
            controller.dataModel = dataModel
            controller.comm = self.comm
        }
    }

}






