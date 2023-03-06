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
    
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCaptureMovieFileOutput()
    @Published var preview : AVCaptureVideoPreviewLayer!
    @Published var isSave = false
    @Published var picData = Data(count: 0)
    @Published var isRecording:Bool = false
    @Published var recordingURL : [URL] = []
    @Published var previewURL : URL?
    @Published var showPreview: Bool = false
    @Published var isExport: Bool = false
    @Published var recordDulation : CGFloat = 1.0
    @Published var maxDuration : CGFloat = 29.0
    @Published var fileFormat = FileFormat(textFieldValue: "")
    
    
    
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
        isRecording = true
    }

    func stopRecording(){
        output.stopRecording()
        isRecording = false
    }
    
    func submitFileFormat(_ fileFormat: FileFormat) {
        print(fileFormat.textFieldValue)
        }
    
    func export(withPreset preset: String = AVAssetExportPresetHighestQuality,
                toFileType outputFileType: AVFileType = .mov) async {
        print("Start export??")
        let video = AVAsset(url: self.previewURL!)
        let outputURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("video.mp4", isDirectory: false)
        isExport = true
        print("Output url: ", outputURL)
        // Check the compatibility of the preset to export the video to the output file type.
        guard await AVAssetExportSession.compatibility(ofExportPreset: preset,
                                                       with: video,
                                                       outputFileType: outputFileType) else {
            print("The preset can't export the video to the output file type.")
            return
        }
        
        // Create and configure the export session.
        guard let exportSession = AVAssetExportSession(asset: video,
                                                       presetName: preset) else {
            print("Failed to create export session.")
            return
        }
        exportSession.outputFileType = outputFileType
        exportSession.outputURL = outputURL
        
        // Convert the video to the output file type and export it to the output URL.
        await exportSession.export()
    }
    
    func uploadVideo(filename: String) {
        guard let url = URL(string: "http://172.16.2.246:5000/upload-video") else { return }
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
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename).mp4\"\r\n".data(using: String.Encoding.utf8)!)
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
                print("success upload")
            }
            print("Another session!")
        }
        task.resume()
        
    }
}

struct FileFormat: Codable {
    var textFieldValue: String
}
