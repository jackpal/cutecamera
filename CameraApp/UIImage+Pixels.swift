//
//  UIImage+Pixels.swift
//  CameraApp
//
//  Created by Jack Palevich on 12/15/17.
//  Copyright © 2017 Jack Palevich. All rights reserved.
//

import UIKit

public struct PixelData {
  var r:UInt8
  var g:UInt8
  var b:UInt8
  var a:UInt8
}

extension UIImage {
  func pixelData() -> [PixelData]? {
    let size = self.size
    let dataSize = size.width * size.height
    let zero = PixelData(r: 0 ,g: 0, b: 0, a: 0)
    var pixelData = [PixelData](repeating: zero, count: Int(dataSize))
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: &pixelData,
                            width: Int(size.width),
                            height: Int(size.height),
                            bitsPerComponent: 8,
                            bytesPerRow: 4 * Int(size.width),
                            space: colorSpace,
                            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
    guard let cgImage = self.cgImage else { return nil }
    context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

    return pixelData
  }

  static func image(fromPixelValues pixelValues:[PixelData], width:Int, height:Int,
                    orientation:UIImageOrientation)->UIImage? {
    let bitsPerComponent = 8
    let bitsPerPixel = 32

    if pixelValues.count != width * height {
      return nil
    }

    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo:CGBitmapInfo =
      CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

    var data = pixelValues // Copy to mutable []
    guard let providerRef = CGDataProvider(
      data: NSData(bytes: &data, length: data.count * MemoryLayout<PixelData>.size)
      ) else {return nil}

    guard let cgim = CGImage(
      width: width,
      height: height,
      bitsPerComponent: bitsPerComponent,
      bitsPerPixel: bitsPerPixel,
      bytesPerRow: width * MemoryLayout<PixelData>.size,
      space: rgbColorSpace,
      bitmapInfo: bitmapInfo,
      provider: providerRef,
      decode: nil,
      shouldInterpolate: false,
      intent: CGColorRenderingIntent.defaultIntent
      ) else {return nil}
    return UIImage(cgImage: cgim, scale: 1.0, orientation: orientation)
  }
}
