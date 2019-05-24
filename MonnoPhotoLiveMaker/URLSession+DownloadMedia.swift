//
//  URLSession+DownloadMedia.swift
//  MonnoPhotoLiveMaker
//
//  Created by Lito Arias on 23/05/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import Foundation

public extension URLSession {
    
    func downloadMediaAndSaveOnDocumentsDirecotry(_ mediaLink: String, completion: @escaping (Result<URL, LivePhotoError>) -> Void) {
        
        // use guard to make sure you have a valid url
        guard let videoURL = URL(string: mediaLink) else {
            completion(.failure(LivePhotoError.badURL))
            return
        }
        
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("documentsDirectoryURL error")
            completion(.failure(LivePhotoError.documentsDirectoryNotFound))
            return
        }
        
        // check if the file already exist at the destination folder if you don't want to download it twice
        guard !FileManager.default.fileExists(atPath: documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent).path) else {
            print("File already exists at destination url")
            completion(.failure(LivePhotoError.fileExist))
            return
        }
        
        // set up your download task
        let task = self.downloadTask(with: videoURL) { (location, response, error) -> Void in
            // use guard to unwrap your optional url
            guard let location = location else {
                print("Location is wrong")
                completion(.failure(LivePhotoError.wrongUnwapURL))
                return
            }
            // create a deatination url with the server response suggested file name
            let destinationURL = documentsDirectoryURL.appendingPathComponent(response?.suggestedFilename ?? videoURL.lastPathComponent)
            do {
                try FileManager.default.moveItem(at: location, to: destinationURL)
                completion(.success(destinationURL))
                
                #warning("Interesting self.clearAllFile")
                //                self.clearAllFile()
                
            } catch {
                completion(.failure(LivePhotoError.movingFile(error)))
                
                print(error)
            }
        }
        task.resume()
    }
}

public enum LivePhotoError: Error {
    case badURL
    case documentsDirectoryNotFound
    case fileExist
    case wrongUnwapURL
    case movingFile(Error)
    case savingToLibrary
}
