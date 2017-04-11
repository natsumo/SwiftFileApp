//
//  ViewController.swift
//  SwiftFileApp
//
//  Created by Natsumo Ikeda on 2016/05/30.
//  Copyright 2017 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
//

import UIKit
import NCMB

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.label.text = "カメラで写真を撮りましょう！"
    }
    
    // 「カメラ」ボタン押下時の処理
    @IBAction func cameraStart(sender: AnyObject) {

        let sourceType: UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.Camera
        // カメラが利用可能か確認する
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.presentViewController(cameraPicker, animated: true, completion: nil)
            
        } else {
            print("エラーが発生しました")
            self.label.text = "エラーが発生しました"
            
        }
    }
    
    // 撮影が終了したときに呼ばれる
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            cameraView.contentMode = .ScaleAspectFit
            cameraView.image = pickedImage
            self.label.text = "撮った写真をクラウドに保存しよう！"
            
        }
        
        // 閉じる処理
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // 撮影がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        print("キャンセルされました")
        self.label.text = "キャンセルされました"
        
    }
    
    // 「mobile backendに保存」ボタン押下時の処理
    @IBAction func saveImage(sender: AnyObject) {
        let image: UIImage! = cameraView.image
        // 画像がnilのとき
        if image == nil {
            print("画像がありません")
            self.label.text = "画像がありません"
            
            return
            
        }
        
        // 画像をリサイズする
        let imageW : Int = Int(image.size.width*0.2)
        let imageH : Int = Int(image.size.height*0.2)
        let resizeImage = resize(image, width: imageW, height: imageH)
        
        // ファイル名を決めるアラートを表示
        let alert = UIAlertController(title: "保存します", message: "ファイル名を指定してください", preferredStyle: .Alert)
        // UIAlertControllerにtextFieldを追加
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
        }
        // アラートのOK押下時の処理
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { (action: UIAlertAction!) -> Void in
            // 入力したテキストをファイル名に指定
            let fileName = alert.textFields![0].text! + ".png"
            
            // 画像をNSDataに変換
            let pngData = NSData(data: UIImagePNGRepresentation(resizeImage)!)
            let file = NCMBFile.fileWithName(fileName, data: pngData) as! NCMBFile
            
            // ACL設定（読み書き可）
            let acl = NCMBACL()
            acl.setPublicReadAccess(true)
            acl.setPublicWriteAccess(true)
            file.ACL = acl
            
            // ファイルストアへ画像のアップロード
            file.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                if error != nil {
                    // 保存失敗時の処理
                    print("保存に失敗しました。エラーコード：\(error.code)")
                    self.label.text = "保存に失敗しました：\(error.code)"
                    
                } else {
                    // 保存成功時の処理
                    print("保存に成功しました")
                    self.label.text = "保存に成功しました"
                    
                }
                
            }, progressBlock: { (int: Int32) -> Void in
                self.label.text = "保存中：\(int)％"
                
            })
        })
        
        // アラートのCancel押下時の処理
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction!) -> Void in
            print("保存がキャンセルされました")
            self.label.text = "保存がキャンセルされました"
            
        })
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // 画像をリサイズする処理
    func resize (image: UIImage, width: Int, height: Int) -> UIImage {
        let size: CGSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizeImage
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

