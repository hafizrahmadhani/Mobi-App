//
//  JointView.swift
//  Mobi
//
//  Created by Muhammad Al Hafiz Rahmadhani on 05/11/25.
//

import SwiftUI
import Vision

struct JointView: View {
    let joints: [VNHumanBodyPoseObservation.JointName : CGPoint]
    
    let videoAspectRatio: CGFloat
    
    private let jointRadius: CGFloat = 8
    private let lineColor = Color(red: 241/255, green: 94/255, blue: 50/255).opacity(0.8)
    private let jointColor = Color(red: 44/255, green: 127/255, blue: 207/255).opacity(0.8)
    private let lineWidth: CGFloat = 4
    
    private let bodySegments: [([VNHumanBodyPoseObservation.JointName])] = [
        [.leftShoulder, .leftElbow, .leftWrist],
        [.rightShoulder, .rightElbow, .rightWrist]
    ]
    
    var body: some View {
        Canvas { context, size in
            let viewWidth = size.width
            let viewHeight = size.height
            let viewAR = viewWidth / viewHeight
            
            var xform: (CGPoint) -> CGPoint
            
            if viewAR > videoAspectRatio {
                let scaledVideoHeight = viewWidth / videoAspectRatio
                let yCropPixels = (scaledVideoHeight - viewHeight) / 2.0
                
                xform = { visionPoint in
                    let x = (1.0 - visionPoint.x) * viewWidth
                    let y_full = (1.0 - visionPoint.y) * scaledVideoHeight
                    let y = y_full - yCropPixels
                    return CGPoint(x: x, y: y)
                }
                
            } else {
                let scaledVideoWidth = viewHeight * videoAspectRatio
                let xCropPixels = (scaledVideoWidth - viewWidth) / 2.0
                
                xform = { visionPoint in
                    let x_full = (1.0 - visionPoint.x) * scaledVideoWidth
                    let x = x_full - xCropPixels
                    let y = (1.0 - visionPoint.y) * viewHeight
                    return CGPoint(x: x, y: y)
                }
            }
            
            for segment in bodySegments {
                var path = Path()
                
                if let firstJointName = segment.first, let firstJoint = joints[firstJointName] {
                    let p = xform(firstJoint)
                    path.move(to: p)
                }
                
                for i in 1..<segment.count {
                    let jointName = segment[i]
                    if let joint = joints[jointName] {
                        let p = xform(joint)
                        path.addLine(to: p)
                    }
                }
                context.stroke(path, with: .color(lineColor), lineWidth: lineWidth)
            }
            
            for (_, jointPoint) in joints {
                let p = xform(jointPoint)
                let circle = Path(ellipseIn: CGRect(x: p.x - jointRadius, y: p.y - jointRadius, width: jointRadius * 2, height: jointRadius * 2))
                context.fill(circle, with: .color(jointColor))
            }
        }
    }
}


#Preview {
    let exampleJoints: [VNHumanBodyPoseObservation.JointName : CGPoint] = [
        .leftShoulder: CGPoint(x: 0.3, y: 0.3),
        .leftElbow: CGPoint(x: 0.2, y: 0.5),
        .leftWrist: CGPoint(x: 0.1, y: 0.7)
    ]
    
    return JointView(joints: exampleJoints, videoAspectRatio: 3.0/4.0)
        .frame(width: 300, height: 400)
        .background(Color.gray)
}
