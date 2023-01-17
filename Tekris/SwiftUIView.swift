//
//  SwiftUIView.swift
//  Tekris
//
//  Created by Teck Tea on 12/01/2023.
//

import SwiftUI


struct SwiftUIView: View {
    @State private var varRed: Double = 0
    @State private var varGreen: Double = 0
    @State private var varBlue: Double = 0
    var body: some View {
        ZStack {
            
            LinearGradient(gradient: Gradient(colors: [ Color(red: (varRed)/255, green: (255-varRed)/255, blue: (255-varRed)/255), Color(red: (255-varRed)/255, green: (255-varRed)/255, blue: (varRed)/255), Color(red: (varRed)/255, green: (255-varRed)/255, blue: (varRed)/255)]), startPoint: .bottomTrailing, endPoint: .topLeading)
                .foregroundColor(.white)
                //.ignoresSafeArea()
                .opacity(1)


                HStack {
                    VStack {
                        Spacer()
                        Text("Red : \(Int(varRed))")
                        HStack{
                            Text("0")
                            Slider(value: $varRed, in: 0...255)
                            Text("255")
                        }
                    }
                    .padding(.bottom)
//                    VStack {
//                        Spacer()
//                        Text("Green : \(Int(varGreen))")
//                        HStack{
//                            Text("0")
//                            Slider(value: $varGreen, in: 0...255)
//                            Text("255")
//                        }
//                    }
//                    .padding(.bottom)
//                    VStack {
//                        Spacer()
//                        Text("Blue : \(Int(varBlue))")
//                        HStack{
//                            Text("0")
//                            Slider(value: $varBlue, in: 0...255)
//                            Text("255")
//                        }
//                    }
//                    .padding(.bottom)
                }
                .padding(.horizontal)
        } .ignoresSafeArea()
    }
}


struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
