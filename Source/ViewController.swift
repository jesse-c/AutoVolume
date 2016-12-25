import Cocoa

class ViewController: NSViewController {
    
    let appDelegate = NSApplication.shared().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        appDelegate.nc.post(name: NSNotification.Name.OnSliderChanged, object: nil, userInfo: userInfo)
    }

}
