//
//  FileManager+Delete.swift
//  MonnoPhotoLiveMaker
//
//  Created by Lito Arias on 23/05/2019.
//  Copyright © 2019 MonnoApps. All rights reserved.
//

import Foundation

public extension FileManager {
    func clearAllFiles() {
        let myDocuments = self.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            try self.removeItem(at: myDocuments)
        } catch {
            return
        }
    }
}
