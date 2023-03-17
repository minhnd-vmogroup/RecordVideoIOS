//
//  StartScene.swift
//  SceneRecordApp
//
//  Created by Hoang Le on 13/03/2023.
//

import SwiftUI

struct ResultScene: View {
    var body: some View {
        GeometryReader{ proxy in
            let size = proxy.size
            VStack{
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.largeTitle)
                Text("BPM")
                Spacer()
                Button(action: {
                    
                }, label: {
                    Label("End", systemImage: "")
                        .foregroundColor(.blue)
                        .padding()
                        .cornerRadius(10)
                })
            }
            .frame(width: size.width, height: size.height)
        
        }
    }
}

