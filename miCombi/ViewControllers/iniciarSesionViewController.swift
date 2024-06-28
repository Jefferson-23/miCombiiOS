//
//  ViewController.swift
//  miCombi
//
//  Created by Jefferson on 19/06/24.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FirebaseDatabase

class iniciarSesionViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let iniciarSesionSegueIdentifier = "iniciarsesionsegue"
    private let crearUsuarioSegueIdentifier = "crearUsuarioSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupGoogleSignIn()
    }
    
    @IBAction func iniciarSesionTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Por favor, ingrese su correo electrónico y contraseña.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            guard let self = self else { return }
            if let error = error {
                print("Error iniciando sesión: \(error.localizedDescription)")
                self.showUserNotFoundAlert()
            } else {
                print("Inicio de sesión exitoso")
                self.performSegue(withIdentifier: self.iniciarSesionSegueIdentifier, sender: nil)
            }
        }
    }
    private func showUserNotFoundAlert() {
        let alert = UIAlertController(title: "Conductor no encontrado", message: "No se encontró un conductor con este correo electrónico. ¿Desea crear un nuevo conductor?", preferredStyle: .alert)
        let crearAction = UIAlertAction(title: "Crear", style: .default) { _ in
            self.performSegue(withIdentifier: self.crearUsuarioSegueIdentifier, sender: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(crearAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func iniciarSesionGoogleTapped(_ sender: Any) {
        signInWithGoogle()
    }
    private func setupGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No se encontró el ID de conductor en la configuración de Firebase")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    private func signInWithGoogle() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("No hay controlador de vista raíz!")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { userAuthentication, error in
            if let error = error {
                print("Error al iniciar sesión con Google: \(error.localizedDescription)")
                return
            }
            
            guard let user = userAuthentication?.user,
                  let idToken = user.idToken else {
                print("Error: Falta el token de ID")
                return
            }
            
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error al iniciar sesión con Google en Firebase: \(error.localizedDescription)")
                } else {
                    print("Usuario inició sesión con Google exitosamente")
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: self.iniciarSesionSegueIdentifier, sender: nil)
                    }
                }
            }
        }
    }
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
