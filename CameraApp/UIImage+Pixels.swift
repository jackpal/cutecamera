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

  static func image(fromPixelValues pixelValues: [PixelData], width: Int, height: Int) -> UIImage?
  {
      var imageRef: CGImage?
      var pixelValues = pixelValues
      let bitsPerComponent = 8
      let bytesPerPixel = 4
      let bitsPerPixel = bytesPerPixel * bitsPerComponent
      let bytesPerRow = bytesPerPixel * width
      let totalBytes = height * bytesPerRow

      imageRef = withUnsafePointer(to: &pixelValues, {
          ptr -> CGImage? in
          var imageRef: CGImage?
          let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
          let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).union(CGBitmapInfo())
          let data = UnsafeRawPointer(ptr.pointee).assumingMemoryBound(to: UInt8.self)
          let releaseData: CGDataProviderReleaseDataCallback = {
              (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
          }

          if let providerRef = CGDataProvider(dataInfo: nil, data: data, size: totalBytes, releaseData: releaseData) {
              imageRef = CGImage(width: width,
                                 height: height,
                                 bitsPerComponent: bitsPerComponent,
                                 bitsPerPixel: bitsPerPixel,
                                 bytesPerRow: bytesPerRow,
                                 space: colorSpaceRef,
                                 bitmapInfo: bitmapInfo,
                                 provider: providerRef,
                                 decode: nil,
                                 shouldInterpolate: false,
                                 intent: CGColorRenderingIntent.defaultIntent)
          }

          return imageRef
      })
    if (imageRef != nil) {
      return UIImage(cgImage:imageRef!)
    }
    return nil
  }
}
