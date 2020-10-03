//
//  ViewController.swift
//  MachineLearningImageRecognition
//
//  Created by Yurii Sameliuk on 22/02/2020.
//  Copyright © 2020 Yurii Sameliuk. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var resaultLabel: UILabel!
    
    var chosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func changeButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciimage = CIImage(image: imageView.image!) {
            chosenImage = ciimage
            
        }
        
        recognizeImage(image: chosenImage)
    }
    func recognizeImage(image: CIImage) {
        
        // 1) Request
        // 2) Handler
        if let model = try? VNCoreMLModel(for: MobileNetV2().model ) {
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in
                if let results = vnrequest.results as? [VNClassificationObservation]{
                    if results.count > 0 {
                        let topResult = results.first
                        DispatchQueue.main.async {
                            
                            let confidenceLevel = (topResult?.confidence ?? 0)  * 100
                            
                            self.resaultLabel.text = "It's: \(topResult!.identifier) , \(Int(confidenceLevel)) % "
                        }
                    }
                    
                }
               
            }
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
                do {
                try handler.perform([request])
                } catch {
                    let nserror = error as NSError
                    fatalError("\(nserror), \(nserror.userInfo)")
                }
        }
        
        }
    }
}

