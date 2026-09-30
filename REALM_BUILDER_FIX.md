# Realm Builder Issue & Resolution Guide

## Problem Summary

When running `dart run build_runner build` (or `flutter pub run build_runner build`) in Flutter with Realm, the build fails or hangs with an error similar to:

```text
[SEVERE] realm:realm_generator on lib/core/routes/route_constants.dart:

Exception: Missing implementation of visitDotShorthandPropertyAccess
#0      ThrowingAstVisitor._throw (package:analyzer/dart/ast/visitor.dart:2971:5)
#1      ThrowingAstVisitor.visitDotShorthandPropertyAccess (package:analyzer/dart/ast/visitor.dart:2542:7)
#2      DotShorthandPropertyAccessImpl.accept (package:analyzer/src/dart/ast/ast.dart:5536:15)
#3      ResolutionSink._writeNode (package:analyzer/src/summary2/bundle_writer.dart:955:10)
...
[WARNING] realm:realm_generator on lib/core/routes/route_constants.dart:
Your current `analyzer` version may not fully support your current SDK version.

Analyzer language version: 3.9.0
SDK language version: 3.13.0
```

---

## Root Cause

1. **Dart SDK & Analyzer Mismatch**:
   - Modern Dart SDKs (Dart 3.13+ / Flutter 3.47+) support new language features such as **dot shorthands** (`DotShorthandPropertyAccess`).
   - The current `realm_generator` package (v`20.2.0`) is pinned to `analyzer: ^7.3.0` (which resolves to `7.7.1` in `pubspec.lock`), which predates these AST additions.
   - Analyzer `7.7.1`'s internal `BundleWriter` does not implement `visitDotShorthandPropertyAccess` and throws an unhandled exception when analyzing newer Dart syntax.

2. **Unconstrained Builder Scope**:
   - By default, `realm_generator` specifies `auto_apply: dependents`. Without an explicit project configuration, `build_runner` attempts to run `realm_generator` on **every `.dart` file** across the entire project (including routes, UI widgets, and Flutter framework consumers).
   - Once the generator visits files that touch modern SDK Flutter code, the analyzer crashes.

---

## The Solution

Configure `build.yaml` in the root of the project to restrict `realm_generator` to execute **only on data model files**. Realm models only import `package:realm/realm.dart` and do not depend on Flutter UI libraries, bypassing the analyzer bug entirely.

### 1. Created `build.yaml` in Project Root

File: [build.yaml](file:///Users/kyrillosmaherfekry/Desktop/mindset_notes/build.yaml)

```yaml
targets:
  $default:
    builders:
      realm:realm_generator:
        generate_for:
          - lib/**/models/**.dart
          - lib/**/model/**.dart
```

> **Note**: This restricts `realm:realm_generator` so it only parses files under `models` or `model` directories (such as `lib/features/notes/data/models/note_model.dart`).

---

## How to Run Code Generation

Whenever you add or update Realm models, run:

```bash
# Using build_runner (Recommended)
dart run build_runner build --delete-conflicting-outputs

# Or using realm's CLI tool
dart run realm generate
```

To clean stale build caches if needed:
```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

---

## Model Authoring Best Practices for Realm

1. **Keep Model Files Dedicated**:
   - Models should only contain the `@RealmModel()` private definition (e.g. `_Note`) and `import 'package:realm/realm.dart';`.
   - Avoid importing `package:flutter/...` into model files.
   - Do not reference the generated class (e.g. `Note`) directly inside the model file before code generation has run, as the analyzer needs to resolve the file to generate code.

2. **Register Schemas in Realm Configuration**:
   - In `realm_config.dart`, always register the generated schema:
     ```dart
     import 'package:realm/realm.dart';
     import '../../features/notes/data/models/note_model.dart';

     final config = Configuration.local([Note.schema]);
     final realm = Realm(config);
     ```
