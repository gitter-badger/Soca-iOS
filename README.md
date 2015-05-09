# Soca-iOS
![status](https://img.shields.io/badge/status-maintained-brightgreen.svg) ![version](https://img.shields.io/github/release/zhuhaow/Soca-iOS.svg) ![license](https://img.shields.io/github/license/zhuhaow/Soca-iOS.svg)

A rule based proxy forwarder on iPhone and iPad. 

iOS上的代理转发器。

## 注意
**Soca不太可能会被App Store批准，因此想要使用Soca，只能：**

1. **自己使用开发者证书对Soca签名**
2. **有人用企业证书对Soca签名后发布**
3. **你的设备已经越狱**

**Soca处在alpha阶段，可能高度不稳定。Soca主要为本人自用，因此除了我当前使用的配置之外的情况并没有大量测试。如果你遇到任何bug，请提交issue。**

**Soca的Mac版尚需时日，主要是我懒得写GUI界面。**


##Soca是做什么的
Soca运行在你的iOS设备上，作为一个代理服务器，将请求根据给定的规则，直接连接到远程服务器或事先指定的的代理服务器上。iOS自带仅支持HTTP和SOCKS5服务器，且均不能加密，Soca支持更多的代理服务器。

##Soca支持
* 在本地运行任意个HTTP或SOCKS5代理服务器
* 根据规则（目前只有根据DNS解析地址的归属国规则）
* 将请求转发至HTTP，HTTP over SSL，SOCKS5或Shadowsocks代理服务器上（Adapter）。
* 生成APN配置文件在蜂窝网络下使用。

## 我好像不需要Soca
那么你确实不需要它。

个人看来，在这个CDN的年代，所有不能使用国内DNS的方案都是完全不可用的方案（任何种类的VPN），这点太显然了应该不用解释。

使用代理服务器的最大问题是：

1. iOS不支持任何加密代理，如果不使用Soca，那么唯一的可行方案就是在国内设置跳板，对速度和成本必然有很大影响。
2. 没有方便的规则，除了基于IP地理位置的规则之外没有看到太省心的规则，因此你至少需要一个服务器放一个pac。

我希望：

1. 没有速度损失
2. 不需要架设国内服务器
3. 一个基于规则的SOCKS5代理


## ROADMAP
1.0.0 版本之前的目标

* 基于列表的域名或者ip规则
* 支持IPv6
* 请求日志
* 流量统计
* 更好的DNS规则（如DNS解析失败，超时）
* Adapter导入


## 使用
在 1.0.0 之前，我不打算发布ipa，所以你需要自己编译。

XCode 6.3+  
iOS 8.0+

1. clone之后打开Soca.xcworkspace
2. scheme 选择 Soca-release
3. 直接Run就可以了

设置:

1. 在Setting中，将自己的代理服务器添加到Adapter中。
2. 新建Profile，添加想要在本地运行的Proxy和规则。
3. 回到主界面点击Profile就可以启动服务器。