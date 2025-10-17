import Foundation

public class RtpDisplay: RtpDisplayBase {

    private var client: RtpClient!

    public init(connectChecker: ConnectChecker) {
        super.init()
        client = RtpClient(connectChecker: connectChecker)
    }

    public func getClient() -> RtpClient {
        return client
    }
    
    public func startStream(host: String, port: Int, enableRtcp: Bool = false) {
        super.startStream(endpoint: "rtp://\(host):\(port)")
        client.connect(
            host: host,
            port: port,
            enableRtcp: enableRtcp
        )
    }
    
  override public func stopStream() {
        client.disconnect()
    }
    
    override func setVideoCodecImp(codec: VideoCodec) {
        // H264 is relevant; packetizer is driven by SPS/PPS provided by the encoder
    }
    
    override func stopStreamImp() {
        client.disconnect()
    }

    override func startStreamImp(endpoint: String) {
        // Not used – there is no RTSP endpoint in RTP-only mode
    }
    
    override func getVideoDataImp(frame: Frame) {
        client.sendVideo(buffer: frame.buffer, ts: frame.timeStamp)
    }

    override func onVideoInfoImp(sps: Array<UInt8>, pps: Array<UInt8>, vps: Array<UInt8>?) {
        client.setVideoInfo(sps: sps, pps: pps, vps: vps)
        // Debug Hint: SDP output so that players like VLC can parse the stream without RTSP
        // Not inportant for stream data. Just log. Can be removed later.
        let spsB64 = Data(sps).base64EncodedString()
        let ppsB64 = Data(pps).base64EncodedString()
        let sdp = """
v=0
o=- 0 0 IN IP4 0.0.0.0
s=RootEncoder RTP H264
c=IN IP4 0.0.0.0
t=0 0
m=video 8554 RTP/AVP 96
a=rtpmap:96 H264/90000
a=fmtp:96 packetization-mode=1;sprop-parameter-sets=\(spsB64),\(ppsB64);
"""
        print("[RTP] Suggested SDP for VLC (adjust IP/port if needed):\n\(sdp)")
    }
}


