//
//  ViewController.swift
//  YRDownLoadManager
//
//  Created by YongRen on 2017/7/7.
//  Copyright © 2017年 YongRen. All rights reserved.
//

import UIKit
//import Alamofire

class ViewController: UIViewController, URLSessionDataDelegate, URLSessionDownloadDelegate {

  var percents = 0;
  @IBOutlet weak var progressBar: UIProgressView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
//    inputTF.text = otherStr
    inputTF.text = testBachStr
  }
  
  
  let testBachStr = "https://r4---sn-i3beln7d.googlevideo.com/videoplayback?dur=566.732&ms=au&mm=31&mv=m&mt=1499848713&mn=sn-i3beln7d&source=youtube&clen=428405616&signature=0F1C2BE9FD99E7CF4CF12E93FDFA334D83B7E57C.5BFACD0E67A297E290F8C83A91D8BBFD7667D852&lmt=1460365519527244&itag=264&key=yt6&mime=video%2Fmp4&ipbits=0&requiressl=yes&keepalive=yes&pl=48&gir=yes&expire=1499870386&sparams=clen%2Cdur%2Cei%2Cgir%2Cid%2Cinitcwndbps%2Cip%2Cipbits%2Citag%2Ckeepalive%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cpl%2Crequiressl%2Csource%2Cexpire&id=o-ABvaD_0G0n7bmD8CpJXTquZzHErR1maZj-HvFKbcY8g6&initcwndbps=1385000&ip=2001%3A250%3A209%3A6901%3A4cc9%3A652d%3A9ee5%3Aa639&ei=UuBlWYTQL4jQ4QLMw5XgBg"
  
  let otherStr = "http://sw.bos.baidu.com/sw-search-sp/software/797b4439e2551/QQ_mac_5.0.2.dmg"
  @IBOutlet weak var inputTF: UITextField!
  @IBAction func btnClicked(_ sender: Any) {
    
    guard let urlStr = inputTF.text else {
      print("输入正确的url")
      return
    }
    
    
    if let task = downloadTask {
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
    }else {
      print(" 创建 ")
      backgroundDownload(urlStr: urlStr)
    }
  }
  
  @IBAction func cancleBtnClicked(_ sender: Any) {
    guard let task = downloadTask else {
      print(" no task for cancle ... ")
      return
    }
    
    print(" cancle: ", task.state.rawValue)
    switch task.state {
    case .running:
      print(" running ~> cancle ")
      task.cancel()
    case .suspended:
      print(" suspended ")
      task.resume()
    case .canceling:
      print(" canceling ~> resumeData")
      
      if let resumeData = readFile() {
        sharedBgSession.downloadTask(withResumeData: resumeData)
      }
    case .completed:
      print(" completed ")
      if let resumeData = readFile() {
        sharedBgSession.downloadTask(withResumeData: resumeData).resume()
      }
    }

  }
  
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
//      print(#function, " ❌error❌: ", errorOC.userInfo)

      let resumeData = errorOC.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
      guard let data = resumeData  else {
        // alert show in mian queue, otherwhise too slow
        DispatchQueue.main.async {
          print(" request done, but no data recieved... totolly clear")
          let vc = UIAlertController(title: "waring", message: "no data recieved... totolly clear, check network!", preferredStyle: .alert)
          let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { _ in
            
          })
          vc.addAction(alertAction)
          self.present(vc, animated: true, completion: nil)
        }
        return
      }
      
      let xmlStr = String(data: data, encoding: String.Encoding.utf8)
      print("xmlStr is: \n", xmlStr as Any)
      
      print(" error here, status is", task.state.rawValue)
      self.writefile(name: "resumeData", with: data)
    }else {
      
      print("✅ 顺利完成 ✅")
      DispatchQueue.main.async {
        // UI here
        self.progressBar.setProgress(0, animated: true)
      }
      downloadTask = nil
    }
    
  }
  
  //MARK: data task delegate
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    print(" ----⥤ ", data.count)
  }
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
    print("data task 变成 downLoad task")
  }
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
    print(" do catche here ...")
  }
  
  /// received the initial reply header
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
    print(" 😋 receive response header: ", response, response.expectedContentLength)
    
  }
  
  //MARK: downLoad task delegate
  /** 跟踪下载进度:
      bytesWritten 本次下载的大小
      percent = totalBytesWritten / totalBytesExpectedToWrite
    
   */
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    
    let value: Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    let percent = String(format: "%.2f%%", value)
    print(" ----⥤ ", percent , " tt=", bytesWritten, downloadTask.state.rawValue)
    
    DispatchQueue.main.async {
      self.progressBar.setProgress(value, animated: false)
    }
  }
  
  /// 下载恢复时调用: 得到正在resume的task
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
   print("oofSet ", fileOffset, " expected: ", expectedTotalBytes)
  }
  
  /// 本次完成，得到临时文件及其url，执行完之后临时文件会被自动删除
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    
    print(" >>> temp ", location.debugDescription, "    ~~~ ", downloadTask.state.rawValue)
    
  }
  
  
  /* ********************************** *
   CachePolicy:
   - useProtocolCachePolicy: 默认，没有就新建，有就接着head开始
   - reloadIgnoringLocalCacheData: 忽略本地
   - reloadIgnoringLocalAndRemoteCacheData // Unimplemented
   - returnCacheDataElseLoad
   - returnCacheDataDontLoad
   - reloadRevalidatingCacheData
   */
  
  var sharedBgSession = URLSession()
  var downloadTask: URLSessionTask? = nil
  
  /// url -> session -> task -> UI
  func backgroundDownload(urlStr: String) {
    let url = URL(string: urlStr)
    let request = URLRequest(url: url!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 3000)
    let backgroundConfig = URLSessionConfiguration.background(withIdentifier: urlStr)
    backgroundConfig.timeoutIntervalForResource = TimeInterval(10)
    let operationQueue = OperationQueue()
    operationQueue.name = "YRDownloadOp"
    operationQueue.maxConcurrentOperationCount = 3;
    sharedBgSession = URLSession(configuration: backgroundConfig, delegate: self, delegateQueue: operationQueue)
    downloadTask = sharedBgSession.downloadTask(with: request)
    downloadTask?.resume()
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
