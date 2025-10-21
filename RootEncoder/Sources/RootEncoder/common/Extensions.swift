//
//  Extensions.swift
//  common
//
//  Created by Pedro  on 20/3/24.
//

import Foundation
import CryptoKit
import CoreImage


public extension Array {
    mutating func get(destiny: inout Array, index: Int, length: Int) {
        destiny[index...index + length - 1] = self[0...length - 1]
        self.removeFirst(length)
    }
}

// TODO: Check if these extension function are still useful. Maybe move buffer rotation here as well.
public extension CIImage {
    
    func cropToAspectRatio(aspectRatio: CGFloat) -> CIImage {
        let originalWidth = extent.width
        let originalHeight = extent.height

        let targetWidth = originalWidth
        let targetHeight = originalWidth / aspectRatio
        
        let finalWidth: CGFloat
        let finalHeight: CGFloat
        if targetHeight > originalHeight {
            finalHeight = originalHeight
            finalWidth = originalHeight * aspectRatio
        } else {
            finalWidth = targetWidth
            finalHeight = targetHeight
        }

        let xOffset = (originalWidth - finalWidth) / 2
        let yOffset = (originalHeight - finalHeight) / 2
        let cropRect = CGRect(x: xOffset, y: yOffset, width: finalWidth, height: finalHeight)
        
        return cropped(to: cropRect).transformed(by: CGAffineTransform(translationX: xOffset, y: -yOffset))
    }
    
    func scaleTo(width: CGFloat, height: CGFloat) -> CIImage {
        let scaleX = width / extent.width
        let scaleY = height / extent.height
        return transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
    }
}

public extension Date {
    var millisecondsSince1970: Int64 {
        Int64((timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

public func intToBytes<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
  withUnsafeBytes(of: value.littleEndian, Array.init)
}
