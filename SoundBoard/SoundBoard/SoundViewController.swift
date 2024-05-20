import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    // MARK: OUTLETS
    
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var labelTimer: UILabel!
    
    var grabarAudio: AVAudioRecorder?
    var reproducirAudio: AVAudioPlayer?
    var audioURL: URL?
    
    var timer: Timer?
    var elapsedTime: TimeInterval = 0
    
    // MARK: ACTION FUNCTIONS
    
    @IBAction func grabarTapped(_ sender: Any) {
        
        if grabarAudio!.isRecording {
            grabarAudio?.stop()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            
            timer?.invalidate()
            timer = nil
            labelTimer?.text = "00:00"
            
        } else {
            agregarButton.isEnabled = true
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
            
            elapsedTime = 0
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
        
    }
    
    @objc func updateTimer() {
        elapsedTime += 1
        let minutos = Int(elapsedTime) / 60
        let segundos = Int(elapsedTime) % 60
        labelTimer.text = String(format: "%02d:%02d", minutos, segundos)
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("REPRODUCIENDO!!")
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        } catch {
            // Manejo de errores
        }
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        guard let grabarAudio = grabarAudio else { return }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.duracion = grabarAudio.currentTime
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        labelTimer?.text = "00:00"
    }
    
    func configurarGrabacion() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponente = [basePath, "Audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponente)!
            print("******")
            print(audioURL!)
            print("******")
            
            var settings: [String: AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
    }
}
