#!/bin/bash
# =============================================================================
# Compliance Check — Bug Condition Exploration Test
# =============================================================================
# Property 1: Bug Condition — Documentation Compliance Defects in Lab 02
#
# This test asserts the EXPECTED (correct) behavior per directrices-laboratorios.md.
# On UNFIXED code, it MUST FAIL — failure confirms the 6 bugs exist.
# On FIXED code, it MUST PASS — passing confirms all bugs are resolved.
#
# Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 1.6
# =============================================================================

set -euo pipefail

# Resolve paths — lab files are two levels up from tests/lab-02/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(cd "$SCRIPT_DIR/../../lab-02-redes-vpc" && pwd)"

README="$LAB_DIR/README.md"
TROUBLESHOOTING="$LAB_DIR/TROUBLESHOOTING.md"
LIMPIEZA="$LAB_DIR/LIMPIEZA.md"

FAILURES=0
TOTAL_CHECKS=0

fail() {
  echo "  FAIL: $1"
  FAILURES=$((FAILURES + 1))
}

pass() {
  echo "  PASS: $1"
}

check() {
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

echo "============================================="
echo "Compliance Check — Lab 02 Networking VPC"
echo "============================================="
echo ""

# ---------------------------------------------------------------
# CHECK 1 (Bug 1): igw-workshop does NOT exist in TROUBLESHOOTING.md
# Expected: igw-lab2 (not igw-workshop)
# Will FAIL on unfixed code — 1 occurrence found
# ---------------------------------------------------------------
echo "[CHECK 1] TROUBLESHOOTING.md: No 'igw-workshop' (should be 'igw-lab2')"
check

if [ ! -f "$TROUBLESHOOTING" ]; then
  fail "TROUBLESHOOTING.md not found"
else
  IGW_WORKSHOP_MATCHES=$(grep -n "igw-workshop" "$TROUBLESHOOTING" || true)

  if [ -n "$IGW_WORKSHOP_MATCHES" ]; then
    IGW_WORKSHOP_COUNT=$(echo "$IGW_WORKSHOP_MATCHES" | wc -l | tr -d ' ')
    fail "'igw-workshop' found $IGW_WORKSHOP_COUNT time(s) in TROUBLESHOOTING.md (expected 0)"
    echo "    Counterexample(s):"
    echo "$IGW_WORKSHOP_MATCHES" | while IFS= read -r line; do
      echo "      $line"
    done
  else
    pass "No 'igw-workshop' in TROUBLESHOOTING.md"
  fi
fi

echo ""

# ---------------------------------------------------------------
# CHECK 2 (Bug 2): No standalone **Attached** without Spanish translation
# Expected: **Asociado** (Attached) — not just **Attached**
# Will FAIL on unfixed code — 4 occurrences (2 in README.md, 2 in TROUBLESHOOTING.md)
# ---------------------------------------------------------------
echo "[CHECK 2] README.md & TROUBLESHOOTING.md: No standalone '**Attached**' without Spanish translation"
check

ATTACHED_TOTAL=0
ATTACHED_DETAILS=""

for FILE in "$README" "$TROUBLESHOOTING"; do
  BASENAME=$(basename "$FILE")
  if [ ! -f "$FILE" ]; then
    fail "$BASENAME not found"
    continue
  fi

  # Find lines with **Attached** that do NOT already have the Spanish translation
  # i.e., lines with **Attached** but NOT preceded by **Asociado**
  ATTACHED_MATCHES=$(grep -n '\*\*Attached\*\*' "$FILE" | grep -v '\*\*Asociado\*\*' || true)

  if [ -n "$ATTACHED_MATCHES" ]; then
    COUNT=$(echo "$ATTACHED_MATCHES" | wc -l | tr -d ' ')
    ATTACHED_TOTAL=$((ATTACHED_TOTAL + COUNT))
    ATTACHED_DETAILS="${ATTACHED_DETAILS}    In $BASENAME ($COUNT occurrence(s)):"$'\n'
    while IFS= read -r line; do
      ATTACHED_DETAILS="${ATTACHED_DETAILS}      $line"$'\n'
    done <<< "$ATTACHED_MATCHES"
  fi
done

if [ "$ATTACHED_TOTAL" -gt 0 ]; then
  fail "Standalone '**Attached**' without Spanish translation found $ATTACHED_TOTAL time(s) (expected 0)"
  echo "    Counterexample(s):"
  echo "$ATTACHED_DETAILS"
else
  pass "No standalone '**Attached**' without Spanish translation"
fi

echo ""

# ---------------------------------------------------------------
# CHECK 3 (Bug 3): All subsection headers ### X.Y have X matching parent Parte number
# Expected: Parte N contains ### N.Y headers
# Will FAIL on unfixed code — 15 headers misaligned
# ---------------------------------------------------------------
echo "[CHECK 3] README.md: Subsection headers ### X.Y aligned with parent Parte number"
check

if [ ! -f "$README" ]; then
  fail "README.md not found"
else
  MISALIGNED=0
  MISALIGNED_DETAILS=""
  CURRENT_PARTE=0

  while IFS= read -r line; do
    LINE_NUM=$(echo "$line" | cut -d: -f1)
    LINE_TEXT=$(echo "$line" | cut -d: -f2-)

    # Check if this is a Parte header
    if echo "$LINE_TEXT" | grep -qE '^## Parte [0-9]+'; then
      CURRENT_PARTE=$(echo "$LINE_TEXT" | grep -oE 'Parte [0-9]+' | grep -oE '[0-9]+')
    fi

    # Check if this is a subsection header ### X.Y
    if echo "$LINE_TEXT" | grep -qE '^### [0-9]+\.[0-9]+'; then
      SUBSECTION_PREFIX=$(echo "$LINE_TEXT" | grep -oE '### [0-9]+\.' | grep -oE '[0-9]+')
      if [ "$CURRENT_PARTE" -gt 0 ] && [ "$SUBSECTION_PREFIX" != "$CURRENT_PARTE" ]; then
        MISALIGNED=$((MISALIGNED + 1))
        MISALIGNED_DETAILS="${MISALIGNED_DETAILS}      Line $LINE_NUM: Found '### ${SUBSECTION_PREFIX}.*' under Parte $CURRENT_PARTE (expected ### ${CURRENT_PARTE}.*)"$'\n'
      fi
    fi
  done < <(grep -nE '^(## Parte [0-9]+|### [0-9]+\.[0-9]+)' "$README")

  if [ "$MISALIGNED" -gt 0 ]; then
    fail "$MISALIGNED subsection header(s) misaligned with parent Parte number (expected 0)"
    echo "    Counterexample(s):"
    echo "$MISALIGNED_DETAILS"
  else
    pass "All subsection headers aligned with parent Parte number"
  fi
fi

echo ""

# ---------------------------------------------------------------
# CHECK 4 (Bug 4): No stray "2. Utilice la barra de búsqueda global..."
# outside subsection structure in Parte 2
# Will FAIL on unfixed code — 1 occurrence
# ---------------------------------------------------------------
echo "[CHECK 4] README.md: No stray numbered step outside subsection structure in Parte 2"
check

if [ ! -f "$README" ]; then
  fail "README.md not found"
else
  # Look for a line starting with "2." followed by "Utilice la barra" that appears
  # between the Parte 2 header and the first subsection header
  STRAY_STEP=$(grep -n '^2\. Utilice la barra' "$README" || true)

  if [ -n "$STRAY_STEP" ]; then
    STRAY_COUNT=$(echo "$STRAY_STEP" | wc -l | tr -d ' ')
    fail "Stray numbered step found $STRAY_COUNT time(s) outside subsection structure (expected 0)"
    echo "    Counterexample(s):"
    echo "$STRAY_STEP" | while IFS= read -r line; do
      echo "      $line"
    done
  else
    pass "No stray numbered step outside subsection structure in Parte 2"
  fi
fi

echo ""

# ---------------------------------------------------------------
# CHECK 5 (Bug 5): sg-lab2- prefix does NOT exist in any of the 3 files
# Expected: security-group-lab2- (not sg-lab2-)
# Will FAIL on unfixed code — 8 occurrences (4 README, 2 LIMPIEZA, 2 TROUBLESHOOTING)
# ---------------------------------------------------------------
echo "[CHECK 5] All files: No 'sg-lab2-' prefix (should be 'security-group-lab2-')"
check

SG_TOTAL=0
SG_DETAILS=""

for FILE in "$README" "$LIMPIEZA" "$TROUBLESHOOTING"; do
  BASENAME=$(basename "$FILE")
  if [ ! -f "$FILE" ]; then
    fail "$BASENAME not found"
    continue
  fi

  SG_MATCHES=$(grep -n "sg-lab2-" "$FILE" || true)

  if [ -n "$SG_MATCHES" ]; then
    COUNT=$(echo "$SG_MATCHES" | wc -l | tr -d ' ')
    SG_TOTAL=$((SG_TOTAL + COUNT))
    SG_DETAILS="${SG_DETAILS}    In $BASENAME ($COUNT occurrence(s)):"$'\n'
    while IFS= read -r line; do
      SG_DETAILS="${SG_DETAILS}      $line"$'\n'
    done <<< "$SG_MATCHES"
  fi
done

if [ "$SG_TOTAL" -gt 0 ]; then
  fail "'sg-lab2-' prefix found $SG_TOTAL time(s) across all files (expected 0)"
  echo "    Counterexample(s):"
  echo "$SG_DETAILS"
else
  pass "No 'sg-lab2-' prefix in any file"
fi

echo ""

# ---------------------------------------------------------------
# CHECK 6 (Bug 6): eip-{nombre-participante} without lab2 component does NOT exist
# Expected: eip-lab2-{nombre-participante} (not eip-{nombre-participante})
# Will FAIL on unfixed code — 2 occurrences (1 README, 1 LIMPIEZA)
# ---------------------------------------------------------------
echo "[CHECK 6] README.md & LIMPIEZA.md: No 'eip-{nombre-participante}' without 'lab2' component"
check

EIP_TOTAL=0
EIP_DETAILS=""

for FILE in "$README" "$LIMPIEZA"; do
  BASENAME=$(basename "$FILE")
  if [ ! -f "$FILE" ]; then
    fail "$BASENAME not found"
    continue
  fi

  # Match eip-{nombre-participante} but NOT eip-lab2-{nombre-participante}
  EIP_MATCHES=$(grep -n 'eip-{nombre-participante}' "$FILE" | grep -v 'eip-lab2-{nombre-participante}' || true)

  if [ -n "$EIP_MATCHES" ]; then
    COUNT=$(echo "$EIP_MATCHES" | wc -l | tr -d ' ')
    EIP_TOTAL=$((EIP_TOTAL + COUNT))
    EIP_DETAILS="${EIP_DETAILS}    In $BASENAME ($COUNT occurrence(s)):"$'\n'
    while IFS= read -r line; do
      EIP_DETAILS="${EIP_DETAILS}      $line"$'\n'
    done <<< "$EIP_MATCHES"
  fi
done

if [ "$EIP_TOTAL" -gt 0 ]; then
  fail "'eip-{nombre-participante}' without 'lab2' component found $EIP_TOTAL time(s) (expected 0)"
  echo "    Counterexample(s):"
  echo "$EIP_DETAILS"
else
  pass "No 'eip-{nombre-participante}' without 'lab2' component"
fi

echo ""

# ---------------------------------------------------------------
# SUMMARY
# ---------------------------------------------------------------
echo "============================================="
echo "RESULTS: $TOTAL_CHECKS checks executed"
if [ "$FAILURES" -gt 0 ]; then
  echo "STATUS: FAILED — $FAILURES check(s) failed"
  echo "============================================="
  exit 1
else
  echo "STATUS: PASSED — All checks passed"
  echo "============================================="
  exit 0
fi
