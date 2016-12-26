import Cocoa

class ViewController: NSViewController {
    
    let appDelegate = NSApplication.shared().delegate as! AppDelegate
    
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var currentVolume: NSTextField!
    @IBOutlet weak var enabledCheckbox: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let volume = appDelegate.defaults.float(forKey: appDelegate.desiredVolumeKey)
        self.currentVolume.placeholderString = "?"
        self.currentVolume.stringValue = NSString(format: "%.2f", volume) as String
        
        self.currentVolume.isEditable = false
        self.currentVolume.isSelectable = false
        
        // Set slider to current volume
        volumeSlider.floatValue = volume
        
        // Set enabled button to current state
        let buttonState = appDelegate.defaults.integer(forKey: appDelegate.enabledKey)
        enabledCheckbox.state = buttonState

        appDelegate.nc.addObserver(self, selector: #selector(self.handleVolumeChanged), name: NSNotification.Name.OnVolumeChanged, object: nil)
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func sliderChanged(_ sender: NSSlider) {
        let val: Float = sender.floatValue
        let userInfo: ValInfo = ["val": val]
        
        NSLog("Slider changed to: \(val)")
        
        appDelegate.nc.post(name: NSNotification.Name.OnVolumeChanged, object: nil, userInfo: userInfo)
    }

    @IBAction func buttonPressed(_ sender: NSButtonCell) {
        let buttonState = enabledCheckbox.state
        let userInfo: EnabledInfo = ["buttonState": buttonState]
        
        NSLog("Enabled button pressed. State is: \(buttonState)")
        
        appDelegate.nc.post(name: NSNotification.Name.OnEnabledButtonPressed, object: nil, userInfo: userInfo)
    }
    
    // This is done here in case we have multiple sources posting notifications
    // modifying the volume.
    func handleVolumeChanged(notification: Notification) {
        NSLog("Received \(notification.name)")
        let userInfo = notification.userInfo as! ValInfo
        currentVolume.stringValue = "\(userInfo["val"])"
    }

}
