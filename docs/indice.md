# Índice de skills

Ficha de cada uma das treze skills: papel, escopo, quando usar, quando não usar, o que sai no output e as regras que reprovam na hora.

As treze se dividem em três grupos.

| Grupo | Skills | Função |
|---|---|---|
| Construção | `hm-init`, `hm-cli` | Começar certo |
| Validação de domínio | `hm-security`, `hm-engineer`, `hm-qa`, `hm-data-integrity`, `hm-performance`, `hm-llm-guardrails`, `hm-designer`, `hm-ux-flow`, `hm-deploy` | Auditar |
| Orquestração e operação | `hm-validate-all`, `hm-docker-clean` | Coordenar e limpar |

---

## hm-init

**Papel:** fazer o projeto nascer no padrão, antes do primeiro commit.

**Tese:** o primeiro commit define o padrão. Projeto world-class não se torna world-class depois, ele começa assim. Segurança não é fase, é fundação.

**Escopo:**
- Escolha de stack por framework de decisão ponderado: fit ao problema, performance, custo em produção, segurança, maturidade, ecossistema, DX, hiring pool. Cada escolha justificada em uma frase.
- Arquitetura agent-first quando o projeto tem componente de IA.
- Estrutura de pastas e convenções.
- Infra local Docker-first.
- Segurança day-1: `.dockerignore`, multi-stage build, usuário non-root.
- Memory + `CLAUDE.md` cravados.
- Configs obrigatórias por stack: Next.js, Supabase, Tailwind v4, Tauri/Electron.

**Quando usar:** repositório do zero, ou reestruturação de um projeto que já nasceu errado.

**Quando não usar:** projeto em andamento que só precisa de auditoria. Para CLI especificamente, complementa com `hm-cli`.

**Reprova na hora:** "todo mundo usa" como justificativa de stack. "É o que eu conheço" sem deadline que justifique. Adicionar dependência por "pode ser que a gente precise".

---

## hm-cli

**Papel:** construir CLI como produto, não como script.

**Tese:** terminal não é console, é cinema com restrição. Cada caractere existe por motivo, cada cor significa algo, cada espaço em branco foi escolhido. Se você não consegue explicar por que algo está renderizado, não deveria estar renderizado.

A barra não é "passou no lint". É: se a Linear, a Stripe ou a A24 fizessem um CLI hoje, seria esse?

**Escopo:**
- Stack obrigatória do ecossistema Higher Mind.
- Filosofia agentic-first: CLI que agente usa, não só humano.
- As 4 camadas de resposta.
- Padrão visual com 7 elementos obrigatórios.
- Tom de voz banker/CFO em pt-BR.
- Custo-consciência e economia de token.
- Dados sagrados no contexto de CLI.
- Aprendizado persistente.
- Padrões técnicos de Ink.
- Estrutura de pastas.
- Checklist de "pronto" e anti-padrões.

**Quando usar:** CLI novo, refactor de visual de CLI medíocre, decisão de arquitetura (intent local vs LLM, sync vs streaming, bloco visual vs markdown), validação pré-ship de CLI.

**Quando não usar:** lib sem UI (vai de `hm-engineer`), web ou mobile (vai de `hm-designer`), script utilitário descartável (senso comum).

---

## hm-designer

**Papel:** validar interface no padrão que ainda vai parecer certo em 2030.

**Tese:** não construa software pro passado. A barra de design não é o que é bonito agora. Se você está igualando o padrão de hoje, já está atrasado.

**Sete critérios de avaliação:**

| Critério | Critério de reprovação |
|---|---|
| Sofisticação | Elemento na tela sem razão de existir, decoração sem propósito, complexidade sem clareza |
| Diferenciação | Trocar o logo e a tela poderia ser de qualquer produto |
| Experiência | Estado padrão de biblioteca em vez de desenhado. Todo estado é desenhado, não default |
| Encantamento | Ausência de qualquer momento que faça o usuário pausar |
| Usabilidade | Usuário fica na dúvida do que fazer. A interface não se ensina sozinha |
| Beleza | Baseado no mais comum em vez do mais belo. Dark-first, tipografia editorial, cinematográfico |
| Pixel perfect | 1px fora de alinhamento, texto cortado, componente quebrando em qualquer viewport |

**Quando usar:** antes de shippar qualquer visual novo ou refactor de UI.

**Quando não usar:** para fluxo cognitivo, use `hm-ux-flow` (designer avalia o olho, ux-flow avalia a cabeça). Para construir interface do zero com tokens, use o design system do projeto: designer valida, não gera.

---

## hm-ux-flow

**Papel:** percorrer o fluxo como o usuário percorreria e caçar friction de decisão.

**Tese:** fluxo ótimo é decisão mínima. Cada clique pergunta "é isso que você quer?". Três tipos de friction matam app e a skill caça os três: **decisão desnecessária**, **decisão mal posicionada**, **decisão sem informação suficiente**.

**Quando usar:** feature nova multi-step, refactor que mudou navegação, usuário reclamando de "não achei" ou "achei que ia fazer outra coisa", onboarding/checkout/forms importantes, queda de conversão.

**Quando não usar:** validar visual (vai de `hm-designer`), validar performance percebida (vai de `hm-performance`).

---

## hm-engineer

**Papel:** auditar um bloco grande de código na barra senior-level.

**Tese:** se você estivesse vendendo esse software e o comprador contratasse os melhores engenheiros do mundo para auditar o codebase, eles não encontrariam nada para reclamar.

**Doze camadas auditadas:**

1. Segurança de aplicação (OWASP Top 10) — **sempre a primeira**
2. Segurança de container e infraestrutura
3. Segurança de dependências
4. Arquitetura
5. Performance
6. LLM-app patterns (obrigatório se integra LLM)
7. Custo por performance
8. Resiliência
9. Dados sagrados
10. Infraestrutura
11. Qualidade
12. Escala

**Baseline inegociável:** zero bare except, zero `any`, zero fire-and-forget, zero secret hardcoded.

**Quando usar:** antes de shippar bloco de código grande.

**Quando não usar:** para deep security use `hm-security`, para profiling profundo use `hm-performance`, para projeto que persiste dados complemente com `hm-data-integrity`.

**Regras de severidade:** `.dockerignore` ausente é CRÍTICO. Dockerfile rodando dev server é CRÍTICO. Container rodando como root é ALTO. Dado em risco é sempre CRÍTICO, nunca MÉDIO.

---

## hm-security

**Papel:** auditoria de segurança profunda na barra de Tempest, Trail of Bits, Cure53.

**Tese:** segurança não é feature, não é fase, não é checklist. É a fundação. Se a fundação tem rachadura, não importa o quão bonito é o prédio.

**Todo finding é CRÍTICO até que se prove o contrário.** O ônus de rebaixar é de quem quer rebaixar, não de quem encontrou.

**Níveis:**

| Nível | Quando | Escopo |
|---|---|---|
| L1 Baseline | Todo projeto, todo deploy | Container, secrets, OWASP Top 10, dependências, `.dockerignore` |
| L2 Enterprise | Auth, dado sensível, multi-tenant | L1 + API Top 10, business logic, ASVS L2, crypto, compliance, AI/LLM |
| L3 Critical | Fintech, saúde, dado regulado, alta exposição | L2 + ASVS L3, supply chain, STRIDE, verificação formal |

Na dúvida, L2.

**Quatorze domínios:**
1. Container e infraestrutura — build (CIS Docker), runtime, rede e portas, banco
2. Aplicação — OWASP Top 10 (A01 a A10) + GraphQL, WebSocket, OAuth/SSO
3. API — OWASP API Top 10 (2023)
4. Autenticação e sessão — ASVS v5.0 capítulos 2 e 3
5. Dados e compliance — trânsito, repouso, LGPD/GDPR, PCI-DSS
6. Dependências e supply chain
7. Secrets — scan no codebase, git history, environment
8. Logging e monitoramento — o que logar, o que nunca aparece em log, proteção dos logs
9. Business logic (L2+)
10. Criptografia (L2+)
11. File upload (L1+)
12. AI/LLM — prompt injection, exfiltração, tool calling, custo e abuso, PII em prompt, cross-channel, ciclo de vida de API key, streaming
13. Multi-tenant isolation (L2+)
14. Supabase/PostgREST — RLS na mesma migration, `security_invoker=true`, gate de fechamento de sprint, `service_role`

**Quando usar:** antes de qualquer deploy externo, ao adicionar auth ou fluxo financeiro, quando manipula PII, periodicamente como manutenção, ao mudar dependências, ao integrar qualquer LLM.

**Skill prima:** `hm-data-integrity` cobre o eixo bug e crash (backup, migration, undo, DR). Segurança e integridade se sobrepõem em "dados sagrados" mas atacam por ângulos diferentes. São primos, não gêmeos.

---

## hm-data-integrity

**Papel:** garantir que dado do usuário não se perde.

**Tese:** a única perda aceitável de dado é a explicitamente autorizada pelo Owner. Todo o resto é bug.

**Nove domínios:**
1. Estratégia de backup — automático, atômico, criptografado, versionado, testado, off-site, retenção
2. Segurança de migration — versionadas, idempotentes, destrutiva com confirmação, backup antes, testada em cópia, rollback documentado, journal sincronizado
3. Operações destrutivas
4. Integridade de dado em runtime
5. Validação de schema em runtime (`JSON.parse` + cast)
6. Disaster recovery para multi-user e produção
7. Compliance (LGPD/GDPR/HIPAA quando aplicável)
8. Integridade de file/blob
9. Observabilidade para detectar problema cedo

**Frase que carrega a skill:** backup que você nunca restaurou não é backup, é esperança.

**Cobre explicitamente produção pessoal:** Electron e Tauri com banco em `userData`.

**Quando usar:** antes de shippar projeto que persiste qualquer coisa, após mudança de schema ou migration, ao definir política de backup, após incidente com perda de dado, periodicamente em projeto com dado pessoal ou financeiro.

---

## hm-performance

**Papel:** medir e localizar gargalo com número, não com especulação.

**Tese:** performance não é feature, é restrição de design. App lento é bug. Latência de LLM é custo disfarçado. Cada milissegundo importa porque o usuário sente, mesmo sem conseguir nomear.

**Oito domínios com alvos numéricos:**

| Domínio | Alvo exemplar |
|---|---|
| Bundle frontend | First-load JS < 200KB gzipped, por rota < 100KB, CSS < 50KB |
| Render frontend | LCP < 2.5s, INP < 200ms, CLS < 0.1, TTFB < 600ms |
| Latência de API | p50, p95, p99 |
| Database | Query lenta, N+1, índice ausente |
| LLM | Token e custo por call |
| Rede | Payload, round-trips |
| Memória | Heap, leak |
| Build | Tempo de build e de dev server |

Cada domínio traz ferramenta de medição por stack, anti-patterns e critério de CRÍTICO.

**Quando usar:** feature performance-critical (chat, lista grande, dashboard), usuário reclamando de lentidão, refactor em data flow, periodicamente em projeto com escala, custo de LLM ou API explodindo.

---

## hm-llm-guardrails

**Papel:** validar que app que integra LLM tem guardrail de produção.

**Tese:** LLM é componente não-determinístico, com custo variável e latência variável, em provedor externo. Trate como qualquer dependência externa: rate limit, retry, fallback, timeout, dedupe, observabilidade. Sem guardrail você não tem produto, tem demo.

**Quatorze patterns obrigatórios:**
1. Sliding window de histórico
2. Lazy client factory (sem singleton com chave velha)
3. Dedupe de geração em voo
4. Rate limit por endpoint de LLM
5. Abort e cleanup de streaming
6. Rota de retry para streaming interrompido
7. Validação de schema na resposta
8. Token budget explícito por call
9. Segurança de contexto cross-channel
10. Rastreamento de custo e estimativa por sessão
11. Failover multi-provider
12. Custo por performance como restrição de design
13. Identidade não-mesclável sem confirmação
14. Guardrails de tool calling

**Quando usar:** antes de shippar feature de LLM, quando custo de API explode sem explicação, quando o usuário reclama de demora ou travamento, ao adicionar tool calling ou agente ou chat persistente, após integrar provider novo.

---

## hm-qa

**Papel:** provar que funciona na prática, e declarar o baseline.

**Tese:** código que não é testado não existe. Feature que não é verificada é suposição. Segurança não testada é vulnerabilidade confirmada.

**Os cinco checks de baseline-ready, todos obrigatórios:**

1. `typecheck` PASS
2. `lint` PASS
3. Smoke test executado
4. Zero `console.error` em código novo
5. Zero TODO crítico em código novo

Qualquer um falhando = BLOQUEADO. Não existe compensar com "passou nos outros domínios".

**Além dos cinco:** varredura de segurança, suíte de testes com cobertura, edge cases (forms, streaming, erro, mobile, LLM, concorrência, dados sagrados), infraestrutura, agente, integridade de dado.

**Distinção que a skill carrega:** `baseline-ready` é declaração da QA. `product-ready` é prerrogativa do Owner. Nunca colapsar as duas.

**Regras duras:** smoke test é responsabilidade do Dev Team. Se não testou UI, diga "não testei UI", não diga "tudo ok". Todo gap encontrado gera o teste, não só a descrição. Container que não sobe é bug.

---

## hm-deploy

**Papel:** validar que o projeto sai do local e vai pro mundo.

**Tese:** deploy não é o último passo, é uma camada de engenharia. Se o deploy é frágil, o produto é frágil. Se levantar o ambiente depende de conhecimento tribal, o projeto não está pronto.

**Identifica o modelo de distribuição primeiro**, porque ele define quais checks se aplicam:

| Modelo | Exemplo | Checks |
|---|---|---|
| Container/Docker | API com Postgres + Redis | Domínio container inteiro, secrets em compose, multi-stage |
| Serverless/Edge | Vercel, Netlify, CF Workers | Cold start, env no dashboard, edge runtime, build output |
| Desktop | Electron, Tauri | Code signing, `contextIsolation`, `nodeIntegration: false`, auto-update, secret embutido |
| Mobile | Expo/RN | EAS build, certificados, ATS, OTA, ABI de módulo nativo |
| Library/SDK | npm, PyPI | Semver, exports, types, lock file, supply chain, zero `any` na superfície |
| CLI | Binário standalone | Build cross-platform, assinatura, install path, auto-update |

Pular seção que não se aplica é parte do trabalho. Electron não tem `.dockerignore`, library npm não tem migration.

**Security Gate primeiro.** Se falha, não continua.

**Quando usar:** antes do primeiro deploy em produção, quando o ambiente local quebrou, quando mudou infra, para validar que qualquer pessoa sobe o projeto do zero, após refactor significativo.

---

## hm-docker-clean

**Papel:** liberar disco sem perder um byte de banco.

**Tese:** dados são sagrados. Disco cheio nunca justifica perder dado.

**Protocolo, em ordem:**
1. Diagnóstico sem tocar em nada
2. Limpar só o descartável puro (dangling, cache trivial), sem perguntar
3. **Pare** antes de containers e imagens de produto
4. Cache pesado (`builder prune -a`)
5. Explicar que o `Docker.raw` não encolhe sozinho
6. Balanço final

**Proibições absolutas:** nunca apagar volume, nunca tocar em container de produto, nunca remover imagem que não seja claramente descartável.

**Fora da skill:** para o lixo trivial recorrente existe automação própria (cache + dangling, conservador, agendado no launchd). A skill é para limpeza profunda assistida.

**Quando usar:** disco cheio por causa do Docker, `Docker.raw` inchado, Owner pedindo limpeza.

**Tamanho:** 59 linhas. É a menor da suíte e a mais afiada. Todo o conteúdo é proibição e ordem de operação, não conceito.

---

## hm-validate-all

**Papel:** orquestrar as outras cinco de validação e consolidar em um relatório.

**Tese:** validação manual passo a passo perde tempo, orquestração ganha. Mesma barra de rodar cada skill isolada, sem o overhead de checkin entre uma e outra.

**Ela não audita. Ela despacha e consolida.** Não refaz auditoria que já foi feita.

**Ordem, com o motivo:**

| Ordem | Skill | Por que nessa posição |
|---|---|---|
| 1 | `hm-security` | Gate de segurança bloqueia tudo. Com CRÍTICO aberto, o resto é desperdício |
| 2 | `hm-engineer` | Bug estrutural invalida QA que passou |
| 3 | `hm-qa` | Funcionalidade validada depois de segurança e código |
| 4 | `hm-designer` | Design polish depois de funcional, senão você pinta feature quebrada |
| 5 | `hm-deploy` | Gate de saída só importa depois de tudo acima |

**Exceção:** ship urgente com Owner pedindo "valida tudo", roda as cinco mesmo com crítico no caminho, para mapa completo do estado, não para shippar.

**Output:** um relatório consolidado único, denso e priorizado, nunca concatenação crua das cinco saídas. Formato em [`contrato-de-output.md`](contrato-de-output.md).

**Quando usar:** antes de qualquer ship, depois de sprint grande, antes de o Owner aprovar entrega final, quando quer confiança de "está pronto" em uma checagem.

**Quando não usar:** validação parcial (chame a skill direta), debug de bug específico, code review de PR pequena.

**Tempo médio:** 15 a 20 minutos para projeto médio.
