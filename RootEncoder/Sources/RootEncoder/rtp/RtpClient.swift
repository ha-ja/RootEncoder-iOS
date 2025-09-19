import Foundation

public class RtpClient {

    private let sender: RtpSender
    private let connectChecker: ConnectChecker
    private var streaming = false
    private var audioDisabled = true
    private var videoDisabled = false

    public init(connectChecker: ConnectChecker) {
        self.connectChecker = connectChecker
        self.sender = RtpSender(callback: connectChecker)
    }

    public func setOnlyVideo(onlyVideo: Bool) {
        videoDisabled = false
        audioDisabled = onlyVideo
    }

    public func setOnlyAudio(onlyAudio: Bool) {
        audioDisabled = false
        videoDisabled = onlyAudio
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
        if (!videoDisabled) {
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
}


