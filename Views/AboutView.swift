//
//  CreditsView.swift
//  FlakeMQ
//
//  Created by Lsong on 2/18/25.
//


import SwiftUI

struct CreditsView: View {
    private let dependencies = [
        DependencyInfo(name: "CocoaMQTT",
                      description: "",
                      url: "https://github.com/emqx/CocoaMQTT",
                      license: "MPL-2.0 License"),
        
    ]
    
    var body: some View {
        List {
            Section(header: Text("Third-Party Libraries")) {
                ForEach(dependencies) { dependency in
                    Link(destination: URL(string: dependency.url)!) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(dependency.name)
                                Text(dependency.license)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            Section(header: Text("Legal")) {
                Text("These libraries are included in accordance with their respective licenses. Full license texts are available in the detailed view for each library.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Acknowledgements")
        .listStyle(InsetGroupedListStyle())
    }
}

// 依赖项信息模型
struct DependencyInfo: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let url: String
    let license: String
}

// 预览
#Preview {
    NavigationView {
        CreditsView()
    }
}

struct AboutView: View {
    @EnvironmentObject var appManager: FlakeAppManager
    
    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "snowflake")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appManager.appName)
                            .font(.headline)
                        Text("Version \(appManager.appVersion)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Additional Info Section
            Section(header: Text("About")) {
                Link(destination: URL(string: "https://github.com/lsongdev/mqtt-ios")!) {
                    HStack {
                        Text("GitHub")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.blue)
                    }
                }
                NavigationLink(destination: CreditsView()) {
                    Text("Acknowledgements")
                }
            }
        }
        .navigationTitle("About")
        .listStyle(InsetGroupedListStyle())
    }
}
