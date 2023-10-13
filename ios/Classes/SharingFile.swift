//
//  SharingFile.swift
//  flutter_sharing_intent
//
//  Created by Bhagat on 29/11/22.
//

class SharingFile: Codable {
    var value: String
    var thumbnail: String?; // video thumbnail
    var duration: Double?; // video duration in milliseconds
    var type: SharingFileType;


    
    init(value: String, thumbnail: String?, duration: Double?, type: SharingFileType) {
        self.value = value
        self.thumbnail = thumbnail
        self.duration = duration
        self.type = type
    }
    
    // Debug method to print out SharedMediaFile details in the console
    func toString() {
        print("[SharingFile] \n\tvalue: \(self.value)\n\tthumbnail: \(self.thumbnail ?? "--" )\n\tduration: \(self.duration ?? 0)\n\ttype: \(self.type)")
    }
}

