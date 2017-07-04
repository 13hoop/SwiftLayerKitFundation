//
//  ViewController.swift
//  SwiftLayerFunc
//
//  Created by YongRen on 2017/7/4.
//  Copyright © 2017年 YongRen. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    view.backgroundColor = UIColor.gray
    
    let centerView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
    centerView.center = view.center
    centerView.backgroundColor = .white
    view.addSubview(centerView)
    
    
    let myLayer:CALayer = CALayer()
    myLayer.frame = CGRect(x: 0, y: 0, width: 250, height: 250)
    myLayer.backgroundColor = UIColor.red.cgColor
    centerView.layer.addSublayer(myLayer)
    
    
    /// using layer than UIImageView display a img
    let image = UIImage(named: "FTK.jpg")!
    myLayer.contents = image.cgImage
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

