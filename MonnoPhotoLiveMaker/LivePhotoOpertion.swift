//
//  LivePhotoOpertion.swift
//  MonnoPhotoLiveMaker
//
//  Created by Lito Arias on 24/05/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import Photos

public class LivePhotoOperation {
    
    var imageRemoteURL: String!
    var videoRemoteURL: String!
    
    public init(imageRemoteURL: String, videoRemoteURL: String) {
        self.imageRemoteURL = imageRemoteURL
        self.videoRemoteURL = videoRemoteURL
    }
    
    public func makeAndSaveLivePhoto(completion: @escaping (Result<PHLivePhoto, LivePhotoError>) -> Void, assamblingProgress: @escaping (Float) -> Void) {
        let group = DispatchGroup()
        var image: UIImage?
        var videoURL: URL?
        
        // Get image
        group.enter()
        self.getMedia(url: imageRemoteURL, completion: { (result: Result<URL, LivePhotoError>) in
            if let url = try? result.get() {
                image = UIImage(contentsOfFile: url.path)
            }
            group.leave()
        })
        
        // Get Video
        group.enter()
        self.getMedia(url: videoRemoteURL, completion: { (result: Result<URL, LivePhotoError>) in
            if let url = try? result.get() {
                videoURL = url
            }
            group.leave()
        })
        
        // End tasks
        group.notify(queue: .main) {
            print("all finished.")
            self.assembleLivePhoto(videoURL: videoURL, frame: image, progress: { progress in
                assamblingProgress(progress)
            }, assembleCompleted: { (result: Result<PHLivePhoto, LivePhotoError>) in
                completion(result)
            })
        }
    }
    
    func getMedia(url: String, completion: @escaping (Result<URL, LivePhotoError>) -> Void) {
        URLSession.shared.downloadMediaAndSaveOnDocumentsDirecotry(url, completion: { (result: Result<URL, LivePhotoError>) in
            switch result {
            case .success(let mediaURL):
                completion(.success(mediaURL))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func assembleLivePhoto(videoURL: URL?, frame: UIImage?, progress: @escaping (Float) -> Void, assembleCompleted: @escaping (Result<PHLivePhoto, LivePhotoError>) -> Void) {
        guard let sourceVideoPath = videoURL else {
            assembleCompleted(.failure(LivePhotoError.badURL))
            return
        }
        var photoURL: URL?
        if let sourceKeyPhoto = frame {
            guard let data = sourceKeyPhoto.jpegData(compressionQuality: 1.0) else { return }
            photoURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("frame.jpg")
            if let photoURL = photoURL {
                try? data.write(to: photoURL)
            }
        }
        LivePhoto.generate(from: photoURL, videoURL: sourceVideoPath, progress: { (percent) in
            DispatchQueue.main.async {
                progress(Float(percent))
            }
        }) { (livePhoto, resources) in
            if let resources = resources {
                LivePhoto.saveToLibrary(resources, completion: { (success) in
                    if success {
                        if let livePhoto = livePhoto {
                            assembleCompleted(.success(livePhoto))
                        } else {
                            assembleCompleted(.failure(LivePhotoError.savingToLibrary))
                        }
                    } else {
                        assembleCompleted(.failure(LivePhotoError.savingToLibrary))
                    }
                })
            }
        }
    }
    
}
