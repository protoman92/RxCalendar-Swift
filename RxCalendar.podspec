Pod::Spec.new do |s|
  s.platform = :ios
  s.ios.deployment_target = "9.0"
  s.name = "RxCalendar"
  s.summary = "Rx-driven calendar view for iOS/OSX applications."
  s.requires_arc = true
  s.version = "1.0.1"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Hai Pham" => "swiften.svc@gmail.com" }
  s.homepage = "https://github.com/protoman92/RxCalendar-Swift.git"
  s.source = { :git => "https://github.com/protoman92/RxCalendar-Swift.git", :tag => "#{s.version}" }
  s.dependency "RxSwift", "~> 4.0"
  s.dependency "SwiftFP/Main"

  s.subspec "Main" do |main|
    main.dependency "InterfaceUtilities/Main"
    main.dependency "RxDataSources"
    main.dependency "RxCocoa", "~> 4.0"
    main.source_files = "{RxCalendarLogic,RxCalendar}/**/*.{swift}"
    main.resources = "{RxCalendar}/**/*.{jpeg,jpg,png,storyboard,xcassets,xib}"
  end

  s.subspec "Redux" do |redux|
    redux.dependency "HMReactiveRedux/Main+Rx"
    redux.source_files = "{RxCalendarLogic,RxCalendarRedux}/**/*.{swift}"
  end

  s.subspec "RegularCalendarPreset" do |regular|
    regular.dependency "RxCalendar/Main"
    regular.source_files =
      "{RxCalendarPresetLogic,RxCalendarPreset}/**/*Entry.{swift}",
      "{RxCalendarPresetLogic,RxCalendarPreset}/RegularCalendar/*.{swift}"
  end

  s.subspec "RegularCalendarLegacy" do |rcLegacy|
    rcLegacy.dependency "RxCalendar/RegularCalendarPreset"
    rcLegacy.source_files =
      "{RxCalendarLegacy}/**/*Entry.{swift}",
      "{RxCalendarLegacy}/RegularCalendar/*.{swift}"
  end
end
