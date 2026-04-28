---
name: llm-cost-evaluator
description: Evaluate LLM API options for a project — estimate token usage, research current pricing from official sources, calculate monthly costs, and recommend the best provider/model within a budget constraint. Use when selecting or switching LLM providers for any project.
---

# LLM Cost Evaluator

Systematic evaluation of LLM API providers for a project, producing a concrete recommendation with cost calculations.

## Inputs

Ask for (or infer from codebase):

1. **Use cases**: What LLM tasks does the project perform? (e.g., text generation, classification, scoring, summarization, vision/multimodal)
2. **Budget constraint**: Monthly spend limit (currency + amount)
3. **Volume estimate**: Approximate monthly call count, or let this skill calculate from usage patterns
4. **Quality requirements**: What matters — accuracy, speed, structured output, multilingual, multimodal?
5. **Deployment region**: China mainland, global, or specific region (affects provider availability)
6. **Existing integration**: Current LLM setup (local Ollama, OpenAI-compatible, specific SDK?)

If inputs are missing, infer from codebase by reading:
- Prompt templates (to estimate input token sizes)
- LLM client code (to understand call patterns and frequency)
- Config files (to find current model/provider settings)
- Scheduler/cron jobs (to estimate daily/monthly call volume)

## Steps

### Step 1: Profile Token Usage

For each LLM task in the project:

1. Read the prompt template and measure its token size (~4 chars = 1 token for English, ~2 chars = 1 token for Chinese)
2. Estimate dynamic input size (e.g., paper abstracts, user queries, document chunks)
3. Estimate output size (structured JSON is typically compact; free-form text varies)
4. Note if batching is used (N items per call)

Produce a table:

```
| Task | Calls/month | Input tokens/call | Output tokens/call | Batched? |
|------|------------|-------------------|-------------------|----------|
```

Sum totals: **X M input tokens + Y M output tokens / month**

### Step 2: Research Current Pricing

**CRITICAL**: Prices change frequently. ALWAYS fetch live data from official sources. Never rely on training data alone.

Search these official pricing pages (prioritize by region):

**China Mainland providers:**
- DeepSeek: `api-docs.deepseek.com/quick_start/pricing` (USD, convert at current rate)
- Alibaba Qwen/Bailian: `help.aliyun.com/zh/model-studio/getting-started/models`
- Zhipu GLM: `open.bigmodel.cn/pricing`
- ByteDance Doubao: `volcengine.com/docs/82379` or Ark console
- Moonshot/Kimi: `platform.moonshot.cn/docs/pricing`
- Baichuan: `platform.baichuan-ai.com/docs/pricing` (often not competitive)

**International providers:**
- OpenAI: `openai.com/api/pricing`
- Anthropic Claude: `anthropic.com/pricing`
- Google Gemini: `ai.google.dev/pricing`

For each model, capture:
- Input price per 1M tokens (note cache hit discount if available)
- Output price per 1M tokens (note thinking vs non-thinking if applicable)
- Free tier / signup credits
- Rate limits (RPM, TPM)
- Context window size
- Batch API discount (if any)
- Structured JSON output support

### Step 3: Calculate Monthly Costs

For each candidate model:

```
Monthly cost = (input_tokens * input_price) + (output_tokens * output_price)
```

Adjustments to consider:
- **Prompt caching** (DeepSeek, Qwen): If system prompts repeat across calls, estimate cache hit rate (typically 60-80%) and blend prices
- **Batch API** (Qwen, OpenAI): Typically 50% off — note if the project's latency tolerance allows async batch
- **Tiered pricing** (Qwen models): Price varies by input length per request — use the tier matching typical request size
- **Thinking mode tokens** (Qwen3, DeepSeek R1): Output includes chain-of-thought tokens that are billed — estimate overhead or recommend disabling thinking for simple tasks

### Step 4: Evaluate Quality Fit

Rate each model on the project's specific needs:

| Dimension | How to assess |
|-----------|--------------|
| Task accuracy | Model class (frontier > mid > budget) for the task complexity |
| Structured output | Does it support `response_format: json_object`? How reliable? |
| Multilingual | Critical for Chinese academic text, legal docs, etc. |
| Multimodal | Can it process images/PDFs natively? Eliminates need for separate VL model |
| Speed | Typical latency (local Ollama: 5-10s, cloud: 0.5-3s, under load: varies) |
| Reliability | Rate limits, queue behavior under high traffic, uptime history |

### Step 5: Assess Integration Path

Check how much code changes are needed:
- **Zero change**: Just swap API key/URL in config (OpenAI-compatible providers)
- **Config change**: Update model provider config (e.g., OpenClaw, LiteLLM)
- **Code change**: Different SDK, different response format, new client needed
- **Architecture change**: E.g., switching from local to cloud, adding proxy

Prefer the path with minimum disruption.

### Step 6: Produce Recommendation

Output format:

```
## Recommendation

### Primary: [Model Name]
- Monthly cost: [amount]
- Why: [1-2 sentences]
- Integration: [effort level + what to change]

### Fallback: [Model Name]
- Monthly cost: [amount]
- Why: [when to use instead of primary]

### Budget option: [Model Name]
- Monthly cost: [amount]
- Why: [for development/testing or non-critical tasks]

### Cost Comparison Table
| Model | Monthly Cost | Quality | Speed | Multimodal | Integration |
|-------|-------------|---------|-------|------------|-------------|

### Usage Assumptions
- [List all assumptions: call volume, token sizes, cache rates, etc.]
- [Monthly tokens: X M input + Y M output]
```

## Guardrails

- **NEVER use stale pricing** — always fetch from official sources during evaluation
- **ALWAYS show your math** — token estimates, price per unit, monthly total
- **ALWAYS note currency** — RMB vs USD, include conversion rate used
- **ALWAYS consider the full picture** — a model that's $1/month cheaper but requires rewriting the client isn't necessarily better
- **Flag risks**: rate limiting under load, pricing changes, vendor lock-in, China firewall considerations
- **Include free tiers** in the comparison — they can cover months of light usage
- **Don't recommend models you haven't verified are available** — check that the API endpoint is actually live

## Common Pitfalls

1. **Forgetting thinking mode overhead**: Qwen3/DeepSeek R1 thinking tokens count toward output — can 3-5x output costs if not disabled
2. **Ignoring cache benefits**: For repetitive prompts (scoring, classification), DeepSeek's automatic prefix caching can cut input costs by 10x
3. **Comparing apples to oranges**: A multimodal model that replaces two separate models (text + vision) may be cheaper overall despite higher per-token price
4. **Not accounting for growth**: If the project adds more rulesets/users, linear cost scaling is fine but exponential is a red flag
5. **Assuming local = free**: Local Ollama costs $0 in API fees but has GPU hardware cost, electricity, and most importantly 5-10x latency impact on UX
