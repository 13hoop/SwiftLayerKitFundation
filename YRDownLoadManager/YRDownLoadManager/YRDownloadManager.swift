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
//    config.timeoutIntervalForResource = TimeInterval(3)
//    config.timeoutIntervalForRequest = TimeInterval(10)
    
    return URLSession(configuration: config, delegate: self, delegateQueue: nil)
  }()
  
  var activeTask: [URL: YRDownload] = [:]
  
  // bg-start
  func startBackgroundDownload(download: YRDownload) {
    let request = URLRequest(url: download.url, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 3000)
    
    let downloadTask = bgSession.downloadTask(with: request)
    downloadTask.resume()
    download.isDownloading = true
    download.task = downloadTask
    activeTask[download.url] = download
    
    print(#function)

  }
  
  // pause: 需要处理避免被重复的暂停操作
  func pauseDownload(download: YRDownload) {
    guard let download = activeTask[download.url] else { return }
    if download.isDownloading {
      download.task?.cancel(byProducingResumeData: { resumeData in

        print(" 暂停下载, 但是并不在这里获取resumeData ～length：\(String(describing: resumeData?.count))")
        
      })
      download.isDownloading = false
    }
  }
  
  // cancle
  var cancleTag = false
  func cancleDownload(download: YRDownload) {
    guard let download = activeTask[download.url] else { return }
    download.task?.cancel()
    cancleTag = true
    activeTask[download.url] = nil
  }
  
  // bg-resume
  func resumeBgDownload(download: YRDownload) {
//    guard let download = activeTask[download.url] else { return }
    
    print(download)
    if let resumeData = download.resumeData {
      download.task = bgSession.downloadTask(withResumeData: resumeData)
    }else {
      print(" not found pre resume, new download ... ")
      download.task = bgSession.downloadTask(with: download.url)
    }
    download.task?.resume()
    download.isDownloading = true
  }
  
  let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  func localFilePath(for url: URL) -> URL {
    return documentsPath.appendingPathComponent(url.lastPathComponent)
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

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    if let bgHandler = appDelegate.bgSessionCompletionHandler {
      bgHandler()
    }
  }
  
  /// bug: 刚开始下载就到这里了，why？ -- 由于使用的是youtu的url，如果被频繁访问，就会会给一个length=0的名为videoplay的空文件
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    print(#function)

    guard let originalURL = downloadTask.originalRequest?.url else { return }
    let download = activeTask[originalURL]
//    activeTask[originalURL] = nil
    
    let destinationUrl = localFilePath(for: originalURL)
    print("   |-->", destinationUrl)
    
    let fileManager = FileManager.default
    try? fileManager.removeItem(at: destinationUrl)
    do {
      try fileManager.copyItem(at: location, to: destinationUrl)
    }catch {
      print("复制临时文件失败")
    }
    
  }
  
  /// 基本上这是一个都会介入的方法(完成会进入／错误也会进入/cancelByPorduc这个方法还是会进入)，这里可以做很多事，具体来说：
  ///   | -> 暂停没有使用suspend，而是用的cancel(byProducingResumeData:),所以暂停的status也是`cancled`
  ///   | -> 上述带来的问题就是于真正cancle的混淆，目前可通过 activeSession 判断之
  /// 
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    
    print(#function, " ❌error❌: ", error?.localizedDescription, " -- ", NSHomeDirectory())
    
    guard let originURL = task.originalRequest?.url, let download = activeTask[originURL] else {
      print(" ～ 无效的originURL ～ ")
      return
    }
    
    if cancleTag {
//      print("  来自 cancled 操作的 task")
//      print(#function, " ❌error❌: ", error.debugDescription)
//      activeTask[originURL] = nil
 
    }
    
    
    if let error = error {
      let errorOC: NSError = error as NSError
      let resumeData = errorOC.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
      guard let data = resumeData  else {
        // alert show in mian queue, otherwhise too slow
        DispatchQueue.main.async {
          self.delegate?.errorMsg!(msg: error.localizedDescription)
        }
        return
      }
      
      download.resumeData = data
      print(download)
//      let xmlStr = String(data: data, encoding: String.Encoding.utf8)
//      print("xmlStr is: \n", xmlStr as Any)
//      print(" error here, status is", task.state.rawValue)
      self.writefile(name: "resumeData", with: data)
      
    }else {
      print("✅ 顺利完成 ✅", task.state.rawValue)
//      DispatchQueue.main.async {
//        self.delegate?.updateProgress!(precent: 0)
//      }
    }
    
  }

  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    
    guard let originURL = downloadTask.originalRequest?.url, let download = activeTask[originURL] else {
      return
    }
    download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    DispatchQueue.main.async {
      self.delegate?.updateProgress!(precent: download.progress)
    }

    //debuge
    let percent = String(format: "%.2f%%", download.progress)
    print(" ----⥤ ", percent , " temp=", bytesWritten, " recived= ", totalBytesWritten)
  }
  
  /// 下载恢复时调用: 得到正在resume的task
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {

    guard let originURL = downloadTask.originalRequest?.url, let download = activeTask[originURL] else {
      print(" 恢复下载失败 ")
      return
    }
    
    print("继续resume之后，会被调用 - offSet: ", fileOffset, " --old: ", download.progress)
    
    // 恢复进度
    download.progress = Float(fileOffset) / Float(expectedTotalBytes)
    DispatchQueue.main.async {
      self.delegate?.updateProgress!(precent: download.progress)
    }
  }
  
}

