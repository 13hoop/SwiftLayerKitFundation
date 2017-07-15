//
//  YRDownloadManager.swift
//  YRDownLoadManager
//
//  Created by YongRen on 2017/7/11.
//  Copyright © 2017年 YongRen. All rights reserved.
//

import UIKit

@objc protocol YRDownLoadDelegate {
  func download(_ url: URL, completionHandler: @escaping () -> Swift.Void)
  @objc optional func updateProgress(precent: Float)
  @objc optional func errorMsg(msg: String?)
}


class YRDownloadManager: NSObject {
  
  static let `default` = YRDownloadManager()
  var delegate: YRDownLoadDelegate?
  
  private var session: URLSession!
  private var bgSession: URLSession!
  
  private var dataTask: URLSessionDataTask?
  fileprivate var downloadTask: URLSessionDownloadTask?

  // start
  func startBackgroundDownload(urlStr: String, fileName: String) {
    
    let url = URL(string: urlStr)
    let request = URLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 3000)
    let backgroundConfig = URLSessionConfiguration.background(withIdentifier: urlStr)
    
    // debuge
    backgroundConfig.timeoutIntervalForResource = TimeInterval(20)
    backgroundConfig.timeoutIntervalForRequest = TimeInterval(3)
    
    let operationQueue = OperationQueue()
    operationQueue.name = "yongren.backgroundSessionQueen"
    operationQueue.maxConcurrentOperationCount = 3;
    
    if bgSession == nil {
//      print(" sigletion session ")
      bgSession = URLSession(configuration: backgroundConfig, delegate: self, delegateQueue: operationQueue)
    }
    
    downloadTask = bgSession.downloadTask(with: request)
    downloadTask?.resume()
  }
  
  // pause
  func pauseDownload() {
    
    if let task = downloadTask {

      print(#function, task.state)
      switch task.state {
      case .running:
        print(" running ")
        task.suspend()
      case .suspended:
        print(" suspended ")
        task.resume()
      case .canceling:
        print(" canceling ")
        task.resume()
      case .completed:
        print(" completed ")
      }
    }
    
  }
  
  
  func writefile(name: String, with data: Data) {
    do {
      let fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(name + ".xml")
      print(fileURL as Any)
      do {
        try data.write(to: fileURL, options: Data.WritingOptions.atomic)
      }catch {
        print(" write file error in: ", error.localizedDescription)
      }
    }catch {
      print(error.localizedDescription)
    }
  }
  
  func readFile() -> Data? {
    do {
      let fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("resumeData.xml")
      do {
        let data = try Data(contentsOf: fileURL)
        return data
      }catch {
        print(" read file error in: ", error.localizedDescription)
        return nil
      }
    }catch {
      print(error.localizedDescription)
      return nil
    }
  }
}

extension YRDownloadManager: URLSessionDownloadDelegate {
  
  //MARK: session delegate
  /// 后台下载全部完成后的最终代理，这里进行最终的UI刷新
  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    print(#function)
  }
  
  func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    print(" ❌error:", error.debugDescription, " 人为早成cuo wu❌")
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    
    if let error = error {
      let errorOC: NSError = error as NSError
      print(#function, " ❌error❌: ", error.localizedDescription, task.state.rawValue)
      let resumeData = errorOC.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
      guard let data = resumeData  else {
        // alert show in mian queue, otherwhise too slow
        DispatchQueue.main.async {
          self.delegate?.errorMsg!(msg: error.localizedDescription)
        }
        return
      }
      print(" ~~~~ state ", task.state.rawValue)

      let xmlStr = String(data: data, encoding: String.Encoding.utf8)
//      print("xmlStr is: \n", xmlStr as Any)
      print(" error here, status is", task.state.rawValue)
      self.writefile(name: "resumeData", with: data)
      
    }else {
      print("✅ 顺利完成 ✅", task.state.rawValue)
      DispatchQueue.main.async {
        self.delegate?.updateProgress!(precent: 0)
      }
      downloadTask = nil
    }
    
  }

  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    
    let value: Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    DispatchQueue.main.async {
      self.delegate?.updateProgress!(precent: value)
    }

    //debuge
    let percent = String(format: "%.2f%%", value)
    print(" ----⥤ ", percent , " temp=", bytesWritten, " recived= ", totalBytesWritten)
  }
  
  /// 下载恢复时调用: 得到正在resume的task
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
    print("offSet ", fileOffset, " expected: ", expectedTotalBytes)
  }
  
  /// 本次完成，得到临时文件及其url，执行完之后临时文件会被自动删除
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    print(" >>> temp ", location.debugDescription, "    ~~~ ", downloadTask.state.rawValue)
  }
}
