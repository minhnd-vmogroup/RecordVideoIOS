//
//  Home.swift
//  SceneRecordApp
//
//  Created by Hoang Le on 28/02/2023.
//

import SwiftUI
import AVKit

struct Home: View {
    @StateObject var cameraModel = CameraViewModel()
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            VStack{
                CameraView()
                    .frame(height: UIScreen.main.bounds.height*3/4)
                    .environmentObject(cameraModel)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                    .background(.black)
                Text("\(cameraModel.logStatus)")
                    .background(.gray)
                Spacer()
                Rectangle()
                    .fill(cameraModel.showButton ? .black : Color(.systemBackground))
                    .frame(width: 250, height: 50)
                    .overlay(content: {
                        if cameraModel.showButton {
                            Button{
                                if cameraModel.isRecording && !cameraModel.isSending{
                                    cameraModel.resetRecording()
                                }
                                else if cameraModel.isSending && !cameraModel.isRecording{
                                    print("End click!")
                                }
                                else{
                                    cameraModel.startRecording()
                                }
                            } label: {
                                Label("\(cameraModel.buttonStatus)", systemImage: "play.fill")
                                    .foregroundColor(.blue)
                                    .padding()
                                    .cornerRadius(10)
                            }
                            .frame(width: 250, height: 50)
                            .background(.gray)
                        }
                        
                    })
                
                Spacer()
                //Preview Button
                Button{
                    cameraModel.showPreview.toggle()
                }label: {
                    Label {
//                        Image(systemName: "")
//                            .font(.callout)
                    } icon: {
//                        Text("Preview")
                    }
//                    .foregroundColor(.black)
//                    .padding(.horizontal,20)
//                    .padding(.vertical, 8)
//                    .background{
//                        Capsule()
//                            .fill(.white)
//                    }
                }
//                .frame(maxWidth: .infinity, alignment: .trailing)
//                .padding(.trailing)
            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                    if cameraModel.recordDulation <= cameraModel.maxDuration && cameraModel.isRecording {
                        cameraModel.logStatus = "Hold the phone for  \(Int(cameraModel.maxDuration - cameraModel.recordDulation)) s"
                    }
                    else if cameraModel.recordDulation >= cameraModel.maxDuration {
                        cameraModel.output.stopRecording()
//                        print("1: ",cameraModel.previewURL)
                        cameraModel.logStatus = "Sending data"
                        cameraModel.buttonStatus = "END"
                        cameraModel.isRecording = false
                        cameraModel.isSending = true
                        cameraModel.showButton = false
                        cameraModel.recordDulation = 0.0
//                        print("2: ",cameraModel.previewURL)
                    }
                    else if cameraModel.sendingDulation >= cameraModel.maxSending {
                        cameraModel.logStatus = "Analysis data"
                        cameraModel.isSending = false
                        cameraModel.isAnalysis = true
                        cameraModel.sendingDulation = 0.0
                        print("3: ",cameraModel.previewURL)
                        cameraModel.uploadVideo(filename: "minhnd")
//                        cameraModel.uploadMinio()
                    }
                    else if cameraModel.analysisDulation >= cameraModel.maxAnalysis {
                        cameraModel.analysisDulation = 0.0
                        cameraModel.isAnalysis = false
                        cameraModel.showPreview.toggle()
                    }
                }
            }
        }
        .overlay(content: {
            ZStack (alignment: .top){
                if let url = cameraModel.previewURL, cameraModel.showPreview {
                    ResultAnalysis(buttonStatus: $cameraModel.buttonStatus, logStatus: $cameraModel.logStatus, showButton: $cameraModel.showButton, showPreview: $cameraModel.showPreview)
                }
            }
        })
    }
}

struct FinalPreview : View{
    var url: URL
    @Binding var showPreview : Bool
    var body: some View{
        GeometryReader{ proxy in
            let size = proxy.size
            
            VideoPlayer(player: AVPlayer(url: url))
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            // mark back button
                .overlay(alignment: .topLeading){
                    Button{
                        showPreview.toggle()
                    }label: {
                        Label{
                            Text("Back")
                        }icon: {
                            Image(systemName: "chevron.left")
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.leading)
                    .padding(.top, 22)
                }
        }
    }
}

struct ResultAnalysis : View{
    @Binding var buttonStatus : String
    @Binding var logStatus : String
    @Binding var showButton : Bool
    @Binding var showPreview : Bool
    var body: some View{
        GeometryReader{ proxy in
            let size = proxy.size
            ZStack(alignment: .top){
                VStack {
                    Spacer()
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.red)
                        .padding(.bottom, 50)
                    Spacer()
                    Button("END") {
                        logStatus = "Ready for start!"
                        buttonStatus = "Start"
                        showButton.toggle()
                        showPreview.toggle()
                    }
                    .frame(width: 250, height: 50)
                    .background(.gray)
                    .padding(.bottom, 30)
                }
            }
            .frame(width: size.width, height: size.height)
            .background(.white)
        }
    }
}
