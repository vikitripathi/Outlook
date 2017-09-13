//
//  EventTableViewCell.swift
//  Outlook
//
//  Created by abhishek dutt on 04/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet var eventDetailView: UIView!
    @IBOutlet var indicatorView: UIView!
    @IBOutlet var timeView: UIView!
    
    @IBOutlet var eventStartTimeLabel: UILabel!
    @IBOutlet var eventDurationLabel: UILabel!
    @IBOutlet var eventHeaderLabel: UILabel!
    @IBOutlet var eventLocationLabel: UILabel!
    
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var weatherCategoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.indicatorView.makeCircular()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    //make a default configuration
    
    func configure(withEvent event: EventModel?)  {
        guard let event = event else {
            configureCellForNoEvent()
            return
        }
        
        configureWeather(event: event)
        
        switch event.eventCategory {
        case .Hangout:
            configureCellForHangout(event: event)
        case .Meeting:
            configureCellForMeeting(event: event)
        case .Holiday:
            configureCellForHoliday(event: event)
        default:
            configureCellForUncategorised(event: event)
        }
    }
    
    private func configureCellForHangout(event: EventModel) {
        eventStartTimeLabel.text = event.getStartDateString
        eventDurationLabel.text = event.eventDuration?.stringTime
        
        eventHeaderLabel.text = event.eventTitle
        eventLocationLabel.text = event.eventLocation
    }
    
    private func configureCellForMeeting(event: EventModel) {
        eventStartTimeLabel.text = event.getStartDateString
        eventDurationLabel.text = event.eventDuration?.stringTime
        
        eventHeaderLabel.text = event.eventTitle
        eventLocationLabel.text = event.eventLocation
    }
    
    private func configureCellForHoliday(event: EventModel) {
        eventStartTimeLabel.text = "All Day"
        eventDurationLabel.text = nil
        
        eventHeaderLabel.text = event.eventTitle
        eventLocationLabel.text = nil
        temperatureLabel.text = nil
        weatherCategoryLabel.text = nil
    }
    
    private func configureCellForUncategorised(event: EventModel) {
        
    }
    
    private func configureCellForNoEvent() {
        
    }
    
    func configureWeather(event: EventModel){
        guard let weather = event.weatherAtEventTime else {
            temperatureLabel.text = ""
            weatherCategoryLabel.text = ""
            return
        }
        
        temperatureLabel.text = weather.temperature+"F"
        weatherCategoryLabel.text = weather.category.getWeatherStringValue()
        
    }
}
