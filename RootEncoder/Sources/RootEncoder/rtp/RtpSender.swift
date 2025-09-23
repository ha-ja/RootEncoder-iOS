import Foundation

public class RtpSender: BaseSender {

    private var videoPacketizer: RtspBasePacket?
    private var rtpSocket: BaseRtpSocket?
    private var senderReport: BaseSenderReport?

    public init(callback: ConnectChecker) {
        super.init(callback: callback, tag: "Rtp")
    }

    public func setDestination(
        host: String,
        port: Int,
        localRtpPort: Int = 50020,
        enableRtcp: Bool = false
    ) {
        rtpSocket = RtpUdpSocket(
            callback: callback,
            host: host,
            port: port,
            localPort: localRtpPort // UDP Constructor
        )
        
        if enableRtcp {
            // In a single-port setup RTCP can be disabled; optionally provide a dedicated RTCP port pair if needed
            senderReport = SenderReportUdp(
                callback: callback,
                host: host,
                videoPorts: [localRtpPort + 2, port + 1],
                audioPorts: [localRtpPort + 4, port + 3]
            )
        }
    }

    public override func setVideoInfo(sps: Array<UInt8>, pps: Array<UInt8>, vps: Array<UInt8>?) {
        videoPacketizer = RtspH264Packet(sps: sps, pps: pps)
    }

    public override func onRun() {
        let ssrcVideo = UInt64(Int.random(in: 0..<Int.max))
        
        videoPacketizer?.setSSRC(ssrc: ssrcVideo)
        
        while (self.running) {
            let mediaFrame = self.queue.dequeue()
            guard let mediaFrame = mediaFrame, mediaFrame.type == .VIDEO else { continue }
            videoPacketizer?.createAndSendPacket(mediaFrame: mediaFrame, callback: { rtpFrames in
                do {
                    var size = 0
                    for frame in rtpFrames {
                        try self.rtpSocket?.sendFrame(rtpFrame: frame)
                        let packetSize = frame.length
                        size += packetSize
                        self.videoFramesSent += 1
                        self.bitrateManager.calculateBitrate(size: Int64(packetSize * 8))
                        // RTCP sender report handling - only active when enableRtcp is true
                        if (try self.senderReport?.update(rtpFrame: frame) == true) {
                            self.bitrateManager.calculateBitrate(size: Int64(RtpConstants.REPORT_PACKET_LENGTH * 8))
                        }
                    }
                    self.rtpSocket?.flush()
                } catch let error {
                    self.callback.onConnectionFailed(reason: error.localizedDescription)
                    return
                }
            })
        }
    }

    public override func stopImp(clear: Bool = true) {
        senderReport?.close()
        videoPacketizer?.reset()
        rtpSocket?.close()
    }
}


