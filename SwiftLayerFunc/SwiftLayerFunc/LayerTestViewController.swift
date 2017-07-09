//
//  LayerTestViewController.swift
//  SwiftLayerFunc
//
//  Created by YongRen on 2017/7/4.
//  Copyright © 2017年 YongRen. All rights reserved.
//

import UIKit

class LayerTestViewController: UIViewController,CALayerDelegate {

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
        /*
         some layout property:
         contentsReact contentsCenter  contentsGravity contentsScale  masksToBoundle ...
         */
        let image = UIImage(named: "FTK.jpg")!
        //    myLayer.contents = image.cgImage
        //    myLayer.contentsGravity = kCAGravityResizeAspectFill // just like view's contentMode
        //    myLayer.masksToBounds = true
        //    myLayer.contentsRect = CGRect(x: 0.5, y: 0.5, width: 0.5, height: 0.5)
        
        
        myLayer.delegate = self as? CALayerDelegate
        myLayer.display()
        
        
        let imgV = UIImageView(frame: CGRect(x: 20, y: 20, width: 100, height: 100))
        imgV.image = image
        imgV.backgroundColor = UIColor.green
        view.addSubview(imgV)
        
        let maskLayer = CALayer()
        maskLayer.frame = imgV.bounds
        let maskImg = UIImage(named: "my.jpg")!
        maskLayer.contents = maskImg.cgImage
        imgV.layer.mask = maskLayer
        
      }
      
      func draw(_ layer: CALayer, in ctx: CGContext) {
        
        print(#function)
        
        let blue = UIColor.blue.cgColor
        ctx.setFillColor(blue)
        let red = UIColor.orange.cgColor
        ctx.setStrokeColor(red)
        ctx.setLineWidth(10)
        ctx.addRect(layer.bounds)
        ctx.drawPath(using: .fillStroke)
      }
      override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
      }
      
      
}
