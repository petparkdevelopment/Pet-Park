/*-----------------------------------
 
 - MyStream -
 
 Created by cubycode ©2017
 All Rights reserved
 
-----------------------------------*/

import UIKit
import Parse
import MobileCoreServices
import AssetsLibrary
import AVFoundation
import AVKit


class AddStream: UIViewController,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UITextViewDelegate,
AVAudioRecorderDelegate,
AVAudioPlayerDelegate
{
    
    /* Views */
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var streamTxt: UITextView!
    @IBOutlet weak var streamImg: UIImageView!
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var recordingView: UIView!
    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var recordingWebView: UIWebView!
    @IBOutlet weak var postOutlet: UIButton!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var removeImageOutlet: UIButton!
    
    
    
    
    /* Variables */
    var streamAttachment = ""
    var videoURL:URL?
    var audioURL:URL?
    var recorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var audioIsPlaying = false
    
    
    
    
override func viewDidAppear(_ animated: Bool) {
    // Attach a Sticker
    if selectedStickerImage != "" {
        streamImg.image = UIImage(named:selectedStickerImage)
        streamAttachment = "sticker"
        removeImageOutlet.isHidden = false
    }
    
    // Show the keyboard
    streamTxt.becomeFirstResponder()
}
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Initial Layout
    recordingView.frame.origin.y = view.frame.size.height
    optionsView.frame.origin.y = view.frame.size.height

    
    // Get user's avatar and full name
    let currUser = PFUser.current()!
    avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
    avatarImg.layer.borderWidth = 2
    avatarImg.layer.borderColor = UIColor(red: 0/255, green: 157/255, blue: 255/255, alpha: 1.0).cgColor
    fullNameLabel.text = "\(currUser[USER_FULLNAME]!)"
    getParseImage(currUser, imgView: avatarImg, columnName: USER_AVATAR)
    
    
    
    // Get shortcut from the Home screen
    print("\nSTREAM ATTACHMENT: \(streamAttachment)\n")
    if streamAttachment == "image" { Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(addImage), userInfo: nil, repeats: false)
    } else if streamAttachment == "video" { Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(addVideo), userInfo: nil, repeats: false)
    } else if streamAttachment == "audio" { Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(addAudio), userInfo: nil, repeats: false) }
    
    
    
    // Init a keyboard toolbar
    let toolbar = UIView(frame: CGRect(x: 0, y: view.frame.size.height+44, width: view.frame.size.width, height: 44))
    toolbar.backgroundColor = LIGHT_BLUE
    
    let doneButt = UIButton(frame: CGRect(x: toolbar.frame.size.width - 60, y: 0, width: 44, height: 44))
    doneButt.setBackgroundImage(UIImage(named:"dismiss_butt_black"), for: .normal)
    doneButt.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
    toolbar.addSubview(doneButt)
    
    let addButton = UIButton(frame: CGRect(x: 12, y: 0, width: toolbar.frame.size.width - doneButt.frame.size.width - 60, height: 44))
    addButton.setTitle("Add to your Timeline", for: .normal)
    addButton.contentHorizontalAlignment = .left
    addButton.setTitleColor(UIColor.black, for: .normal)
    addButton.titleLabel?.font = UIFont(name: "Titillium-Regular", size: 14)
    addButton.addTarget(self, action: #selector(showOptionsView), for: .touchUpInside)
    toolbar.addSubview(addButton)
    
    let photoImg = UIImageView(image: UIImage(named:"icons8-picture-50"))
    photoImg.frame = CGRect(x: doneButt.frame.origin.x - 48, y: 7, width: 30, height: 30)
    toolbar.addSubview(photoImg)
    
    let videoImg = UIImageView(image: UIImage(named:"icons8-video-call-50"))
    videoImg.frame = CGRect(x: photoImg.frame.origin.x - 38, y: 7, width: 30, height: 30)
    toolbar.addSubview(videoImg)
    
    let audioImg = UIImageView(image: UIImage(named:"icons8-audio-wave-50"))
    audioImg.frame = CGRect(x: videoImg.frame.origin.x - 38, y: 7, width: 30, height: 30)
    toolbar.addSubview(audioImg)
    
    let stickerImg = UIImageView(image: UIImage(named:"icons8-sticker-100"))
    stickerImg.frame = CGRect(x: audioImg.frame.origin.x - 38, y: 7, width: 30, height: 30)
    toolbar.addSubview(stickerImg)
    
    streamTxt.inputAccessoryView = toolbar
    streamTxt.delegate = self

    
    // Call method to prepare the Audio Recorder
    prepareAudioRecorder()
}
    
    
    
// MARK: - TEXTVIEW DELEGATES
func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    
    var textFrame = textView.frame
    textFrame.size.height = textView.contentSize.height
    textView.frame = textFrame
    
    // Move the streamTxt down
    attachmentView.frame.origin.y = textView.frame.origin.y + textView.frame.size.height
    
    // Increase the containerScrollview's height
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width,
                                             height: attachmentView.frame.origin.y + attachmentView.frame.size.height + 40)
return true
}
 
func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == "What do you want to post?" {
        textView.text = ""
    }
    postOutlet.isEnabled = true
}

func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text == "" {
        textView.text = "What do you want to post?"
        postOutlet.isEnabled = false
    }
}

    
    
    
    
// MARK: - ADD IMAGE FUNCTION
@objc func addImage() {
    let alert = UIAlertController(title: APP_NAME,
        message: "Add Photo",
        preferredStyle: .alert)
    
    let camera = UIAlertAction(title: "Take a Picture", style: .default, handler: { (action) -> Void in
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    })
    
    let library = UIAlertAction(title: "Pick from Library", style: .default, handler: { (action) -> Void in
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    })
    
    // Cancel button
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
    
    alert.addAction(camera)
    alert.addAction(library)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}
    
    
    
    
    
    
// MARK: - ADD VIDEO FUNCTION
@objc func addVideo() {
    let alert = UIAlertController(title: APP_NAME,
        message: "Add Video",
        preferredStyle: .alert)
    
    // Open video Camera
    let videoCamera = UIAlertAction(title: "Take a Video", style: .default, handler: { (action) -> Void in
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [String(kUTTypeMovie)]
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            // imagePicker.videoMaximumDuration = 20.0
            self.present(imagePicker, animated: true, completion: nil)
        }
    })
    
    // Open Video library
    let videoLibrary = UIAlertAction(title: "Choose a Video", style: .default, handler: { (action) -> Void in
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [String(kUTTypeMovie)]
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            // imagePicker.videoMaximumDuration = 20.0
            self.present(imagePicker, animated: true, completion: nil)
        }
    })
    
    // Cancel button
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
    
    alert.addAction(videoCamera)
    alert.addAction(videoLibrary)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}
    

    
// MARK: - ImagePicker delegate
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    let mediaType = info[UIImagePickerControllerMediaType] as! String
        
    // mediaType is IMAGE
    if mediaType == kUTTypeImage as String {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        streamImg.image = scaleImageToMaxWidth(image: image, newWidth: 600)
        streamAttachment = "image"
        playVideoButton.isHidden = true

            
    // mediaType is VIDEO
    } else if mediaType == kUTTypeMovie as String {
        let videoPath = info[UIImagePickerControllerMediaURL] as! URL
        videoURL = videoPath
        
        // Convert video
        convertVideoToMp4()
        
        // Make thumbnail
        streamImg.image = createVideoThumbnail(videoURL!)!
        streamAttachment = "video"
        playVideoButton.isHidden = false
    }
    
    removeImageOutlet.isHidden = false
    dismiss(animated: true, completion: nil)
}
    

  
    
    
// MARK: - ADD STICKER FUNCTION
@objc func addSticker() {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "Stickers") as! Stickers
    present(aVC, animated: true, completion: nil)
}
    

    

    
    
// MARK: - ADD AUDIO FUNCTION
@objc func addAudio() {
    let alert = UIAlertController(title: APP_NAME,
        message: "Add Audio",
        preferredStyle: .alert)
    let record = UIAlertAction(title: "Record Audio", style: .default, handler: { (action) -> Void in
        self.removeImageOutlet.isHidden = false
        self.showRecordingViewAndRecord()
    })

    
    // Cancel button
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        self.removeImageOutlet.isHidden = true
    })

    alert.addAction(record)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}

    
    
    
    
// MARK: - SHOW RECORDING VIEW AND RECORD AUDIO
func showRecordingViewAndRecord() {
    recordingView.frame.origin.y = 0
    if !recorder!.isRecording {
        recorder!.record()
        
        let url = Bundle.main.url(forResource: "recording", withExtension: "gif")!
        let data = try! Data(contentsOf: url)
        recordingWebView.load(data, mimeType: "image/gif", textEncodingName: "UTF-8", baseURL: NSURL() as URL)
        recordingWebView.scalesPageToFit = true
        recordingWebView.contentMode = UIViewContentMode.scaleAspectFit
        
        // Call timer to update the recording time
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateRecTime), userInfo: nil, repeats: true)
    }
}
    
@objc func updateRecTime() {
    let minutes = floor(recorder!.currentTime/60)
    let seconds = recorder!.currentTime - (minutes * 60)
    let time = String(format: "%0.0f:%0.0f", minutes, seconds)
    recordTimeLabel.text = time;
}

// MARK: - STOP RECORDING BUTTON
@IBAction func stopRecordingButt(_ sender: Any) {
    if recorder!.isRecording {
        recorder!.stop()
        recordingView.frame.origin.y = view.frame.size.height
        streamAttachment = "audio"
        streamImg.image = UIImage(named:"audio_image")
        playVideoButton.isHidden = false
    
        // Set audioURL
        audioURL = recorder!.url
        print("AUDIO URL: \(String(describing: audioURL))")
        print("STREAM ATTACHMENT: \(String(describing: streamAttachment))")
    }
}
    
    
    
    
    
    
    
    
// MARK: - SHOW OPTIONS VIEW
@objc func showOptionsView() {
    dismissKeyboard()
    optionsView.frame.origin.y = view.frame.size.height - optionsView.frame.size.height
}

// MARK: - HIDE OPTIONS VIEW BUTTON
@IBAction func hideOptionsView(_ sender: Any) {
    optionsView.frame.origin.y = view.frame.size.height
    streamTxt.becomeFirstResponder()
}
    
// PHOTO BUTTON
@IBAction func photoButt(_ sender: Any) {
    addImage()
    hideOptionsView(self)
}
    
// VIDEO BUTTON
@IBAction func videoButt(_ sender: Any) {
    addVideo()
    hideOptionsView(self)
}
    
// AUDIO BUTTON
@IBAction func audioButt(_ sender: Any) {
    addAudio()
    hideOptionsView(self)
}

// STICKER BUTTON
@IBAction func stickerButt(_ sender: Any) {
    addSticker()
    hideOptionsView(self)
}
    
    
    
    
    
    
// MARK: - PLAY VIDEO OR AUDIO BUTTON
@IBAction func playVideoAudioButt(_ sender: Any) {
    
    // PLAY VIDEO
    if streamAttachment == "video" {
        print("VIDEO URL: \(String(describing: videoURL))")
        
        let player = AVPlayer(url: videoURL!)
        let pVC = AVPlayerViewController()
        pVC.player = player
        self.present(pVC, animated: true) {
            pVC.player!.play()
        }
        
    // PLAY AUDIO
    } else if streamAttachment == "audio" {
        if !audioIsPlaying {
            audioPlayer = try? AVAudioPlayer(contentsOf: audioURL!)
            audioPlayer!.delegate = self
            audioPlayer!.play()
            audioIsPlaying = true
            
            // Set stop button icon
            playVideoButton.setBackgroundImage(UIImage(named:"stop_butt"), for: .normal)
        } else {
            audioIsPlaying = false
            audioPlayer!.stop()
            playVideoButton.setBackgroundImage(UIImage(named:"play_butt"), for: .normal)
        }
    }
}

// Audio Player finish playing
func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    audioIsPlaying = false
    playVideoButton.setBackgroundImage(UIImage(named:"play_butt"), for: .normal)
}

    
    
// MARK: - REMOVE IMAGE THUMBNAIL BUTTON
@IBAction func removeImageButt(_ sender: Any) {
    // Reset variables
    streamImg.image = nil
    videoURL = nil
    audioURL = nil
    playVideoButton.isHidden = true
    streamAttachment = ""
    selectedStickerImage = ""
    removeImageOutlet.isHidden = true
}
    

    
// MARK: - CONVERT VIDEO INTO .MP4 FORMAT
    var exportSession:AVAssetExportSession!
func convertVideoToMp4() {
    let avAsset = AVURLAsset(url: videoURL!)
        
    // Create Export session
    exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)
        
    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let myDocumentPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("temp.mp4").absoluteString
    _ = NSURL(fileURLWithPath: myDocumentPath)
    let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
    let filePath = documentsDirectory2.appendingPathComponent("video.mp4")
    deleteFile(filePath: filePath as NSURL)
        
    //Check if the file already exists then remove the previous file
    if FileManager.default.fileExists(atPath: myDocumentPath) {
        do { try FileManager.default.removeItem(atPath: myDocumentPath)
        } catch let error { print(error) }
    }
        
    exportSession!.outputURL = filePath
    exportSession!.outputFileType = AVFileType.mp4
    exportSession!.shouldOptimizeForNetworkUse = true
    let start = CMTimeMakeWithSeconds(0.0, 0)
    let range = CMTimeRangeMake(start, avAsset.duration)
    exportSession?.timeRange = range
        
    exportSession!.exportAsynchronously(completionHandler: {() -> Void in
        switch self.exportSession!.status {
            case .failed:
                print(self.exportSession!.error!.localizedDescription)
            case .cancelled:
                print("Export canceled")
            case .completed:
                // Video conversion finished
                print("MP4 VIDEO URL: \(self.exportSession!.outputURL!))")
                
        default: break }
    })
}

    
    
    
    
// MARK: - POST STREAM BUTTON
@IBAction func postStreamButt(_ sender: Any) {
    let sObj = PFObject(className: STREAMS_CLASS_NAME)
    let currentUser = PFUser.current()!
    
    if streamTxt.text == "What do you want to post?" || streamTxt.text == "" {
        simpleAlert("You must type something!")
   
    } else {
        showHUD("Please wait...")
        dismissKeyboard()
        
        // Prepare data
        sObj[STREAMS_USER_POINTER] = currentUser
                sObj[STREAMS_TEXT] = self.streamTxt.text
        sObj[STREAMS_LIKES] = 0
        sObj[STREAMS_COMMENTS] = 0
        sObj[STREAMS_VIEWS] = 0
        sObj[STREAMS_PROFILE_CLICKS] = 0
        sObj[STREAMS_SHARES] = 0
        sObj[STREAMS_NOOED_BY] = 0
        sObj[STREAMS_NOS] = 0

        let reportedBy = [String]()
        sObj[STREAMS_REPORTED_BY] = reportedBy
        let likedBy = [String]()
        sObj[STREAMS_LIKED_BY] = likedBy
        let nooedBy = [String]()
        sObj[STREAMS_NOOED_BY] = nooedBy

        // Prepare keywords
        let k1 = self.streamTxt.text.lowercased().components(separatedBy: " ")
        let k2 = "\(currentUser[USER_USERNAME]!)".lowercased().components(separatedBy: " ")
        let k3 = "\(currentUser[USER_FULLNAME]!)".lowercased().components(separatedBy: " ")
        let keywords = k1 + k2 + k3
        sObj[STREAMS_KEYWORDS] =  keywords
        
        
        // Prepare Image
        if self.streamImg.image != nil {
            let imageData = UIImageJPEGRepresentation(self.streamImg.image!, 1.0)
            let imageFile = PFFile(name:"image.jpg", data:imageData!)
            sObj[STREAMS_IMAGE] = imageFile
        }
        
        // Prepare Video
        if self.streamAttachment == "video" {
            let videoURL = self.exportSession.outputURL!
            let videoData = try! Data(contentsOf: videoURL)
            let videoFile = PFFile(name:"video.mp4", data:videoData)
            sObj[STREAMS_VIDEO] = videoFile
            
            
        // Prepare Audio
        } else if self.streamAttachment == "audio" {
            let audioData = try! Data(contentsOf: self.audioURL!)
            let audioFile = PFFile(name: "audio.wav", data: audioData)
            sObj[STREAMS_AUDIO] = audioFile
        }
        
        
        // Saving block
        sObj.saveInBackground(block: { (succ, error) in
            if error == nil {
                self.hideHUD()
                
                let alert = UIAlertController(title: APP_NAME,
                    message: "Your post has been created!",
                    preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    // Dismiss controller
                    self.removeImageButt(self)
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)

            // error
            } else {
                self.hideHUD()
                self.simpleAlert("\(error!.localizedDescription)")
        }})
        
    }// end IF
}


// DELETE VIDEO FILE AFTER SAVING IT
func deleteFile(filePath:NSURL) {
    guard FileManager.default.fileExists(atPath: filePath.path!) else {
        return
    }
        
    do { try FileManager.default.removeItem(atPath: filePath.path!)
    } catch { fatalError("Unable to delete file: \(error)") }
}
    
    
    
// MARK: - PREPARE THE AUDIO RECORDER
func prepareAudioRecorder() {
    let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let recordingName = "sound.wav"
    let pathArray = [dirPath, recordingName]
    let filePath = NSURL.fileURL(withPathComponents: pathArray)
    let recordSettings = [
        AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
        AVEncoderBitRateKey: 8,
        AVNumberOfChannelsKey: 2,
        AVFormatIDKey: Int(kAudioFormatLinearPCM),
        AVSampleRateKey: 44100.0] as [String : Any]
    
    let session = AVAudioSession.sharedInstance()
    do { try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        recorder = try AVAudioRecorder(url: filePath!, settings: recordSettings as [String : AnyObject])
    } catch _ {  print("Error") }
    
    recorder!.delegate = self
    recorder!.isMeteringEnabled = true
    recorder!.prepareToRecord()
}
 
    
    
// MARK: - DISMISS KEYBOARD
@objc func dismissKeyboard() { streamTxt.resignFirstResponder() }
    
    
    
// MARK: - DISMISS BUTTON
@IBAction func dismissButt(_ sender: Any) {
    dismissKeyboard()
    removeImageButt(self)
    dismiss(animated: true, completion: nil)
}

   
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
