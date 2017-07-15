# layer + draw K Charts using Swift3
- 处理一些股票K线图，现阶段只是借助4个关键点画出蜡烛图标
- 初步使用context绘制，等完善之后换位CAShaplayer层实现

# URLSession Download
- [x] background session
- [ ] ...

## 下载部分相关说明:
  1 创建background的session时，自iOS8之后默认网络变动是不会去调用`didCompleteWithError`方法得处`error`的，如果想要`timeout`的话，应该为session设置，like this：
  ```swift
  // 其默认是一个星期 https://forums.developer.apple.com/thread/22690
  backgroundSessonConfig.timeoutIntervalForResource = TimeInterval(10)
  ```
  2 `Error` vs `NSError`   
  在swift3中，前者是一个protocol，而后者是OC的类，现在暂时的处理方式是将其转换，如：
  ```swift
  let errorOC: NSError = error as NSError
  print("error: ", errorOC.userInfo)
  ```
  下面就是timeout时的userInfo字典的信息，可见有我们断点续传需要关心的`NSURLSessionDownloadTaskResumeData`
  ```
  [
    AnyHashable("NSLocalizedDescription"): The request timed out.,
  
    AnyHashable("_kCFStreamErrorDomainKey"): 4,
  
    AnyHashable("NSErrorFailingURLStringKey"):
  https://r1---sn-i3b7kn76.googlevideo.com/videoplayback?ms=au&id=o-APrfVMgM_oH26Ty9g1XVoz1Unh9udswIdhYAxDq3...,
  
    AnyHashable("NSErrorFailingURLKey"): https://r1---sn-i3b7kn76.googlevideo.com/videoplayback?ms=au&id=o-APrfVMgM_oH26Ty9g1XVoz1Unh9udswIdhYAxDq3...,
  
    AnyHashable("NSURLSessionDownloadTaskResumeData"): <6164 44617465 3c2f6b65 793e0a09 3c737472 696e673e 5361742c 20323120 4e6f7620 32303135 2031313a 33303a31 3220474d 543c2f73 7472696e 673e0a3c 2f646963 743e0a3c 2f706c69 73743e0a .... >,
  
    AnyHashable("_kCFStreamErrorCodeKey"): -2103
  ]
  ```
  如果将其按xml的string提取出来就是：
  ```xml
  <?xml version=\"1.0\" encoding=\"UTF-8\"?>
  <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
  <plist version=\"1.0\">
  <dict>
      <key>NSURLSessionDownloadURL </key>
      <string>https://r1---sn-i3b7kn76.goo......</string>
  
      <key>NSURLSessionResumeBytesReceived </key>
      <integer>65535504 </integer>
  
      <key>NSURLSessionResumeCurrentRequest </key>
      <data>YnBsaXN0vX3B..........二进制数据...........</data>
  
      <key>NSURLSessionResumeInfoTempFileName </key>
      <string>CFNetworkDownload_cO7orV.tmp </string>
  
      <key>NSURLSessionResumeInfoVersion </key>
      <integer>2 </integer>
  
      <key>NSURLSessionResumeOriginalRequest </key>
      <data>YnBsaXN0MDYmp..........二进制数据.........</data>
  
      <key>NSURLSessionResumeServerDownloadDate </key>
      <string>Sat, 21 Nov 2015 11:30:12 GMT </string>
  </dict>
  </plist>
  ```
## 后台任务的基本流程
app退到后台，配置好了的bgSession，所以会在一个单独的线程执行下载，接下来分为几种情况：

1 后台任务默默地顺利完成    
`handleEventsForBackgroundURLSession:completionHandler`被调用 -> 保存`completionHandler` -> 用`identufier`创建bgSession -> 执行代理最终是`DidFinishEventsForBackgroundURLSession:` -> 执行之前保存的`completionHandler`

2 用户再次回到前台,在前台完成     
`didFinishLaunchingWithOptions:`中获取`identifier` -> 创建session -> 重复上边步骤...

3 断点续传问题
理论上来讲，通过关联到的session，配合`partOFDataRecieved.tmp` + `resumeData`就能完成，所以至少涉及到对resumeData的获取保存和对已下载的临时文件的保存



  接下来聚焦于2个最关键问题：   
  第一： 断点续传问题，兼具各种错误处理   
  第二： 后台下载问题，结合上一个问题处理后台完成，网络中断，应用被完全kill等情况
  
处于iOS8～iOS10兼容的考虑，选择从`didCompleteWithError`这个代理方法中获取`resumeData` 
