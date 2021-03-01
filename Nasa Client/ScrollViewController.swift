//
//  ScrollViewController.swift
//  Nasa Client
//
//  Created by enchtein on 21.02.2021.
//

import UIKit

class ScrollViewController: UIViewController, StoryboardInitializable {
    
    var delegate: NewTableViewCell?
    var imageScrollView: ImageScrollView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        print(delegate?.cameraLabel)
//        fatalError()
        
        self.imageScrollView = ImageScrollView(frame: self.view.bounds)
        self.view.addSubview(imageScrollView!)
        self.setupImageScrollView()
        
//        let imagePath = Bundle.main.path(forResource: "apple", ofType: "png")!
//        let image = UIImage(contentsOfFile: imagePath)!
        let prepairImage = delegate?.avatarImageView.image
        guard let image = prepairImage else { return }
        imageScrollView?.set(image: image)
      }
      
      private func setupImageScrollView() {
        imageScrollView?.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView?.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        imageScrollView?.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        imageScrollView?.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        imageScrollView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
      }

}
