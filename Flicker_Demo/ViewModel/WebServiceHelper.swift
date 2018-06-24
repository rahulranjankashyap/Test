//
//  WebServiceHelper.swift
//  Flicker_Demo
//
//  Created by Apple on 6/21/18.
//  Copyright © 2018 Uber. All rights reserved.
//

import UIKit

class WebServiceHelper {
    
    //flickr API key
    var apiKey = "833e7d1178aa789a21ce115c3337caae"
    
    var  urlStr = String()
    
    //singleton instance
    static let sharedInstanceAPI = WebServiceHelper()
    private init(){}
    
    
    
    // MARK: - get photo from server
    func load(_ urlString: String, page: String, withCompletion completion: @escaping ([String : Any]) -> Void) {
        
        
        ////url with search text and page number
        urlStr = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&tags=\(urlString)&per_page=30&format=json&nojsoncallback=1&page=\(page)"
        print(urlStr)
        let task = URLSession.shared.dataTask(with: URL(string: urlStr)!) {(data, response, error ) in
            
            guard error == nil else {
                print("returned error")
                return
            }
            
            if error != nil {
                
            }else {
                print("returned error")
            }
            
            guard let content = data else {
                
                print("No data")
                return
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                print("Not containing JSON")
                return
            }
            
            // return data in model
            PhotoDetailsResponse.sharedInstance.model(json)
            completion(json)
            
        }
        task.resume()
        
    }
}


