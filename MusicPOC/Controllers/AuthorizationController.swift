//
//  AuthorizationController.swift
//  MusicPOC
//
//  Created by Ankur Kumar on 19/02/22.
//

import MusicKit
import UIKit

class AuthorizationController: UIViewController {
    
    var onSuccess:((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - MusicKit methods
    private func checkAuthorization() async throws {
        let status = await MusicAuthorization.request()
        
        switch status {
        case .authorized :
            print("User is authorize...")
            onSuccess?(true)
            
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        default:
            print("User is not authorized...")
            self.onSuccess?(false)
        }
    }
    
    // MARK:- IBAction methods
    @IBAction private func continueBtn(_ sender: UIButton) {
        Task {
            try? await checkAuthorization()
        }
    }
    @IBAction private func dismissAler(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.onSuccess?(false)
        }
    }
}
