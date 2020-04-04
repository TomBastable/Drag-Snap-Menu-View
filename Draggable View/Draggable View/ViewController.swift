//
//  ViewController.swift
//  Draggable View
//
//  Created by Tom Bastable on 03/04/2020.
//  Copyright © 2020 Tom Bastable. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var draggableView: DraggableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        draggableView.initView()
    }
    


}

