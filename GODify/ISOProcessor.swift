//
//  ISOProcessor.swift
//  GODify
//
//  Created by mike on 3/13/26.
//


import Foundation

/**
 Handles processing a single ISO
 */
class ISOProcessor {

    static func getBundlediso2godURL() -> URL? {
#if arch(arm64)
        let name = "iso2god-aarch64-macos"
#elseif arch(x86_64)
        let name = "iso2god-x86_64-macos"
#endif
        
        return Bundle.main.url(forResource: name, withExtension: nil);
    }
    
    /**
     Processes a single ISO, putting the converted Game On Demand into the specified output folder.
     */
    static func runISO(
        url: URL,
        outputDir: URL,
        logHandler: @escaping (String) -> Void,
        completion: @escaping () -> Void
    )
    {
        guard let iso2godPath = getBundlediso2godURL() else {
            fatalError("Unsupported architecture.")
        }

        // Setup process
        let process = Process()
        let pipe = Pipe()

        process.standardOutput = pipe
        process.standardError = pipe

        process.executableURL = iso2godPath
        process.arguments = [ url.path, outputDir.path ]

        // Setup stdout/stderr handle pipe.
        // WHAT THIS MEANS: When data is available to be read on the pipe,
        // we will take that data and pass it to the provided "logHandler".
        // This will then plop the contents into the log view.
        let handle = pipe.fileHandleForReading
        handle.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if data.count > 0 {
                if let str = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        logHandler(str)
                    }
                }
            }
        }

        // Setup termination handler for normal closing.
        process.terminationHandler = { _ in
            handle.readabilityHandler = nil
            DispatchQueue.main.async {
                completion()
            }
        }

        do {
            try process.run()
        } catch {
            logHandler("Failed to run iso2god: \(error)\n")
            completion()
        }
    }
}
