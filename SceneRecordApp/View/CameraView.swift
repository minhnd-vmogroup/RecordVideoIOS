//
//  CameraModelView.swift
//  SceneRecordApp
//
//  Created by Hoang Le on 28/02/2023.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @EnvironmentObject var cameraModel : CameraViewModel;
    var body: some View {
        GeometryReader{ proxy in
            let size = proxy.size
            VStack{
                CameraPreview(size: size)
                    .environmentObject(cameraModel)
            }
            // Time duration
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.black.opacity(0.25))
                Rectangle()
                    .fill(Color(.red))
                    .frame(width: size.width * (cameraModel.recordDulation / cameraModel.maxDuration))
                
            }
            .frame(height: 12)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .onAppear(perform: cameraModel.CheckPermission)
        .alert(isPresented: $cameraModel.alert){
            Alert(title: Text("Please enable cameraModel access or microphone access!"))
        }
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()){ _ in
            if cameraModel.recordDulation <= cameraModel.maxDuration && cameraModel.isRecording{
                cameraModel.recordDulation += 0.01;
            }
            else if cameraModel.sendingDulation <= cameraModel.maxSending && cameraModel.isSending {
                cameraModel.sendingDulation += 0.01;
            }
            else if cameraModel.analysisDulation <= cameraModel.maxAnalysis && cameraModel.isAnalysis {
                cameraModel.analysisDulation += 0.01;
            }
        }
        
    }
}

//setting view for preview
struct CameraPreview: UIViewRepresentable {
    @EnvironmentObject var CameraModel: CameraViewModel
    var size : CGSize
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        CameraModel.preview = AVCaptureVideoPreviewLayer(session: CameraModel.session)
        CameraModel.preview.frame.size = size
        print("Preview UIViewRepresentable")
        
        //Your own property...
        CameraModel.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(CameraModel.preview)
        CameraModel.session.startRunning()
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
