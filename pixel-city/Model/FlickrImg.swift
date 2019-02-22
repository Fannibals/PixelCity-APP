//
//  FlickrImg.swift
//  pixel-city
//
//  Created by Ethan  on 22/2/19.
//  Copyright © 2019 Ethan . All rights reserved.
//

import Foundation

struct FlickrImg {
    private var _imgTitle: String
    private var _imgDescription: String
    private var _postedTime: String
    private var _latitude: String
    private var _longtitude: String
    private var _userName: String
    private var _faves: String

    
    var imgTitle: String {
        return self._imgTitle
    }
    
    var imgDescription: String {
        return self._imgDescription
    }
    
    var postedTime: String {
        return self._postedTime
    }
    
    var latitude: String {
        return self._latitude
    }
    
    var longtitude: String {
        return self._longtitude
    }
    
    var userName: String {
        return self._userName
    }
    
    var faves: String {
        return self._faves

    }
    
    init(title: String, desc: String, time: String, lat: String, logt: String, userName: String, faves: String) {
        self._imgTitle = title
        self._imgDescription = desc
        self._postedTime = time
        self._latitude = lat
        self._longtitude = logt
        self._userName = userName
        self._faves = faves
    }
}
