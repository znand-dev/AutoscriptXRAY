#!/bin/bash
# Verification script untuk variable quotes

echo "🔍 Checking for unquoted variables that might be security risks..."

# Patterns yang harus di-quote
critical_patterns=(
    '\$svc'
    '\$bin' 
    '\$user\.conf'
    '\$headerpkg'
    '\$temp_[a-zA-Z]*'
    '\$backup_[a-zA-Z]*'
    '\$config[^_]'
)

issues_found=0

for pattern in "${critical_patterns[@]}"; do
    if grep -r --include="*.sh" -E "$pattern" . | grep -v "\".*$pattern.*\"" | grep -v "#.*$pattern"; then
        echo "⚠️ Found unquoted: $pattern"
        ((issues_found++))
    fi
done

if [[ $issues_found -eq 0 ]]; then
    echo "✅ No critical unquoted variables found!"
else
    echo "❌ Found $issues_found potential issues"
fi
