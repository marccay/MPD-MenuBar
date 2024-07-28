//
//  AppMenu.swift
//  MPD-MenuBar
//
//  Created by marc on 7/25/24.
//

import SwiftUI

struct AppMenu: View {
    
    @StateObject private var networkManager = NetworkManager()
    @State var settings: Bool = false
    
    // Reloads mpd data on timer. Found onReceive in Now Playing Section.
    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        
        // Connect/Disconnect Button depending on connectionStatus
        if networkManager.connectionStatus == "Disconnected" {
            Button {
                networkManager.connect()
            } label: {
                Label("Connect", systemImage: "rectangle.connected.to.line.below")
            }
            .padding()
        } else {
            Button {
                networkManager.disconnectFromServer()
            } label: {
                Label("Disconnect", systemImage: "rectangle.connected.to.line.below")
            }
            .padding()
        }
        
        if networkManager.connectionStatus == "Connected" {
            // Tottle Controls
            HStack {
                // shuffle toggle
                if networkManager.dataMap["random"] == "1" {
                    Button("on", systemImage: "shuffle") {
                        networkManager.randomToggle()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("off", systemImage: "shuffle") {
                        networkManager.randomToggle()
                    }
                    .buttonStyle(.bordered)
                }
                
                // repeat toggle
                if networkManager.dataMap["repeat"] == "1" {
                    Button("on", systemImage: "repeat") {
                        networkManager.repeatToggle()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("off", systemImage: "repeat") {
                        networkManager.repeatToggle()
                    }
                    .buttonStyle(.bordered)
                }
                
                
                // single toggle
                if networkManager.dataMap["single"] == "1" {
                    Button("on", systemImage: "1.circle") {
                        networkManager.singleToggle()
                    }
                    .buttonStyle(.borderedProminent)
                } else if networkManager.dataMap["single"] == "oneshot" {
                    Button("oneshot", systemImage: "1.circle") {
                        networkManager.singleToggle()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("off", systemImage: "1.circle") {
                        networkManager.singleToggle()
                    }
                }
                
                // consume toggle
                
                if networkManager.dataMap["consume"] == "1" {
                    Button("on", systemImage: "circle.badge.minus") {
                        networkManager.consumeToggle()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("off", systemImage: "circle.badge.minus") {
                        networkManager.consumeToggle()
                    }
                }
                
                //** mpd 0.24
                /*
                if networkManager.dataMap["consume"] == "1" {
                    Button("on", systemImage: "circle.badge.minus") {
                        networkManager.consumeToggle()
                    }
                    .buttonStyle(.borderedProminent)
                } else if networkManager.dataMap["consume"] == "oneshot" {
                    Button("oneshot", systemImage: "circle.badge.minus") {
                        networkManager.consumeToggle()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("off", systemImage: "circle.badge.minus") {
                        networkManager.consumeToggle()
                    }
                }
                */
                
            }
            
            // Now Playing Info
            VStack {
                //Test
                //Text(networkManager.dataMap["random"] ?? "test")
                Text(networkManager.dataMap["Title"] ?? "")
                    .fontWeight(.medium)
                Text(networkManager.dataMap["Artist"] ?? "")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(networkManager.dataMap["Album"] ?? "")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(width: 300)
            .onReceive(timer, perform: { _ in
                networkManager.getInfo()
            })
            
            // Media Keys
            HStack {
                Button {
                    networkManager.previousSong()
                } label: {
                    Label("Previous Song", systemImage: "backward.end.fill")
                        .labelStyle(.iconOnly)
                        .imageScale(.large)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                // Dynamic Play/Pause depending on mpd state
                if networkManager.dataMap["state"] == "play" {
                    // pause button
                    Button {
                        networkManager.pauseSong()
                    } label: {
                        Label("Pause", systemImage: "pause")
                            .labelStyle(.iconOnly)
                            .imageScale(.large)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                } else {
                    // play button
                    Button {
                        networkManager.playSong()
                    } label: {
                        Label("Play/Pause Toggle", systemImage: "play.fill")
                            .labelStyle(.iconOnly)
                            .imageScale(.large)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                
                Button {
                    networkManager.stopSong()
                } label: {
                    Label("Stop", systemImage: "stop")
                        .labelStyle(.iconOnly)
                        .imageScale(.large)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Button {
                    networkManager.nextSong()
                } label: {
                    Label("Next Song", systemImage: "forward.end.fill")
                        .labelStyle(.iconOnly)
                        .imageScale(.large)
                }
                .buttonStyle(BorderlessButtonStyle())
                
            }
            .padding()
        }
    }
}

#Preview {
    AppMenu()
}
