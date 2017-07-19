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
  
  
  let testBachStr = "https://r5---sn-i3beln76.googlevideo.com/videoplayback?pl=48&expire=1500463327&dur=1309.908&gir=yes&mt=1500441675&sparams=clen%2Cdur%2Cei%2Cgir%2Cid%2Cinitcwndbps%2Cip%2Cipbits%2Citag%2Ckeepalive%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cpl%2Crequiressl%2Csource%2Cexpire&ip=2001%3A250%3A209%3A6901%3A85ec%3A99a8%3Ab266%3A703a&lmt=1429777526745699&initcwndbps=1453750&id=o-AFCvq5ZosFfCaFPe94-ienbEHe26cHb0rI_IrZpPYxvq&ei=f-xuWcORM5Sy4AKPpLjwCw&mn=sn-i3beln76&mm=31&mime=video%2Fmp4&requiressl=yes&clen=97458524&source=youtube&keepalive=yes&mv=m&key=yt6&ms=au&signature=31021A191DEA0F3EB17721C231FE3EEE95EC3E70.85082EA8E3688E128A5EF97369B3539E14EFAF57&ipbits=0&itag=135"
  let otherStr = "http://sw.bos.baidu.com/sw-search-sp/software/797b4439e2551/QQ_mac_5.0.2.dmg"
  
  @IBOutlet weak var inputTF: UITextField!
  
  
  var download: YRDownload?
  @IBAction func startClicked(_ sender: Any) {
//    guard let urlStr = inputTF.text else {
//      print("输入正确的url")
//      return
//    }
    print("-- start --")
    let download = YRDownload(urlStr: testBachStr)
    self.download = download
    inputTF.text = nil
    YRDownloadManager.default.delegate = self
    YRDownloadManager.default.startBackgroundDownload(download: download)
  }

  @IBAction func stopClicked(_ sender: Any) {
    guard let download = download else {
      print(#function)
      return
    }
    if download.isDownloading {
      print("-- stop --")
      YRDownloadManager.default.pauseDownload(download: download)
    }else {
      print("-- resume --")      
      YRDownloadManager.default.resumeBgDownload(download: download)
    }
  }
  
  @IBAction func cancleBtnClicked(_ sender: Any) {
    print("-- cancle --")
    guard let download = download else { return }
    YRDownloadManager.default.cancleDownload(download: download)
  }
  
  
  
  @IBAction func crashedClicked(_ sender: Any) {
    print("-- crashed --")
    fatalError()
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
