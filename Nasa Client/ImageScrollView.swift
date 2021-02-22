//
//  ImageScrollView.swift
//  Nasa Client
//
//  Created by enchtein on 21.02.2021.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {

  private var imageView: UIImageView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.showsVerticalScrollIndicator = false
    self.showsHorizontalScrollIndicator = false
    self.delegate = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func set(image: UIImage) {
    imageView?.removeFromSuperview()
    imageView = nil
    imageView = UIImageView(image: image)
    self.addSubview(imageView)
    
    configurateFor(imageSize: image.size)
    
//    self.minimumZoomScale = 0.1
//    self.maximumZoomScale = 2
    setCurrentMaxAndMinZoomScale()
    self.zoomScale = self.minimumZoomScale
  }
  
  private func configurateFor(imageSize: CGSize) {
    self.contentSize = imageSize
  }
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.centerImage()
    }
    func setCurrentMaxAndMinZoomScale() {
        let boundsSize = self.bounds.size
        let imageSize = imageView?.bounds.size
        
        guard let imageSizeD = imageSize else { return }
        let xScale = boundsSize.width / imageSizeD.width
        let yScale = boundsSize.height / imageSizeD.height
        
        let minScale = min(xScale, yScale)
        
        var maxScale: CGFloat = 1.0
        if minScale < 0.1 {
            maxScale = 0.3
        }
        if minScale >= 0.1 && minScale < 0.5 {
            maxScale = 0.7
        }
        if minScale >= 0.5 {
            maxScale = max(1.0, minScale)
        }
        self.minimumZoomScale = minScale
        self.maximumZoomScale = maxScale
    }
    
    func centerImage() {
//        let boundsSize = self.superview?.bounds.size
//        let safeA = window?.safeAreaInsets.top
        
        let guide = self.safeAreaLayoutGuide
        let height = guide.layoutFrame.size.height
        let width = guide.layoutFrame.size.width
//        let cg = CGSize(

        let boundsSize = CGSize(width: width, height: height)
//        let boundsSize = self.bounds.size
        guard let imageView = imageView else { return }
        var frameToCenter = imageView.frame
        
        if frameToCenter.size.width < bounds.size.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        if frameToCenter.size.height < bounds.size.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        imageView.frame = frameToCenter
    }
}
