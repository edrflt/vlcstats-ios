/* ***************************************************************************
* PlayerViewController.swift
*
* Copyright © 2019 VLC authors and VideoLAN
*
* Authors: Edgar Fouillet <vlc # edgar.fouillet.eu>
*
* Refer to the COPYING file of the project for license.
*****************************************************************************/

import UIKit

class PlayerViewController: UIViewController {
    @IBOutlet weak var movieView: UIView!
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var chartView: QuickLineChartView!
    @IBOutlet weak var demuxBitrateLabel: UILabel!
    @IBOutlet weak var inputBitrateLabel: UILabel!
    @IBOutlet weak var dataLabel: TopAlignedLabel!
    var mediaURL = ""
    var mediaPlayer = VLCMediaPlayer()

    static let maxCount = 50

    let demuxChart = QuickChartData(label: "demuxBitrate")
    let inputChart = QuickChartData(label: "inputBitrate")

    override func viewDidLoad() {
        super.viewDidLoad()
        chartView.backgroundColor = .clear
        demuxChart.maximumValue = 50
        demuxChart.color = .blue
        chartView.charts.append(demuxChart)
        inputChart.maximumValue = 50
        inputChart.color = .orange
        chartView.charts.append(inputChart)
        setupMediaPLayer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mediaPlayer.play()
    }

    func setupMediaPLayer() {
        mediaPlayer.delegate = self
        mediaPlayer.drawable = movieView
        mediaPlayer.media = VLCMedia(url: URL(string: mediaURL)!)
    }

    @IBAction func tapped(_ sender: Any) {
        if overlay.alpha == 1.0 {
            overlay.alpha = 0.1
        } else {
            overlay.alpha = 1.0
        }
    }

}

extension PlayerViewController: VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        if mediaPlayer.state == .stopped {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        demuxChart.addPoint(CGFloat(Int(mediaPlayer.media.demuxBitrate * 8000)))
        inputChart.addPoint(CGFloat(Int(mediaPlayer.media.inputBitrate * 8000)))
        chartView.reload()

        demuxBitrateLabel.text = labelText("demuxBitrate: ", mediaPlayer.media.demuxBitrate)
        inputBitrateLabel.text = labelText("inputBitrate: ", mediaPlayer.media.inputBitrate)
        dataLabel.text! = ""
        let tracksInfo = mediaPlayer.media.tracksInformation
        for (i, track) in tracksInfo.enumerated() {
            let trackInfo = track as! NSDictionary
            let type = trackInfo[VLCMediaTracksInformationType] as! String
            dataLabel.text! += "Stream \(i) (\(type))\n"
            let codec = trackInfo[VLCMediaTracksInformationCodec] as! UInt32
            dataLabel.text! += "    Codec: " + VLCMedia.codecName(forFourCC: codec, trackType: type) + "\n"
            if type == VLCMediaTracksInformationTypeVideo {
                let rate = trackInfo[VLCMediaTracksInformationFrameRate] as! UInt32
                let denominator = trackInfo[VLCMediaTracksInformationFrameRateDenominator] as! UInt32
                dataLabel.text! += "    Frame rate: \(rate/denominator) (\(rate)/\(denominator))\n"
                let width = trackInfo[VLCMediaTracksInformationVideoWidth] as! UInt32
                let height = trackInfo[VLCMediaTracksInformationVideoHeight] as! UInt32
                dataLabel.text! += "    Resolution: \(width)x\(height)\n"
            } else if type == VLCMediaTracksInformationTypeAudio {
                let rate = trackInfo[VLCMediaTracksInformationAudioRate] as! UInt32
                dataLabel.text! += "    Sample rate: \(rate)Hz\n"
            }
        }
        dataLabel.numberOfLines = 0
        dataLabel.sizeToFit()
    }

    func labelText(_ title: String, _ value: Float) -> String {
        return title + String(Int(value * 8000)) + "kb/s"
    }
}

@IBDesignable class TopAlignedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        if let stringText = text {
            let stringTextAsNSString = stringText as NSString
            let labelStringSize = stringTextAsNSString.boundingRect(with: CGSize(width: self.frame.width,height: CGFloat.greatestFiniteMagnitude),
                                                                            options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                            attributes: [NSAttributedString.Key.font: font!],
                                                                            context: nil).size
            super.drawText(in: CGRect(x:0,y: 0,width: self.frame.width, height:ceil(labelStringSize.height)))
        } else {
            super.drawText(in: rect)
        }
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
}

