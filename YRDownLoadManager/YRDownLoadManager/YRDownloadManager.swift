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

class YRDownload {
  let url: URL!
  init(urlStr: String) {
    self.url = URL(string: urlStr)!
  }
  
  var task: URLSessionDownloadTask?
  var resumeData: Data?
  
  var progress: Float = 0.0
  var isDownloading = false
}


class YRDownloadManager: NSObject {
  
  static let `default` = YRDownloadManager()
  var delegate: YRDownLoadDelegate?
  
  lazy var session: URLSession = {
    let config = URLSessionConfiguration.default
    return URLSession(configuration: config, delegate: self, delegateQueue: nil)
  }()
  
  lazy var bgSession: URLSession = {
    let config = URLSessionConfiguration.background(withIdentifier: "com.yongren,bgSession")
    // debuge
    config.timeoutIntervalForResource = TimeInterval(20)
    config.timeoutIntervalForRequest = TimeInterval(3)
    return URLSession(configuration: config, delegate: self, delegateQueue: nil)
  }()
  
  var activeTask: [URL: YRDownload] = [:]
  
  // start
  func startBackgroundDownload(download: YRDownload) {
    let request = URLRequest(url: download.url, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 3000)
    let downloadTask = bgSession.downloadTask(with: request)
    downloadTask.resume()
    download.isDownloading = true
    download.task = downloadTask
    activeTask[download.url] = download
  }
  
  // pause
  func pauseDownload() {
    
    
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

