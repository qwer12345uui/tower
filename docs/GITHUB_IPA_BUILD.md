# GitHub 在线构建与下载 IPA

本仓库的 [Build iOS IPA](../.github/workflows/build-ipa.yml) 工作流**只允许手动启动**。它不监听代码推送，不创建 GitHub Release，不上传 App Store Connect 或 TestFlight，也不会将 IPA 自动发布到任何第三方位置。

## 下载位置

在 GitHub 仓库中打开 **Actions**，选择左侧的 **Build iOS IPA**，点击 **Run workflow**。构建成功后，进入该次运行页面底部的 **Artifacts** 区域，下载名称形如 `Tower-unsigned-iOS15-运行号` 或 `Tower-development-signed-iOS15-运行号` 的构件。构件保留 14 天，过期后会自动删除。

| 选项 | 产物 | 是否可直接安装 | 用途 |
| --- | --- | --- | --- |
| `unsigned` | `Tower-unsigned-ios15.ipa` | 否 | 仅用于验证 iOS 15 最低部署目标能够完成设备版编译；iOS 会拒绝未签名 App。 |
| `development-signed` | `Tower-development-signed-ios15.ipa` | 是，限配置文件内设备 | 使用 Apple Development 证书和 Development provisioning profile 签名，可通过 Xcode、Apple Configurator 或其他受支持的开发安装方式安装到已登记 UDID 的设备。 |

> **请勿将开发证书、`.p12`、描述文件或其密码提交到仓库。** 签名材料必须只保存为仓库的 Actions secrets。

## 生成可安装 IPA 的一次性准备

在仓库 **Settings → Secrets and variables → Actions** 新建以下四个 secrets。其值不会出现在构建日志中。

| Secret 名称 | 内容 |
| --- | --- |
| `BUILD_CERTIFICATE_BASE64` | Apple Development 证书 `.p12` 文件的 Base64 内容。 |
| `P12_PASSWORD` | 导出该 `.p12` 时设置的密码。 |
| `BUILD_PROVISION_PROFILE_BASE64` | 与 `com.jzb.tower` 匹配、且包含目标设备 UDID 的 Development `.mobileprovision` 文件的 Base64 内容。 |
| `APPLE_TEAM_ID` | Apple Developer Team ID。 |

macOS 上可用下列命令生成 Base64 文本，随后把输出完整粘贴到相应 secret 中：

```sh
base64 -i AppleDevelopment.p12 | pbcopy
base64 -i TowerDevelopment.mobileprovision | pbcopy
```

准备完成后，在手动运行工作流时选择 `development-signed`。工作流会在临时钥匙串中导入签名材料，导出完成后仅上传 IPA 构件；不会创建发布页或对外分发链接。

## iOS 15 兼容性边界

工程最低部署目标已调整为 **iOS 15.0**。为保持稳定性，iOS 16 及以上的实时相机二维码扫描、横向拖拽排序、滚动吸附和新式数值转场在 iOS 15 上会降级为可访问的替代交互：二维码扫描提示用户改用粘贴输入，客户端排序仍可通过已保留的“向前移动 / 向后移动”辅助功能操作。iOS 16 及以上仍保留实时相机扫码。

每次改动 Swift 源码后，应先运行 `unsigned` 以验证无签名设备构建；准备在真机测试时再运行 `development-signed`。如果签名构建失败，请优先核对描述文件的 Bundle ID、Team ID、证书类型和设备 UDID，而不是修改工作流来绕过签名校验。
