//
//  ModalViewController.swift
//  AeroVision
//
//  Created by Sinan Ulkuatam on 11/23/17.
//  Copyright © 2017 Cappsule. All rights reserved.
//

import Foundation
import UIKit
import DeckTransition

class ModalViewController: UIViewController, UITextViewDelegate {
    
    let textView = UITextView()

    var classificationText = UITextView()

    var imgData = Data()

    var classificationResult = String()

    var imgRepresentation = UIImageView()

    var shadowLayer = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationCapturesStatusBarAppearance = true
        
        view.backgroundColor = .white
        
        textView.isEditable = false
        textView.isSelectable = false
        textView.showsVerticalScrollIndicator = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightHeavy)
        textView.textAlignment = .center
        textView.text = "Image Classification"
        
        view.addSubview(textView)
        textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        textView.bounces = false
        textView.delegate = self
        
        classificationText.isEditable = false
        classificationText.isSelectable = true
        classificationText.showsVerticalScrollIndicator = false
        classificationText.translatesAutoresizingMaskIntoConstraints = false
        classificationText.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightMedium)
        classificationText.textAlignment = .center
        classificationText.text = classificationResult
        
        view.addSubview(classificationText)
        classificationText.topAnchor.constraint(equalTo: view.topAnchor, constant: self.view.frame.height-250).isActive = true
        classificationText.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        classificationText.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        classificationText.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        classificationText.bounces = false
        classificationText.delegate = self
        
        imgRepresentation.image = UIImage(data: imgData)
        imgRepresentation.contentMode = .scaleToFill
        imgRepresentation.backgroundColor = UIColor.black
        imgRepresentation.frame.size = CGSize(width: 250, height: 250)
        imgRepresentation.center = CGPoint(x: view.center.x, y: view.center.y-50)
        imgRepresentation.layer.cornerRadius = 8
        imgRepresentation.layer.masksToBounds = true

        view.addSubview(imgRepresentation)
        
        shadowLayer.clipsToBounds = true
        shadowLayer.layer.masksToBounds = false
        shadowLayer.layer.cornerRadius = 8
        shadowLayer.backgroundColor = UIColor.white
        shadowLayer.frame.size = CGSize(width: 250, height: 250)
        shadowLayer.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        shadowLayer.layer.shadowRadius = 5
        shadowLayer.layer.shadowOpacity = 0.5
        shadowLayer.center = CGPoint(x: view.center.x, y: view.center.y-50)
        view.bringSubview(toFront: shadowLayer)
        view.addSubview(shadowLayer)
        view.bringSubview(toFront: imgRepresentation)

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewWasTapped))
        view.addGestureRecognizer(tap)
    }
    
    func viewWasTapped() {
        let modal = ModalViewController()
        let transitionDelegate = DeckTransitioningDelegate()
        modal.transitioningDelegate = transitionDelegate
        modal.modalPresentationStyle = .custom
        present(modal, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isEqual(textView) else {
            return
        }
        
        if let delegate = transitioningDelegate as? DeckTransitioningDelegate {
            if scrollView.contentOffset.y > 0 {
                scrollView.bounces = true
                delegate.isDismissEnabled = false
            } else {
                if scrollView.isDecelerating {
                    view.transform = CGAffineTransform(translationX: 0, y: -scrollView.contentOffset.y)
                    scrollView.subviews.forEach {
                        $0.transform = CGAffineTransform(translationX: 0, y: scrollView.contentOffset.y)
                    }
                } else {
                    scrollView.bounces = false
                    delegate.isDismissEnabled = true
                }
            }
        }
    }
    
}
