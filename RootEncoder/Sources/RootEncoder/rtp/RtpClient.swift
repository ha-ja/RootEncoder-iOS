import Foundation

public class RtpClient {

    private let sender: RtpSender
    private let connectChecker: ConnectChecker
    private var streaming = false

    public init(connectChecker: ConnectChecker) {
        self.connectChecker = connectChecker
        self.sender = RtpSender(callback: connectChecker)
        
        self.setOnlyVideo(onlyVideo: true)
    }

    public func setOnlyVideo(onlyVideo: Bool) {
        RtpConstants.trackVideo = 0
        RtpConstants.trackAudio = 1
    }

    public func setOnlyAudio(onlyAudio: Bool) {
        // Ignored in video-only setup
    }

    public func setAudioInfo(sampleRate: Int, isStereo: Bool) {
        // Ignored in video-only setup
    }

    public func setVideoInfo(sps: Array<UInt8>, pps: Array<UInt8>, vps: Array<UInt8>?) {
        sender.setVideoInfo(
            sps: sps,
            pps: pps,
            vps: vps
        )
    }

    public func connect(host: String, port: Int, localRtpPort: Int = 50020, enableRtcp: Bool = false) {
        sender.setDestination(
            host: host,
            port: port,
            localRtpPort: localRtpPort,
            enableRtcp: enableRtcp
        )
        sender.start()
        streaming = true
        connectChecker.onConnectionSuccess()
    }

    public func disconnect() {
        if streaming {
            sender.stop()
            streaming = false
            connectChecker.onDisconnect()
        }
    }

    public func isStreaming() -> Bool { streaming }

    public func sendVideo(buffer: Array<UInt8>, ts: UInt64) {
        sender.sendMediaFrame(
            mediaFrame: MediaFrame(
                data: buffer,
                info: MediaFrame.Info(
                    offset: 0,
                    size: buffer.count,
                    timestamp: ts
                ),
                type: MediaFrame.MediaType.VIDEO
            )
        )
    }
}


