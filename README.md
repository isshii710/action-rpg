# action-rpg

ドラゴンズドグマのような「2.5D（3Dフィールド＋三人称視点）」アクションをスマートフォンで動かすことを目指した
アクションRPGのプロトタイプです。Godot 4.3 (GDScript) で実装しています。

## 今のプロトタイプでできること

- タッチ操作（仮想スティック＋画面ドラッグ）によるキャラクターの移動・カメラ操作
- カメラ基準の三人称視点での移動とキャラクターの向き変更
- 攻撃ボタンによる近接攻撃（剣を振るアニメーション付き）
- 敵キャラクターの索敵・追跡・近接攻撃AI
- HPバー、被弾フラッシュ、ゲームオーバー／勝利時のリザルト表示とリトライ

## プロジェクト構成

```
project.godot          # プロジェクト設定（モバイル向け / 横画面）
scenes/
  main.tscn             # メインステージ（地形・障害物・敵・プレイヤー・HUD配置）
  player.tscn           # プレイヤーキャラクター（カメラリグ含む）
  enemy.tscn            # 敵キャラクター
  ui/
    hud.tscn            # 仮想スティック・攻撃ボタン・HPバー・リザルト表示
    virtual_joystick.tscn
scripts/
  player.gd             # 移動・カメラ操作・攻撃・被ダメージ処理
  enemy.gd              # 敵AI（索敵・追跡・攻撃・被ダメージ）
  main.gd               # ステージの初期化・勝敗判定
  hud.gd                # UIイベントの中継、HP表示、リザルト表示
  virtual_joystick.gd   # 仮想スティックの入力処理
  touch_look_area.gd    # ドラッグによるカメラ回転入力の処理
```

## 操作方法

- **左下の仮想スティック**: 移動（カメラの向きを基準とした前後左右）
- **画面のドラッグ**: カメラの回転（横方向＝ヨー、縦方向＝ピッチ）
- **右下の「ATK」ボタン**: 近接攻撃

## ブラウザでプレイ（Web版 / GitHub Pages）

`main` ブランチへの push をトリガーに、GitHub Actions (`.github/workflows/deploy-web.yml`) が
Godot の HTML5 (Web) ビルドを自動生成し、GitHub Pages に公開します。

公開後のURL（リポジトリ設定に依存）:

```
https://isshii710.github.io/action-rpg/
```

スマートフォンのブラウザからこのURLにアクセスすればそのままプレイできます（タッチ操作対応）。

> **初回のみ必要な設定**: リポジトリの `Settings > Pages > Build and deployment > Source` を
> `GitHub Actions` に設定してください。設定後、ワークフローが実行されるとPagesが公開されます。

## 開発環境

- [Godot Engine 4.3](https://godotengine.org/) 以降を推奨
- このリポジトリをクローンし、Godot で `project.godot` を開いて実行してください
- マウスでもタッチ操作をエミュレートできるよう `emulate_touch_from_mouse` を有効化しているため、PC上でも操作確認が可能です

### スマートフォンでの実行（Android）

1. Godot エディタで Android のエクスポートテンプレートをセットアップ
2. `Project > Export` から Android プリセットを追加してビルド
3. 実機またはエミュレータで `.apk` を実行

## 今後の拡張案

- 3Dモデル・アニメーション（現在はプリミティブ形状のプレースホルダー）
- 複数の武器種・スキル、ロックオン機能
- マップの拡張、クエスト、NPC・仲間（ポーン的存在）
- セーブ／ロード、装備・育成システム
