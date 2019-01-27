//
//  HomeVC.swift
//  
//
//  Created by Daniel Parra on 1/27/19.
//

import UIKit
import NVActivityIndicatorView

class HomeVC: UIViewController {
    
    @IBOutlet var indicator: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.startAnimating()
    }
}
