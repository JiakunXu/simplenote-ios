import XCTest

class NoteEditor {

    class func clearText() {
        app.textViews.element.clearAndEnterText(text: "")
    }

    class func clearAndEnterText(enteredValue: String) {
        app.textViews.element.clearAndEnterText(text: enteredValue)
    }

    class func getEditorText() -> String {
        return app.textViews.element.value as! String
    }

    class func setFocus() {
        app.textViews.firstMatch.tap()
    }
    
    class func undo() {
        app.textViews.element.tap(withNumberOfTaps: 2, numberOfTouches: 3)
        app.otherElements["UIUndoInteractiveHUD"].children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).tap()
    }

    class func swipeToPreview() {
        app.textViews.firstMatch.swipeLeft()
        sleep(1)
    }

    class func leaveEditor() {
        app.navigationBars[uidNavBar_AllNotes].buttons[uidButton_NoteEditor_AllNotes].tap()
    }

    class func toggleMarkdownState() {
        app.navigationBars[uidNavBar_AllNotes].buttons[uidButton_NoteEditor_Menu].tap()
        app.tables.staticTexts[uidText_NoteEditor_Options_Markdown].tap()
        app.navigationBars[uidNavBar_NoteEditor_Options].buttons[uidButton_Done].tap()
    }

    class func insertChecklist() {
        app.navigationBars[uidNavBar_AllNotes].buttons[uidButton_NoteEditor_Checklist].tap()
    }
    
    class func markdownEnable() {
        swipeToPreview()

        if app.navigationBars[uidNavBar_NoteEditor_Preview].exists {
            Preview.leavePreviewViaBackButton()
        } else {
            toggleMarkdownState()
        }
    }

    class func markdownDisable() {
        swipeToPreview()

        guard app.navigationBars[uidNavBar_NoteEditor_Preview].exists else { return }
        
        Preview.leavePreviewViaBackButton()
        toggleMarkdownState()
    }

    class func pressLink(containerText: String, linkifiedText: String) {
        // Should be replaced with proper way to determine if page is loaded
        app.textViews[containerText].links[linkifiedText].press(forDuration: 1.3)
        sleep(4)
    }
    
    class func getAllTextViews() -> XCUIElementQuery {
        // If we are in Note Editor, and there's zero TextViews, we should try setting focus first
        if app.descendants(matching: .textView).count < 1 {
            NoteEditor.setFocus()
        }
        
        return app.descendants(matching: .textView)
    }
    
    class func getCheckboxesForTextCount(text: String) -> Int {
        let matchesCount = NoteEditor.getTextViewsWithExactLabelCount(label: text)
        print(">>> ^ Found " + String(matchesCount) + " Checkboxe(s) for '" + text + "'")
        return matchesCount
    }
    
    class func getTextViewsWithExactValueCount(value: String) -> Int {
        let textViews = getAllTextViews()
        var matchesCounter = 0

        for index in 0...textViews.count - 1
        {
            let currentValue = textViews.element(boundBy: index).value as! String
            let currentValueStripped = currentValue.replacingOccurrences(of: "\u{fffc}", with: "")

            if currentValueStripped == value {
                matchesCounter += 1
            }
        }
        
        print(">>> Found " + String(matchesCounter) + " TextView(s) with '" + value + "' value")
        return matchesCounter
    }
    
    class func getTextViewsWithExactLabelCount(label: String) -> Int {
        let _ = getAllTextViews()// To initialize the editor
        let predicate = NSPredicate(format: "label == '" + label + "'")
        let matchingTextViews = app.textViews.matching(predicate)
        let matchesCount = matchingTextViews.count
        print(">>> Found " + String(matchesCount) + " TextView(s) with '" + label + "' label")
        return matchesCount
    }
    
}

class NoteEditorAssert {

    class func linkifiedURL(containerText: String, linkifiedText: String) {
        let linkContainer = app.textViews[containerText]
        XCTAssertTrue(linkContainer.exists, "\"" + containerText + linkContainerNotFoundInEditor)
        XCTAssertTrue(linkContainer.links[linkifiedText].exists, "\"" + linkifiedText + linkNotFoundInEditor)
    }

    class func editorShown() {
        let allNotesNavBar = app.navigationBars[uidNavBar_AllNotes]

        XCTAssertTrue(allNotesNavBar.waitForExistence(timeout: minLoadTimeout), uidNavBar_AllNotes + navBarNotFound)
        XCTAssertTrue(allNotesNavBar.buttons[uidButton_NoteEditor_AllNotes].waitForExistence(timeout: minLoadTimeout), uidButton_NoteEditor_AllNotes + buttonNotFound)
        XCTAssertTrue(allNotesNavBar.buttons[uidButton_NoteEditor_Checklist].waitForExistence(timeout: minLoadTimeout), uidButton_NoteEditor_Checklist + buttonNotFound)
        XCTAssertTrue(allNotesNavBar.buttons[uidButton_NoteEditor_Information].waitForExistence(timeout: minLoadTimeout), uidButton_NoteEditor_Information + buttonNotFound)
        XCTAssertTrue(allNotesNavBar.buttons[uidButton_NoteEditor_Menu].waitForExistence(timeout: minLoadTimeout), uidButton_NoteEditor_Menu + buttonNotFound)
    }

    class func textViewWithExactValueShownOnce(value: String) {
        let matchesCount = NoteEditor.getTextViewsWithExactValueCount(value: value)
        XCTAssertEqual(1, matchesCount)
    }
        
    class func textViewWithExactLabelShownOnce(label: String) {
        let matchesCount = NoteEditor.getTextViewsWithExactLabelCount(label: label)
        XCTAssertEqual(1, matchesCount)
    }
    
    class func textViewWithExactLabelsShownOnce(labelsArray: Array<String>) {
        for label in labelsArray {
            NoteEditorAssert.textViewWithExactLabelShownOnce(label: label)
        }
    }
    
    class func checkboxForTextShownOnce(text: String) {
        let matchesCount = NoteEditor.getCheckboxesForTextCount(text: text)
        XCTAssertEqual(1, matchesCount)
    }
    
    class func checkboxForTextNotShown(text: String) {
        let matchesCount = NoteEditor.getCheckboxesForTextCount(text: text)
        XCTAssertEqual(0, matchesCount)
    }
}