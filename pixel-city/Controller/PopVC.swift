//
//  PopVC.swift
//  pixel-city
//
//  Created by Ethan  on 28/1/19.
//  Copyright © 2019 Ethan . All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate{
    
    // MARK: outlets
    @IBOutlet weak var popImageView: UIImageView!
    
    // MARK: variables
    var passedImage: UIImage!
    
    func initData(forImage image:UIImage) {
        self.passedImage = image
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        addDoubleTap()
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
