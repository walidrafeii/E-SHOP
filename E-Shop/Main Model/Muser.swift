//
//  Muser.swift
//  E-Shop
//
//  Created by Walid Rafei on 9/2/20.
//  Copyright © 2020 Walid Rafei. All rights reserved.
//

import Foundation

import FirebaseAuth

class Muser {
    let objectId: String
    var email: String
    var firstName: String
    var lastName: String
    var fullName: String
    var purchasedItemIds: [String]
    
    var fullAddress: String?
    var onBoard: Bool
    
    //MARK: - initializers
    
    init (_objectId: String, _email: String, _firstName: String, _lastName: String) {
        objectId = _objectId
        email = _email
        firstName = _firstName
        lastName = _lastName
        fullName = _firstName + " " + _lastName
        fullAddress = ""
        onBoard = false
        purchasedItemIds = []
    }
    
    init(_dictionary: NSDictionary) {
        objectId = _dictionary[kOBJECTID] as! String
        
        if let mail = _dictionary[kEMAIL] {
            email = mail as! String
        } else {
            email = ""
        }
        
        if let fname = _dictionary[kFIRSTNAME] {
            firstName = fname as! String
        } else {
            firstName = ""
        }
        
        if let lName = _dictionary[kLASTNAME] {
            lastName = lName as! String
        } else {
            lastName = ""
        }
        
        fullName = firstName + " " + lastName
        
        if let faddress = _dictionary[kFULLADDRESS] {
            fullAddress = faddress as! String
        } else {
            fullAddress = ""
        }
        
        if let onB = _dictionary[kONBOARD] {
            onBoard = onB as! Bool
        } else {
            onBoard = false
        }

        if let purchaseIds = _dictionary[kPURCHASEDITEMS] {
            purchasedItemIds = purchaseIds as! [String]
        } else {
            purchasedItemIds = []
        }
    }
    
    //MARK: Return current user
    class func currentId() ->String {
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser() -> Muser? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
                return Muser.init(_dictionary: dictionary as! NSDictionary)
            }
        }
        
        return nil
    }
    
    //MARK: login func
    class func loginUserWith(email: String, password: String, completion: @escaping(_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error == nil {
                if authDataResult!.user.isEmailVerified {
                    // to download the user from firestore
                    downloadUserFromFireStore(userId: authDataResult!.user.uid, email: email)
                    //complete the task
                    completion(error, true)
                } else {
                    print("Email is not verified")
                    completion(error, false)
                }
            } else {
                completion(error, false)
            }
        }
    }
    
    //MARK: Register User
    class func RegisterUserWith(email: String, password: String, completion: @escaping(_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            
            completion(error)
            if error == nil {
                // send email verification
                authDataResult!.user.sendEmailVerification { (error) in
                    print ("auth email verification error: ", error?.localizedDescription)
                }
            }
        }
    }
    
    //MARK: resend link methods
    class func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    class func resendVerificationEmail(email: String, completion: @escaping(_ error: Error?) -> Void) {
        Auth.auth().currentUser?.reload(completion: { (error) in
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                print("resend email error", error?.localizedDescription)
                
                completion(error)
            })
        })
    }
    
    class func logOutCurrentUser(completion: @escaping(_ error: Error?) -> Void) {
        
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: kCURRENTUSER)
            UserDefaults.standard.synchronize()
            completion(nil)
            
        } catch let error as NSError {
            completion(error)
        }
    }
}

//MARK: download User

func downloadUserFromFireStore(userId: String, email: String) {
    FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
        guard let snapshot = snapshot else { return }
        
        if snapshot.exists {
            print("download current user from firestore")
            saveUserLocally(mUserDictionary: snapshot.data()! as NSDictionary)
        } else {
            // there is no user, save new user in firestore
            let user = Muser(_objectId: userId, _email: email, _firstName: "", _lastName: "")
            saveUserLocally(mUserDictionary: userDictionaryFrom(user: user))
            saveUserToFireStore(mUser: user)
        }
    }
}
//MARK: save user to firebase

func saveUserToFireStore( mUser: Muser) {
    FirebaseReference(.User).document(mUser.objectId).setData(userDictionaryFrom(user: mUser) as! [String : Any]) { (error) in
        if error != nil {
            print("error saving user \(error!.localizedDescription)")
        }
    }
}

func saveUserLocally(mUserDictionary: NSDictionary) {
    UserDefaults.standard.set(mUserDictionary, forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
}

//MARK: Helper Function

func userDictionaryFrom(user: Muser) -> NSDictionary {
    return NSDictionary(objects: [user.objectId, user.email, user.firstName, user.lastName, user.fullName, user.fullAddress ?? "", user.onBoard, user.purchasedItemIds], forKeys: [kOBJECTID as NSCopying, kEMAIL as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kFULLNAME as NSCopying, kFULLADDRESS as NSCopying, kONBOARD as NSCopying, kPURCHASEDITEMS as NSCopying])
}

//MARK: update user
func updateCurrentUserInFireStore(withValues: [String: Any], completion: @escaping(_ error: Error?) -> Void) {
    if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
        let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
        userObject.setValuesForKeys(withValues)
        
        FirebaseReference(.User).document(Muser.currentId()).updateData(withValues) { (error) in
            completion(error)
            if error == nil {
                //update was successful
                saveUserLocally(mUserDictionary: userObject)
            }
        }
    }
}
