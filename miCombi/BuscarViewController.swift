//
//  BuscarViewController.swift
//  miCombi
//
//  Created by Jefferson Coaquira Cruz on 6/23/24.
//

import UIKit

class BuscarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaCombis.delegate = self
        tablaCombis.dataSource = self
        
        let ruta = "http://localhost:3000/combis/"
        cargarCombis(ruta: ruta) {
            self.tablaCombis.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let ruta = "http://localhost:3000/combis/"
        cargarCombis(ruta: ruta) {
            self.tablaCombis.reloadData()
        }
    }
    
    var combis = [Combi]()
    
    
    @IBOutlet weak var txtBuscar: UITextField!
    @IBOutlet weak var tablaCombis: UITableView!
    
    @IBAction func btnBuscar(_ sender: Any) {
        let ruta = "http://localhost:3000/combis?"
        let nombre = txtBuscar.text!
        let url = ruta + "nombre_like=\(nombre)"
        let crearURL = url.replacingOccurrences(of: " ", with: "%20")
        
        if nombre.isEmpty {
            let ruta = "http://localhost:3000/combis/"
            self.cargarCombis(ruta: ruta) {
                self.tablaCombis.reloadData()
            }
        } else {
            cargarCombis(ruta: crearURL) {
                if self.combis.count <= 0 {
                    self.mostrarAlerta(titulo: "Error", mensaje: "No se encontraron coincidencias para: \(nombre)", accion: "Cancelar")
                } else {
                    self.tablaCombis.reloadData()
                }
            }
        }
    }
    
    // Pet URL
    func cargarCombis(ruta: String, completed: @escaping () -> ()) {
        let url = URL(string: ruta)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                do {
                    self.combis = try JSONDecoder().decode([Combi].self, from: data!)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch {
                    print("Error en JSON")
                }
            }
        }.resume()
    }
    
    func eliminarCombi(combi: Combi, completed: @escaping () -> ()) {
        guard let url = URL(string: "http://localhost:3000/combis/\(combi.id)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error al eliminar la combi: \(error)")
            } else {
                completed()
            }
        }.resume()
    }
    
    // Funciones
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return combis.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(combis[indexPath.row].nombre)"
        cell.detailTextLabel?.text = "Rutas: \(combis[indexPath.row].nrutas) Unidades: \(combis[indexPath.row].nunidades)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let combi = combis[indexPath.row]
        performSegue(withIdentifier: "segueEditar", sender: combi)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alerta = UIAlertController(title: "Confirmación de eliminación", message: "¿Desea eliminar la combi?", preferredStyle: .alert)
            let btnOK = UIAlertAction(title: "Si", style: .default, handler: { (UIAlertAction) in
                let combi = self.combis[indexPath.row]
                self.eliminarCombi(combi: combi) {
                    self.combis.remove(at: indexPath.row)
                    let ruta = "http://localhost:3000/combis/"
                    self.cargarCombis(ruta: ruta) {
                        self.tablaCombis.reloadData()
                    }
                }
            })
            alerta.addAction(btnOK)
            let btnCANCEL = UIAlertAction(title: "No", style: .default, handler: nil)
            alerta.addAction(btnCANCEL)
            present(alerta, animated: true, completion: nil)
        }
    }
    
    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnOK = UIAlertAction(title: accion, style: .default, handler: nil)
        alerta.addAction(btnOK)
        present(alerta, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueEditar" {
            let siguienteVC = segue.destination as! AgregarViewController
            siguienteVC.combi = sender as? Combi
        }
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
