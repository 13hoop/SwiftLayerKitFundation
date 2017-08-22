//
//  SessionWrapperOperation.swift
//  YRDownLoadManager
//
//  Created by YongRen on 2017/8/9.
//  Copyright © 2017年 YongRen. All rights reserved.
//

import UIKit

class SessionWrapperOperation: Operation {
  
  class func operationForURLSession(task: URLSessionTask) -> SessionWrapperOperation {
    let op: SessionWrapperOperation = SessionWrapperOperation()
    op.task = task
    return op
  }
  
  var testStr: String?
  
  var task: URLSessionTask?
  var isObersving: Bool = false
  
  var executingTag: Bool = false
  var finishedTag: Bool = true
  init(str: String) {
    self.testStr = str
    super.init()
  }
  
  override init() {
    super.init()
  }
  
  deinit {
    stopObservingTask()
  }
  
  func startObservingTask() {
    synchronized(lock: self) {
      if isObersving {
        return
      }
      task?.addObserver(self, forKeyPath: "state", options: .new, context: nil)
      isObersving = true
    }
  }
  func stopObservingTask() {
    synchronized(lock: self) {
      if !isObersving {
        return
      }
      
      isObersving = false
      task?.removeObserver(self, forKeyPath: "state", context: nil)
    }
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if task?.state == URLSessionTask.State.canceling || task?.state == URLSessionTask.State.completed {
      stopObservingTask()
      completionOp()
    }
  }
  
  /// 尾随闭包，写起来跟原来很像
  func synchronized(lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
  }
}

// MARK: ～ 实现 NSOperation methods
extension SessionWrapperOperation {
  
  override var isExecuting: Bool {
    get {
      return executingTag
    }
    set {
      willChangeValue(forKey: "isExecuting")
      executingTag = newValue
      didChangeValue(forKey: "isExecuting")
    }
  }
  
  override var isFinished: Bool {
    get {
      return finishedTag
    }
    set {
      willChangeValue(forKey: "isFinished")
      finishedTag = newValue
      didChangeValue(forKey: "isFinished")
    }
  }
  override var isAsynchronous: Bool {
    return true
  }
  
  override func start() {
    if isCancelled {
      isFinished = true
      return
    }
    
    isExecuting = true
    Thread.detachNewThreadSelector(#selector(self.main), toTarget: self, with: nil)
  }
  
  override func main() {
    startObservingTask()
    task?.resume()
  }
  
  func completionOp() {
    executingTag = false
    finishedTag = true
  }
}


/// OC时代解决现场问题方式： NSLock 和 @synchronized
/*
 NSMutableArray *mArr;
 
 - (void) push: (id)elm {
   [lock lock];
   [mArr addObject: elm];
   [lock unlock];
 }
 
 // 另一种方式
 
 - (void) push: (id)elm {
   @synchronized( self ) {
     [mArr addObject: elm];
   }
 }
 */
