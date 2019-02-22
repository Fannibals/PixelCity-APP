//
//  PopVC.swift
//  pixel-city
//
//  Created by Ethan  on 28/1/19.
//  Copyright © 2019 Ethan . All rights reserved.
//

import UIKit
import MapKit

class PopVC: UIViewController, UIGestureRecognizerDelegate{
    
    // MARK: outlets
    @IBOutlet weak var popImageView: UIImageView!
    @IBOutlet weak var imgTitle: UILabel!
    @IBOutlet weak var imgDescription: UILabel!
    @IBOutlet weak var imgTimePosted: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: variables
    var passedImage: UIImage!
    var _title: String!
    var _desc: String!
    var _time: String!
    var _lat: String!
    var _logt: String!
    
    func initData(forImage image:UIImage, title:String, desc: String,time: String, lat: String, logt: String) {
        self.passedImage = image
        self._title = title
        self._desc = desc
        self._time = time
        self._lat = lat
        self._logt = logt
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        addDoubleTap()
        mapView.delegate = self
    }
    
    func setUpView() {
        popImageView.image = passedImage
        self.imgTitle.text = self._title
        self.imgDescription.text = self._desc
        self.imgTimePosted.text = self._time
        let lat = Double(self._lat)
        let logt = Double(self._logt)
        
        let initialLocation = CLLocation(latitude: lat!, longitude: logt!)
        let regionRadius: CLLocationDistance = 100

        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        let annotation = DroppablePin(coordinate: initialLocation.coordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        


    }
    
    // gesture
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        self.view.addGestureRecognizer(doubleTap)
    }
    
    @objc func tapToDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

extension PopVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
}
