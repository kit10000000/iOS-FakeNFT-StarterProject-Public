//
//  AuthorWebViewController.swift
//  FakeNFT
//
//  Created by Dmitrii Pogonia on 13.10.2026.
//

import Foundation

import UIKit
import WebKit

final class AuthorWebViewController: UIViewController {

    private let url: URL
    private lazy var webView = WKWebView()

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        view.addSubview(webView)
        webView.constraintEdges(to: view)
        webView.load(URLRequest(url: url))
    }
}
