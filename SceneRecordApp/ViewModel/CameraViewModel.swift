//
//  CameraViewModel.swift
//  SceneRecordApp
//
//  Created by Hoang Le on 28/02/2023.
//

import SwiftUI
import AVFoundation
import Alamofire

enum CameraModelError: Error{
    case configurationFailed
}

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error != nil{
            print("File output error")
            return
        }
        print("file url: ", outputFileURL)
        self.previewURL = outputFileURL
    }
    
    
    @Published var alert = false
    @Published var isSave = false
    @Published var picData = Data(count: 0)
    @Published var recordingURL : [URL] = []
    @Published var showPreview: Bool = false
    @Published var isExport: Bool = false
    @Published var fileFormat = FileFormat(textFieldValue: "")
    
    @Published var session = AVCaptureSession()
    @Published var isRecording : Bool = false
    @Published var isSending : Bool = false
    @Published var isAnalysis : Bool = false
    @Published var output = AVCaptureMovieFileOutput()
    @Published var preview : AVCaptureVideoPreviewLayer!
    @Published var previewURL : URL?
    @Published var recordDulation : CGFloat = 0.0
    @Published var maxDuration : CGFloat = 10.0
    @Published var sendingDulation : CGFloat = 0.0
    @Published var maxSending : CGFloat = 3.0
    @Published var analysisDulation : CGFloat = 0.0
    @Published var maxAnalysis : CGFloat = 2.0
    @Published var logStatus : String = "Ready for record!"
    @Published var buttonStatus : String = "Start"
    @Published var showButton : Bool = true
    @Published var sendingDuration : CGFloat = 3.0
    @Published var analysisDuration : CGFloat = 2.0
    @Published var showResult : Bool = false
    @Published var PPM : String = "Predicting"
    
    
    
    
    func CheckPermission(){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video){ (status) in
                if status{
                    self.setUp()
                }
            }
            
        case .denied:
            self.alert.toggle()
            return
            
        default:
            return
        }
    }
    
    func setUp(){
        do{
            self.session.beginConfiguration()
            let cameraDevice = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front)
            let videoInput = try AVCaptureDeviceInput(device: cameraDevice!)
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if self.session.canAddInput(videoInput) && self.session.canAddInput(audioInput){
                self.session.addInput(videoInput)
                self.session.addInput(audioInput)
                
            }
            
            if self.session.canAddOutput(output){
                self.session.addOutput(output)
            }
            
            self.session.commitConfiguration()
            
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func startRecording(){
        let tempURL = NSTemporaryDirectory() + "\(Date()).mp4"
        output.startRecording(to: URL(fileURLWithPath: tempURL), recordingDelegate: self)
        previewURL = URL(string: tempURL)
        buttonStatus = "Reset"
        isRecording = true
    }

    func resetRecording(){
        output.stopRecording()
        buttonStatus = "Start"
        logStatus = "Ready for start!"
        recordDulation = 0.0
        isRecording = false
        isSending = false
    }
    
    func wait(for duration: TimeInterval, then completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion()
        }
    }
    
    func submitFileFormat(_ fileFormat: FileFormat) {
        print(fileFormat.textFieldValue)
        }
    
    
    func uploadVideo(filename: String) {
        guard let url = URL(string: "http://172.16.2.204:5000/upload-video") else { return }
        var request = URLRequest(url: url)
        let timestamp = Date.now
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        let videoData = try? Data(contentsOf: self.previewURL!)
        let fieldName = "video"
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"nguyen_2.mp4\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: video/mp4\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(videoData!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // handle the response from the server
            if error != nil {
                print(error?.localizedDescription as Any)
            }else{
//                PPM = response["ppm"]
                do {
                        // Parse the JSON data into a dictionary
                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                            // Access the properties of the JSON object
                        let propertyValue = json["HR"] as? String
                        self.PPM = String(propertyValue!)
                            print(propertyValue)
                        }
                    } catch {
                        // Handle JSON parsing errors here...
                    }
                print("success upload")
            }
            print("Another session!")
        }
        task.resume()
        
    }
    
    var retryCount = 0
    
}

struct FileFormat: Codable {
    var textFieldValue: String
}
