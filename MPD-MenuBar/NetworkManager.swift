//
//  NetworkManager.swift
//  MPD-MenuBar
//
//  Created by marc on 7/25/24.
//

import Foundation
import Network

class NetworkManager: ObservableObject {
    @Published var connectionStatus: String = "Disconnected"
    @Published var dataMap: [String:String] = [
        "Artist": "",
        "Title": "",
        "Album": "",
        "state": "",
        "random": "",
        "repeat": "",
        "consume": "",
        "single": ""
    ]

    private var connection: NWConnection?
    
    // Connect to TCP Server
    private func connectToServer() {
        let host = NWEndpoint.Host("127.0.0.1")
        let port = NWEndpoint.Port("6600")!

        connection = NWConnection(host: host, port: port, using: .tcp)
        connection?.stateUpdateHandler = { [weak self] newState in
            switch newState {
            case .ready:
                DispatchQueue.main.async {
                    self?.connectionStatus = "Connected"
                }
            case .failed(let error):
                DispatchQueue.main.async {
                    self?.connectionStatus = "Failed: \(error.localizedDescription)"
                }
                self?.connection?.cancel()
                self?.connection = nil
            case .waiting(let error):
                DispatchQueue.main.async {
                    self?.connectionStatus = "Waiting: \(error.localizedDescription)"
                }
            case .cancelled:
                DispatchQueue.main.async {
                    self?.connectionStatus = "Disconnected"
                }
                self?.connection = nil
            default:
                break
            }
        }

        connection?.start(queue: .global())
    }
    
    // Initialized Listener
    private func receiveData() {
        var temp: String = ""
        
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 1024) { [weak self] (data, context, isComplete, error) in
            if let data = data, !data.isEmpty {
                if let receivedString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        temp += receivedString
                        if receivedString.hasSuffix("OK\n") {
                            self?.stringToDictionary(data: temp)
                            // Test Point, Print to Terminal
                            print(temp)
                        }
                    }
                }
                self?.receiveData()
            } else if let error = error {
                DispatchQueue.main.async {
                    self?.connectionStatus = "Error: \(error.localizedDescription)"
                }
                self?.disconnectFromServer()
            }
        }
    }
    
    // Splits String Array to Dictionary (key: value) & saves to dataMap
    private func stringToDictionary(data: String) {
        let linesArray = data.components(separatedBy: "\n")
        for line in linesArray {
            let components = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            if components.count == 2 {
                let key = String(components[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                let value = String(components[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                if key == "Artist" || key == "Title" || key == "Album" || key == "state" || key == "random" || key == "repeat" || key == "consume" || key == "single" {
                    dataMap.updateValue(value, forKey: key)
                }
            }
        }
    }

    // Send command to MPD server. Note: must end in "\n".
    private func sendCommand(cmd: String) {
        let data = cmd.data(using: .utf8)
        connection?.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                print("failed to send command: \(error)")
            }
        }))
    }
    
    
    // Public functions available
    func connect() {
        connectToServer()
        receiveData()
        getCurrent()
        getStatus()
    }
    
    func getInfo() {
        if self.connectionStatus == "Connected" {
            getCurrent()
            getStatus()
        }
    }
    
    func getStatus() {
        sendCommand(cmd: "status\n")
    }
    
    func getCurrent() {
        sendCommand(cmd: "currentsong\n")
    }
    
    func nextSong() {
        sendCommand(cmd: "next\n")
        getInfo()
    }
    
    func previousSong() {
        sendCommand(cmd: "previous\n")
        getInfo()
    }
    
    func playSong() {
        sendCommand(cmd: "play\n")
        getInfo()
    }
    
    func stopSong() {
        sendCommand(cmd: "stop\n")
        getInfo()
    }
    
    func pauseSong() {
        sendCommand(cmd: "pause\n")
        getInfo()
    }
    
    func randomToggle() {
        if dataMap["random"] == "1" {
            sendCommand(cmd: "random 0\n")
        } else {
            sendCommand(cmd: "random 1\n")
        }
        getInfo()
    }
    
    func repeatToggle() {
        if dataMap["repeat"] == "1" {
            sendCommand(cmd: "repeat 0\n")
        } else {
            sendCommand(cmd: "repeat 1\n")
        }
        getInfo()
    }
    
    func singleToggle() {
        if dataMap["single"] == "1" {
            sendCommand(cmd: "single oneshot\n")
        } else if dataMap["single"] == "oneshot" {
            sendCommand(cmd: "single 0\n")
        } else {
            sendCommand(cmd: "single 1\n")
        }
        getInfo()
    }
    
    func consumeToggle() {
        if dataMap["consume"] == "1" {
            sendCommand(cmd: "consume 0\n")
        } else {
            sendCommand(cmd: "consume 1\n")
        }
        getInfo()
    }
    
    // mpd 0.24
    /*
    func consumeToggle() {
        if dataMap["consume"] == "1" {
            sendCommand(cmd: "consume oneshot\n")
        } else if dataMap["consume"] == "oneshot" {
            sendCommand(cmd: "consume 0\n")
        } else {
            sendCommand(cmd: "consume 1\n")
        }
        getInfo()
    }
    */
    
    func disconnectFromServer() {
        print("disconnected")
        connection?.cancel()
        connection = nil
        connectionStatus = "Disconnected"
    }
    
}
