//
//  AudioViewController.swift
//  miCombi
//
//  Created by Jefferson Coaquira Cruz on 6/22/24.
//


import UIKit
import AVFoundation
import Firebase
import FirebaseStorage

class AudioViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var tituloTextField: UITextField!
    @IBOutlet weak var elegirContactoBoton: UIButton!
    
    var audioRecorder: AVAudioRecorder?
    var audioID = NSUUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        elegirContactoBoton.isEnabled = false
    }
    
    func setupRecorder() {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            session.requestRecordPermission { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        // Permiso otorgado, no es necesario hacer nada aquí
                    } else {
                        self.mostrarAlerta(titulo: "Permiso denegado", mensaje: "Por favor, habilite el acceso al micrófono en Configuración", accion: "Aceptar")
                    }
                }
            }
        } catch {
            mostrarAlerta(titulo: "Error", mensaje: "No se pudo configurar la sesión de grabación", accion: "Aceptar")
        }
    }
    
    func startRecording() {
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            let audioURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(audioID).m4a")
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            recordButton.setTitle("Detener", for: .normal)
        } catch {
            mostrarAlerta(titulo: "Error", mensaje: "No se pudo configurar el grabador de audio", accion: "Aceptar")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        recordButton.setTitle("Grabar", for: .normal)
        elegirContactoBoton.isEnabled = true
    }
    
    @IBAction func recordTapped(_ sender: Any) {
        if audioRecorder?.isRecording == true {
            stopRecording()
        } else {
            setupRecorder()
            startRecording() // Start recording when the user taps the record button
        }
    }
    
    @IBAction func elegirContactoTapped(_ sender: Any) {
        self.elegirContactoBoton.isEnabled = false
        guard let audioURL = audioRecorder?.url else {
            mostrarAlerta(titulo: "Error", mensaje: "No se ha grabado ningún audio.", accion: "Aceptar")
            self.elegirContactoBoton.isEnabled = true
            return
        }

        let audiosFolder = Storage.storage().reference().child("comunicados")
        let cargarAudio = audiosFolder.child("\(audioID).m4a")
        
        cargarAudio.putFile(from: audioURL, metadata: nil) { (metadata, error) in
            if let error = error {
                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir el audio. Verifique su conexión a internet y vuelva a intentarlo.", accion: "Aceptar")
                self.elegirContactoBoton.isEnabled = true
                print("Ocurrió un error al subir audio: \(error.localizedDescription)")
                return
            }
            
            cargarAudio.downloadURL { (url, error) in
                if let error = error {
                    self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información del audio.", accion: "Cancelar")
                    self.elegirContactoBoton.isEnabled = true
                    print("Ocurrió un error al obtener información del audio \(error.localizedDescription)")
                    return
                }
                
                guard let enlaceURL = url else {
                    self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo obtener la URL del audio.", accion: "Aceptar")
                    self.elegirContactoBoton.isEnabled = true
                    return
                }
                
                self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: enlaceURL.absoluteString)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let siguienteVC = segue.destination as? ElegirUsuariosViewController, let audioURLString = sender as? String {
            siguienteVC.audioURL = audioURLString
            siguienteVC.audioDescrip = tituloTextField.text ?? ""
            siguienteVC.audioID = audioID
        }
    }
    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnOK = UIAlertAction(title: accion, style: .default, handler: nil)
        alerta.addAction(btnOK)
        present(alerta, animated: true, completion: nil)
    }
}
