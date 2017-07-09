//
//  YRStockChartView.swift
//  SwiftLayerFunc
//
//  Created by YongRen on 2017/7/4.
//  Copyright © 2017年 YongRen. All rights reserved.
//

import UIKit

class YRStockChartView: UIView {
  
  // Only override draw() if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    drawBackground(rect: rect)
    drawTextLb(rect: rect)
    drawCandleAndAvgLine(rect: rect)
  }
  
  
  var gapY:CGFloat = 0
  // 画背景
  func drawBackground(rect: CGRect) {
    
    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(UIColor.orange.cgColor)
    context?.fill(bounds)
    
    // 边框 insert(8, 8, 8, 8)
    let contentRect = CGRect(x: 8, y: 8, width: rect.width-16, height: rect.height-16)
    context?.stroke(contentRect, width: 1)
    context?.setStrokeColor(UIColor.black.cgColor)
    context?.strokePath()
    
    context?.saveGState()
    // 横线
    self.gapY = (rect.height - 10 - 10) / 4
    context?.setLineWidth(1.0)
    context?.setLineDash(phase: 0, lengths: [5,5])
    context?.setStrokeColor(UIColor.red.cgColor)
    
    let originX:CGFloat = 20
    let endX:CGFloat = rect.width - 20
    for i in 0 ..< 4 {
      let y =  gapY * CGFloat(i) + 20
      let a1 = CGPoint(x: originX, y: y)
      let a2 = CGPoint(x: endX, y: y)
      context?.move(to: a1)
      context?.addLine(to: a2)
    }
    
    context?.strokePath()
    context?.restoreGState()
  }
  
  // 绘制文字
  func drawTextLb(rect: CGRect) {
    let gap: CGFloat = (30 - 25) / 4
    
    for i in (0 ... 4) {
      let str = "\(gap * CGFloat(i) + 25.00)"
//      let strValue = String(format: "%.2f", str)
      let strAtt: NSAttributedString = NSAttributedString(string: str, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 11), NSForegroundColorAttributeName: UIColor.blue])
      
      let y: CGFloat = i == 4 ? rect.height-8-12 : 8 + CGFloat(i) * self.gapY + strAtt.size().height - 2
      print(str, y)
      
      strAtt.draw(in: CGRect(x: 8+2, y: rect.height - y, width: strAtt.size().width, height: strAtt.size().height))
    }
  }
  
  // 蜡烛和均线
  let candle_W:CGFloat = 5
  func drawCandleAndAvgLine(rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }

    let data: [CGFloat] = [26.1,26.4, 27.0,28.1]
    let dataCount = 10
    let gapX = (rect.width - 8*2) / 10
    let margin = CGFloat(candle_W + 2)
    
    /*
     4个点可确定一个candle，将数据转化为坐标，共用1个x
     */
    for i in 0 ... dataCount-1 {
      let x = CGFloat(i) * (gapX+margin) + 8 + 5
//      for j in 0 ..< 4 {
//          data[j]
      
        drawCandle(cxt: context, rect: rect, xData: x, ydatas: data)
    }
    
  }
  
  func drawCandle(cxt: CGContext, rect: CGRect,xData:CGFloat, ydatas: [CGFloat]) {
    
    cxt.saveGState()
    cxt.setStrokeColor(UIColor.red.cgColor)
    cxt.setLineWidth(2)
    
    let rdm = CGFloat(arc4random_uniform(100))
    let p1 = CGPoint(x: xData, y: 40 + rdm)
    let p2 = CGPoint(x: xData, y: 70 + rdm)
    let p3 = CGPoint(x: xData, y: 120 + rdm)
    let p4 = CGPoint(x: xData, y: 140 + rdm)
    
    cxt.move(to: p1)
    cxt.addLine(to: p2)
    cxt.move(to: p3)
    cxt.addLine(to: p4)
    cxt.strokePath()
    
    let x1:CGFloat = xData - (self.candle_W / 2)
    let y1:CGFloat = p2.y
    let y2:CGFloat = p3.y
    cxt.stroke(CGRect(x: x1, y: y1, width: self.candle_W, height: (y2-y1)))
    cxt.restoreGState()
  }
}

