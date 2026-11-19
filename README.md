# HM Skills Legacy (v1)

Treze skills de validação pré-ship no padrão Higher Mind, escritas para Claude Code e Codex. Cada uma cobre um domínio de engenharia, audita por completo e devolve findings priorizados com fix obrigatório.

Esta é a **geração v1**. Foi substituída pelo [HM Orbit 4.0.0](https://github.com/rodrigohighermind/highermind-skills), que reorganiza o mesmo acervo em quatro skills com ciclo, playbooks e contrato de fechamento. O conteúdo por domínio continua válido, então fica publicado como referência e como fallback para quem quer um validador por domínio em vez de um ciclo contínuo.

## Estado

| | |
|---|---|
| Geração | v1 (legacy) |
| Substituído por | `hm-skills-orbit` 4.0.0 |
| Runtimes | Claude Code, Codex |
| Idioma | pt-BR |
| Formato | um `SKILL.md` por skill, frontmatter `name` + `description` |
| Skills | 13 |
| Linhas | 3.686 |

## O que a v1 resolve

Um agente genérico aprova código por impressão. A v1 troca impressão por auditoria de domínio: oito camadas de engenharia e cinco de validação, cada uma com critério explícito, alvo numérico e severidade calibrada.

O modelo mental é **validador, não gerador**. A skill não constrói a interface nem escolhe a stack. Ela olha o que existe e responde uma pergunta: isso passa ou não passa, e se não passa, o que exatamente muda.

Quatro convenções valem em todas as treze:

1. **Severidade calibrada.** CRÍTICO, ALTO, MÉDIO, BAIXO. Dado em risco é sempre CRÍTICO. Health check raso é MÉDIO. Inflar finding destrói a confiança no relatório.
2. **Finding sem fix não é finding.** Todo item aponta arquivo, problema, impacto e a mudança específica.
3. **Segurança primeiro.** Em toda skill, o bloco de segurança é o primeiro auditado, nunca o último.
4. **`baseline-ready` é da skill, `product-ready` é do Owner.** A skill nunca declara algo pronto para produção. Ela declara que o baseline está pronto para o Owner avaliar.

## Índice

| Skill | Papel | Linhas | Onde para |
|---|---|---|---|
| [`hm-init`](hm-init/SKILL.md) | Início de projeto: escolha de stack, estrutura, infra Docker-first, segurança day-1 | 287 | Antes do primeiro commit |
| [`hm-cli`](hm-cli/SKILL.md) | Construção de CLI como produto: densidade visual, agentic-first, custo | 589 | CLI novo ou refactor de visual |
| [`hm-designer`](hm-designer/SKILL.md) | Validação visual: sofisticação, diferenciação, encantamento, pixel-perfect | 107 | Visual novo ou refactor de UI |
| [`hm-ux-flow`](hm-ux-flow/SKILL.md) | Fluxo cognitivo: decisão desnecessária, mal posicionada, sem informação | 203 | Feature multi-step, navegação |
| [`hm-engineer`](hm-engineer/SKILL.md) | Auditoria de código senior-level em todas as camadas | 189 | Antes de shippar bloco grande |
| [`hm-security`](hm-security/SKILL.md) | Auditoria de segurança profunda, 14 domínios, L1/L2/L3 | 758 | Antes de deploy externo |
| [`hm-data-integrity`](hm-data-integrity/SKILL.md) | Dados sagrados: backup, migration, operação destrutiva, DR | 223 | Schema, backup, incidente |
| [`hm-performance`](hm-performance/SKILL.md) | Profiling com metas numéricas, 8 domínios | 234 | Feature performance-critical |
| [`hm-llm-guardrails`](hm-llm-guardrails/SKILL.md) | 14 patterns obrigatórios para LLM em produção | 369 | Feature de LLM |
| [`hm-qa`](hm-qa/SKILL.md) | Quality assurance e os 5 checks de baseline-ready | 276 | Antes de entregar ao Owner |
| [`hm-deploy`](hm-deploy/SKILL.md) | Deploy por modelo de distribuição, 6 modelos | 254 | Antes de produção |
| [`hm-docker-clean`](hm-docker-clean/SKILL.md) | Faxina de Docker sem perder dado | 59 | Disco cheio |
| [`hm-validate-all`](hm-validate-all/SKILL.md) | Orquestrador: dispara as 5 de validação e consolida em um report | 138 | Pré-ship completo |

Ficha completa de cada uma, com escopo, quando usar e quando não usar: [`docs/indice.md`](docs/indice.md).

## Como funciona a orquestração

`hm-validate-all` não audita. Ela despacha as cinco skills de validação em ordem de custo crescente, para no primeiro gate bloqueante e consolida tudo em um único relatório.

```
hm-security  →  hm-engineer  →  hm-qa  →  hm-designer  →  hm-deploy
   gate            estrutura     função      olho           saída
```

A ordem existe porque skill não é independente. Segurança bloqueia tudo: com CRÍTICO aberto, validar design é desperdício. Código estrutura a função: bug de arquitetura invalida QA que passa. Design polish vem depois de funcional, senão você pinta uma feature quebrada. Deploy é o último gate e o menos informativo.

Exceção: ship urgente com o Owner pedindo mapa completo do estado. Aí roda as cinco mesmo com crítico no caminho, para saber onde está, não para shippar.

## Instalação

Requisito: `bash` e, para clonar, `git`. As skills são arquivos markdown, sem dependência de runtime.

### Automática

```bash
git clone https://github.com/leogm1995/hm-skills-legacy.git
cd hm-skills-legacy
./install.sh
```

O script copia as treze pastas para `~/.claude/skills/` e `~/.codex/skills/`, guarda backup do que sobrescrever em `.hm-skills-legacy-backup/<timestamp>/` e não toca em nenhuma skill que não seja desta suíte.

Opções:

```bash
./install.sh --dry-run            # mostra o plano, não escreve
./install.sh --runtime claude     # só Claude Code
./install.sh --runtime codex      # só Codex
./install.sh --uninstall          # remove as treze
```

### Manual

Cada skill é autossuficiente. Copie a pasta que você quer:

```bash
cp -r hm-security ~/.claude/skills/
```

Para Codex, o mesmo destino relativo em `~/.codex/skills/`.

### Verificação

```bash
ls ~/.claude/skills | grep '^hm-'
```

Sessões novas enxergam as skills. Sessão já aberta precisa de restart.

## Como usar

Invocação direta pelo nome:

```
/hm-security
```

Ou em linguagem natural, deixando a `description` do frontmatter rotear:

```
audita a segurança disso antes de eu subir
```

Para o pré-ship completo:

```
/hm-validate-all
```

O relatório consolidado sai no formato fixo: os 5 checks de baseline, resumo executivo com contagem por severidade, bloqueantes de ship, correções antes de uso real, débito aceitável, o que está sólido e próximos passos.

## Estrutura do repositório

```
.
├── hm-cli/SKILL.md
├── hm-data-integrity/SKILL.md
├── hm-deploy/SKILL.md
├── hm-designer/SKILL.md
├── hm-docker-clean/SKILL.md
├── hm-engineer/SKILL.md
├── hm-init/SKILL.md
├── hm-llm-guardrails/SKILL.md
├── hm-performance/SKILL.md
├── hm-qa/SKILL.md
├── hm-security/SKILL.md
├── hm-ux-flow/SKILL.md
├── hm-validate-all/SKILL.md
├── docs/
│   ├── indice.md
│   ├── contrato-de-output.md
│   └── migracao-para-orbit.md
├── install.sh
└── README.md
```

Um arquivo por skill, sem dependência externa, sem script auxiliar. O que está no `SKILL.md` é tudo que o agente lê.

## O que mudou no Orbit

A v1 é grande: `hm-security` sozinha tem 758 linhas e cobre 14 domínios. O Orbit corta isso em quatro skills com orçamento de 150 linhas e joga o detalhe em playbooks carregados sob demanda. Ganha em contexto e em ciclo; perde em granularidade de invocação, porque não existe mais um `/hm-security` isolado.

Resumo do mapeamento:

| v1 | Orbit 4.0.0 |
|---|---|
| `hm-init`, `hm-engineer`, `hm-performance`, `hm-llm-guardrails`, `hm-security`, `hm-data-integrity`, `hm-deploy`, `hm-docker-clean`, `hm-cli` | `hm-engineering` (playbooks `init`, `review`, `performance`, `llm`, `security`, `data-integrity`, `ship`, `operate`, `cli`) |
| `hm-designer`, `hm-ux-flow` | `hm-design` (playbooks `direction`, `flow`, `review`) |
| `hm-validate-all` | `hm-engineering` gate + `hm-design` fechamento |
| nenhuma | `hm-product`, `hm-council` (novos) |

Detalhe por skill: [`docs/migracao-para-orbit.md`](docs/migracao-para-orbit.md).

## Escrevendo uma skill nova neste padrão

O que toda skill da suíte tem:

1. **Frontmatter com `name` e `description`.** A `description` é o roteador: lista os gatilhos concretos que fazem o agente carregar a skill. Genérica demais não dispara, específica demais não serve para nada.
2. **`Princípio central` na primeira seção.** Uma tese em duas ou três frases que explica por que a skill existe. Se não cabe em três frases, a skill tá fazendo coisa demais.
3. **`Quando usar` e `Quando NÃO usar`, com a skill vizinha indicada.** Toda skill da suíte tem um vizinho e a fronteira precisa estar escrita, senão o agente escolhe errado.
4. **Domínios enumerados com critério, não com adjetivo.** "Alvo: <200KB gzipped" em vez de "bundle pequeno".
5. **Formato de output fixo.** Sempre o mesmo bloco, para o consolidado ser mecânico.
6. **`Regras` no fim, em imperativo.** São os freios: o que reprova na hora e o que nunca é rebaixado de severidade.

## Histórico

| Versão | O que mudou |
|---|---|
| v4 | `hm-qa` ganha os 5 checks de baseline-ready e a separação explícita com `product-ready` |
| v3 | `hm-deploy` vira validação por modelo de distribuição; `hm-engineer` e `hm-init` endurecem o baseline |
| v2.3 | `hm-security` chega a 14 domínios com ASVS, supply chain e LLM |
| v2 | `hm-data-integrity` e `hm-llm-guardrails` entram na suíte |
| v1 | `hm-designer`, `hm-ux-flow`, `hm-performance`, `hm-qa`, `hm-security`, `hm-engineer`, `hm-init`, `hm-cli`, `hm-deploy`, `hm-docker-clean`, `hm-validate-all` |

## Licença

Conteúdo do autor, sem licença declarada. Uso pessoal e interno. Se você quer usar comercialmente ou redistribuir, abra uma issue.
