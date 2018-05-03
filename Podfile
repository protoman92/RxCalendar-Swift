# Uncomment the next line to define a global platform for your project
 platform :ios, '8.0'

def allBasePods
  pod 'SwiftFP/Main', git: 'https://github.com/protoman92/SwiftFP.git'
end

def allLogicPods
  allBasePods
  pod 'RxSwift', '~> 4.0'
end

def allViewPods
  allLogicPods
  pod 'RxCocoa', '~> 4.0'
  pod 'RxDataSources'
  pod 'InterfaceUtilities/Main', git: 'https://github.com/protoman92/InterfaceUtilities-Swift.git'
end

def allReduxPods
  allBasePods
  pod 'HMReactiveRedux/Main+Rx', git: 'https://github.com/protoman92/HMReactiveRedux-Swift.git'
end

def allTestPods
  allLogicPods
  pod 'SwiftUtilities/Main+Rx', git: 'https://github.com/protoman92/SwiftUtilities.git'
  pod 'SwiftUtilitiesTests/Main+Rx', git: 'https://github.com/protoman92/SwiftUtilities.git'
end

target 'RxCalendar' do
  use_frameworks!
  allViewPods
  
  # Pods for RxCalendar
  
  target 'RxCalendarTests' do
    inherit! :search_paths
  end
end

target 'RxCalendarLogic' do
  inherit! :search_paths
  use_frameworks!
  allLogicPods
  
  target 'RxCalendarLogicTests' do
    inherit! :search_paths
    allTestPods
  end
end

target 'RxCalendarRedux' do
  use_frameworks!
  allReduxPods
  
  target 'RxCalendarReduxTests' do
    inherit! :search_paths
    allTestPods
  end
end

target 'RxCalendarPresetLogic' do
  use_frameworks!
  allLogicPods
end

target 'RxCalendarPreset' do
  use_frameworks!
  allViewPods
end

target 'RxCalendarLegacy' do
  use_frameworks!
  allViewPods
end

target 'RxCalendarDemo' do
  use_frameworks!
  allViewPods
  allReduxPods
end
