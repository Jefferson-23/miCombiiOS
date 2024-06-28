//
//  ComuniViewController.swift
//  miCombi
//
//  Created by Jefferson Coaquira Cruz on 6/22/24.
//

import UIKit
import Firebase
import FirebaseStorage

class ComuniViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBAction func cerrarSesionTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var tablaComuni: UITableView!
    var comunis: [Comuni] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaComuni.delegate = self
        tablaComuni.dataSource = self
        
        let userComunisRef = Database.database().reference().child("conductores").child((Auth.auth().currentUser?.uid)!).child("comunicados")
        
        userComunisRef.observe(DataEventType.childAdded, with: { (comunishot) in
            if let comuniDict = comunishot.value as? [String: Any] {
                let comuni = Comuni()
                comuni.id = comunishot.key
                comuni.from = comuniDict["from"] as? String ?? "Unknown"
                comuni.audioDescrip = comuniDict["audioDescrip"] as? String ?? ""
                comuni.audioURL = comuniDict["audioURL"] as? String ?? ""
                comuni.audioID = comuniDict["audioID"] as? String ?? ""
                self.comunis.append(comuni)
                self.tablaComuni.reloadData()
            }
        })
        
        userComunisRef.observe(DataEventType.childRemoved, with: { (comunishot) in
            self.comunis.removeAll { $0.id == comunishot.key }
            self.tablaComuni.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comunis.isEmpty ? 1 : comunis.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if comunis.isEmpty {
            cell.textLabel?.text = "No hay Comunicados 🤯"
        } else {
            let comuni = comunis[indexPath.row]
            cell.textLabel?.text = comuni.from
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if comunis.isEmpty {
            return
        }
        
        let comuni = comunis[indexPath.row]
        if !comuni.audioURL.isEmpty {
            if let audioURL = URL(string: comuni.audioURL) {
                print("Navegando a escuchar audio con URL: \(audioURL)")
                performSegue(withIdentifier: "escucharaudio", sender: (audioURL, comuni))
            } else {
                print("Error: URL de audio no válida")
                mostrarAlerta(titulo: "Error", mensaje: "No se pudo cargar el audio.", accion: "Aceptar")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "escucharaudio" {
            if let (audioURL, comuni) = sender as? (URL, Comuni) {
                print("Preparando segue a EscucharAudioViewController con URL: \(audioURL)")
                let siguienteVC = segue.destination as! EscucharAudioViewController
                siguienteVC.audioURL = audioURL
                siguienteVC.comuni = comuni
            } else {
                print("Error: El sender no es un URL válido")
                mostrarAlerta(titulo: "Error", mensaje: "No se pudo cargar el audio.", accion: "Aceptar")
            }
        }/*else if segue.identifier == "versnapsegue" {
            if let snap = sender as? Snap {
                let siguienteVC = segue.destination as! VerSnapViewController
                siguienteVC.snap = snap
            }
        }
         */
    }

    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnOK = UIAlertAction(title: accion, style: .default, handler: nil)
        alerta.addAction(btnOK)
        present(alerta, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
