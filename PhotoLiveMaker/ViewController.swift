//
//  ViewController.swift
//  PhotoLiveMaker
//
//  Created by Lito Arias on 23/05/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import UIKit
import PhotosUI
import MonnoPhotoLiveMaker

class ViewController: UIViewController {
    
    var photoLiveView: PHLivePhotoView!
   
    override func loadView() {
        super.loadView()
        photoLiveView = PHLivePhotoView(frame: UIScreen.main.bounds)
        view.addSubview(photoLiveView)
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let video = "https://file-examples.com/wp-content/uploads/2018/04/file_example_MOV_480_700kB.mov"
        let image = "https://media.idownloadblog.com/wp-content/uploads/2018/08/iPhone-XS-marketing-wallpaper.jpg"
        
        let operation = LivePhotoOperation(imageRemoteURL: image, videoRemoteURL: video)
        
        operation.makeAndSaveLivePhoto(completion: { (result: Result<PHLivePhoto, LivePhotoError>) in
            switch result {
            case .success(let photo):
                self.photoLiveView.livePhoto = photo
            case .failure(let error):
                print(error)
            }
        }, assamblingProgress: { progressAssambling in
            print("Assambling \(progressAssambling)")
        })
    }
    
    
}

