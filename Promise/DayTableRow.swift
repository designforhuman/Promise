////
////  DayTableRow.swift
////  Promise
////
////  Created by LeeDavid on 10/24/16.
////  Copyright © 2016 Daylight. All rights reserved.
////
//
//import UIKit
//
//
//
//protocol DayTableRowDelegate: class {
//    func dayTableRowCheckIn(_ controller: DayTableRow, _ collectionController: DayCell, didCheckIn day: Int)
//}
//
//
//
//class DayTableRow: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    fileprivate let itemsPerRow: CGFloat = 7
//    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 12.0, bottom: 10.0, right: 12.0)
//    
//    weak var delegate: DayTableRowDelegate?
//    var promise: Promise!
//    var curDay = 0
//    
//    @IBOutlet weak var collectionView: UICollectionView!
//
//    
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        
//        let duration = promise.duration
//        
//        return duration * 7
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! DayCell
//        
//        // make circle
//        cell.circle.layer.cornerRadius = 17
//        
//        // set colors
//        //        print("PROMISE: \(promise.interval)")
//        //        cell.backgroundColor = UIColor.red
//        if promise.interval[indexPath.row % 7] {
//            cell.circle.backgroundColor = UIColor(red: 255/255, green: 205/255, blue: 44/255, alpha: 1)
//        } else {
//            cell.circle.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1)
//        }
//        
//        if indexPath.row == curDay {
//            cell.circle.backgroundColor = UIColor(red: 255/255, green: 142/255, blue: 44/255, alpha: 1)
//        }
//        
//        // add emoji
//        cell.emoji.image = UIImage(named: promise.days[indexPath.row].emojiName)
////        if curDay == indexPath.row {
////            delegate?.dayTableRowCheckIn(self, didCheckIn: curDay)
////        }
//        
//        
//        return cell
//    }
//    
////    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
////        collectionView.deselectItem(at: indexPath, animated: true)
////        
////        var selection = indexPath.row
////        print("SELECTED: \(selection)")
////    }
//
//    
//    
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        let paddingSpace = sectionInsets.left + sectionInsets.right
//        let availableWidth = collectionView.frame.width - paddingSpace
//        let widthPerItem = floor(availableWidth / itemsPerRow)
//        //        print("widthPerItem: \(widthPerItem)")
//        
//        return CGSize(width: widthPerItem, height: widthPerItem + 4.0)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        
//        return sectionInsets
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//    
//}
//
//
//
////extension DayTableRow: UICollectionViewDataSource {
////    
////    func numberOfSections(in collectionView: UICollectionView) -> Int {
////        return 1
////    }
////    
////    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
////        
//////        print("duration: \(promise.duration)")
////        let duration = promise.duration
////        
////        return duration * 7
////    }
////    
////    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
////        
////        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! DayCell
////        
////        // make circle
////        cell.circle.layer.cornerRadius = 17
////        
////        // set colors
//////        print("PROMISE: \(promise.interval)")
//////        cell.backgroundColor = UIColor.red
////        if promise.interval[indexPath.row % 7] {
////            cell.circle.backgroundColor = UIColor(red: 255/255, green: 205/255, blue: 44/255, alpha: 1)
////        } else {
////            cell.circle.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1)
////        }
////        
////        if indexPath.row == curDay {
////            cell.circle.backgroundColor = UIColor(red: 255/255, green: 142/255, blue: 44/255, alpha: 1)
////        }
////        
////        // add emoji
////        cell.emoji.image = UIImage(named: "sunglasses")
////        
////        
////        return cell
////    }
////    
////    
////    
////}
////
////
////extension DayTableRow: UICollectionViewDelegateFlowLayout {
////    
////    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
////        
////        let paddingSpace = sectionInsets.left + sectionInsets.right
////        let availableWidth = collectionView.frame.width - paddingSpace
////        let widthPerItem = floor(availableWidth / itemsPerRow)
//////        print("widthPerItem: \(widthPerItem)")
////        
////        return CGSize(width: widthPerItem, height: widthPerItem + 4.0)
////    }
////    
////    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
////        return sectionInsets
////    }
////    
////    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
////        return 0
////    }
////    
////    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
////        return 0
////    }
////    
////}
//
//
//
//
//
//
//
//
//
//
//
//
//
