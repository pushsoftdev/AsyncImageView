//
//  ViewController.swift
//  NetworkImageView
//
//  Created by Pushparaj Jayaseelan on 11/08/16.
//
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageURL = "http://www.tourist-destinations.com/wp-content/uploads/2013/02/lanikai-kayaking.jpg"
        
        imageView.loadImage(withURL: imageURL) { (image) in
            // TODO: Handle the downloaded image here
            print("completion handler fired...")
            self.imageView.image = image
        }
        
        //imageView.loadImage(withURL: imageURL, completionHandler: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

