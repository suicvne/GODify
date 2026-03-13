import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {

    @State private var isoItems: [ISOItem] = []
    @State private var logText: String = ""
    @State private var isRunning = false
    @State private var currentIndex = 0
    @State private var outputDirectory: URL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("GODified")
    
    @State private var curProgressValue = 0;
    @State private var curTotalProgressValue = 0;

    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("ISOs").font(.headline)
                List {
                    ForEach(isoItems) { item in
                        HStack {
                            Text(item.url.lastPathComponent)
                            Spacer()
                            Button("Remove") {
                                remove(item)
                            }
                        }
                    }
                }
                .frame(minHeight: 200)
                .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                    handleDrop(providers)
                }
                .disabled(isRunning)
            }.padding()

            ProgressView(
                value: Double(curProgressValue),
                total: Double(max(curTotalProgressValue, 1))
            )
            .padding(.horizontal)
            .disabled(!isRunning)

            ScrollViewReader { proxy in
                ScrollView {
                    Text(logText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                    
                    // Hack
                    Color.clear.frame(height: 1).id("BOTTOM")
                }
                .background(Color.black.opacity(0.05))
                .frame(height: 200)
                .onChange(of: logText) {
                    withAnimation {
                        proxy.scrollTo("BOTTOM", anchor: .bottom)
                    }
                }
            }

            HStack {

                Text("Output:")
                    .bold()

                Text(outputDirectory.path)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                Button("Change") {
                    chooseOutputFolder()
                }.disabled(isRunning)
                Button("Open Folder") {
                    openOutputFolder()
                }
            }
            .padding(.horizontal)
            
            HStack {

                Button("Add ISO(s)") {
                    openPicker()
                }.disabled(isRunning)

                Button("Clear") {
                    isoItems.removeAll()
                }.disabled(isoItems.isEmpty || isRunning)

                Spacer()

                Button("Start") {
                    startProcessing()
                }
                .disabled(isoItems.isEmpty || isRunning)
            }
            .padding()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(WindowAdapter())
    }

    func remove(_ item: ISOItem) {
        isoItems.removeAll { $0.id == item.id }
    }

    func openPicker() {

        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.diskImage]
        panel.allowsMultipleSelection = true

        if panel.runModal() == .OK {
            for url in panel.urls {
                isoItems.append(ISOItem(url: url))
            }
        }
    }
    
    func chooseOutputFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK {
            if let url = panel.url {
                outputDirectory = url
            }
        }
    }
    
    func openOutputFolder() {
        NSWorkspace.shared.open(outputDirectory);
    }

    func handleDrop(_ providers: [NSItemProvider]) -> Bool {

        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in

                guard
                    let data = item as? Data,
                    let url = URL(dataRepresentation: data, relativeTo: nil)
                else { return }

                DispatchQueue.main.async {
                    isoItems.append(ISOItem(url: url))
                }
            }
        }

        return true
    }

    func startProcessing() {
        // Set state
        isRunning = true
        currentIndex = 0
        logText = ""
        SharedAppState.shared.isRunning = true;
        
        // Validate directory exists
        try? FileManager.default.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )

        // Run the next iso.
        runNext()
    }
    
    func parsePartLog(line: String) -> (Int, Int) {
        var current = -1;
        var total = -1;
        
        if line.contains("writing part files:") {
            let numbers = line.components(separatedBy: ":")[1]
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .split(separator: "/")

            if numbers.count == 2 {
                current = Int(numbers[0]) ?? 0
                total = Int(numbers[1]) ?? 1
            }
        }
        
        return (current, total);
    }

    func runNext() {

        guard currentIndex < isoItems.count else {
            logText.append("\nAll conversions finished.\n")
            isRunning = false
            SharedAppState.shared.isRunning = false;
            return
        }

        let item = isoItems[currentIndex]

        logText.append("\n===== Converting \(item.url.lastPathComponent) =====\n")

        ISOProcessor.runISO(
            url: item.url,
            outputDir: outputDirectory,
            logHandler: { output in
                
                let Outputs = parsePartLog(line: output);
                if(Outputs.0 != -1 && Outputs.1 != -1) {
                    curProgressValue = Outputs.0;
                    curTotalProgressValue = Outputs.1;
                }
                
                logText.append(output)
            },
            completion: {
                currentIndex += 1
                runNext()
            }
        )
    }
}

#Preview {
    ContentView()
}
