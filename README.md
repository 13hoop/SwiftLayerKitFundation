# layer + draw K Charts using Swift3

# URLSession Download

- [x] background session
- [x] ...


### warming:
  - 创建background的session时，自iOS8之后默认网络变动是不会去调用`didCompleteWithError`方法得处`error`的，如果想要`timeout`的话，应该为session设置，like this：
  ```swift
  // 其默认是一个星期：https://forums.developer.apple.com/thread/22690
      backgroundSessonConfig.timeoutIntervalForResource = TimeInterval(10)
  ```
  - Error vs NSError
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
  将其按xml的string提取出来就是：
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
    <data>
        YnBsaXN0MDDUAQIDBAUGbm9YJHZlcnNpb25YJG9iamVjdHNZJGFyY2hpdmVyVCR0b3ASAAGGoK8QEwcIRkdNTlRVViwrWDlZWmJjZGlVJG51bGzfEB8JCgsMDQ4PEBESExQVFhcYGRobHB0eHyAhIiMkJSYnKCkpKywtLi8wMCkvNCspNjc4OTo7KSk+OykvQkM7RVIkMV8QIF9fbnN1cmxyZXF1ZXN0X3Byb3RvX3B...
    </data>

    <key>NSURLSessionResumeInfoTempFileName </key>
    <string>CFNetworkDownload_cO7orV.tmp </string>

    <key>NSURLSessionResumeInfoVersion </key>
    <integer>2 </integer>

    <key>NSURLSessionResumeOriginalRequest </key>
    <data>
        YnBsaXN0MDDUAQIDBAUGamtYJHZlcnNpb25YJG9iamVjdHNZJGFyY2hpdmVyVCR0b3ASAAGGoK8QEQcIRkdNTlRVViwrWDlZWmBlVSRudWxs3xAfCQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKSssLS4vMDApLzQrKTY3ODk6OykpPjspL0JDO0VSJDFfECBfX25zdXJscmVxdWVzdF9wcm90b19wcm9wX29ial8yMF8QIF9fbnN1cmxyZXF1ZXN0X3Byb3RvX3Byb3Bfb2JqXzIxXxAQc3RhcnRUaW1lb3V0VGltZV8QHnJlcXVpcmVzU2hvcnRDb25uZWN0aW9uVGltZW91dF8QIF9fbnN1cmxyZXF1ZXN0X3Byb3RvX3Byb3Bfb2JqXzEwViRjbGFzc18QIF9fbnN1cmxyZXF1ZXN0X3Byb3RvX3Byb3Bfb2JqXzExXxAgX19uc3VybHJlcXVlc3RfcHJvdG9fcHJvcF9vYmpfMTJfECBfX25zdXJscmVxdWVzdF9wcm90b19wcm9wX29ial8xM18QGl9fbnN1cmxyZXF1ZXN0X3Byb3RvX3Byb3BzXxAgX19uc3VybHJlcXVlc3RfcHJvdG9fcHJvcF9vYmpfMTRfECBfX25zdXJscmVxdWVzdF9wcm90b19wcm9wX29ial8xNV8QGnBheWxvYWRUcmFuc21pc3Npb25UaW1lb3V0XxAgX19uc3VybHJlcXVlc3RfcHJvdG9fcHJvcF9vYmpfMTZfEBRhbGxvd2VkUHJvdG9jb2xUeXBlc18QIF9fbnN1cmxyZXF1ZXN0X3Byb3RvX3Byb3Bfb2JqXzE3XxAgX19uc3VybHJlcXVlc3RfcHJvdG9fcHJvcF9vYmp...
    </data>

    <key>NSURLSessionResumeServerDownloadDate </key>
    <string>Sat, 21 Nov 2015 11:30:12 GMT </string>

  </dict>
  </plist>
  ```
  
