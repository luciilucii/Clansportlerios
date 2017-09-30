//
//  CustomImageView.swift
//  Clansportler
//
//  Created by Luca Kiedrowski on 30.07.17.
//  Copyright © 2017 LucaKiedrowski. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    var toConvertImage: UIImage? {
        didSet {
            guard let image = toConvertImage else { return }
            convertToGrayScale(image: image)
        }
    }
    
    func loadImage(urlString: String) {
        lastURLUsedToLoadImage = urlString
        
        self.image = nil
        
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("failed to fetch post image: ", err)
                return
            }
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            guard let imageData = data else { return }
            let photoImage = UIImage(data: imageData)
            imageCache[url.absoluteString] = photoImage
            
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()
    }
    
    func loadAndConvertToGray(urlString: String) {
        lastURLUsedToLoadImage = urlString
        
        self.image = nil
        
        if let cachedImage = imageCache[urlString] {
            self.toConvertImage = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("failed to fetch post image: ", err)
                return
            }
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            guard let imageData = data else { return }
            let photoImage = UIImage(data: imageData)
            imageCache[url.absoluteString] = photoImage
            
            DispatchQueue.main.async {
                self.toConvertImage = photoImage
            }
        }.resume()
    }
    
    func convertToGrayScale(image: UIImage) {
        
        let imageRect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = image.size.width
        let height = image.size.height
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.draw(image.cgImage!, in: imageRect)
        let imageRef = context!.makeImage()
        let newImage = UIImage(cgImage: imageRef!)
        
        self.image = newImage
    }
    
}

