import UIKit
import AVFoundation
import Firebase
import FirebaseStorage

class EscucharAudioViewController: UIViewController {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var snap = Snap()
    var audioDescrip: String?
    var audioURL: URL?
    var audioPlayer: AVAudioPlayer?
    var audioDuration: TimeInterval?
    
    var timer: Timer?
    
    deinit {
        timer?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = audioURL {
            downloadAndPrepareAudio(from: url)
        }
        titleLabel.text = "Titulo: " + snap.audioDescrip
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioPlayer?.stop()
        timer?.invalidate()
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if audioPlayer == nil || !audioPlayer!.isPlaying {
            audioPlayer?.play()
            updateUIForPlayback()
            setupTimer()
        }
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        audioPlayer?.pause()
        updateUIForPlayback()
        timer?.invalidate()
    }
    
    func downloadAndPrepareAudio(from url: URL) {
        let task = URLSession.shared.downloadTask(with: url) { [weak self] (localURL, response, error) in
            guard let self = self else { return }
            if let localURL = localURL {
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: localURL)
                    self.audioPlayer?.delegate = self
                    self.audioPlayer?.prepareToPlay()
                    if let duration = self.audioPlayer?.duration {
                        self.audioDuration = duration
                        DispatchQueue.main.async {
                            self.durationLabel.text = "Duracion: \(self.formatTime(duration))"
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo cargar el audio", accion: "Aceptar")
                    }
                    print("Error loading audio: \(error)")
                }
            } else {
                DispatchQueue.main.async {
                    self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo descargar el audio", accion: "Aceptar")
                }
                print("Error downloading audio: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        task.resume()
    }
    
    func updateUIForPlayback() {
        guard let player = audioPlayer else { return }
        playButton.isEnabled = !player.isPlaying
        pauseButton.isEnabled = player.isPlaying
    }
    
    func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updatePlaybackProgress), userInfo: nil, repeats: true)
    }
    
    @objc func updatePlaybackProgress() {
        guard let player = audioPlayer else { return }
        let currentTime = player.currentTime
        durationLabel.text = "Duracion: \(formatTime(currentTime)) / \(formatTime(audioDuration ?? 0))"
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnOK = UIAlertAction(title: accion, style: .default, handler: nil)
        alerta.addAction(btnOK)
        present(alerta, animated: true, completion: nil)
    }
}

extension EscucharAudioViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateUIForPlayback()
        timer?.invalidate()
    }
}

