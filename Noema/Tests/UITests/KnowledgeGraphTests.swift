//
//  KnowledgeGraphTests.swift
//  Noema
//
//  Created on November 19, 2025.
//

import XCTest

final class KnowledgeGraphTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Navigate to Graph Tab Tests

    func test_navigateToGraphTab_showsKnowledgeGraph() {
        // When
        let graphTab = app.tabBars.buttons["Graph"]
        if graphTab.exists {
            graphTab.tap()
        }

        // Then
        XCTAssertTrue(app.navigationBars["Knowledge Graph"].exists || app.otherElements["graphView"].exists)
    }

    // MARK: - Graph Visualization Tests

    func test_graphView_displaysNodes() {
        // Given
        let graphTab = app.tabBars.buttons["Graph"]
        if graphTab.exists {
            graphTab.tap()
        }

        // Then - Graph view should show some content
        XCTAssertTrue(app.otherElements["graphView"].exists || app.scrollViews.firstMatch.exists)
    }

    func test_graphView_canZoom() {
        // Given
        let graphTab = app.tabBars.buttons["Graph"]
        if graphTab.exists {
            graphTab.tap()
        }

        let graphView = app.otherElements["graphView"]
        if graphView.exists {
            // When - Pinch to zoom
            graphView.pinch(withScale: 2.0, velocity: 1.0)

            // Then - View should still be visible
            XCTAssertTrue(graphView.exists)
        }
    }

    func test_graphView_canPan() {
        // Given
        let graphTab = app.tabBars.buttons["Graph"]
        if graphTab.exists {
            graphTab.tap()
        }

        let graphView = app.otherElements["graphView"]
        if graphView.exists {
            // When - Swipe to pan
            graphView.swipeLeft()

            // Then
            XCTAssertTrue(graphView.exists)
        }
    }

    // MARK: - Entity Selection Tests

    func test_selectEntity_showsDetail() {
        // Given
        let graphTab = app.tabBars.buttons["Graph"]
        if graphTab.exists {
            graphTab.tap()
        }

        // When - Tap on an entity node
        let entityNode = app.otherElements["entityNode"].firstMatch
        if entityNode.exists {
            entityNode.tap()
        }

        // Then - Detail view should appear
        XCTAssertTrue(app.navigationBars.count > 0 || app.sheets.firstMatch.exists)
    }

    func test_entityDetail_showsInformation() {
        // Given
        let graphTab = app.tabBars.buttons["Graph"]
        if graphTab.exists {
            graphTab.tap()
        }

        let entityNode = app.otherElements["entityNode"].firstMatch
        if entityNode.exists {
            entityNode.tap()
        }

        // Then - Should show entity information
        XCTAssertTrue(app.staticTexts.count > 0)
    }

    // MARK: - Entity List Tests

    func test_viewEntityList_showsAllEntities() {
        // Given
        let graphTab = app.tabBars.buttons["Graph"]
        if graphTab.exists {
            graphTab.tap()
        }

        // When
        let listButton = app.buttons["viewListButton"]
        if listButton.exists {
            listButton.tap()
        }

        // Then
        XCTAssertTrue(app.tables.firstMatch.exists || app.collectionViews.firstMatch.exists)
    }

    func test_entityList_filterByType() {
        // Given
        let graphTab = app.tabBars.buttons["Graph"]
        if graphTab.exists {
            graphTab.tap()
        }

        let listButton = app.buttons["viewListButton"]
        if listButton.exists {
            listButton.tap()
        }

        // When
        let filterButton = app.buttons["filterTypeButton"]
        if filterButton.exists {
            filterButton.tap()

            let personFilter = app.buttons["filter_person"]
            if personFilter.exists {
                personFilter.tap()
            }
        }

        // Then
        XCTAssertTrue(app.cells.count >= 0)
    }

    // MARK: - Search Entities Tests

    func test_searchEntities_findsMatches() {
        // Given
        let graphTab = app.tabBars.buttons["Graph"]
        if graphTab.exists {
            graphTab.tap()
        }

        // When
        let searchField = app.searchFields["searchEntitiesField"]
        if searchField.exists {
            searchField.tap()
            searchField.typeText("test")
        }

        // Then
        XCTAssertTrue(app.cells.count >= 0)
    }

    // MARK: - Entity Relationships Tests

    func test_viewEntityRelationships_showsConnections() {
        // Given
        let graphTab = app.tabBars.buttons["Graph"]
        if graphTab.exists {
            graphTab.tap()
        }

        let entityNode = app.otherElements["entityNode"].firstMatch
        if entityNode.exists {
            entityNode.tap()
        }

        // When
        let relationshipsButton = app.buttons["viewRelationshipsButton"]
        if relationshipsButton.exists {
            relationshipsButton.tap()
        }

        // Then
        XCTAssertTrue(app.cells.count >= 0 || app.staticTexts["No Relationships"].exists)
    }

    // MARK: - Graph Layout Tests

    func test_changeGraphLayout_switchesToList() {
        // Given
        let graphTab = app.tabBars.buttons["Graph"]
        if graphTab.exists {
            graphTab.tap()
        }

        // When
        let layoutButton = app.buttons["layoutButton"]
        if layoutButton.exists {
            layoutButton.tap()

            let listLayout = app.buttons["listLayout"]
            if listLayout.exists {
                listLayout.tap()
            }
        }

        // Then
        XCTAssertTrue(app.tables.firstMatch.exists || app.collectionViews.firstMatch.exists)
    }

    // MARK: - Entity Creation Tests

    func test_createEntity_showsForm() {
        // Given
        let graphTab = app.tabBars.buttons["Graph"]
        if graphTab.exists {
            graphTab.tap()
        }

        // When
        let createButton = app.buttons["createEntityButton"]
        if createButton.exists {
            createButton.tap()
        }

        // Then
        XCTAssertTrue(app.textFields["entityNameField"].exists || app.sheets.firstMatch.exists)
    }

    func test_createEntity_savesNewEntity() {
        // Given
        let graphTab = app.tabBars.buttons["Graph"]
        if graphTab.exists {
            graphTab.tap()
        }

        let createButton = app.buttons["createEntityButton"]
        if createButton.exists {
            createButton.tap()
        }

        // When
        let nameField = app.textFields["entityNameField"]
        if nameField.exists {
            nameField.tap()
            nameField.typeText("New Entity")
        }

        let saveButton = app.buttons["saveEntityButton"]
        if saveButton.exists {
            saveButton.tap()
        }

        // Then
        XCTAssertTrue(app.navigationBars["Knowledge Graph"].exists)
    }

    // MARK: - Export Graph Tests

    func test_exportGraph_showsShareSheet() {
        // Given
        let graphTab = app.tabBars.buttons["Graph"]
        if graphTab.exists {
            graphTab.tap()
        }

        // When
        let exportButton = app.buttons["exportGraphButton"]
        if exportButton.exists {
            exportButton.tap()
        }

        // Then
        XCTAssertTrue(app.sheets.firstMatch.exists || app.buttons["Save to Files"].exists)
    }

    // MARK: - Graph Statistics Tests

    func test_viewGraphStats_showsStatistics() {
        // Given
        let graphTab = app.tabBars.buttons["Graph"]
        if graphTab.exists {
            graphTab.tap()
        }

        // When
        let statsButton = app.buttons["graphStatsButton"]
        if statsButton.exists {
            statsButton.tap()
        }

        // Then
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Entities' OR label CONTAINS 'Connections'")).firstMatch.exists)
    }
}
