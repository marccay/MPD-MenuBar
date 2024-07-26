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
            // Now Playing Info
            VStack {
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
                networkManager.getCurrent()
            })
            
            // Media Keys
            HStack {
                Button {
                    networkManager.previousSong()
                } label: {
                    Label("Previous Song", systemImage: "backward.end.fill")
                        .labelStyle(.iconOnly)
                }
                
                // Dynamic Play/Pause depending on mpd state
                if networkManager.dataMap["state"] == "play" {
                    // pause button
                    Button {
                        networkManager.pauseSong()
                    } label: {
                        Label("Pause", systemImage: "pause")
                            .labelStyle(.iconOnly)
                    }
                } else {
                    // play button
                    Button {
                        networkManager.playSong()
                    } label: {
                        Label("Play/Pause Toggle", systemImage: "play")
                            .labelStyle(.iconOnly)
                    }
                }
                
                Button {
                    networkManager.stopSong()
                } label: {
                    Label("Stop", systemImage: "stop")
                        .labelStyle(.iconOnly)
                }
                
                Button {
                    networkManager.nextSong()
                } label: {
                    Label("Next Song", systemImage: "forward.end.fill")
                        .labelStyle(.iconOnly)
                }
                
            }
            .padding()
        }
    }
}

#Preview {
    AppMenu()
}
