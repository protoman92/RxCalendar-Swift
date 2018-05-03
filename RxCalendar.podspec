Pod::Spec.new do |s|
  s.platform = :ios
  s.ios.deployment_target = '9.0'
  s.name = 'RxCalendar'
  s.summary = 'Rx-driven calendar view for iOS/OSX applications.'
  s.requires_arc = true
  s.version = '1.0.0'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Hai Pham' => 'swiften.svc@gmail.com' }
  s.homepage = 'https://github.com/protoman92/RxCalendar-Swift.git'
  s.source = { :git => 'https://github.com/protoman92/RxCalendar-Swift.git', :tag => '#{s.version}'}
  s.dependency 'RxSwift', '~> 4.0'
  s.dependency 'SwiftFP/Main'

  s.subspec 'Main' do |main|
    main.dependency 'InterfaceUtilities/Main'
    main.dependency 'RxDataSources'
    main.dependency 'RxCocoa', '~> 4.0'
    main.source_files = '{RxCalendarLogic,RxCalendar}/**/*.{swift}'
    main.resources = '{RxCalendar}/**/*.{json,png,xib}'
  end

  s.subspec 'Redux' do |redux|
    redux.dependency 'HMReactiveRedux/Main+Rx'
    redux.source_files = '{RxCalendarLogic,RxCalendarRedux}/**/*.{swift}'
  end

  s.subspec 'Regular99Preset' do |regular99|
    regular99.dependency 'RxCalendar/Main'
    regular99.source_files = 
      '{RxCalendarPresetLogic,RxCalendarPreset}/**/*Entry.{swift}',
      '{RxCalendarPresetLogic,RxCalendarPreset}/Regular99/*.{swift}'
  end

  s.subspec 'Regular99Legacy' do |r99legacy|
    r99legacy.dependency 'RxCalendar/Regular99Preset'
    r99legacy.source_files =
      '{RxCalendarLegacy}/**/*Entry.{swift}',
      '{RxCalendarLegacy}/Regular99/*.{swift}'
  end
end
