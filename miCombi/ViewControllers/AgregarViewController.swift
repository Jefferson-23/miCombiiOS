//
//  AgregarViewController.swift
//  miCombi
//
//  Created by Jefferson Coaquira Cruz on 6/23/24.
//

import UIKit

class AgregarViewController: UIViewController {
    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtNrutas: UITextField!
    @IBOutlet weak var txtNunidades: UITextField!
    @IBOutlet weak var txtImagen: UITextField!
    @IBOutlet weak var botonGuardar: UIButton!
    @IBOutlet weak var botonActualizar: UIButton!
    
    var combi: Combi?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if combi == nil {
            botonGuardar.isEnabled = true
            botonActualizar.isEnabled = false
        } else {
            botonGuardar.isEnabled = false
            botonActualizar.isEnabled = true
            txtNombre.text = combi!.nombre
            txtNrutas.text = combi!.nrutas
            txtNunidades.text = combi!.nunidades
            txtImagen.text = combi!.imagen
        }
        // Do any additional setup after loading the view.
    }
    

    @IBAction func btnGuardar(_ sender: Any) {
        let nombre = txtNombre.text!
        let nrutas = txtNrutas.text!
        let nunidades = txtNunidades.text!
        let imagen = txtImagen.text!
        let datos = ["usuarioId": 1, "nombre": "\(nombre)", "nrutas": "\(nrutas)", "nunidades": "\(nunidades)", "imagen": "\(imagen)"] as Dictionary<String, Any>
        let ruta = "http://64.23.129.61:8080/combis"
        metodoPOST(ruta: ruta, datos: datos)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnActualizar(_ sender: Any) {
        let nombre = txtNombre.text!
        let nrutas = txtNrutas.text!
        let nunidades = txtNunidades.text!
        let imagen = txtImagen.text!
        let datos = ["usuarioId": 1, "nombre": "\(nombre)", "nrutas": "\(nrutas)", "nunidades": "\(nunidades)", "imagen": "\(imagen)"] as Dictionary<String, Any>
        let ruta = "http://64.23.129.61:8080/combis/\(combi!.id)"
        metodoPUT(ruta: ruta, datos: datos)
        navigationController?.popViewController(animated: true)

    }
    
    
    func metodoPOST (ruta: String, datos: [String:Any]) {
        let url: URL = URL(string: ruta)!
        var request = URLRequest(url: url)
        let session = URLSession.shared
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: datos, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            print("Error serializando JSON")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            if let data = data {
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves)
                    print(dict)
                } catch {
                    print("Error procesando respuesta JSON")
                }
            }
        })
        task.resume()
    }
    
    func metodoPUT (ruta: String, datos: [String:Any]) {
        let url: URL = URL(string: ruta)!
        var request = URLRequest(url: url)
        let session = URLSession.shared
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: datos, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            print("Error serializando JSON")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            if let data = data {
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves)
                    print(dict)
                } catch {
                    print("Error procesando respuesta JSON")
                }
            }
        })
        task.resume()
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
