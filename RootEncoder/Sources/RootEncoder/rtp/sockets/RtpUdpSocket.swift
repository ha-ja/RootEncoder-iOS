import Foundation

public class RtpUdpSocket: BaseRtpSocket, SocketCallback {

    private var socket: Socket
    private let connectChecker: ConnectChecker

    public init(callback: ConnectChecker, host: String, port: Int, localPort: Int = 50020) {
        self.connectChecker = callback
        socket = Socket(
            host: host,
            localPort: localPort,
            port: port,
            callback: nil
        )
        
        do {
            try socket.connect()
        } catch let error {
            callback.onConnectionFailed(reason: error.localizedDescription)
        }
        
        super.init()
        socket.setCallback(callback: self)
    }

    public override func close() {
        socket.disconnect()
    }

    public override func sendFrame(rtpFrame: RtpFrame) throws {
        try socket.write(buffer: rtpFrame.buffer)
        socket.flush()
    }

    public override func flush() {
        socket.flush()
    }

    public func onSocketError(error: String) {
        self.connectChecker.onConnectionFailed(reason: error)
    }
}


