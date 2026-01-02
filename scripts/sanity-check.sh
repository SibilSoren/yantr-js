#!/bin/bash
set -e

# Configuration
REPO_ROOT=$(pwd)
CLI_BIN="$REPO_ROOT/cli/dist/index.js"
TEST_DIR="$REPO_ROOT/../test-yantr-sanity"

echo "🚀 Starting Sanity Check for Yantr-js..."

# 1. Setup Test Directory
echo "📁 Setting up test directory: $TEST_DIR"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# 2. Initialize Node Project
echo "📦 Initializing Node project..."
npm init -y > /dev/null

# 3. Build CLI if needed (Double check)
echo "🛠️ Ensuring CLI is built..."
cd "$REPO_ROOT/cli"
pnpm build > /dev/null
cd "$TEST_DIR"

# 4. Run yantr init
echo "🪛 Running 'yantr init --yes'..."
node "$CLI_BIN" init --yes

# 5. Run yantr add auth
echo "🔐 Running 'yantr add auth'..."
node "$CLI_BIN" add auth --overwrite

# 6. Verify Results
echo "🧪 Verifying results..."

if [ -f "yantr.json" ]; then
    echo "✅ yantr.json exists"
else
    echo "❌ yantr.json missing"
    exit 1
fi

if [ -f "src/lib/yantr/error-handler.ts" ]; then
    echo "✅ Base templates (error-handler) injected"
else
    echo "❌ Base templates missing"
    exit 1
fi

if [ -d "src/lib/yantr/auth" ]; then
    echo "✅ Auth component injected"
else
    echo "❌ Auth component missing"
    exit 1
fi

# 7. Check if yantr.json contains auth
if grep -q "auth" yantr.json; then
    echo "✅ yantr.json updated with auth component"
else
    echo "❌ yantr.json not updated"
    exit 1
fi

echo "✨ Sanity Check Passed Successfully! 🪛"
