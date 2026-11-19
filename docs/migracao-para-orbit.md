# Migração para o HM Orbit 4.0.0

Neste documento, **v1** significa a geração pré-Orbit publicada neste repositório, não a versão de uma skill específica (que chega a v4 em `hm-qa`).

A v1 era um validador por domínio. O Orbit é um ciclo com playbooks. Este documento mapeia onde cada coisa da v1 foi parar, o que melhorou e o que se perdeu, para você decidir quando usar qual.

## A mudança estrutural

| | v1 (este repositório) | Orbit 4.0.0 |
|---|---|---|
| Skills | 13 | 4 |
| Unidade | domínio de validação | fase de trabalho |
| Contexto | `SKILL.md` monolítico | `SKILL.md` + playbooks sob demanda |
| Orçamento de linhas | nenhum. `hm-security` tem 758 | 150 por skill |
| Postura | validador | validador e construtor |
| Saída | findings | decisão, especificação, implementação, gate |
| Fechamento | relatório de findings | `baseline-ready` da skill, `product-ready` do Owner |
| Autoridade | skill decide o técnico | lei 8 do Orbit: duas vias decide, uma via recomenda |

O Orbit não é a v1 reorganizada. Ele acrescenta ciclo: a skill não só audita o que existe, ela conduz do problema até o gate. A v1 é mais estreita e mais fácil de invocar por domínio.

## Mapa skill por skill

| v1 | Destino no Orbit | Observação |
|---|---|---|
| `hm-init` | `hm-engineering` playbook `init` | O framework de escolha de stack por peso sobrevive |
| `hm-cli` | `hm-engineering` playbook `cli` | A tese de "terminal como produto cinematográfico" sobrevive inteira |
| `hm-designer` | `hm-design`, playbooks `direction` e `review` | Avaliação visual virou contrato: nenhum veredito sobre tela sem renderizar |
| `hm-ux-flow` | `hm-design` playbook `flow` | Os três tipos de friction continuam |
| `hm-engineer` | `hm-engineering` playbook `review` | As 12 camadas viraram camadas de review |
| `hm-security` | `hm-engineering` playbook `security` | Os 14 domínios comprimidos. Detalhe normativo fica no playbook, não no contexto carregado por padrão |
| `hm-data-integrity` | `hm-engineering` playbook `data-integrity` | |
| `hm-performance` | `hm-engineering` playbook `performance` | |
| `hm-llm-guardrails` | `hm-engineering` playbook `llm` | Os 14 patterns continuam |
| `hm-qa` | `hm-engineering` gate + `hm-design` fechamento | Os 5 checks de baseline viraram o gate do Orbit |
| `hm-deploy` | `hm-engineering` playbooks `ship` e `operate` | Deploy e operação separados, que a v1 misturava |
| `hm-docker-clean` | `hm-engineering` playbooks `operate` e `ship` | Não é mais skill isolada. É procedimento dentro de operação |
| `hm-validate-all` | Gate do `hm-engineering` + fechamento do `hm-design` | O orquestrador deixa de existir como skill e vira o gate do ciclo |
| nenhum equivalente | `hm-product` | Novo. Vale construir, tese, JTBD, spec, roadmap, pricing, GTM |
| nenhum equivalente | `hm-council` | Novo. Decisão de uma via levada a vários modelos, às cegas |

## O que se ganha

**Contexto.** 758 linhas de `hm-security` em todo prompt é caro. O Orbit carrega 150 linhas de skill e puxa o playbook de segurança só quando o problema é de segurança. Para a maior parte das tarefas, isso é a diferença entre um agente com espaço para raciocinar e um agente saturado de checklist.

**Ciclo.** A v1 audita e para. O Orbit conduz do problema ao gate, com modos declarados: diagnóstico sem mutar quando o pedido é análise, implementação quando autorizado.

**Autoridade explícita.** A v1 tem uma regra só: `product-ready` é do Owner. O Orbit formaliza isso em oito leis, incluindo a lei 8, que separa decisão de duas vias (decide) de uma via (recomenda). Menos atrito em revisão.

**Kernel.** O Orbit tem um kernel de sessão (`SessionStart`) e um guard destrutivo (`PreToolUse` com `onFailure: block`). A v1 é markdown puro, sem hook, sem lock, sem rollback. O installer do Orbit dá preflight completo, journal com rollback e backup.

**Conselho.** `hm-council` não existe na v1. Quando uma decisão merece mais de um olhar, o Orbit leva a vários modelos independentes e devolve o que concordam, o que só um viu e o que medir antes de decidir.

## O que se perde

**Granularidade de invocação.** Não existe mais `/hm-security`. Você invoca `hm-engineering` e a skill decide que o playbook de segurança é o certo. Quando você sabe exatamente qual domínio quer, a v1 é mais direta.

**Densidade de domínio.** `hm-security` tem 758 linhas de check concreto. O playbook do Orbit tem o essencial e delega o resto para o julgamento da skill. Em auditoria L3, a v1 é mais exaustiva por construção.

**Independência.** Cada skill da v1 é autossuficiente: copia a pasta e funciona. O Orbit depende do kernel e das leis estarem no contexto. Instalação parcial quebra o contrato.

**Tamanho.** 59 linhas de `hm-docker-clean` fazem uma coisa só, muito bem. No Orbit, virou procedimento dentro de `operate`, que faz várias.

## Quando usar cada geração

Use o **Orbit** como padrão. É o que está mantido e o que cobre produto, conselho e ciclo.

Use a **v1** quando:

- Você quer invocar um domínio específico e sabe qual. `/hm-security` é mais direto que entrar em `hm-engineering` e esperar o roteamento.
- Você precisa do detalhe normativo completo em auditoria de segurança L3 ou de dados.
- Você está em um runtime sem suporte a hooks, onde o kernel do Orbit não roda.
- Você quer uma skill autossuficiente, sem dependência de contexto.

As duas convivem. A v1 é arquivo markdown e não colide com a suíte que tem marcador de instalação: uma skill da v1 sem marcador nunca é aposentada pelo installer do Orbit.

## Nota sobre a instalação

O installer do Orbit aposenta skills da geração anterior apenas quando encontra marcador `suite=highermind-skills`. Estas treze não têm marcador, então sobrevivem lado a lado com `hm-design`, `hm-engineering`, `hm-product` e `hm-council`.

Isso é conveniência e risco ao mesmo tempo:

- **Conveniência:** as duas gerações disponíveis, você escolhe por tarefa.
- **Risco:** sobreposição de escopo. `hm-designer` e `hm-design` disputam o mesmo gatilho; `hm-engineer` e `hm-engineering` disputam o mesmo gatilho. O roteamento pode escolher qualquer um dos dois.

Se a sobreposição incomodar, remova as da v1 do diretório de skills e mantenha este repositório como arquivo consultável. Se preferir a v1 para um domínio, remova a skill do Orbit correspondente. É escolha de configuração, não de código.
