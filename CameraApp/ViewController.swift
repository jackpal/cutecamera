//
//  ViewController.swift
//  CameraApp
//
//  Created by Jack Palevich on 12/15/17.
//  Copyright © 2017 Jack Palevich. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var toolbar: UIToolbar!

  var newMedia: Bool?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    if !UIImagePickerController.isSourceTypeAvailable(
      UIImagePickerControllerSourceType.camera) {
      if var items = toolbar.items {
        items.removeFirst()
        toolbar.items = items
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func doCamera(_ sender: UIBarButtonItem) {
    if UIImagePickerController.isSourceTypeAvailable(
      UIImagePickerControllerSourceType.camera) {

      let imagePicker = UIImagePickerController()

      imagePicker.delegate = self
      imagePicker.sourceType =
        UIImagePickerControllerSourceType.camera
      imagePicker.mediaTypes = [kUTTypeImage as String]
      imagePicker.allowsEditing = false

      self.present(imagePicker, animated: true,
                   completion: nil)
      newMedia = true
    }
  }

  @IBAction func doCameraRoll(_ sender: UIBarButtonItem) {
    if UIImagePickerController.isSourceTypeAvailable(
      UIImagePickerControllerSourceType.savedPhotosAlbum) {
      let imagePicker = UIImagePickerController()

      imagePicker.delegate = self
      imagePicker.sourceType =
        UIImagePickerControllerSourceType.photoLibrary
      imagePicker.mediaTypes = [kUTTypeImage as String]
      imagePicker.allowsEditing = false
      self.present(imagePicker, animated: true,
                   completion: nil)
      newMedia = false
    }
  }

  @IBAction func doFilter(_ sender: UIBarButtonItem) {
    guard let image = imageView.image else { return }
    guard let bytes = image.pixelData() else { return }
    var mutableBytes = bytes
    filter(width: Int(image.size.width),
           height: Int(image.size.height), pixels:&mutableBytes)
    guard let image2 = UIImage.image(fromPixelValues: mutableBytes,
                                     width: Int(image.size.width),
                                     height: Int(image.size.height),
                                     orientation:image.imageOrientation) else {return}
    imageView.image = image2
  }

  @IBAction func doShare(_ sender: UIBarButtonItem) {
    guard let image = imageView.image else {return}
    let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
    present(vc, animated: true)
  }

  func filter(width:Int, height:Int, pixels: inout [PixelData]) {
    var index = 0
    for y in 0..<height {
      for x in 0..<width {
        pixels[index].r = 255-pixels[index].r
        index += 1
      }
    }
  }

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

    let mediaType = info[UIImagePickerControllerMediaType] as! NSString

    self.dismiss(animated: true, completion: nil)

    if mediaType.isEqual(to: kUTTypeImage as String) {
        let image = info[UIImagePickerControllerOriginalImage]
                                as! UIImage

        imageView.image = image

        if (newMedia == true) {
            UIImageWriteToSavedPhotosAlbum(image, self,
                #selector(ViewController.image(image:didFinishSavingWithError:contextInfo:)), nil)
        } else if mediaType.isEqual(to: kUTTypeMovie as String) {
                // Code to support video here
        }

    }
}

  @objc func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafeRawPointer) {

      if error != nil {
          let alert = UIAlertController(title: "Save Failed",
              message: "Failed to save image",
              preferredStyle: UIAlertControllerStyle.alert)

          let cancelAction = UIAlertAction(title: "OK",
              style: .cancel, handler: nil)

          alert.addAction(cancelAction)
          self.present(alert, animated: true,
                          completion: nil)
      }
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.dismiss(animated: true, completion: nil)
  }
}

