//
//  Downloader.swift
//  E-Shop
//
//  Created by Walid Rafei on 8/29/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import Foundation
import FirebaseStorage

let storage = Storage.storage()


func uploadImages(images: [UIImage?], itemID: String, completion: @escaping (_ imageLinks: [String]) -> Void) {
    // check if there is internet connection to upload images from Reachability swift file
    if Reachability.HasConnection() {
        var uploadImagesCount = 0
        var imageLinkArray: [String] = []
        var nameSuffix = 0
        
        for image in images {
            let fileName = "ItemImages/" + itemID + "/" + "\(nameSuffix)" + ".jpg"
            let imageData = image!.jpegData(compressionQuality: 0.8)
            saveImageInFirebase(imageData: imageData!, fileName: fileName) { (imageLink) in
                
                if imageLink != nil {
                    imageLinkArray.append(imageLink!)
                    uploadImagesCount += 1
                    if uploadImagesCount == images.count {
                        completion(imageLinkArray)
                    }
                }
            }
            nameSuffix += 1
        }
    } else{
        print("No Internet Connection");
    }
}

func saveImageInFirebase(imageData: Data, fileName: String, completion: @escaping (_ imageLink: String?) -> Void ) {
    var task: StorageUploadTask!
    
    let storageRef = storage.reference(forURL: KFILEREFERENCE).child(fileName)
    
    task = storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
        
        task.removeAllObservers()
        if error != nil {
            print("Error uploading Image", error!.localizedDescription)
            completion(nil)
            return
        }
        
        storageRef.downloadURL { (url, error) in
            guard let downloadUrl = url else {
                completion(nil)
                return
            }
            
            completion(downloadUrl.absoluteString)
        }
    })
}
    
func downloadImages(imageUrls: [String], completion: @escaping (_ images: [UIImage?]) -> Void) {
    var imageArray: [UIImage] = []
    var downloadCounter = 0
    for link in imageUrls {
            
        let url = NSURL(string: link)
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        downloadQueue.async {
            downloadCounter += 1
            let data = NSData(contentsOf: url! as URL)
                
            if data != nil {
                imageArray.append(UIImage(data:data! as Data)!)
                if downloadCounter == imageArray.count {
                    DispatchQueue.main.async {
                        completion(imageArray)
                    }
                }
            }
            else {
                print("couldn't download image")
                completion(imageArray)
            }
        }
    }
}

