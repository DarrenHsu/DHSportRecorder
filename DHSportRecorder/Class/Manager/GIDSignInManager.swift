//
//  GIDSignInManager.swift
//  DHYoutube
//
//  Created by Darren Hsu on 17/10/2017.
//  Copyright © 2017 D.H. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class GIDSignInManager: NSObject, GIDSignInDelegate {
    
    private static var _manager: GIDSignInManager?
    
    private var token: String?
    
    private let scopes = [kGTLRAuthScopeYouTube,
                          kGTLRAuthScopeYouTubeForceSsl,
                          kGTLRAuthScopeYouTubeUpload,
                          kGTLRAuthScopeYouTubeYoutubepartner,
                          kGTLRAuthScopeYouTubeYoutubepartnerChannelAudit,
                          kGTLRAuthScopeYouTubeReadonly]
    
    private var authResult: ((Bool) -> Void)?
    
    public static func sharedInstance() -> GIDSignInManager {
        if _manager == nil {
            _manager = GIDSignInManager()
        }
        return _manager!
    }
    
    
    private var _accessToken: String?
    var accessToken: String {
        set{ _accessToken = newValue }
        get { return _accessToken! }
    }
    
    private var _email: String?
    var email: String {
        set{ _email = newValue }
        get { return _email! }
    }
    
    func getAPIKey() -> String {
        var apikey: String? = nil
        if let path = Bundle.main.path(forResource: "GoogleService-Info" , ofType: "plist" ) {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                apikey = dict["API_KEY"] as? String
            }
        }
        return apikey!
    }
    
    func getClientID() -> String {
        var clientId: String? = nil
        if let path = Bundle.main.path(forResource: "GoogleService-Info" , ofType: "plist" ) {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                clientId = dict["CLIENT_ID"] as? String
            }
        }
        
        return clientId!
    }
    
    func authorization(controller: GIDSignInUIDelegate, result: @escaping (Bool) -> Void) {
        authResult = result
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = getClientID()
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().uiDelegate = controller
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    // MARK: - GIDSignInDelegate Methods
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            authResult?(false)
        } else {
            self.accessToken = user.authentication.accessToken
            self.email = user.profile.email
            authResult?(true)
        }
    }
}
