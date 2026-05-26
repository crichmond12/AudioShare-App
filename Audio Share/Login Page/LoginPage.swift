//
//  LoginPage.swift
//  Audio Share
//
//  Created by Christian Richmond on 5/23/24.
//

import SwiftUI
//
//  LoginScreen.swift
//  SchoolPathways
//
//  Created by Christian Richmond on 2/17/24.
//

import SwiftUI
import SpotifyiOS;
import LocalAuthentication

struct LoginScreen: View {
    private let keychainManager = KeychainManager()
    private let SEC = Sec.shared;
    @State private var initial_time_passed: Bool = false
    @State private var slide_logo_up: Bool = false
    @State private var username: String = ""
    @State private var email: String = "";
    @State private var user_password: String = ""
    @State private var remember_me: Bool = false
    @State private var show_form: Bool = false
    @State private var user_scope: String = ""
    @State private var keyboard_is_shown: Bool = false
    @State private var scrollPosition: CGPoint = .zero
    @State private var isLogin: Bool = true;
    @State private var show_device_connect: Bool = false;
    @StateObject private var loginManager = LoginManager.shared;
    
    func createAccount() async -> Bool {
        let (public_key, private_key) = self.SEC.generateKeyPair()!;
        if (!keychainManager.savePrivateKey(private_key, for: "\(username)_audioshare_pkey")){
            print("ERROR saving private key");
            return false;
        }
        
        if (!keychainManager.savePublicKey(public_key, for: "\(username)_audioshare_pubkey")){
            print("ERROR saving public key");
            return false;
        }
        
        if (!keychainManager.saveCredentials(username: username, password: user_password)){
            print("ERROR saving credentials.");
            return false;
        }
        
        var success = false;
        if (!isLogin){
            success = await loginManager.createUser(username: username, password: user_password)
        }
        else{
            success = await loginManager.login(username: username, password: user_password);
        }
        
        return success;
    }
    
    func authenticateUser() async -> Bool {
        let success = await loginManager.login(username: username, password: user_password);
        return true;
    }
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [Color(hex: "DCDCDC"), Color(hex: "591E7D")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            GeometryReader{
                geometry in
                VStack(){
                    Spacer()
                        .frame(height: geometry.size.height * 0.05)
                    Text(isLogin ? "Log in" : "Welcome")
                        .font(.system(size: 35))
                        .animation(.easeInOut(duration: 0.2), value: isLogin)
                    Spacer()
                        .frame(height: geometry.size.height * 0.2)
                    HStack{
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: geometry.size.width * 0.8, height: UIScreen.main.bounds.height * 0.5)
                            .foregroundColor(Color.black)
                            .opacity(0.3)
                            .overlay(
                                VStack(alignment: .leading){
                                    Text("Email")
                                        .font(.system(size: 20))
                                    TextField("", text: $username)
                                        .textInputAutocapitalization(.never)
                                    Divider()
                                        .frame(height: 2)
                                        .background(Color.white)
                                    Spacer()
                                        .frame(height: 20)
                                    Text("Password")
                                        .font(.system(size: 20))
                                    SecureField("", text: $user_password)
                                    Divider()
                                        .frame(height: 2)
                                        .background(Color.white)
                                    Spacer()
                                        .frame(height: geometry.size.height * 0.15)
                                    HStack(alignment: .center){
                                        
                                        Spacer()
                                        GeometryReader{
                                            geometry in
                                            NavigationLink(destination: DeviceConnect()){
                                                Button(action: {
                                                    print(self.username);
                                                    print(self.user_password);
                                                    Task{
                                                        print(self.username);
                                                        print(self.user_password);
                                                        if (self.username != "" && self.user_password != ""){
                                                            if (isLogin){
                                                                let success = await authenticateUser();
                                                            }
                                                            else{
                                                                let success = await createAccount();
                                                                if (!success){
                                                                    print("ERROR");
                                                                }
                                                                
                                                                show_device_connect = true;
                                                            }
                                                        }

                                                    }
                                                }){
                                                    Text(isLogin ? "Log In": "Create Account")
                                                        .frame(width: geometry.size.width, height: 48)
                                                        .font(.headline) // Custom font size
                                                        .foregroundColor(.white) // Text color
                                                        .background(Color.blue) // Background color
                                                        .cornerRadius(8) // Rounded corners
                                                        .shadow(radius: 10) // Shadow effect
                                                        .animation(.easeInOut(duration: 0.3), value: isLogin)
                                                }}

                                            }
                                        Spacer()
                                    }
                                    
                                
                                    HStack{
                                        if (isLogin){
                                            
                                            Text("Forgot Password")
                                                .animation(.easeInOut(duration: 0.3), value: isLogin)
                                                .underline()
                                            Text("Create a new account")
                                                .underline()
                                                .onTapGesture{
                                                    withAnimation{
                                                        self.isLogin = false;
                                                    }
                                                }
                                        }
                                        else{
                                            Spacer()
                                            Text("Log in")
                                                .underline()
                                                .onTapGesture{
                                                    withAnimation{
                                                        self.isLogin = true;
                                                    }
                                                }
                                            Spacer()

                                        }
                                    }
                                    .animation(.easeInOut(duration: 0.2), value: isLogin)
                                }
                                    .padding(20)
                            )
                        Spacer()
                        
                    }
                }
            }
        }
    }
}


