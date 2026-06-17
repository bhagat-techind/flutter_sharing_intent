//
//  ShareViewController.swift
//  Share Extension
//
//  Created by Bhagat on 25/11/22.
//

// If you get a `no such module 'flutter_sharing_intent'` error,
// go to Build Phases of your Runner target and move
// `Embed Foundation Extension` to the top of `Thin Binary`.

import flutter_sharing_intent

class ShareViewController: FSIShareViewController {

    // Override this method to return false if you don't want to redirect
    // to the host app automatically. Default is true.
    // override func shouldAutoRedirect() -> Bool {
    //     return false
    // }

}
