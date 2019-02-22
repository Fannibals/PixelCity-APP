//
//  MapVC.swift
//  pixel-city
//
//  Created by Ethan  on 28/1/19.
//  Copyright © 2019 Ethan . All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import AlamofireImage
import CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    // MARK: outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewBotConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!
    
    // MARK: variables
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    var screenSize = UIScreen.main.bounds
    var spinner : UIActivityIndicatorView?
    var progressLbl : UILabel?
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView : UICollectionView?
    
    // arrays
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    var flickrImgs = [FlickrImg]()
    var faveArray = [String]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        //collectionView part
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        pullUpView.addSubview(collectionView!)
        
        registerForPreviewing(with: self, sourceView: collectionView!)
        
        // accurate location
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        self.mapView.showsUserLocation = true
        
    }
    
    // UI set up
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: screenSize.width / 2, y: 150)
        spinner?.style = .whiteLarge
        spinner?.color = UIColor.darkGray
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    // Using the autoLayout to do it again
    func addProgressLbl() {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 150, y: 175, width: 300, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 18)
        progressLbl?.textColor = UIColor.darkGray
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgressLbl() {
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }
    
    func animateViewUp() {
        mapViewBotConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        cancelAllSessions()
        mapViewBotConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func centerMapBtnPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}




extension MapVC: MKMapViewDelegate {
    
    // change the color of the pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // let userLocation be the default one
        if annotation is MKUserLocation {
            return nil
        }
        
        var pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: DROP_PIN
    @objc func dropPin(sender: UITapGestureRecognizer) {
        //
        removePin()
        removeSpinner()
        removeProgressLbl()
        cancelAllSessions()
        
        imageArray = []
        imageUrlArray = []
        flickrImgs = []
        collectionView?.reloadData()
        
        //
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()

        
        // drop the pin on the map
        let touchPoint = sender.location(in: mapView)
        
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        // api
        let url = flickrUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 40)
        retrieveUrls(forAnnotation: annotation) { (success) in
            if success {
                self.retrieveImages(handler: { (sucess) in
                    if success {
                        self.removeSpinner()
                        self.removeProgressLbl()
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
        
        // same as above
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
        imageUrlArray = []
        flickrImgs = []
        
        Alamofire.request(flickrUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            
            if response.result.error == nil {
                guard let json = response.result.value as? Dictionary<String, AnyObject> else {return}
                let photosDict = json["photos"] as! Dictionary<String, AnyObject>
                let photoDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]

                
                for photo in photoDictArray {
                    let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                    self.imageUrlArray.append(postUrl)
                    let title = "\(photo["title"]!)"
                    let id = "\(photo["id"]!)"
                    let secret = "\(photo["secret"]!)"
                    
                    Alamofire.request(flickrGetInfo(key: API_KEY, photoId: id, secret: secret)).responseJSON(completionHandler: { (response) in
                        
                        if response.result.error == nil {
                            guard let json = response.result.value as? Dictionary<String, AnyObject> else {return}
                            let photoDict = json["photo"] as! Dictionary<String, AnyObject>
                            let time = photoDict["dates"]!["posted"]! as! String
                            let unixTime = Double(time)
                            let date = Date(timeIntervalSince1970: unixTime!)
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
                            dateFormatter.locale = NSLocale.current
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" //Specify your format that you want
                            let strDate = dateFormatter.string(from: date)
                            
                            let desc = photoDict["description"]!["_content"]! as! String
                            let userName = photoDict["owner"]!["username"]! as! String
                            let pos_lat = photoDict["location"]!["latitude"]!! as! String
                            let pos_lot = photoDict["location"]!["longitude"]!! as! String
                            Alamofire.request(flickrGetFaves(key: API_KEY, photoId: id)).responseJSON(completionHandler: { (response) in
                                
                                if response.result.error == nil {
                                    guard let json = response.result.value as? Dictionary<String, AnyObject> else {return}
                                    let photoDict = json["photo"] as! Dictionary<String, AnyObject>
                                    let faves = photoDict["total"]! as! String
                                    let flickImg = FlickrImg(title: title, desc: desc, time: strDate, lat: pos_lat, logt:pos_lot, userName: userName, faves:faves)
                                    print(flickImg)
                                    self.flickrImgs.append(flickImg)
                                }
                            })
                        }
                    })
                 
                }
                handler(true)
            }
        }
    }
    
    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
        imageArray = []
        
        for url in imageUrlArray {
            Alamofire.request(url).responseImage { (response) in
                if response.result.error == nil {
                    guard let image = response.result.value else {return}
                    self.imageArray.append(image)
                    self.progressLbl?.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"
                    
                    if self.imageArray.count == self.imageUrlArray.count {
                        handler(true)
                    }
                }
            }
        }
    }
    
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({$0.cancel()})
            downloadData.forEach({$0.cancel()})
        }
    }
    
}

extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}


extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {return UICollectionViewCell()}
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return}
        popVC.initData(forImage: imageArray[indexPath.row],title:flickrImgs[indexPath.row].imgTitle, desc: flickrImgs[indexPath.row].imgDescription, time: flickrImgs[indexPath.row].postedTime, lat: flickrImgs[indexPath.row].latitude, logt: flickrImgs[indexPath.row].longtitude)
        present(popVC, animated: true, completion: nil)
    }
    
}


extension MapVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else {return nil}
        let imgDetail = ImgDetailVC()
        imgDetail.configure(name: flickrImgs[indexPath.row].userName, fave: flickrImgs[indexPath.row].faves, img: imageArray[indexPath.row])
        imgDetail.modalPresentationStyle = .custom
        
        previewingContext.sourceRect = cell.contentView.frame
        
        return imgDetail
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
}


