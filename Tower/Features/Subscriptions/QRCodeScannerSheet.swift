import SwiftUI
import VisionKit

struct QRCodeScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onScan: (String) -> Void

    var body: some View {
        TowerNavigation {
            Group {
                if #available(iOS 16.0, *) {
                    QRCodeScannerAvailabilityView { value in
                        onScan(value)
                        dismiss()
                    }
                    .ignoresSafeArea(edges: .bottom)
                } else {
                    QRCodeScannerUnavailableContent(detail: "请返回后粘贴二维码中的链接。")
                }
            }
            .navigationTitle("扫描二维码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}

struct QRCodeScannerPreview: View {
    let onScan: (String) -> Void

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                QRCodeScannerAvailabilityView(onScan: onScan)
            } else {
                QRCodeScannerUnavailableContent(detail: "当前系统不支持相机扫码，请切换到粘贴识别。")
            }
        }
        .frame(maxWidth: .infinity, minHeight: 250)
        .background(Color.black.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct QRCodeScannerUnavailableContent: View {
    let detail: String

    var body: some View {
        TowerUnavailableContentView(
            "无法使用相机扫码",
            systemImage: "camera.fill",
            description: Text(detail)
        )
    }
}

@available(iOS 16.0, *)
private struct QRCodeScannerAvailabilityView: View {
    let onScan: (String) -> Void

    var body: some View {
        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
            QRCodeScannerView(onScan: onScan)
        } else {
            QRCodeScannerUnavailableContent(detail: "请检查相机权限，或切换到粘贴识别。")
        }
    }
}

@available(iOS 16.0, *)
private struct QRCodeScannerView: UIViewControllerRepresentable {
    let onScan: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan)
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ scanner: DataScannerViewController, context: Context) {
        guard !scanner.isScanning else { return }
        try? scanner.startScanning()
    }

    static func dismantleUIViewController(_ scanner: DataScannerViewController, coordinator: Coordinator) {
        scanner.stopScanning()
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let onScan: (String) -> Void
        private var hasDeliveredValue = false

        init(onScan: @escaping (String) -> Void) {
            self.onScan = onScan
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didAdd addedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            guard !hasDeliveredValue else { return }
            guard case .barcode(let barcode) = addedItems.first,
                  let value = barcode.payloadStringValue,
                  !value.isEmpty else { return }
            hasDeliveredValue = true
            onScan(value)
        }
    }
}
