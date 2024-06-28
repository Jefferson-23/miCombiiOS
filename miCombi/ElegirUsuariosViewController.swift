//
//  ElegirUsuariosViewController.swift
//  SnapChat
//
//  Created by Jefferson Coaquira Cruz on 6/7/24.
//

import UIKit
import Firebase

class ElegirUsuariosViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
        @IBOutlet weak var listaUsuarios: UITableView!
        
        var usuarios: [Usuario] = []
        var audioURL = ""
        var audioDescrip = ""
        var audioID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listaUsuarios.delegate=self
        listaUsuarios.dataSource=self
        Database.database().reference().child("usuarios").observe(DataEventType.childAdded,with: {(snapshot) in print(snapshot)
            let usuario = Usuario()
            usuario.email = (snapshot.value as! NSDictionary)["email" ] as! String
            usuario.uid = snapshot.key
            self.usuarios.append(usuario)
            self.listaUsuarios.reloadData()
        })
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection
                   section: Int) -> Int {
        return usuarios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:
                   IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let usuario = usuarios[indexPath.row]
        cell.textLabel?.text = usuario.email
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let usuario = usuarios[indexPath.row]
        let snap = ["from" : Auth.auth().currentUser?.email, "audioDescrip":audioDescrip, "audioURL": audioURL,"audioID" : audioID]
                Database.database().reference().child("usuarios").child(usuario.uid).child("snaps").childByAutoId().setValue(snap)
                navigationController?.popViewController(animated: true)
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
