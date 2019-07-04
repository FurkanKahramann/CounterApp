//
//  ViewController.swift
//  CounterApp
//
//  Created by fkahraman on 4.07.2019.
//  Copyright © 2019 fkahraman. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {

    

    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var counterTextField: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    
    var timer : Timer?
    let shapeLayer = CAShapeLayer()
    var player: AVAudioPlayer?
    var second = 0
    
    var hour:Int = 0
    var minutes:Int = 0
    var seconds:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        closeButton.isHidden = true
        view.backgroundColor = UIColor.black
        closeButton.layer.cornerRadius = 15
        let center = view.center
        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi/2 , endAngle: 2*CGFloat.pi, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        view.layer.addSublayer(trackLayer)
        
        //let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi/2 , endAngle: 2*CGFloat.pi, clockwise: true)
        
        shapeLayer.path = circularPath.cgPath
        
        
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
        
        
        //let toolBar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = UIColor.black
        toolbar.sizeToFit()
        
        // Adding Button ToolBar
        
        let doneButton = UIBarButtonItem(title: "Tamam", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        doneButton.tintColor = UIColor.black
        toolbar.setItems([spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        counterTextField.inputAccessoryView = toolbar

    }
    @IBAction func closeAlert(_ sender: Any) {
        playSound(runStop: 1)
        closeButton.isHidden = true
    }
    @objc func doneClick() {
        viewWillDisappear(true)
        //textBox.resignFirstResponder()
        counterTextField.resignFirstResponder()
        UIView.animate(withDuration: 0.25, animations: {
            self.toolbar.isHidden = true
            self.picker.isHidden = true
        })
        viewWillAppear(false)
        handlerTap()
    }
    @objc private func handlerTap(){
        closeButton.isHidden = true
        let hourToMinutes = hour * 60
        let hourSecond = hourToMinutes * 60
        
        let minutesToSecond = minutes * 60
        
        second = hourSecond + minutesToSecond + seconds

        print("Second : \(second)")
        
        if(second != 0){
            timer = Timer.scheduledTimer(timeInterval:1, target:self, selector:#selector(prozessTimer), userInfo: nil, repeats: true)
        }
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 0.8
        
        basicAnimation.duration = Double(second)
        second = Int(basicAnimation.duration)
        //counterLabel.text = ("\(hour) : \(minutes) : \(second)")
        counterLabel.text = timeString(time: TimeInterval(second))
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
    }
    
    @objc func prozessTimer() {
        second -= 1
        //counterLabel.text = ("\(hour) : \(minutes) : \(second)")
        counterLabel.text = timeString(time: TimeInterval(second))

        if(second == 0){
            closeButton.isHidden = false
            playSound(runStop: 0)
            timer?.invalidate()
            timer = nil
        }
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBAction func textFieldDidBeginEditing(textField: UITextField){
        print("Click")
        self.picker.isHidden = false
        self.toolbar.isHidden = false
        textField.endEditing(true)
    }
    
    func timeString(time: TimeInterval) -> String {
        let hour2 = Int(time) / 3600
        let minutes2 = Int(time) / 60 % 60
        let seconds2 = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hour2, minutes2, seconds2)
    }
    func playSound(runStop: Int) {
        if (runStop == 0){
            guard let url = Bundle.main.url(forResource: "badguy", withExtension: "mp3") else { return }
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                
                
                guard let player = player else { return }
                
                player.play()
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
        else{
            player?.stop()
        }
        
    }

    

}
extension ViewController:UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 25
        case 1,2:
            return 60
            
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.width/3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        switch component {
        case 0:
            return "\(row) Hour"
        case 1:
            return "\(row) Minute"
        case 2:
            return "\(row) Second"
        default:
            return ""
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            hour = row
            counterTextField.text = " \(hour) Saat: \(minutes) Dakika: \(seconds) Saniye"
            //picker.isHidden = true
        case 1:
            minutes = row
            counterTextField.text = " \(hour) Saat: \(minutes) Dakika: \(seconds) Saniye"
            //picker.isHidden = true
        case 2:
            seconds = row
            counterTextField.text = " \(hour) Saat: \(minutes) Dakika: \(seconds) Saniye"
            //picker.isHidden = true
        default:
            break;
        }
    }
}

