# 食卓ヘルパーアプリ

## アプリの説明
大きく2つの機能があります。

**・冷蔵庫の食材管理**
　冷蔵庫など家にある食材を入力し、リストとして管理をするもの。消費期限などを設定し、近いものは赤く表示されたりします。

**・レシピ推薦機能**
　楽天のAPIを使い、レシピを検索して表示する機能。

## 設計方針 
**画面偏移**:

ホーム画面 -> 食材登録画面

食材登録画面 -> 食材リスト画面

ホーム画面 -> レシピ検索画面

レシピ検索画面 -> レシピ検索結果画面

**使いやすさ**: シンプルで直感的な UI を採用し、誰でも簡単に操作できるように設計しました。

**見やすさ**: 食材リストやレシピ検索結果を見やすく表示し、必要な情報にすぐにアクセスできるように設計しました。

**拡張性**: 将来的に、食材リストにある食材を加味してレシピを推薦できるようにしたいです。

## 工夫したところ

**消費期限の可視化**: 消費期限が近い食材を赤く表示することで、食材の無駄を減らすように工夫しました。

**レシピ検索の柔軟性**: カテゴリからレシピを検索できるようにすることで、より多くのレシピにアクセスできるように工夫しました。

**データベースの活用**: SQLite を使用してデータを保存することで、オフラインでもアプリを使用できるように工夫しました。


## 動作環境

Flutter version -3.24.4 

Dart version -3.5.4 