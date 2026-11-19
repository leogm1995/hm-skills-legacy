#!/usr/bin/env bash
# Instala as 13 skills do HM Skills Legacy no Claude Code e no Codex.
# Copia pastas inteiras, guarda backup do que sobrescrever, nao toca em skill de outra origem.
set -euo pipefail

SKILLS=(
  hm-init hm-cli hm-designer hm-ux-flow hm-engineer hm-security
  hm-data-integrity hm-performance hm-llm-guardrails hm-qa hm-deploy
  hm-docker-clean hm-validate-all
)
MARKER=".hm-legacy-install.json"
SUITE="hm-skills-legacy"
HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

runtime=both
dry=0
uninstall=0
adopt=0

usage() {
  sed -n '2,3p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  cat <<'EOF'

Uso:
  ./install.sh                    instala nos dois runtimes
  ./install.sh --runtime claude   so Claude Code
  ./install.sh --runtime codex    so Codex
  ./install.sh --dry-run          mostra o plano, nao escreve
  ./install.sh --uninstall        remove as 13 (move para backup, reversivel)
  ./install.sh --adopt            assume skills existentes sem marcador (backup antes)

Opcoes:
  --claude-home DIR   padrao ~/.claude
  --codex-home DIR    padrao ~/.codex
EOF
}

claude_home="$HOME/.claude"
codex_home="$HOME/.codex"

while [ $# -gt 0 ]; do
  case "$1" in
    --runtime) runtime="${2:?--runtime exige claude, codex ou both}"; shift 2 ;;
    --claude-home) claude_home="${2:?}"; shift 2 ;;
    --codex-home) codex_home="${2:?}"; shift 2 ;;
    --dry-run) dry=1; shift ;;
    --uninstall) uninstall=1; shift ;;
    --adopt) adopt=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'argumento desconhecido: %s\n' "$1" >&2; usage; exit 2 ;;
  esac
done

case "$runtime" in
  both) homes=("$claude_home" "$codex_home") ;;
  claude) homes=("$claude_home") ;;
  codex) homes=("$codex_home") ;;
  *) printf 'runtime invalido: %s\n' "$runtime" >&2; exit 2 ;;
esac

# Falha antes de qualquer escrita.
for skill in "${SKILLS[@]}"; do
  [ -f "$HERE/$skill/SKILL.md" ] || { printf 'skill ausente no repo: %s\n' "$skill" >&2; exit 1; }
done

plan_lines=()
for home in "${homes[@]}"; do
  skills_dir="$home/skills"
  plan_lines+=("[home] $home")
  if [ ! -d "$home" ]; then
    plan_lines+=("  ignorado: $home nao existe")
    continue
  fi
  for skill in "${SKILLS[@]}"; do
    target="$skills_dir/$skill"
    if [ "$uninstall" = 1 ]; then
      if [ ! -e "$target" ]; then
        continue
      elif [ -f "$target/$MARKER" ]; then
        plan_lines+=("  remover: $skill")
      else
        plan_lines+=("  CONFLITO (sem marcador desta suite, intocado): $skill")
      fi
    elif [ ! -e "$target" ]; then
      plan_lines+=("  instalar: $skill")
    elif [ -f "$target/$MARKER" ] && grep -q "\"$SUITE\"" "$target/$MARKER"; then
      plan_lines+=("  substituir: $skill")
    elif [ "$adopt" = 1 ]; then
      plan_lines+=("  adotar (backup antes): $skill")
    else
      plan_lines+=("  CONFLITO (skill de outra origem, intocado): $skill")
    fi
  done
done

printf '%s\n' "${plan_lines[@]}"

if [ "$dry" = 1 ]; then
  printf '\nDry-run. Nada foi escrito.\n'
  exit 0
fi

if [ "$uninstall" = 1 ]; then
  for home in "${homes[@]}"; do
    [ -d "$home" ] || continue
    skills_dir="$home/skills"
    backup_dir="$skills_dir/.hm-skills-legacy-backup/$STAMP"
    for skill in "${SKILLS[@]}"; do
      target="$skills_dir/$skill"
      [ -f "$target/$MARKER" ] || continue
      grep -q "\"$SUITE\"" "$target/$MARKER" || continue
      mkdir -p "$backup_dir"
      mv "$target" "$backup_dir/$skill"
      printf 'removido %s (backup em %s)\n' "$target" "$backup_dir/$skill"
    done
  done
  printf '\nPASS. Removido. Backups preservados.\n'
  exit 0
fi

for home in "${homes[@]}"; do
  [ -d "$home" ] || continue
  skills_dir="$home/skills"
  backup_dir="$skills_dir/.hm-skills-legacy-backup/$STAMP"
  mkdir -p "$skills_dir"
  for skill in "${SKILLS[@]}"; do
    target="$skills_dir/$skill"
    if [ -e "$target" ] && [ "$adopt" = 0 ] && { [ ! -f "$target/$MARKER" ] || ! grep -q "\"$SUITE\"" "$target/$MARKER"; }; then
      continue
    fi
    if [ -e "$target" ]; then
      mkdir -p "$backup_dir"
      mv "$target" "$backup_dir/$skill"
    fi
    staging="$skills_dir/.$skill.staging-$$"
    rm -rf -- "$staging"
    cp -R "$HERE/$skill" "$staging"
    printf '{"suite":"%s","version":"1.0.0","skill":"%s"}\n' "$SUITE" "$skill" > "$staging/$MARKER"
    mv "$staging" "$target"
    printf 'ok %s -> %s\n' "$skill" "$target"
  done
  [ -d "$backup_dir" ] && printf 'backup em %s\n' "$backup_dir"
done

printf '\nPASS. Sessoes novas enxergam as skills; sessao aberta precisa de restart.\n'
