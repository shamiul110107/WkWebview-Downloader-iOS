//
//  ViewController.swift
//  WebKitTest
//
//  Created by Md. Shamiul Islam on 20/12/23.
//

import UIKit
import WebKit
import Photos

@available(iOS 14.5, *)
class ViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet var webView: WKWebView!
    var downloadUrl = URL(fileURLWithPath: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let link = URL(string:"https://www.test.interactive-makers.com/")!
        let request = URLRequest(url: link)
        webView.navigationDelegate = self
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        return navigationAction.shouldPerformDownload ? decisionHandler(.download, preferences) : decisionHandler(.allow, preferences)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        navigationResponse.canShowMIMEType ? decisionHandler(.allow) : decisionHandler(.download)
    }
}

// MARK: - WKDownloadDelegate
@available(iOS 14.5, *)
extension ViewController: WKDownloadDelegate {
    
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        download.delegate = self
    }
    
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileUrl =  documentDirectory.appendingPathComponent("\(suggestedFilename)", isDirectory: false)
        
        self.downloadUrl = fileUrl
        completionHandler(fileUrl)
        /// Save to photo library (optional)
         savePhotoToPhotoLibrary(filePath: fileUrl)
    }
    
    // MARK: - Optional
    func downloadDidFinish(_ download: WKDownload) {
    }
    
    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        print("\(error.localizedDescription)")
    }
}
@available(iOS 14.5, *)
extension ViewController {
    func savePhotoToPhotoLibrary(filePath: URL) {
        PHPhotoLibrary.shared().performChanges {
            // Create a request to add the photo to the library
            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: filePath)
        } completionHandler: { (success, error) in
            // Handle the result of saving to the Photos library
            if success {
                print("Photo saved to the Photos library.")
            } else {
                print("Error saving photo to the Photos library: \(error?.localizedDescription ?? "Unknown error")")
            }
            
            // Optionally, you might want to clean up the temporary file
            do {
                try FileManager.default.removeItem(at: filePath)
            } catch {
                print("Error removing temporary file: \(error.localizedDescription)")
            }
        }
    }
}
