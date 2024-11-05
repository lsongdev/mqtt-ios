//
//  SettingsView.swift
//  FlakeMQ
//
//  Created by Lsong on 2/18/25.
//
import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
//                NavigationLink(destination: Text("General")) {
//                    Text("General")
//                }
                NavigationLink(destination: AboutView()) {
                    Text("About")
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
        }
    }
}
