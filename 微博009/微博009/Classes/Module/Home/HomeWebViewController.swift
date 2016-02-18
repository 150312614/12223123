//
//  HomeWebViewController.swift
//  Weibo09
//
//  Created by Romeo on 15/9/15.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

class HomeWebViewController: UIViewController {

    var url: NSURL? {
        didSet {
            webView.loadRequest(NSURLRequest(URL: url!))
        }
    }
    
    private lazy var webView = UIWebView()
    
    override func loadView() {
        view = webView
        
        title = "网页"
    }
}
