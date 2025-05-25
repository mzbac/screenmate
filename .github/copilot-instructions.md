**Objective:** Generate clean, maintainable, and self-documenting Swift code for the ScreenMate macOS application. Adhere to Swift best practices and the specific instructions below.

**I. Commenting Policy: "Code Should Be Self-Documenting First"**

1.  **Avoid Explanatory Comments for Obvious Code:**
    *   **DO NOT** write comments that merely restate what the code clearly does.
        *   *Bad:* `// Increment count by one` followed by `count += 1`
        *   *Good:* (No comment needed if `count += 1` is clear in context).
    *   Focus on making variable names, function names, and code structure so clear that comments become redundant for explaining *what* the code is doing.

2.  **Use Comments for "Why," Not "What" (When Necessary):**
    *   If the *reason* behind a piece of code isn't immediately obvious (e.g., a workaround for a system bug, a complex business logic decision, a non-intuitive optimization), then a concise comment explaining the "why" is appropriate.
        *   *Example:* `// Workaround for macOS bug XYZ where direct UI update causes flickering.`

3.  **Documentation Comments (DocC Syntax):**
    *   **DO** use standard Swift documentation comments (`///` or `/** ... */`) for all public and internal APIs (classes, structs, enums, protocols, methods, properties).
    *   These comments should explain the purpose of the API, its parameters, return values, and any important usage notes.
    *   Focus on how to *use* the API, not its internal implementation details (unless critical for usage).
        *   *Example:*
            ```swift
            /// Performs OCR on the provided in-memory image using the currently loaded VLM.
            ///
            /// This function processes the image asynchronously and calls the completion
            /// handler on the main thread with the result.
            ///
            /// - Parameters:
            ///   - nsImage: The `NSImage` to process.
            ///   - customPrompt: The user-defined prompt to guide the VLM.
            ///   - completion: A closure called with the `Result` containing either the
            ///                 recognized text or a `ScreenMateEngineError`.
            @MainActor
            func processImage(onNSImage nsImage: NSImage, prompt: String, completion: @escaping (Result<String, ScreenMateEngineError>) -> Void) {
                // ... implementation ...
            }
            ```

4.  **TODOs and FIXMEs:**
    *   Use `// TODO:` for tasks that need to be completed.
    *   Use `// FIXME:` for known issues that need to be addressed.
    *   Include a brief explanation.
        *   *Example:* `// TODO: Add more robust error handling for network timeouts.`
        *   *Example:* `// FIXME: This calculation can be inaccurate under X condition.`

5.  **Header Comments/File Banners:**
    *   A standard file header comment is acceptable if it's part of the project template (e.g., filename, project name, copyright). Keep it concise.
        ```swift
        // ScreenMateEngine.swift
        // ScreenMate
        //
        // Created by [Your Name/LLM] on [Date].
        // Copyright © [Year] [Your Name/Company]. All rights reserved.
        //
        ```
    *   Avoid large, verbose comment blocks that don't add significant value.

6.  **No Commented-Out Code:**
    *   **DO NOT** leave blocks of commented-out code in the final submission. Use version control (Git) to manage old code. If code is temporarily disabled for testing, mark it with a clear `// TODO: Re-enable this after testing X` and remove it before finalizing.

**II. Swift Best Practices and Style Guide:**

1.  **Naming Conventions:**
    *   Use `UpperCamelCase` for types (classes, structs, enums, protocols).
    *   Use `lowerCamelCase` for functions, methods, properties, variables, and enum cases.
    *   Names should be descriptive and clear. Avoid overly terse abbreviations.

2.  **Type Inference:**
    *   Prefer type inference where the type is obvious from the context (e.g., `let name = "ScreenMate"` instead of `let name: String = "ScreenMate"`).
    *   Explicitly state types when it improves clarity or is necessary (e.g., for protocol conformance, complex expressions).

3.  **Immutability:**
    *   Use `let` for constants wherever possible. Use `var` only when the value needs to change.

4.  **Optional Handling:**
    *   Use `guard let` or `if let` for safely unwrapping optionals. Avoid force unwrapping (`!`) unless you are absolutely certain the optional will contain a value and a crash is the desired outcome if it doesn't (rarely the case).
    *   Use optional chaining (`?.`) and the nil-coalescing operator (`??`) where appropriate.

5.  **Error Handling:**
    *   Use Swift's `do-try-catch` mechanism for functions that can throw errors.
    *   Define custom `Error` enums for specific error conditions within components (e.g., `ScreenMateEngineError`). Provide `localizedDescription`.

6.  **Access Control:**
    *   Use `private`, `fileprivate`, `internal`, `public`, `open` appropriately to encapsulate implementation details and define clear APIs. Default to the most restrictive access level possible.

7.  **Code Formatting:**
    *   Follow standard Swift formatting (indentation, spacing, line breaks). Xcode's default formatting is a good baseline.
    *   Keep lines to a reasonable length (e.g., under 120 characters if possible).

8.  **SwiftUI Specifics:**
    *   Keep Views small and focused on a single responsibility.
    *   Use `@State`, `@StateObject`, `@ObservedObject`, `@EnvironmentObject`, `@Environment`, `@Binding` correctly for state management and data flow.
    *   Prefer `Image(systemName:)` for SF Symbols.

9.  **Asynchronous Code:**
    *   Use `async/await` for asynchronous operations.
    *   Dispatch UI updates to the main thread using `@MainActor` or `await MainActor.run { ... }`.
    *   Use `Task.detached` for computationally intensive background work that should not block the current actor or task.

10. **Dependency Management:**
    *   Clearly import only necessary modules.

**III. Task-Specific Instructions (Example):**

*   When implementing **Component C006 (`ScreenMateEngine.swift`)**:
    *   Ensure all public methods and properties have DocC comments.
    *   Internal helper functions should have clear names; only add explanatory comments if the logic is unusually complex or non-obvious.
    *   No comments merely explaining what a line of MLX API usage does if the API name itself is descriptive.
    *   A comment explaining *why* a particular `GenerateParameter` value was chosen for OCR might be acceptable if it's based on specific VLM tuning.

**IV. Review Process:**

*   Code generated by the LLM will be reviewed for adherence to these guidelines.
*   Emphasis will be placed on clarity, correctness, and the principle of self-documenting code over excessive commenting.

