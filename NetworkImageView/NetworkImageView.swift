//
//  NetworkImageView.swift
//  NetworkImageView
//
//  Created by Pushparaj Jayaseelan on 11/08/16.
//

import UIKit

// MARK: - UIImageView extension - This extension enables all the UIImageViews across the whole application to have the our own implemented methods. Ex. In an ideal case, UIImageView will not have a method called loadImage. But by extending this way, we can call loadImageFromURL on any UIImageView objects throughout application.
extension UIImageView {
    var cachedImage:UIImage? {
        return ImageCache.sharedCache.objectForKey(self.imageURL) as? UIImage
    }
    
    /**
     Loads the image from the given server URL
     
     - parameter url: image url to load
     */
    func loadImage(withURL url:String, completionHandler completion:((image:UIImage) -> Void)?) {
        if let URL:NSURL = NSURL(string: url) {
            self.imageURL = url
            
            // If the cached image is found for the requested url, then just load the image from cache and exit
            if cachedImage != nil {
                if completion != nil {
                    completion!(image:cachedImage!)
                } else {
                    self.image = cachedImage
                }
                
                self.imageURL = nil
                return
            }
            
            self.showLoader(true)
            let task = NSURLSession.sharedSession().dataTaskWithURL(URL) { (data, response, error) in
                if error == nil {
                    if let imageData = data {
                        if let myImage:UIImage = UIImage(data: imageData) {
                            if self.imageURL == url {
                                
                                // cache the image
                                ImageCache.sharedCache.setObject(myImage, forKey: self.imageURL, cost: imageData.length)
                                
                                // update the ui with the downloaded image
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.showLoader(false)
                                    
                                    // notify the completion handler if user wish to handle the downloaded image. Otherwise just load the image with alpha animation
                                    if completion != nil {
                                        completion!(image: myImage)
                                    } else {
                                        self.alpha = 0
                                        self.image = myImage
                                        UIView.animateWithDuration(0.3, animations: {
                                            self.alpha = 1
                                        })
                                    }
                                })
                            }else {
                                print("URLs are not same.")
                            }
                        } else {
                            print("Image cannot be created from the given url \(self.imageURL)")
                        }
                        
                        self.imageURL = nil
                    } else {
                        print("data not found for url\(self.imageURL)")
                        print(error)
                    }
                }
            }
            
            task.resume()
        } else {
            print("Invalid image url given. The image url should be a server URL.")
        }
    }
    
    /**
     Adds / removes an activity indicator view within the UIImageView
     
     - parameter canShow: true to add the loader else false
     */
    func showLoader(canShow:Bool) {
        if canShow {
            let activityLoader:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
            activityLoader.startAnimating()
            activityLoader.color = UIColor.blackColor()
            activityLoader.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(activityLoader)
            
            let xConstraint:NSLayoutConstraint = NSLayoutConstraint(item: activityLoader, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
            let yConstraint:NSLayoutConstraint = NSLayoutConstraint(item: activityLoader, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
            NSLayoutConstraint.activateConstraints([xConstraint,yConstraint])
        } else {
            if self.subviews.count != 0 {
                self.subviews[0].removeFromSuperview()
            }
        }
    }
    
    /**
     Resizes the given image to a best matching size to fit in the UIImageView
     
     - parameter image: iamge to resize
     
     - returns: resized image view
     */
    func resizeImage(inout image:UIImage) -> UIImage {
        var newImageSize: CGSize = self.frame.size
        if image.size.height > newImageSize.height || image.size.width > newImageSize.width {
            newImageSize = self.getSizeToFitInImageView(image.size, imageViewSize: newImageSize)
            UIGraphicsBeginImageContextWithOptions(newImageSize, false, 0.0)
            image.drawInRect(CGRectMake(0, 0, newImageSize.width, newImageSize.height))
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image
    }
    
    func getSizeToFitInImageView(imageSize: CGSize, imageViewSize: CGSize) -> CGSize {
        var requiredSize: CGSize = CGSizeZero
        let requiredHeight: CGFloat = (imageSize.height * imageViewSize.width) / imageSize.width
        requiredSize = CGSizeMake(imageViewSize.width, requiredHeight)
        return requiredSize
    }
    
    private struct AssociatedKeys {
        static var DescriptiveName = "nsh_DescriptiveName"
    }
    
    var imageURL: String! {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.DescriptiveName) as? String
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.DescriptiveName,
                    newValue as NSString?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
}

class ImageCache {
    static let sharedCache: NSCache = {
        let cache = NSCache()
        cache.name = "MyImageCache"
        cache.countLimit = 20 // Max 20 images in memory.
        cache.totalCostLimit = 10*1024*1024 // Max 10MB used.
        return cache
    }()
}
