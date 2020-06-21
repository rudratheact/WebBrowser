//
//  ViewController.swift
//  WebBrowser
//
//  Created by Rudra Misra on 6/21/20.
//  Copyright © 2020 Rudra Misra. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var browserView: WKWebView!
    
    @IBAction func browserNavigation(_ sender: UIButton) {
        if sender.tag == 1{
            // Reload
            browserView.reload()
        }else if sender.tag == 2{
            // Go back
            browserView.goBack()
        }else{
            // Go forward
            browserView.goForward()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        browserView.navigationDelegate = self
        browserView.uiDelegate = self
        browserView.allowsBackForwardNavigationGestures = true
        
        urlTextField.delegate = self
        
        browserView.load("https://www.apple.com")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            self.urlTextField.text = ""
            self.browserView.stopLoading()
            self.activity.stopAnimating()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}

// Mark: URL TextField implementation
extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        if textField.text != "" || textField.text != " "{
            browserView.load("https://"+textField.text!)
        }
        return true
    }
}

// Mark: Browser navigation implementation
extension ViewController: WKNavigationDelegate, WKUIDelegate{
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activity.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activity.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showAlert(title: "Error", message: error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if url.host == "www.youtube.com" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                self.showAlert(title: "Error", message: "YouTube is not allowed.")
                return
            }
            urlTextField.text = url.host
        }
        decisionHandler(.allow)
    }
}

// Mark: URL manupulation
extension WKWebView {
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
        }
    }
}
