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
    
    inputTF.text = otherStr
  }
  
  
  let testBachStr = "https://r2---sn-oguesnzd.googlevideo.com/videoplayback?dur=180.063&ms=au&mm=31&mv=m&mt=1499786477&mn=sn-oguesnzd&source=youtube&clen=73722926&lmt=1442923898466317&itag=298&key=yt6&mime=video%2Fmp4&ipbits=0&requiressl=yes&keepalive=yes&pl=23&gir=yes&expire=1499808154&sparams=clen%2Cdur%2Cei%2Cgir%2Cid%2Cinitcwndbps%2Cip%2Cipbits%2Citag%2Ckeepalive%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cpl%2Crequiressl%2Csource%2Cexpire&id=o-AKd69wes67Y_yzOFBUCoH6b-Eoe73iGglGwMZJM_i4wE&initcwndbps=1966250&ip=106.187.98.213&ei=Ou1kWbefJYjQ4QLFpq_gCA&alr=yes&ratebypass=yes&signature=70BDB42AB5BDC9F6020FCF31050E0580D503E12A.3CA87906C5EDAF23426AC54BF9213A11FCBF5FD1&cpn=x-q5CuUfSBItO3Z6&c=WEB&cver=1.20170710&rn=0&rbuf=0"
  
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
  
  
  //MARK: session delegate
  /// 后台下载全部完成后的最终代理，这里进行最终的UI刷新
  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    print(#function)
    
    
  }
  
  func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    print(" ❌error:", error.debugDescription)
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    print(#function, " ❌error: ", error.debugDescription, task.state.rawValue)
    downloadTask = nil
    
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
    let operationQueue = OperationQueue()
    operationQueue.name = "YRDownloadOp"
    operationQueue.maxConcurrentOperationCount = 3;
    sharedBgSession = URLSession(configuration: backgroundConfig, delegate: self, delegateQueue: operationQueue)
//    let dataTask = sharedBgSession.dataTask(with: request)
    downloadTask = sharedBgSession.downloadTask(with: request)
    downloadTask?.resume()
  }
}


//    percents += 5
//    let value: Float = Float(percents)/100
//    print(value)
//    progressBar.setProgress(value, animated: true)
