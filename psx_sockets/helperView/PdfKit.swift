//
//  PdfKit.swift
//  psx_sockets
//
//  Created by sarim khan on 04/02/2026.
//

import Foundation
import SwiftUI
import PDFKit

struct PdfKit: UIViewRepresentable{
    
    let url: URL
    
    
    func makeUIView(context: Context) -> some UIView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        
        do {
            // Try to load PDF with error handling
            let document = try PDFDocument(url: url)
            pdfView.document = document
            
            if document == nil || document!.pageCount == 0 {
                print( "PDF could not be loaded")
            }
        } catch {
            print("Failed to load PDF: \(error.localizedDescription)")
        }
        
        
        return pdfView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    
}
