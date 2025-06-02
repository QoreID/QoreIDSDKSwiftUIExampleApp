import SwiftUI
import QoreIDSDK


struct ContentView: View {
    @State private var showLauncher = false

    var body: some View {
        Button("Launch QoreID") {
            showLauncher = true
        }
        .fullScreenCover(isPresented: $showLauncher) {
            QoreIDLauncherView {
                // This will be called when SDK is done or cancelled
                showLauncher = false
            }
        }
    }
}


struct QoreIDLauncherView: UIViewControllerRepresentable {
    var onDismiss: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let hostVC = UIViewController()
        let nav = UINavigationController(rootViewController: hostVC)

        DispatchQueue.main.async {
            launchQoreID(from: hostVC)
        }

        return nav
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private func launchQoreID(from vc: UIViewController) {
        let applicant = ApplicantData(firstname: "Jane", lastname:"Doe", phone: "+2348078361234")
        let clientId = ""
        let customerref = "ref-hhdaxxc-ssid"
        let productcode = ""

        let param = QoreIDParam()
            .clientId(clientId: clientId)
            .customerReference(customerref)
            .collection(productcode)
            .inputData(InputData(applicant: applicant))
            .build()

        QoreIdSdk.shared.launch(param: param, vc: vc) { result in
            handleResult(result)
        }
    }

    private func handleResult(_ result: QoreIDResult?) {
        if let error = result as? ErrorResult {
            print("Error: \(error.message)")
            onDismiss()
        } else if let success = result as? SuccessResult {
            print("Success: \(success.message ?? "")")
            onDismiss()
        } else if let pending = result as? PendingResult {
            print("Pending: \(pending.message ?? "")")
            onDismiss()
        }
    }
}
