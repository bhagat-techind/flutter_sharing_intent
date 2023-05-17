//
//  SharingFile.swift
//  flutter_sharing_intent
//
//  Created by Bhagat on 29/11/22.
//

class SharingFile: Codable {
    var path: String?
    var value: String?
    var thumbnail: String? // video thumbnail
    var duration: Double? // video duration in milliseconds
    var type: SharingFileType

    enum CodingKeys: String, CodingKey {
        case value
        case path
        case thumbnail
        case duration
        case type
    }
    
    init(value: String, path: String?, thumbnail: String?, duration: Double?, type: SharingFileType) {
        self.value = value
        self.path = path
        self.thumbnail = thumbnail
        self.duration = duration
        self.type = type
    }
    
    // Debug method to print out SharedMediaFile details in the console
    func toString() {
        print("[SharingFile] \n\tvalue: \(String(describing: self.value))\n\tthumbnail: \(self.thumbnail ?? "--" )\n\tduration: \(self.duration ?? 0)\n\ttype: \(self.type)")
    }
}

