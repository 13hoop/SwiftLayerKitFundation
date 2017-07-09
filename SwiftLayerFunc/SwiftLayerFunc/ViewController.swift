//
//  ViewController.swift
//  SwiftLayerFunc
//
//  Created by YongRen on 2017/7/4.
//  Copyright © 2017年 YongRen. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController  {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let stockView:YRStockChartView = YRStockChartView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
    stockView.center = view.center
    view.addSubview(stockView)
  }
}

