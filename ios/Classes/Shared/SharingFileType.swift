//
//  SharingFileType.swift
//  flutter_sharing_intent
//
//  Created by Bhagat on 29/11/22.
//

import UniformTypeIdentifiers

enum SharingFileType: Int, Codable {
    case text
    case url
    case image
    case video
    case file
    
    public var toUTTypeIdentifier: String {
           if #available(iOS 14.0, *) {
               switch self {
               case .image:
                   return UTType.image.identifier
               case .video:
                   return UTType.movie.identifier
               case .text:
                   return UTType.text.identifier
       //         case .audio:
       //             return UTType.audio.identifier
               case .file:
                   return UTType.fileURL.identifier
               case .url:
                   return UTType.url.identifier
               }
           }
           switch self {
           case .image:
               return "public.image"
           case .video:
               return "public.movie"
           case .text:
               return "public.text"
   //         case .audio:
   //             return "public.audio"
           case .file:
               return "public.file-url"
           case .url:
               return "public.url"
           }
       }
}
