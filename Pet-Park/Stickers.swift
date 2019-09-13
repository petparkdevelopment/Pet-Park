/*-----------------------------------
 
 - MyStream -
 
 Created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/

import UIKit


// MARK: - STICKER CELL
class StickerCell: UICollectionViewCell {
    /* Views */
    @IBOutlet weak var stickerImg: UIImageView!
}





// MARK: - STICKERS CONTROLLER
class Stickers: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout
{
    
    /* Views */
    @IBOutlet weak var stickersCollView: UICollectionView!
    
    
    /* Variables */

    
    
override func viewDidLoad() {
        super.viewDidLoad()


}


    
// MARK: - COLLECTION VIEW DELEGATES
func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
}
    
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return STICKERS_AMOUNT
    }
    
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StickerCell", for: indexPath) as! StickerCell
    
    cell.stickerImg.image = UIImage(named:"s\(indexPath.row)")

return cell
}
    
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 98, height: 98)
}
    
    
    
// TAP ON A CELL -> SHOW USER'S DETAILS
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectedStickerImage = "s\(indexPath.row)"
    dismiss(animated: true, completion: nil)
}

    
   
 
// MARK: - DISMISS BUTTON
@IBAction func dismissButt(_ sender: Any) {
    dismiss(animated: true, completion: nil)
}
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
