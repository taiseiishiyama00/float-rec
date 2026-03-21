# FloatRec

macOS用の軽量な画面録画ユーティリティ。常に最前面にフロートする小さなウィンドウから、画面録画の開始・停止を操作できます。

## 特徴

- **フローティングウィンドウ** — 常に最前面に表示される小さなコントロールパネル
- **ワンクリック操作** — 録画開始/停止をボタン一つで切り替え
- **録画状態の表示** — 録画中は赤く点滅し、状態が一目でわかる
- **経過時間表示** — 録画中の経過時間をリアルタイム表示
- **ドラッグ移動** — ウィンドウを画面上の好きな位置にドラッグで配置
- **macOS ネイティブ** — SwiftUI + ScreenCaptureKit で構築

## 動作要件

- macOS 14.0 (Sonoma) 以上
- Swift toolchain（Command Line Tools または Xcode）
- 画面収録の権限（初回起動時にシステムが許可を求めます）

## 技術スタック

- **UI**: SwiftUI
- **画面録画**: ScreenCaptureKit
- **動画書き出し**: AVFoundation
- **言語**: Swift

## ビルド・インストール

```bash
# ビルドのみ（build/FloatRec.app が生成される）
make build

# ビルド + /Applications にインストール
make install

# ビルド + そのまま起動
make run

# アンインストール
make uninstall

# ビルド成果物を削除
make clean
```

## 使い方

1. アプリを起動すると、画面右上に小さなフローティングウィンドウが表示される
2. **●** ボタンをクリックして録画を開始
3. 録画中はウィンドウが赤く変わり、経過時間が表示される
4. **■** ボタンをクリックして録画を停止
5. 保存先を選択するダイアログが表示され、`.mov` ファイルとして保存される

## プロジェクト構成

```
FloatRec/
├── FloatRecApp.swift          # アプリのエントリーポイント
├── Views/
│   └── FloatingPanelView.swift # フローティングウィンドウのUI
├── Models/
│   └── RecordingState.swift    # 録画状態の管理
├── Services/
│   └── ScreenRecorder.swift    # ScreenCaptureKit を使った録画ロジック
└── Helpers/
    └── FloatingPanel.swift     # NSPanel のカスタマイズ（常に最前面）
```

## ライセンス

MIT
