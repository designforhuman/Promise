//
//  SupporterNoTableRow.swift
//  Promise
//
//  Created by LeeDavid on 10/26/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import UIKit




class SupporterNoTableRow: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    var promise: Promise!
    var supporterNames = [String]()
    var supporterPhotoUrls = [String]()
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 12.0, bottom: 0.0, right: 12.0)
    
    @IBOutlet weak var collectionView: UICollectionView!

    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        for promise in promise.supporters {
//            if promise.reaction == "no" {
//                supporterCount += 1
//                supporterNames.append(promise.name)
//                supporterPhotoUrls.append(promise.photoUrl)
//            }
//        }
//        
//    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return supporterNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SupporterCell", for: indexPath) as! SupporterCell
        
        cell.userImage.backgroundColor = UIColor.lightGray
        cell.userImage.contentMode = .scaleAspectFill
        cell.userImage.clipsToBounds = true
        cell.userImage.layer.cornerRadius = 25
        
        // load name
        cell.userName.text = supporterNames[indexPath.row]
        
        // load photo
        let url = URL(string: supporterPhotoUrls[indexPath.row])
        DispatchQueue.global().async {
            //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            if let data = try? Data(contentsOf: url!) {
                DispatchQueue.main.async {
                    cell.userImage.image = UIImage(data: data)
                }
            } else {
                cell.userImage.image = UIImage(named: "defaultUserPhoto")
            }
        }
        
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 78, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
}
