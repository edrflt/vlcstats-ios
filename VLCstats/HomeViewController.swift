/* ***************************************************************************
* HomeViewController.swift
*
* Copyright © 2019 VLC authors and VideoLAN
*
* Authors: Edgar Fouillet <vlc # edgar.fouillet.eu>
*
* Refer to the COPYING file of the project for license.
*****************************************************************************/

import UIKit

class HomeViewController: UIViewController, UIDocumentPickerDelegate {
    @IBOutlet weak var mediaURL: UITextField!
    @IBOutlet weak var selectFileButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .open)
    var documentURL: URL? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        selectFileButton.layer.cornerRadius = 5.0
        playButton.layer.cornerRadius = 5.0
        documentPicker.delegate = self
    }

    @IBAction func pickDocument(_ sender: Any) {
        present(documentPicker, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? PlayerViewController {
            if let mediaURL = mediaURL.text {
                destinationViewController.mediaURL = mediaURL
            }
        }
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            documentURL = url
            if url.startAccessingSecurityScopedResource() {
                mediaURL.text = urls.first?.absoluteString
            }
        }
    }
}

