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
            //Mark Camera view
            CameraView()
                .environmentObject(cameraModel)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.top, 10)
                .padding(.bottom, 30)
            
            VStack {
                TextField("Save as filename", text: $cameraModel.fileFormat.textFieldValue)
                Button("Submit") {
                    cameraModel.uploadVideo(filename: cameraModel.fileFormat.textFieldValue)
                    cameraModel.fileFormat.textFieldValue = ""
                    cameraModel.recordDulation = 0.0
                    cameraModel.previewURL = URL(string: "")
                }
            }
            .frame(alignment: .bottomLeading)
            .background(.gray)
//            Mark Camera control
            ZStack{
                Button{
                    if cameraModel.isRecording{
                        cameraModel.stopRecording()
                    }
                    else{
                        cameraModel.startRecording()
                    }
                } label: {
                    Image("Reels")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.black)
                        .opacity(cameraModel.isRecording ? 0 : 1)
                        .padding(12)
                        .frame(width: 60, height: 60)
                        .background{
                            Circle()
                                .stroke(cameraModel.isRecording ? .clear : .black)
                        }
                        .padding(6)
                        .background{
                            Circle()
                                .fill(cameraModel.isRecording ? .red : .white)
                        }
                }
                
//                //Export button
//                Button{
//                    cameraModel.uploadVideo()
//                }label: {
//                    Text("Export")
//                }
//                .padding()
//                .frame(width: 30, height: 30, alignment: .bottomLeading)
//                .background(.red)
               
                //Preview Button
                Button{
                    cameraModel.showPreview.toggle()
                }label: {
                    Label {
                        Image(systemName: "chevron.right")
                            .font(.callout)
                    } icon: {
                        Text("Preview")
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal,20)
                    .padding(.vertical, 8)
                    .background{
                        Capsule()
                            .fill(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 10)
            .padding(.bottom, 30)
            
            
        }
        .overlay(content: {
            if let url = cameraModel.previewURL, cameraModel.showPreview{
                FinalPreview(url: url, showPreview: $cameraModel.showPreview)
                    .transition(.move(edge: .trailing))
            }
        })
        .animation(.easeInOut, value: cameraModel.showPreview)
        .preferredColorScheme(.dark)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
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
