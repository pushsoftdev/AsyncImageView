# NetworkImageView
Asynchronously downloads and loads the image in an UIImageView

When we are using lot of UIImageViews which loads images from server, it is hard to write code to manage the downloaded image data and process it. This application uses a Class called NetworkImageView to load the images from the given server URL and reduces the developers effort.

## How to use:

1. Just download and import the NetworkImageView.swift file into your application
2. Once you have imported this file into your application, call the loadImage method on any UIImageView objects in your application.

You can make use of the loadImage method in two ways.

1. You just tell the NetworkImageView to silently load the image into your UIImageView

####
    imageView.loadImage(withURL: imageURL, completionHandler: nil)
    
2. You ask the NetworkImageView to download and give the UIImage object to you so that you can handle it.

####
    imageView.loadImage(withURL: imageURL) { (image) in
            // TODO: Handle the downloaded image here
            //self.imageView.image = image
        }

Thats it! We are good to go!
