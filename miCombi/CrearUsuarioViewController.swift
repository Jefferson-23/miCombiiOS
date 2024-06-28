//
//  CrearUsuarioViewController.swift
//  SnapChat
//
//  Created by Jefferson Coaquira Cruz on 6/1/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CrearUsuarioViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func crearUsuarioTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Por favor, ingrese su correo electrónico y contraseña.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if let error = error {
                print("Error creando usuario: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "No se pudo crear el usuario. \(error.localizedDescription)")
            } else {
                print("Usuario creado exitosamente")
                if let uid = user?.user.uid {
                    Database.database().reference().child("usuarios").child(uid).child("email").setValue(email)
                }
                self.showAlert(title: "Creación de Usuario", message: "Usuario: \(email) se creó correctamente.", dismiss: true)
            }
        }
    }
    
    private func showAlert(title: String, message: String, dismiss: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Aceptar", style: .default) { _ in
            if dismiss {
                self.dismiss(animated: true, completion: nil)
            }
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
