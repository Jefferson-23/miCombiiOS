//
//  CrearUsuarioViewController.swift
//  miCombi
//
//  Created by Jefferson on 19/06/24.
//

import UIKit
import Firebase
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
                print("Error creando conductor: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "No se pudo crear el conductor. \(error.localizedDescription)")
            } else {
                print("Conductor creado exitosamente")
                if let uid = user?.user.uid {
                    Database.database().reference().child("conductores").child(uid).child("email").setValue(email)
                }
                self.showAlert(title: "Creación de Conductor", message: "Conductor: \(email) se creó correctamente.", dismiss: true)
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
