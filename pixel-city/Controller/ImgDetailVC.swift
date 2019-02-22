//
//  ImgDetailVC.swift
//  pixel-city
//
//  Created by Ethan  on 22/2/19.
//  Copyright © 2019 Ethan . All rights reserved.
//

import UIKit

class ImgDetailVC: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var favesLbl: UILabel!
    @IBOutlet weak var ownerLbl: UILabel!
    
    var name: String?
    var fave: String?
    var imgForTap: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    func configure(name: String, fave: String, img:UIImage) {
        self.name = name
        self.fave = fave
        self.imgForTap = img
    }
    func setupViews() {
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imgViewClick))
        self.img?.addGestureRecognizer(singleTapGesture)
        self.img?.isUserInteractionEnabled = true
        
        self.favesLbl.text = "Faves: \(self.fave!)"
        self.ownerLbl.text = "Username: \(self.name!)"
        self.img.image = self.imgForTap!

    }
    
    @objc func imgViewClick() {
        dismiss(animated: true, completion: nil)
    }
    
}
