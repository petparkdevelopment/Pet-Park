/*-----------------------------------
 
 - MyStream -
 
 Created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/

import Foundation
import UIKit
import Parse
import AVFoundation



// IMPORTANT: Replace the red string below with the new name you'll give to this app
let APP_NAME = "Pet Park"



// IMPORTANT: Reaplce the red strings below with your own Application ID and Client Key of your app on back4app.com
let PARSE_APP_ID = "LVRmCTZfISsAWWsh8zubFSbG61hBIC0kgmOCbFfk"
let PARSE_CLIENT_KEY = "tOKQKKX47XAf2GiBGrY7nghtHr18t49odtuAR7r6"
//-----------------------------------------------------------------------------




// IMPORTANT: REPLACE THE STRINGS BELOW WITH THE URL's TO YOUR FACEBOOK AND TWITTER PAGE OF YOUR APP (OR YOUR OWN ACCOUNT)
let FACEBOOK_URL = "https://www.facebook.com/petparkofficial/"
let TWITTER_URL = "https://www.pet-park.net"


// REPLACE "1253850533" WITH THE APP ID OF YOUR APP ON THE APP STORE
let APP_ID = "1479337575"




// IMPORTANT: REPLACE THE RED STRING BELOW WITH YOUR OWN INTERSTITIAL UNIT ID YOU'LL GET FROM  http://apps.admob.com
let ADMOB_INTERSTITIAL_UNIT_ID = ""



// IMPORTANT: SET THE EXACT AMOUNT OF STICKER IMAGES YOU'VE PLACED INTO THE 'STICKERS' FOLDER IN Assets.xcassets
let STICKERS_AMOUNT = 13



// YOU CAN CHANGE THE RGB VALUES OF THIS COLOR AS YOU WISH
let MAIN_COLOR = UIColor(red: 30/255, green: 26/255, blue: 25/255, alpha: 1.0)
let LIGHT_BLUE = UIColor(red: 238/255, green: 245/255, blue: 251/255, alpha: 1.0)




// HUD View extension
let hudView = UIView(frame: CGRect(x:0, y:0, width:120, height: 120))
let label = UILabel()
let indicatorView = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:80, height:80))

extension UIViewController {
    func showHUD(_ mess:String) {
        hudView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        hudView.backgroundColor = MAIN_COLOR
        hudView.alpha = 1.0
        hudView.layer.cornerRadius = 8
        
        indicatorView.center = CGPoint(x: hudView.frame.size.width/2, y: hudView.frame.size.height/2)
        indicatorView.activityIndicatorViewStyle = .white
        hudView.addSubview(indicatorView)
        indicatorView.startAnimating()
        view.addSubview(hudView)
        
        label.frame = CGRect(x: 0, y: 90, width: 120, height:20)
        label.font = UIFont(name: "Titillium-Semibold", size: 14)
        label.text = mess
        label.textAlignment = .center
        label.textColor = UIColor.white
        hudView.addSubview(label)
    }
    
    func hideHUD() {
        hudView.removeFromSuperview()
        label.removeFromSuperview()
    }
    
    func simpleAlert(_ mess:String) {
        let alert = UIAlertController(title: APP_NAME,
            message: mess, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
}// end extension








/****** DO NOT EDIT THE CODE BELOW *****/
let USER_CLASS_NAME = "_User"
let USER_USERNAME = "username"
let USER_EMAIL = "email"
let USER_FULLNAME = "fullName"
let USER_AVATAR = "avatar"
let USER_COVER_IMAGE = "cover"
let USER_IS_REPORTED = "isReported"
let USER_REPORT_MESSAGE = "reportMessage"
let USER_ABOUT_ME = "aboutMe"
let USER_HAS_BLOCKED = "hasBlocked"
let USER_BADGE = "hasBadge"

let STREAMS_CLASS_NAME = "Streams"
let STREAMS_USER_POINTER = "userPointer"
let STREAMS_TEXT = "text"
let STREAMS_VIDEO = "video"
let STREAMS_IMAGE = "image"
let STREAMS_AUDIO = "audio"
let STREAMS_LIKED_BY = "likedBy" // Array
let STREAMS_NOOED_BY = "nooedBy" // Array //nooedBy
let STREAMS_KEYWORDS = "keywords" // Array
let STREAMS_LIKES = "likes"
let STREAMS_NOS = "nos" //nos
let STREAMS_VIEWS = "views"
let STREAMS_PROFILE_CLICKS = "profileClicks"
let STREAMS_SHARES = "shares"
let STREAMS_COMMENTS = "comments"
let STREAMS_REPORTED_BY = "reportedBy" // Array
let STREAMS_CREATED_AT = "createdAt"

let COMMENTS_CLASS_NAME = "Comments"
let COMMENTS_USER_POINTER = "userPointer"
let COMMENTS_STREAM_POINTER = "streamPointer"
let COMMENTS_COMMENT = "comment"
let COMMENTS_REPORTED_BY = "reportedBy" // Array
let COMMENTS_CREATED_AT = "createdAt"


let FOLLOW_CLASS_NAME = "Follow"
let FOLLOW_CURR_USER = "currUser"
let FOLLOW_IS_FOLLOWING = "isFollowing"

let ACTIVITY_CLASS_NAME = "Activity"
let ACTIVITY_CURRENT_USER = "currentUser"
let ACTIVITY_OTHER_USER = "otherUser"
let ACTIVITY_STREAM_POINTER = "streamPointer"
let ACTIVITY_TEXT = "text"
let ACTIVITY_CREATED_AT = "createdAt"

let MESSAGES_CLASS_NAME = "Messages"
let MESSAGES_LAST_MESSAGE = "lastMessage"
let MESSAGES_USER_POINTER = "userPointer"
let MESSAGES_OTHER_USER = "otherUser"
let MESSAGES_ID = "chatID"

let INBOX_CLASS_NAME = "Inbox"
let INBOX_SENDER = "sender"
let INBOX_RECEIVER = "receiver"
let INBOX_INBOX_ID = "inboxID"
let INBOX_MESSAGE = "message"
let INBOX_IMAGE = "image"



var selectedStickerImage = ""
var mustRefresh = false


// SHORTCUT TO GET PARSE IMAGE
func getParseImage(_ parseObj: PFObject, imgView: UIImageView, columnName: String) {
    let imageFile = parseObj[columnName] as? PFFile
    imageFile?.getDataInBackground(block: { (data, error) in
        if error == nil { if let imageData = data {
            imgView.image = UIImage(data: imageData)
    }}})
}



// SHORTCUT TO SAVE ACTIVITY
extension UIViewController {
    func saveActivity(currUser:PFUser, streamObj:PFObject, text:String) {
        // Get User Pointer
        let userPointer = streamObj[STREAMS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                let aObj = PFObject(className: ACTIVITY_CLASS_NAME)
                aObj[ACTIVITY_CURRENT_USER] = userPointer
                aObj[ACTIVITY_OTHER_USER] = currUser
                aObj[ACTIVITY_STREAM_POINTER] = streamObj
                aObj[ACTIVITY_TEXT] = "\(currUser[USER_FULLNAME]!) " + text
                aObj.saveInBackground()

            } else {
                self.simpleAlert("\(error!.localizedDescription)")
        }})
    }
}



// SHORTCUT TO SEND A PUSH NOTIFICATION
extension UIViewController {
    func sendPushNotification(currentUser:PFUser, pushMess:String, textColumn:String, obj:PFObject, userPointerColumn:String) {
        let userPointer = obj[userPointerColumn] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                let pushStr = "\(currentUser[USER_FULLNAME]!) \(pushMess) '\(obj[textColumn]!)'"
                let data = [ "badge" : "Increment",
                             "alert" : pushStr,
                             "sound" : "bingbong.aiff"
                ]
                let request = [
                    "someKey" : userPointer.objectId!,
                    "data" : data
                    ] as [String : Any]
                
                PFCloud.callFunction(inBackground: "push", withParameters: request as [String : Any], block: { (results, error) in
                    if error == nil {
                        print ("\nPUSH SENT TO: \(userPointer[USER_USERNAME]!)\nMESSAGE: \(pushStr)\n")
                    } else {
                        self.simpleAlert("\(error!.localizedDescription)")
                }})
                
        }}) // end userPointer
    }
}





// EXTENSION TO FORMAT LARGE NUMBERS INTO K OR M (like 1.1M, 2.5K)
extension Int {
    var abbreviated: String {
        let abbrev = "KMBTPE"
        return abbrev.enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.1f%@")
            return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
            } ?? String(self)
    }
}



// MARK: - METHOD TO CREATE A THUMBNAIL OF A VIDEO
func createVideoThumbnail(_ url:URL) -> UIImage? {
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    var time = asset.duration
    time.value = min(time.value, 2)
    do { let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
        return UIImage(cgImage: imageRef)
    } catch let error as NSError {
        print("Image generation failed with error \(error)")
        return nil
    }
}



// MARK: - EXTENSION TO RESIZE A UIIMAGE
extension UIViewController {
    func scaleImageToMaxWidth(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}




// EXTENSION TO SHOW TIME AGO DATES
extension UIViewController {
    func timeAgoSinceDate(_ date:Date,currentDate:Date, numericDates:Bool) -> String {
        let calendar = Calendar.current
        let now = currentDate
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
    }
}




