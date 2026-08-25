# TestFlight 持续分发

仓库的 `.github/workflows/ios-testflight.yml` 提供两条独立但关联的自动化路径。拉取请求和推送到 `main` 会执行 iPhone 模拟器测试；只有创建 `v*` 标签，或在 Actions 页面手动运行并明确勾选 `publish` 后，才会创建签名的 Release 归档并上传至 TestFlight。这样可以避免常规开发提交消耗分发签名或误传测试构建。

> 工作流以 `macos-26` 运行，并动态选择该运行器当前可用的最高版本 iOS Runtime，再创建独立的 iPhone 17 模拟器。它不会依赖预创建的设备名称或固定 UUID，并在测试结束后删除该设备。项目的最低部署版本仍是 iOS 17，因此此流程验证的是当前 Xcode 与新版 iOS 的前向兼容性，不等同于覆盖所有 iOS 17–26 的真机组合。[1]

## 配置 GitHub 机密变量

先在 App Store Connect 创建或确认 `com.jzb.tower` 的 App 记录与对应的 Apple Developer App ID。发布描述文件必须属于该 Bundle ID，并包含项目声明的 iCloud 容器能力 `iCloud.com.jzb.tower`。为避免误将 Ad Hoc 或开发描述文件上传到 App Store Connect，工作流会检查 Bundle ID、`get-task-allow=false` 和不含 `ProvisionedDevices`。

| 机密变量 | 内容 | 生成方式 |
| --- | --- | --- |
| `APPLE_DISTRIBUTION_CERTIFICATE_BASE64` | `Apple Distribution` 证书及私钥导出的 `.p12` 文件 | 在受控 Mac 上导出 `.p12` 后执行 `base64 -i distribution.p12 \| pbcopy`。 |
| `APPLE_DISTRIBUTION_CERTIFICATE_PASSWORD` | 上述 `.p12` 的导出密码 | 使用高强度、独立的随机密码。 |
| `APP_STORE_PROVISIONING_PROFILE_BASE64` | `com.jzb.tower` 的 App Store `.mobileprovision` | 下载描述文件后执行 `base64 -i Tower_AppStore.mobileprovision \| pbcopy`。 |
| `KEYCHAIN_PASSWORD` | 云端临时钥匙串密码 | 使用独立的随机密码；它不应复用证书密码。 |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API Key ID | 从 App Store Connect 的 API 密钥详情获得。 |
| `APP_STORE_CONNECT_API_ISSUER_ID` | App Store Connect Issuer ID | 从 App Store Connect 的 API 密钥页面获得。 |
| `APP_STORE_CONNECT_API_PRIVATE_KEY_BASE64` | API Key 的 `.p8` 私钥 | 下载一次性 `.p8` 文件后执行 `base64 -i AuthKey_KEYID.p8 \| pbcopy`。 |

在仓库中依次打开 **Settings → Secrets and variables → Actions → New repository secret**，按上表逐项创建机密变量。请不要把 `.p12`、`.mobileprovision`、`.p8` 文件或其 Base64 内容提交到 Git，也不要在 Issue、Pull Request、构建日志或聊天中粘贴它们。GitHub 建议以机密变量传递证书和描述文件，并在任务中导入临时钥匙串。[2]

App Store Connect API 的团队密钥需要 Account Holder 或 Admin 创建。若使用个人密钥，密钥只能下载一次；遗失或怀疑泄露时应立即撤销并新建。[3]

## 触发与产物

| 场景 | 发生的操作 | 输出 |
| --- | --- | --- |
| 提交 Pull Request 至 `main` | 在动态创建的 iPhone 17 / 最高可用 iOS Runtime 模拟器执行串行 `xcodebuild test` | 测试日志与保留 14 天的 `.xcresult` 结果包。 |
| 推送 `main` | 在同一动态模拟器执行兼容性测试 | 测试日志与保留 14 天的 `.xcresult` 结果包。 |
| 推送 `v*` 标签，例如 `v1.0.3` | 测试通过后，签名 Release Archive、导出 IPA、上传 App Store Connect | TestFlight 构建，以及保留 14 天的 IPA 工作流产物。 |
| 手动运行并开启 `publish` | 同上，适合需要临时测试分发时使用 | TestFlight 构建，以及保留 14 天的 IPA 工作流产物。 |

工作流基于 `GITHUB_RUN_NUMBER` 生成大于 10000 的 `CURRENT_PROJECT_VERSION`。这让同一营销版本下的每次云端上传拥有不同的 build string；App Store Connect 用 Bundle ID、版本号与 build string 识别上传构建。[4]

## 使用前检查

在首次触发发布前，确认下列条件全部成立。第一，App Store Connect 中存在 Bundle ID 为 `com.jzb.tower` 的应用记录。第二，App Store 描述文件、Distribution 证书和 App ID 来自同一 Apple Developer 团队。第三，描述文件启用了 iCloud 容器与 CloudDocuments。第四，App Store Connect API 密钥具备 Developer、App Manager、Admin 或 Account Holder 权限，以便上传构建。[4]

发布工作流不会自动将构建提交 App Review，也不会自动邀请外部测试者；它只会上传至 App Store Connect，之后由 Apple 处理并在 TestFlight 中显示。外部测试、测试信息和 App Review 的操作仍应在 App Store Connect 完成。

## 兼容性边界

模拟器测试可及时发现 Swift 编译、单元测试和新 iOS 运行时的回归，但不能替代真实设备上的网络、推送、签名、iCloud、性能和目标代理客户端导入验证。发布前仍应至少在一台运行最低支持系统版本的 iPhone 和一台运行当前系统版本的 iPhone 上完成手动回归。

## 参考资料

[1]: https://github.com/actions/runner-images/blob/main/images/macos/macos-26-Readme.md "GitHub Actions macOS 26 runner image"
[2]: https://docs.github.com/actions/use-cases-and-examples/deploying/installing-an-apple-certificate-on-macos-runners-for-xcode-development "GitHub：在 macOS Runner 安装 Apple 签名证书"
[3]: https://developer.apple.com/help/app-store-connect/get-started/app-store-connect-api/ "Apple：App Store Connect API"
[4]: https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/ "Apple：上传构建"
