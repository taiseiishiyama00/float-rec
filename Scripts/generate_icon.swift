#!/usr/bin/env swift
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let size = 1024
let outputPath = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "icon_1024.png"

guard let ctx = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
) else {
    fprint("Failed to create CGContext")
    exit(1)
}

let s = CGFloat(size)

// -- Background: dark rounded rect with gradient --
let bgRect = CGRect(x: 0, y: 0, width: s, height: s)
let cornerRadius = s * 0.22 // macOS icon corner radius
let bgPath = CGPath(roundedRect: bgRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

ctx.saveGState()
ctx.addPath(bgPath)
ctx.clip()

// Gradient: dark charcoal
let colors = [
    CGColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1.0),
    CGColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1.0),
] as CFArray
let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 1.0])!
ctx.drawLinearGradient(gradient, start: CGPoint(x: s/2, y: s), end: CGPoint(x: s/2, y: 0), options: [])
ctx.restoreGState()

// -- Outer ring (white, subtle) --
let center = CGPoint(x: s/2, y: s/2)
let outerRadius = s * 0.32
ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.25))
ctx.setLineWidth(s * 0.025)
ctx.addArc(center: center, radius: outerRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
ctx.strokePath()

// -- Red record circle --
let innerRadius = s * 0.22
ctx.saveGState()

// Glow
let glowColor = CGColor(red: 1.0, green: 0.15, blue: 0.15, alpha: 0.4)
ctx.setShadow(offset: .zero, blur: s * 0.08, color: glowColor)

// Red gradient for the circle
let redCircleRect = CGRect(
    x: center.x - innerRadius,
    y: center.y - innerRadius,
    width: innerRadius * 2,
    height: innerRadius * 2
)
ctx.addEllipse(in: redCircleRect)
ctx.clip()

let redColors = [
    CGColor(red: 1.0, green: 0.25, blue: 0.25, alpha: 1.0),
    CGColor(red: 0.85, green: 0.10, blue: 0.10, alpha: 1.0),
] as CFArray
let redGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: redColors, locations: [0.0, 1.0])!
ctx.drawLinearGradient(redGradient, start: CGPoint(x: center.x, y: center.y + innerRadius), end: CGPoint(x: center.x, y: center.y - innerRadius), options: [])
ctx.restoreGState()

// -- Highlight on the red circle (glossy) --
ctx.saveGState()
let highlightRect = CGRect(
    x: center.x - innerRadius * 0.6,
    y: center.y + innerRadius * 0.1,
    width: innerRadius * 1.2,
    height: innerRadius * 0.7
)
ctx.addEllipse(in: highlightRect)
ctx.clip()
let highlightColors = [
    CGColor(red: 1, green: 1, blue: 1, alpha: 0.25),
    CGColor(red: 1, green: 1, blue: 1, alpha: 0.0),
] as CFArray
let highlightGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: highlightColors, locations: [0.0, 1.0])!
ctx.drawLinearGradient(highlightGradient, start: CGPoint(x: center.x, y: center.y + innerRadius), end: CGPoint(x: center.x, y: center.y), options: [])
ctx.restoreGState()

// -- Small "F" letter bottom-right as branding --
// Skip text to keep it clean - the red dot on dark bg is distinctive enough.

// -- Write PNG --
guard let image = ctx.makeImage() else {
    fprint("Failed to create image")
    exit(1)
}

let url = URL(fileURLWithPath: outputPath)
guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    fprint("Failed to create image destination")
    exit(1)
}
CGImageDestinationAddImage(dest, image, nil)
guard CGImageDestinationFinalize(dest) else {
    fprint("Failed to write PNG")
    exit(1)
}

func fprint(_ msg: String) {
    FileHandle.standardError.write(Data((msg + "\n").utf8))
}
