//
//  ContentView.swift
//  AbstractKeyboard
//
//  Created by Zixuan on 12/27/19.
//  Copyright © 2019 Zixuan. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var text: String = ""
    
    var body: some View {
        VStack {
            TextField("", text: $text)
                .background(Color.gray)
        }
    .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
