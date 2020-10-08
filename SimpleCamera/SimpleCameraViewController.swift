//
//  SimpleCameraViewController.swift
//  SimpleCamera
//
//  Created by 能登 要 on 2020/10/08.
//

import UIKit
import AVFoundation

class SimpleCameraViewController: UIViewController {
    @IBOutlet weak var previewPlaceholderView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var modeLabel: UILabel!
    
    let session = AVCaptureSession()
#if QRCODE_READER
    let metadataOutput = AVCaptureMetadataOutput()
#else
    let output = AVCapturePhotoOutput()
#endif
    let settings = AVCapturePhotoSettings()
    var previewLayer: AVCaptureVideoPreviewLayer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

#if QRCODE_READER
        setupReaderFeature()
#else
        setupCamFeature()
#endif
    }
    
#if QRCODE_READER
    private func setupReaderFeature() {
        modeLabel.text = "QRCode Reader"
        captureButton.isHidden = true
        
        guard let captureDevice = AVCaptureDevice.default(for: .video), let input = try? AVCaptureDeviceInput(device: captureDevice) , session.canAddInput(input), session.canAddOutput(metadataOutput) else {
            return
        }
        session.addInput(input)
        session.addOutput(metadataOutput)
        session.startRunning()

        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        if let previewLayer = previewLayer {
            previewLayer.frame = previewPlaceholderView.bounds
            previewLayer.videoGravity = .resizeAspectFill
            previewPlaceholderView.layer.addSublayer(previewLayer)
        }
        previewPlaceholderView.clipsToBounds = true
    }
#else
    private func setupCamFeature() {
        modeLabel.text = "Camera"

        guard let captureDevice = AVCaptureDevice.default(for: .video), let input = try? AVCaptureDeviceInput(device: captureDevice), session.canAddInput(input), session.canAddOutput(output) else {
            return
        }
        session.addInput(input)
        session.addOutput(output)
        session.startRunning()

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        if let previewLayer = previewLayer {
            previewLayer.frame = previewPlaceholderView.bounds
            previewLayer.videoGravity = .resizeAspectFill
            previewPlaceholderView.layer.addSublayer(previewLayer)
        }
        previewPlaceholderView.clipsToBounds = true
    }
    @IBAction func onCapture(_ sender: Any) {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
#endif
}

#if QRCODE_READER
extension SimpleCameraViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !metadataObjects.isEmpty, let metadataObject = metadataObjects.first, let qr = metadataObject as? AVMetadataMachineReadableCodeObject else {
            return
        }
        print("qr=\(qr.stringValue)")
    }
}
#else
extension SimpleCameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            return
        }
        print("width=\(image.size.width)")
        print("height=\(image.size.height)")
    }
}
#endif
