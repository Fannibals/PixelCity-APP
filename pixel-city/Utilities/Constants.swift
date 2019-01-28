//
//  Constants.swift
//  pixel-city
//
//  Created by Ethan  on 28/1/19.
//  Copyright © 2019 Ethan . All rights reserved.
//

import Foundation

let API_KEY = "1d55e77c668d6ef743a9fdac43f72fc6"

func flickrUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
}
