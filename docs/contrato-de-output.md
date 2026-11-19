# Contrato de output

As treze skills compartilham o mesmo contrato de relatório. Ele existe para que o output de uma skill possa ser consolidado por outra, e para que o veredito seja comparável entre domínios diferentes.

## Severidade

Quatro níveis, sem escala intermediária.

| Nível | Significado | Prazo implícito |
|---|---|---|
| CRÍTICO | Perda de dado, vazamento, ship bloqueado | Antes de qualquer deploy |
| ALTO | Dano real em condição provável | 48 horas |
| MÉDIO | Dívida com impacto contido | Próximo sprint |
| BAIXO | Polimento, inconsistência | Sem prazo, registre |

Três regras de calibração, repetidas em quase toda skill:

1. **Dado em risco é sempre CRÍTICO.** Nunca MÉDIO, nunca BAIXO.
2. **Finding de segurança é CRÍTICO até que se prove o contrário.** O ônus de rebaixar é de quem quer rebaixar.
3. **Severidade proporcional ao impacto real.** SQL injection é CRÍTICO, health check raso é MÉDIO. Inflar finding destrói a confiança no relatório inteiro.

Exemplos concretos de calibração que as skills cravam:

| Situação | Severidade |
|---|---|
| `.dockerignore` ausente | CRÍTICO |
| Dockerfile rodando dev server em produção | CRÍTICO |
| Secret em build arg ou em `COPY` | CRÍTICO |
| Secret no git history | CRÍTICO, com rotação imediata |
| Container rodando como root | ALTO |
| Porta desnecessária exposta | ALTO |
| Imagem base full em vez de slim | MÉDIO |
| Health check superficial | MÉDIO |

## Anatomia de um finding

`hm-engineer` e `hm-designer` usam o formato curto:

```
[CRÍTICO] .dockerignore ausente
Onde: raiz do projeto
Problema: build copia .env e .git para dentro da imagem
Impacto: credencial de produção vaza em qualquer registry público
Fix: criar .dockerignore excluindo .env*, .git, node_modules, __pycache__
```

`hm-security` usa o formato longo, com prova de conceito e referência normativa:

```
[CRÍTICO] RLS ausente em tabela profiles
DOMÍNIO: 14 — Supabase/PostgREST
Onde: supabase/migrations/20260103_profiles.sql
Vulnerabilidade: tabela em public sem policy de RLS
Impacto: qualquer usuário autenticado lê todos os profiles via PostgREST
PoC: curl "$SUPABASE_URL/rest/v1/profiles?select=*" -H "apikey: $ANON"
Fix: habilitar RLS na mesma migration, policy por auth.uid() = id
Referência: OWASP API A01
```

O que nunca é opcional, em nenhuma das duas formas:

- **Onde.** Arquivo, linha ou área.
- **Impacto.** O que acontece se ninguém corrigir.
- **Fix específico.** "Melhore a segurança" não é fix. "Você pode querer considerar" também não.

Quando não há finding, a skill para. `hm-engineer` diz "World-class. Shippa." e não inventa problema para parecer útil.

## Baseline-ready e product-ready

A distinção aparece em `hm-qa` e em `hm-validate-all`, e é a regra mais violada por agente genérico.

| Estado | Quem declara | Significado |
|---|---|---|
| `baseline-ready` | A skill | Dev Team pode entregar ao Owner avaliar |
| `product-ready` | O Owner | O produto está pronto para o mundo |

A skill nunca declara `product-ready`. Mesmo com zero findings. O veredito dela é sobre o baseline técnico, não sobre produto.

`hm-validate-all` reforça e ainda registra que o Owner pode dar override: "ship mesmo com X aberto". A skill reporta o estado, o Owner decide. Ela informa, não bloqueia autoritariamente.

## Os cinco checks de baseline-ready

Obrigatórios em `hm-qa` e no consolidado de `hm-validate-all`. Todos os cinco precisam passar.

```
1. typecheck            PASS / FAIL
2. lint                 PASS / FAIL
3. smoke test           PASS / FAIL / NOT_RUN
4. console.error novo   zero / N
5. TODO crítico novo    zero / N
```

Qualquer falha = BLOQUEADO. Não existe compensar com os outros domínios. `NOT_RUN` não é `PASS`: se ninguém testou UI, o relatório diz "não testei UI", não "tudo ok".

## Formato do relatório consolidado

Saída de `hm-validate-all`:

```
/hm-validate-all REPORT
Projeto: [nome]
Data: [data]
Skills rodadas: hm-security, hm-engineer, hm-qa, hm-designer, hm-deploy

BASELINE-READY GATE (5 checks obrigatórios)
1. typecheck: PASS/FAIL
2. lint: PASS/FAIL
3. smoke test: PASS/FAIL/NOT_RUN
4. console.error em código novo: zero/N
5. TODO crítico em código novo: zero/N
Baseline-ready: SIM / NÃO

EXECUTIVE SUMMARY
Total findings: X CRÍTICO, Y ALTO, Z MÉDIO, W BAIXO
Veredicto: BASELINE-READY / BLOQUEADO

BLOQUEANTE SHIP (CRÍTICOS + ALTOS de segurança)
1. [SKILL] [ID] Título curto — fix em 1 linha

CORRIGIR ANTES DE USO REAL (ALTOS funcionais)
1. ...

TECHNICAL DEBT ACEITÁVEL (MÉDIOS + BAIXOS)
1. ...

PASS (o que está sólido)
- [SKILL]: DOMÍNIO X, DOMÍNIO Y

PRÓXIMOS PASSOS
1. [ação do Owner ou do Dev Team]
```

O relatório é denso e priorizado. Nunca a concatenação crua das cinco saídas: se o leitor precisa pular para a quarta skill para saber o veredito, o consolidado falhou.

## Regras de comunicação

Válidas em todas as treze:

- Sem hedge. "Você pode querer considerar" não é finding.
- Sem inflar. Relatório com tudo CRÍTICO não prioriza nada.
- Sem inventar. Código sólido é reportado em uma linha, não com problema fictício.
- Fix junto do finding, sempre. Reportar sem corrigir é metade do trabalho.
- Não apontar preferência de estilo. A barra é engenharia, não tabs versus spaces.
- Infraestrutura conta como teste. Container que não sobe é bug.
- Custo conta como finding. API call desnecessária é bug de performance.
