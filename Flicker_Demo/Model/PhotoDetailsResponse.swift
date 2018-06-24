//
//  PhotoDetailsResponse.swift
//  Flicker_Demo
//
//  Created by Apple on 6/22/18.
//  Copyright © 2018 Uber. All rights reserved.
//

import Foundation
class PhotoDetailsResponse
{
    static let sharedInstance = PhotoDetailsResponse()
    private init(){}

    var photosDic : [String : Any] = [:]
    var photosDicPhotos : [String : Any] = [:]
    var photosArray = [[String:Any]]()
    
    func model(_ photosDic:[String : Any]){
        self.photosDic = photosDic
        self.photosDicPhotos = photosDic["photos"] as! [String : Any]
        
        //get photo data in array type
        self.photosArray = self.photosDicPhotos["photo"] as! [[String:Any]]
    }

}
