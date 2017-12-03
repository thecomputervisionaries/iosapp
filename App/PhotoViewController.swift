/*Copyright (c) 2016, Andrew Walz.

Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

import UIKit
import Alamofire
import DeckTransition
import Foundation

class PhotoViewController: UIViewController {

	override var prefersStatusBarHidden: Bool {
		return true
	}

    var modal_ = ModalViewController()

	private var backgroundImage: UIImage

	init(image: UIImage) {
		self.backgroundImage = image
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.gray
		let backgroundImageView = UIImageView(frame: view.frame)
		backgroundImageView.contentMode = UIViewContentMode.scaleAspectFit
		backgroundImageView.image = backgroundImage
		view.addSubview(backgroundImageView)
        
		let cancelButton = UIButton(frame: CGRect(x: 20.0, y: 20.0, width: 20.0, height: 20.0))
		cancelButton.setImage(#imageLiteral(resourceName: "cancel"), for: UIControlState())
		cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
		view.addSubview(cancelButton)
        
        let sendButton = UIButton(frame: CGRect(x: self.view.bounds.minX, y: self.view.bounds.maxY-50, width: self.view.bounds.width, height: 50.0))
        sendButton.tintColor = UIColor.white
        sendButton.backgroundColor = UIColor.orange
        sendButton.setTitle("Send Image to Server", for: .normal)
        view.addSubview(sendButton)
        
        let sendImageToServer = UITapGestureRecognizer(target: self, action: #selector(self.send))
        sendButton.addGestureRecognizer(sendImageToServer)
    }
    
    func displayModal() {
        let transitionDelegate = DeckTransitioningDelegate()
        modal_.transitioningDelegate = transitionDelegate
        modal_.modalPresentationStyle = .custom
        modal_.imgData = UIImageJPEGRepresentation(self.backgroundImage, 0.2)!
        present(modal_, animated: true, completion: {
            print("displayed modal")
        })
    }

	func cancel() {
		dismiss(animated: true, completion: nil)
	}
    
    func send() {
        let imgData = UIImageJPEGRepresentation(self.backgroundImage, 0.2)!
        
        let rname = "params"
        // let parameters = ["name": rname]

        let fileSize = Float(imgData.count)
        NSLog("File size is : %.2f MB", fileSize)
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "plane",fileName: "plane.jpg", mimeType: "image/jpg")
        }, to: BASE_API_URL + ":3000/image/upload", method: HTTPMethod.post, headers: nil)
        { (result) in
            print(result)
            switch result {
            case .success(let upload, _, _):
                
                print("in success")
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    
                    switch response.result {
                        
                    case .failure(let error):
                        print(error)
                        return
                        
                    case .success(let data):
                        
                        let arrayOfOptionals: [String?] = data as! [String?]
                        let array:[String] = arrayOfOptionals.map{ $0 ?? "" }
                        
                        var str = array[0]
                        str = str.replacingOccurrences(of: "\'", with: "\"")
                        let data = str.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:AnyObject]

                            let x = json["classification"]
                            let y = json["probability"]
                            let z = json["idx"]

                            self.modal_.classificationResult = String(describing: String(describing: "Image classified as: " + (x! as! String)) + String(describing: ", with probability: " + (y! as! String)))
                            self.displayModal()

                        } catch let error as NSError {
                            print("Failed to load: \(error.localizedDescription)")
                        }

                    
                        print("JSON: \(String(describing: response.result.value))")
                        
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)  
            }
        }
        print("sending image to server")
    }
}
