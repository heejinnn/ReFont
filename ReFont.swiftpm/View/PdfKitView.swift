//
//  PdfKitView.swift
//  ReFont
//
//  Created by 최희진 on 2/14/25.
//
import SwiftUI
import PDFKit

struct PdfKitView: UIViewRepresentable {
    let document: PDFDocument
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
}
