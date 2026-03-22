import SwiftUI
import UniformTypeIdentifiers
import Combine

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
            
            // VStack list of ISOs to process.
            VStack(alignment: .leading, spacing: 6) {
                Text("ISOs").font(.headline)
                List {
                    ForEach(isoItems.indices, id: \.self) { idx in
                        let item = isoItems[idx];
                        HStack {
                            ISORowView(
                                item: $isoItems[idx],
                                currentIndex:   $currentIndex,
                                isRunning:      $isRunning,
                            ).id("\(item.id)-\(isRunning)-\(currentIndex)");
                            Spacer()
                            Button {
                                remove(item)
                            } label: {
                                Image(systemName: "xmark.square.fill")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                            .help("Remove Item")
                        }
                    }
                }
                .frame(minHeight: 200)
                .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                    handleDrop(providers)
                }
                .disabled(isRunning)
            }.padding()

            // Progress indicator for a specific item running.
            ProgressView(
                value: Double(curProgressValue),
                total: Double(max(curTotalProgressValue, 1))
            )
            .padding(.horizontal)
            .disabled(!isRunning)

            // Scrolling view for logging text coming in from iso2god.
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(logText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                        
                        // Hack
                        Color.clear.frame(height: 1).id("BOTTOM")
                    }
                }
                .background(Color.black.opacity(0.05))
                .frame(height: 200)
                .onChange(of: logText) { _ in
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo("BOTTOM", anchor: .bottom)
                    }
                }
            }

            // HStack for selecting or opening the output directory.
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
            
            // HStack for primary controls: Add ISOs, Clear, Start.
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

    // removes an ISOItem from the last matching the given item's ID.
    func remove(_ item: ISOItem) {
        isoItems.removeAll { $0.id == item.id }
    }

    // open the file picker for ISOs.
    func openPicker() {
        
        guard
            let IsoType =
                UTType(filenameExtension: "iso", conformingTo: .diskImage)
        else { assert(false) }
        
        let panel = NSOpenPanel();
        panel.allowedContentTypes = [ IsoType ];
        panel.allowsMultipleSelection = true;

        if panel.runModal() == .OK {
            for url in panel.urls {
                _ = addIsoToList(inIsoUrl: url);
            }
        }
    }
    
    // open folder picker for output directory.
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
    
    // open the output folder in Finder/other
    func openOutputFolder() {
        NSWorkspace.shared.open(outputDirectory);
    }

    // drop handler so the app can accept dropped ISOs
    func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        // providers are just fancy names for "stuff"
        // in this case we're trying to grab it as a file URL
        for provider in providers {
            // for a provider, try to load an item of type "UTType.fileURL". Aka, a file.
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                guard
                    let data = item as? Data,
                    let url = URL(dataRepresentation: data, relativeTo: nil)
                else { return }

                DispatchQueue.main.async {
                    _ = addIsoToList(inIsoUrl: url);
                }
            }
        }

        return true
    }
    
    func addIsoToList(inIsoUrl: URL) -> Bool {
        let existing = isoItems.first(where: { a in
            return a.url == inIsoUrl;
        });
        
        if existing != nil {
            return false;
        }
        
        isoItems.append(ISOItem(url: inIsoUrl));
        return true;
    }

    // start button press - starts processing the list of ISOs
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
    
    // parses new logs coming in for process updates.
    func parsePartLog(line: String) -> (Int, Int) {
        var current = -1;
        var total = -1;
        
        // iso2god-rs is not translated so this should be fine.
        if line.contains("writing part files:") {
            let numbers = line.components(separatedBy: ":")[1]
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .split(separator: "/")

            if numbers.count == 2 {
                current = Int(numbers[0]) ?? 0
                total = Int(numbers[1]) ?? 1
            }
        }
        
        if line.contains("Error") {
            isoItems[currentIndex].isErrored = true;
            isoItems[currentIndex].isComplete = false;
        }
        
        return (current, total);
    }

    // runs the next item to be processed.
    func runNext() {
        guard currentIndex < isoItems.count else {
            logText.append("\nAll conversions finished.\n");
            isRunning = false;
            currentIndex = 0;
            SharedAppState.shared.isRunning = false;
            return;
        }

        let item = isoItems[currentIndex]

        logText.append("\n===== Converting \(item.url.lastPathComponent) =====\n")

        ISOProcessor.runISO(
            url: item.url,
            outputDir: outputDirectory,
            logHandler: { output in
                let Outputs = parsePartLog(line: output);
                if(Outputs.0 != -1 && Outputs.1 != -1) {
                    curTotalProgressValue = Outputs.1;
                    curProgressValue = Outputs.0;
                }
                
                logText.append(output)
            },
            completion: {
                isoItems[currentIndex].isComplete = true &&
                    !isoItems[currentIndex].isErrored;
                currentIndex += 1
                runNext()
            }
        )
    }
}

#Preview {
    ContentView()
}
