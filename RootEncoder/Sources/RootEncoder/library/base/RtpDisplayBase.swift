import AVFoundation
import Foundation

public class RtpDisplayBase {
  
  internal var videoEncoder: VideoEncoder!
  private(set) var endpoint: String = ""
  private var streaming = false
  private var onPreview = false
  private var fpsListener = FpsListener()
  private var callback: DisplayBaseCallback? = nil
  private(set) public var metalInterface: MetalInterface
  
  public init() {
    metalInterface = MetalStreamInterface()
    let callback = createRtpDisplayBaseCallbacks()
    self.callback = callback
    videoEncoder = VideoEncoder(callback: callback)
  }
  
  public func prepareVideo(width: Int, height: Int, fps: Int, bitrate: Int, iFrameInterval: Int, rotation: Int = 0) -> Bool {
    metalInterface.setEncoderSize(width: width, height: height)
    metalInterface.setForceFps(fps: fps)
    metalInterface.setOrientation(orientation: rotation)
    return videoEncoder.prepareVideo(width: width, height: height, fps: fps, bitrate: bitrate, iFrameInterval: iFrameInterval, rotation: rotation)
  }
  
  public func prepareVideo() -> Bool {
    let w = 1280
    let h = 720
    return prepareVideo(width: w, height: h, fps: 30, bitrate: 1200 * 1024, iFrameInterval: 2, rotation: 0)
  }
  
  public func setFpsListener(fpsCallback: FpsCallback) {
    fpsListener.setCallback(callback: fpsCallback)
  }
  
  private func startEncoders() {
    videoEncoder.start()
    metalInterface.setCallback(callback: callback)
  }
  
  private func stopEncoders() {
    metalInterface.setCallback(callback: nil)
    videoEncoder.stop()
  }
  
  func startStreamImp(endpoint: String) {}
  
  
  public func startStream(endpoint: String) {
    self.endpoint = endpoint
    if (!isStreaming()) {
      startEncoders()
    }
    onPreview = true
    streaming = true
    startStreamImp(endpoint: endpoint)
  }
  
  func stopStreamImp() {}
  
  public func stopStream() {
    if (isStreaming()) {
      stopEncoders()
    }
    stopStreamImp()
    endpoint = ""
    streaming = false
  }
  
  public func isStreaming() -> Bool {
    streaming
  }
  
  public func setVideoBitrateOnFly(bitrate: Int) {
    videoEncoder.setVideoBitrateOnFly(bitrate: bitrate)
  }
  
  public func setVideoCodec(codec: VideoCodec) {
    setVideoCodecImp(codec: codec)
    videoEncoder.setCodec(codec: codec)
  }
  
  func setVideoCodecImp(codec: VideoCodec) {}
  
  func onVideoInfoImp(sps: Array<UInt8>, pps: Array<UInt8>, vps: Array<UInt8>?) {}
  
  func getVideoDataImp(frame: Frame) {}
  
  public func getYUVData(from buffer: CMSampleBuffer) {
    videoEncoder.encodeFrame(buffer: buffer)
  }
  
  public func getVideoData(frame: Frame) {
    fpsListener.calculateFps()
    getVideoDataImp(frame: frame)
  }
  
  public func onVideoInfo(sps: Array<UInt8>, pps: Array<UInt8>, vps: Array<UInt8>?) {
    onVideoInfoImp(sps: sps, pps: pps, vps: vps)
  }
}

extension RtpDisplayBase {
  func createRtpDisplayBaseCallbacks() -> DisplayBaseCallback {
    class RtpDisplayBaseCallbackHandler: DisplayBaseCallback {
      
      func getPcmData(frame: PcmFrame) {
        // NOOP - No local recording and no audio
      }
      
      func getAudioData(frame: Frame) {
        // NOOP - No audio data necessary
      }
      
      private let displayBase: RtpDisplayBase
      
      init(displayBase: RtpDisplayBase) {
        self.displayBase = displayBase
      }
      
      public func getYUVData(from buffer: CMSampleBuffer) {
        displayBase.metalInterface.sendBuffer(buffer: buffer)
      }
      
      func getVideoData(pixelBuffer: CVPixelBuffer, pts: CMTime) {
        displayBase.videoEncoder.encodeFrame(pixelBuffer: pixelBuffer, pts: pts)
      }
      
      public func getVideoData(frame: Frame) {
        displayBase.fpsListener.calculateFps()
        displayBase.getVideoDataImp(frame: frame)
      }
      
      public func onVideoInfo(sps: Array<UInt8>, pps: Array<UInt8>, vps: Array<UInt8>?) {
        displayBase.onVideoInfoImp(sps: sps, pps: pps, vps: vps)
      }
    }
    return RtpDisplayBaseCallbackHandler(displayBase: self)
  }
}
