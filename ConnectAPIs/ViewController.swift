
import UIKit
import Charts

struct FindLatLng: Decodable {
    let message: String?
    let cod: String?
    let count: Int?
    let list: [List]
}

struct List: Decodable {
    let id: Int?
    let name: String?
    let coord: coord
    let main: main
    let dt: Int?
    let wind: wind
    let sys: sys
    let clouds: clouds
    let weather: [weather]
}

struct coord: Decodable {
    let lat: Double?
    let lon: Double?
}

struct main: Decodable {
    let temp: Double?
    let pressure: Double?
    let humidity: Int?
    let temp_min: Double?
    let temp_max: Double?
}
struct weather: Decodable {
    let id: Int?
    let main: String?
    let description: String?
    let icon: String?
}
struct wind: Decodable {
    let speed: Double?
    let deg: Double?
}
struct clouds: Decodable {
    let all: Int?
}
struct sys: Decodable {
    let country: String?
}

class ViewController: UIViewController {
    var numberCity: Int = 10
    var temp = [Double]()
    var humid = [Double]()
    var name = [String]()
    var arrData = [FindLatLng]()
    var test = LineChartData()
    
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var inputNumber: UITextField!
    @IBAction func OKButton(_ sender: Any) {
        if inputNumber.text == "" {
            alert(checkCondition: 0)
        } else {
            self.checkNum(inputText: Int(inputNumber.text!) ?? 10)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let jsonUrlString = "https://api.openweathermap.org/data/2.5/find?lat=13.03&lon=101.49&cnt=\(numberCity)&APPID=50cd795c5105f9a886516993e7e6cacf"
        guard let url = URL(string: jsonUrlString) else {return}

        URLSession.shared.dataTask(with: url) { (data, responds,err) in
            guard let data = data else { return }
            self.temp = []
            self.name = []
            do {
                let ff = try JSONDecoder().decode(FindLatLng.self, from: data)
                for mainArr in ff.list {
                    self.temp.append(mainArr.main.temp!)
                    self.humid.append(Double(mainArr.main.humidity!))
                    self.name.append(mainArr.name!)
                }
                
            } catch let jsonErr {
                print("Error serializing json", jsonErr)
            }
        }.resume()
        print("name ", name)
    }

    func setChart(xValues: [String], yValuesLineChart: [Double], yValuesBarChart: [Double]) {
        chartView.noDataText = "Please provide data for the chart."
        
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        var yVals2 : [BarChartDataEntry] = [BarChartDataEntry]()
        
        for i in 0..<xValues.count {
            yVals1.append(ChartDataEntry(x: Double(i), y: yValuesLineChart[i], data: xValues as AnyObject?))
            yVals2.append(BarChartDataEntry(x: Double(i), y: yValuesBarChart[i], data: xValues as AnyObject?))
        }
        
        let lineChartSet = LineChartDataSet(values: yVals1, label: "Temperature")
        let barChartSet: BarChartDataSet = BarChartDataSet(values: yVals2, label: "Humidity")
        let data: CombinedChartData = CombinedChartData()
        data.barData=BarChartData(dataSets: [barChartSet])
        if yValuesLineChart.contains(0) == false {
            data.lineData = LineChartData(dataSets:[lineChartSet] )
            
        }
        self.chartView.data = data
        self.chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:xValues)
        self.chartView.xAxis.granularity = 100
    }
    // show alert
    func alert (checkCondition: Int) {
        var msg = ""
        if checkCondition == 0 {
            msg = "Please input number of cities."
        } else {
            msg = "Not input string"
        }
        
        let alert = UIAlertController(title: "Warning", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // check input is number
    func checkNum (inputText: Int) {
        if inputText != nil {
            numberCity = inputText
            self.viewDidLoad()
            self.setChart(xValues: name, yValuesLineChart: temp, yValuesBarChart: humid)
        } else {
            self.alert(checkCondition: 1)
        }
    }

}

