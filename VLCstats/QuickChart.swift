/* ***************************************************************************
* QuickChart.swift
*
* Copyright © 2019 VLC authors and VideoLAN
*
* Authors: Edgar Fouillet <vlc # edgar.fouillet.eu>
*
* Refer to the COPYING file of the project for license.
*****************************************************************************/

import UIKit
import CoreGraphics

class QuickChartData {
    var label: String
    var color: UIColor = .blue
    var maximumValue: Int = 0
    var yVals: [CGFloat] = []
    var maxY: CGFloat {
        get {
            return yVals.max() ?? 0.0
        }
    }
    var points: EnumeratedSequence<[CGFloat]> {
        get {
            return yVals.enumerated()
        }
    }
    var lineWidth: CGFloat = 2.0

    init(label: String) {
        self.label = label
    }

    func addPoint(_ point: CGFloat) {
        yVals.append(point)
        while maximumValue > 0 && yVals.count > maximumValue {
            yVals.removeFirst()
        }
    }
}

class QuickLineChartView : UIView {
    var charts: [QuickChartData] = []

    func reload() {
        self.setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        if let context = UIGraphicsGetCurrentContext() {
            let width: CGFloat = self.frame.width
            let height: CGFloat = self.frame.height
            var maxY: CGFloat = 0.0
            for chart in charts {
                maxY = max(maxY, chart.maxY)
            }
            for chart in charts {
                if maxY > 0.0 {
                    for (i, point) in chart.points {
                        if i + 1 < chart.yVals.count {
                            let x1 = CGFloat(i) / CGFloat(chart.yVals.count) * width
                            let x2 = CGFloat(i + 1) / CGFloat(chart.yVals.count) * width
                            let y1 = height - (point / maxY) * height
                            let y2 = height - (chart.yVals[i + 1] / maxY) * height
                            context.setStrokeColor(chart.color.cgColor)
                            context.setLineWidth(chart.lineWidth)
                            context.move(to: CGPoint(x: x1, y: y1))
                            context.addLine(to: CGPoint(x: x2, y: y2))
                            context.strokePath()
                        }
                    }
                }
            }
            let maxStr = NSMutableAttributedString(string: "max: \(String(Int(maxY)))")

            maxStr.addAttribute(.backgroundColor, value: UIColor.black, range: NSRange(location: 0, length: maxStr.length))
            maxStr.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: maxStr.length))
            maxStr.addAttribute(.font, value: UIFont(name: "Courier New", size: 15.0) ?? UIFont(), range: NSRange(location: 0, length: maxStr.length))
            maxStr.draw(at: CGPoint(x: 0, y: 0))
        }
    }
}
