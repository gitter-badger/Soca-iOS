platform :ios, '8.0'

use_frameworks!

#def shared_dependency
#    pod "SocaCrypto", path: '../SocaCrypto'
#    pod "SocaCore", path: '../SocaCore'
#    pod 'XLForm', git: 'https://github.com/zhuhaow/XLForm.git'
#end

def shared_dependency
    pod "SocaCrypto", git: 'https://github.com/zhuhaow/SocaCrypto.git', tag: '0.1.0'
    pod "SocaCore", git: 'https://github.com/zhuhaow/SocaCore.git', tag: 'v0.4.2'
    pod 'XLForm', git: 'https://github.com/zhuhaow/XLForm.git'
end


target 'Soca' do
    shared_dependency
end

target 'SocaTests' do
    shared_dependency
end

