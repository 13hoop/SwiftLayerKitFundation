//
//  YRDownloadManager.swift
//  YRDownLoadManager
//
//  Created by YongRen on 2017/7/11.
//  Copyright © 2017年 YongRen. All rights reserved.
//

import Foundation

class YRDownloadManager {
  
  static let shared: URLSession = {
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    return session
  }()
  
  
  
  
  
}
