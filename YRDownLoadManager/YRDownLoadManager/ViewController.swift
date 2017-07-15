//
//  ViewController.swift
//  YRDownLoadManager
//
//  Created by YongRen on 2017/7/7.
//  Copyright © 2017年 YongRen. All rights reserved.
//

import UIKit
//import Alamofire

class ViewController: UIViewController {

  var percents = 0;
  @IBOutlet weak var progressBar: UIProgressView!

  override func viewDidLoad() {
    super.viewDidLoad()
//    inputTF.text = otherStr
    inputTF.text = testBachStr
  }
  
  let testBachStr = "https://r1---sn-i3beln7r.googlevideo.com/videoplayback?mime=video%2Fmp4&itag=264&expire=1499963805&sparams=clen%2Cdur%2Cei%2Cgir%2Cid%2Cinitcwndbps%2Cip%2Cipbits%2Citag%2Ckeepalive%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cpl%2Crequiressl%2Csource%2Cexpire&requiressl=yes&ei=PU1nWc2eLYLC4gLsvpuoDA&dur=702.785&key=yt6&ip=2001%3A250%3A209%3A6901%3A4853%3A6f23%3Abbb8%3Ae604&keepalive=yes&mm=31&mn=sn-i3beln7r&mt=1499942083&initcwndbps=847500&mv=m&id=o-AAS65dlIlVD1ePBGcC4hLbCY6c-tZhfAVF9s_AagrFyR&ms=au&signature=02FA4E5D6FB575FB07E66202D3D180B0DA2D169D.5CCFC477DA0B6728741963454CEA634CEA483AA0&lmt=1441506828840884&pl=48&gir=yes&source=youtube&clen=459308087&ipbits=0"
  let otherStr = "http://sw.bos.baidu.com/sw-search-sp/software/797b4439e2551/QQ_mac_5.0.2.dmg"
  
  @IBOutlet weak var inputTF: UITextField!
  
  @IBAction func startClicked(_ sender: Any) {
    guard let urlStr = inputTF.text else {
      print("输入正确的url")
      return
    }
    
    YRDownloadManager.default.delegate = self
    YRDownloadManager.default.startBackgroundDownload(urlStr: urlStr, fileName: "fileName")
  }

  @IBAction func stopClicked(_ sender: Any) {
    YRDownloadManager.default.pauseDownload()
  }
  
  @IBAction func cancleBtnClicked(_ sender: Any) {
    
    print(#function)

//    guard let task = downloadTask else {
//      print(" no task for cancle ... ")
//      return
//    }
//    
//    print(" cancle: ", task.state.rawValue)
//    switch task.state {
//    case .running:
//      print(" running ~> cancle ")
//      task.cancel()
//    case .suspended:
//      print(" suspended ")
//      task.resume()
//    case .canceling:
//      print(" canceling ~> resumeData")
//      if let resumeData = readFile() {
//        sharedBgSession.downloadTask(withResumeData: resumeData)
//      }
//    case .completed:
//      print(" completed ")
//      if let resumeData = readFile() {
//        sharedBgSession.downloadTask(withResumeData: resumeData).resume()
//      }
//    }
  }
}

extension ViewController: YRDownLoadDelegate {
  
  func download(_ url: URL, completionHandler: @escaping () -> Void) {
    
  }
  
  func updateProgress(precent: Float) {
    self.progressBar.setProgress(precent, animated: false)
  }
  
  func errorMsg(msg: String?) {
    if let msg = msg {
      let vc = UIAlertController(title: "waring", message: msg, preferredStyle: .alert)
      vc.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
      self.present(vc, animated: true, completion: nil)
    }
  }
}
