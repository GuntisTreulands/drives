//
//  ContentView.swift
//  WatchApp Watch App
//
//  Created by GT on 02/02/2023.
//  Copyright © 2023 . All rights reserved.
//

import SwiftUI



struct ContentView: View {
    
    @EnvironmentObject var appBgStatuss: MyWatchAppDelegate
    
    @State private var successOpen: Bool = false
    @State private var inProgress: Bool = false
    @State private var allowedToOpenTheGates: Bool = true
    @State private var buttonTitle: String = "Open the Gates"
    
    
    @State private var dateLastOpened: Date = Date.now.addingTimeInterval(-10)
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    
    var body: some View {
        if(inProgress) {
            VStack {
                ProgressView()
                    .scaleEffect(2, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                Text("Opening the\ngates..")
                    .onChange(of: appBgStatuss.appInBackground, perform: { newValue in
                        dateLastOpened = Date.now.addingTimeInterval(-10)
                    })
                    .onReceive(timer) { _ in
                        if(Date().timeIntervalSince1970 > dateLastOpened.timeIntervalSince1970) {
                            resetTheButton()
                        }
                    }
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                Text("")
                
            }
        } else {
            Button(action: {
                if(self.inProgress == false
                   && Date().timeIntervalSince1970 > dateLastOpened.timeIntervalSince1970) {
                    
                    self.inProgress = true
                    self.successOpen = false
                    
                    dateLastOpened = Date().addingTimeInterval(5)
                    
                    AppConnectionWorker.shared.requestOpenGates { success in
                        if(success) {
                            dateLastOpened = Date().addingTimeInterval(5)
                            buttonTitle = "Gates are open"
                        } else {
                            dateLastOpened = Date().addingTimeInterval(3)
                            buttonTitle = "Failed to open the gates"
                        }
                        self.successOpen = success
                        self.inProgress = false
                        self.allowedToOpenTheGates = false
                    }
                }
            } ) {
                Text("\(buttonTitle)")
                    .onChange(of: appBgStatuss.appInBackground, perform: { newValue in
                        dateLastOpened = Date.now.addingTimeInterval(-10)
                    })
                    .onReceive(timer) { _ in
                        if(Date().timeIntervalSince1970 > dateLastOpened.timeIntervalSince1970) {
                            resetTheButton()
                        }
                    }
                    .font(.title)
                    .frame(maxHeight: .infinity)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderless)
            .tint(allowedToOpenTheGates ? Color.white : successOpen ? Color.black : Color.white)
            .cornerRadius(4)
            .background(allowedToOpenTheGates ? Color.black : successOpen ? Color.green : Color.red)
        }
    }
    
    func resetTheButton() {
        if(self.inProgress == true) {
            dateLastOpened = Date().addingTimeInterval(3)
            buttonTitle = "Failed to open the gates"
            self.allowedToOpenTheGates = false
            self.successOpen = false
            self.inProgress = false
        } else {
            buttonTitle = "Open the Gates"
            self.allowedToOpenTheGates = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
