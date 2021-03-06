import UIKit

class MapViewController: UIViewController {
    
    // The background images for scenarios.
    let backgroundImages: [String?] = [
        nil,
        "class_room_background",
        nil,
        nil,
        nil,
        "home_background",
        "hospital_background",
        "library_background"
    ]
    
    // MARK: Properties
    var dataSource: DataSource = DatabaseAccessor.sharedInstance
    var selectedScenarioName = ""
    
    // MARK: Views
    @IBOutlet var scenarioButtons: Array<UIButton>!
    @IBOutlet var scenarioImages: Array<UIImageView>!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unlockScenarios()
    }
    
    func unlockScenarios() {
        
        // Check which scenarios are unlocked.
        for (index, button) in scenarioButtons.enumerated() {
            let scenarioID = button.tag
            
            // Query database, see if the scenario is unlocked.
            var currScenario: Scenario
            do {
                currScenario = try dataSource.getScenario(of: scenarioID)
            } catch _ {
                let alert = UIAlertController(title: "Warning", message: "Error loading scenarios, please and try again, if this error still occurs, try restarting the app.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            if !currScenario.unlocked {
                // Lock the building.
                button.isHidden = true
                scenarioImages[index].isHidden = true
            } else {
                // Unlock the building.
                button.isHidden = false
                scenarioImages[index].isHidden = false
            }
        }
    }
    
    // MARK: Actions
    @IBAction func scenarioSelected(_ sender: UIButton) {
        // Get the scenario.
        var selectedScenario: Scenario
        do {
            selectedScenario = try dataSource.getScenario(of: sender.tag)
        } catch _ {
            let alert = UIAlertController(title: "Warning", message: "Error loading scenarios, please and try again, if this error still occurs, try restarting the app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        // Configure the selected scenario name.
        selectedScenarioName = selectedScenario.name
        // If completed, go to completed view.
        if selectedScenario.completed {
            performSegue(withIdentifier: "toCompletedView", sender: sender)
        } else {
            // Go to the corresponding scenario
            performSegue(withIdentifier: "toScenarioView", sender: sender)
        }
    }
    
    // MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let senderButton = sender as? UIButton {
            let scenarioID = senderButton.tag
            
            if segue.identifier == "toScenarioView" {
                (segue.destination as? ScenarioViewController)?.scenarioID = scenarioID
                (segue.destination as? ScenarioViewController)?.scenarioName = selectedScenarioName
                (segue.destination as? ScenarioViewController)?.backgroundImage = UIImage(named: backgroundImages[scenarioID] ?? "")
            } else if segue.identifier == "toCompletedView" {
                (segue.destination as? CompletedViewController)?.scenarioID = scenarioID
                (segue.destination as? CompletedViewController)?.scenarioName = selectedScenarioName
                (segue.destination as? CompletedViewController)?.backgroundImage = UIImage(named: backgroundImages[scenarioID] ?? "")
            }
        }
    }
    
    @IBAction func unwindToMap(unwindSegue: UIStoryboardSegue) {
        unlockScenarios()
    }
}
