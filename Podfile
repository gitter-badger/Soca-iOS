platform :ios, '8.0'

use_frameworks!

def shared_dependency
    pod "SocaCrypto", path: '../SocaCrypto'
    pod "SocaCore", path: '../SocaCore'
    pod 'XLForm', git: 'https://github.com/zhuhaow/XLForm.git'
end

target 'Soca' do
    shared_dependency
end

target 'SocaTests' do
    shared_dependency
end

