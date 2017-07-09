//
//  ViewController.swift
//  YRDownLoadManager
//
//  Created by YongRen on 2017/7/7.
//  Copyright © 2017年 YongRen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBOutlet weak var inputTF: UITextField!
  @IBAction func btnClicked(_ sender: Any) {
    
    if let str = inputTF.text {
      print("\(str) ")
    }

  }

}
