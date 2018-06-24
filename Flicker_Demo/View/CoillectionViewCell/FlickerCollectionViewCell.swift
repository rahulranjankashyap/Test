//
//  FlickerCollectionViewCell.swift
//  Flicker_Demo
//
//  Created by Apple on 6/20/18.
//  Copyright © 2018 Uber. All rights reserved.
//

import UIKit
import Foundation

let imageCache = NSCache<AnyObject, AnyObject>.sharedInstance




@objc extension NSCache {
    class var sharedInstance: NSCache<NSString, AnyObject> {
        let cache = NSCache<NSString, AnyObject>()
        return cache
    }
}

class FlickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    private var downloadTask: URLSessionDownloadTask?
    
    ////load image
    public var imageURL: URL? {
        didSet {
            self.downloadItemImageForSearchResult(imageURL: imageURL)
        }
    }
    
    deinit {
        self.downloadTask?.cancel()
        imgView?.image = nil
    }
    
}

//MARK:
//MARK: -Image Caching
extension FlickerCollectionViewCell{
    
    
    //caching image for load on collection view
    public func downloadItemImageForSearchResult(imageURL: URL?) {
        
        if let urlOfImage = imageURL {
            if let cachedImage = imageCache.object(forKey: urlOfImage.absoluteString as NSString){
                imgView?.image = cachedImage as? UIImage
            } else {
                let session = URLSession.shared
                self.downloadTask = session.downloadTask(
                    with: urlOfImage as URL, completionHandler: { [weak self] url, response, error in
                        if error == nil, let url = url, let data = NSData(contentsOf: url), let image = UIImage(data: data as Data) {
                            
                            DispatchQueue.main.async() {
                                
                                let imageToCache = image
                                
                                if let strongSelf = self, let imageView = strongSelf.imgView {
                                    
                                    imageView.image = imageToCache
                                    
                                    imageCache.setObject(imageToCache, forKey: urlOfImage.absoluteString as NSString , cost: 1)
                                }
                            }
                        } else {
                        }
                })
                self.downloadTask!.resume()
            }
        }
    }
    
    override public func prepareForReuse() {
        self.downloadTask?.cancel()
        imgView?.image = UIImage(named: "placeholder")
    }
    
    
}

