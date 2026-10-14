# Technical Feasibility Assessment

## ProofBuy AI — PayPal AI Hackathon 2026

---

## Summary Verdict: FEASIBLE within the 6-week window

All three core APIs (PayPal Orders v2, Channel3, OpenAI) are publicly accessible with free or low-cost tiers sufficient for a hackathon prototype. The riskiest unknown is the Channel3 product schema coverage for specialized items (e.g., niche electronics), which can be validated early with a free key.

---

## API 1: PayPal Orders v2

**Status: Ready to integrate**

| Concern | Finding |
|---|---|
| Sandbox available? | Yes — `api-m.sandbox.paypal.com` |
| OAuth2 flow | Standard `client_credentials` grant, token endpoint is public |
| Create order flow | POST `/v2/checkout/orders` → get order ID + approve URL → redirect buyer → capture |
| Buyer approval | HATEOAS `rel:approve` link in create response; buyer visits PayPal, approves |
| Capture | POST `/v2/checkout/orders/{id}/capture` → returns COMPLETED status |
| Server-side verification | GET `/v2/checkout/orders/{id}` → check `status == COMPLETED` and `purchase_units[0].payments.captures[0].status == COMPLETED` |
| SDK | Official JS SDK (`@paypal/paypal-js`) and Node SDK available |
| Free for development? | Yes, sandbox is free |

**Risks:**
- PayPal developer docs have aggressive cookie walls; the APIMatic Context Plugin (free via hackathon) is the recommended workaround — it grounds AI-assisted coding in the actual spec.
- Token expires after ~9 hours; must implement refresh.

---

## API 2: Channel3 (trychannel3.com)

**Status: Ready to integrate — free tier sufficient for prototype**

| Concern | Finding |
|---|---|
| Documentation | `docs.trychannel3.com` — fully public, no login |
| Base URL | `https://api.trychannel3.com` (inferred from SDK); search endpoint: POST `/v1/search` |
| Auth | API key via `x-api-key` header or `Authorization: Bearer <key>` |
| Free tier | 1,000 search credits/month; 10 req/s, 10,000/day daily quota |
| Product coverage | 100M+ products from 25,000+ brands across US, UK, CA, AU, EU |
| Response fields | `id`, `title`, `description`, `brands[]`, `images[]`, `offers[].url`, `offers[].price.price`, `offers[].price.currency`, `offers[].availability`, `variants`, `key_features[]`, `materials[]`, `structured_attributes` |
| Pagination | `next_page_token` in response; up to 500 products per query (costs 1 credit per page) |
| Price tracking | Separate Price Tracking API — subscribe by `product_id`, webhook on price change, historical data |
| Locales | US, UK, CA, AU + 12 EU countries; 8 currencies; 12 languages |
| SDK | `npm install @channel3/sdk` — `client.products.search({ query: "..." })` |

**Risks:**
- Coverage of niche/specialty items may be incomplete; validate with target product categories early.
- Rate limit is 10 req/s on free (default) tier — sufficient for demo, upgrade for production.
- `rel:approve` buy links are tracked/affiliated; ensure this aligns with intended UX.

---

## API 3: OpenAI GPT-4o Structured Outputs

**Status: Production-ready feature, low integration risk**

| Concern | Finding |
|---|---|
| Endpoint | `POST https://api.openai.com/v1/responses` (Responses API) or `POST /v1/chat/completions` |
| Structured output mode | `response_format: { type: "json_schema", json_schema: { name: "...", strict: true, schema: {...} } }` |
| Model support | `gpt-4o-2024-08-06` and later, `gpt-4o-mini-2024-07-18` and later |
| Schema guarantee | With `strict: true`, model output is guaranteed to match the JSON Schema |
| Latency | First request with a new schema has added latency (schema processing); subsequent reuses are normal. Typical: 1–3s for short prompts. |
| Cost | $2.50/1M input tokens · $10.00/1M output tokens. A typical 500-token prompt + 200-token structured response ≈ $0.0047. Cache reads: $1.25/1M. |
| Refusals | Safety refusals return a `refusal` field instead of `output_text`; must handle in code |
| Schema limits | Up to 5,000 object properties, 10 levels of nesting, 1,000 enum values |

**Cost estimate for hackathon demo (10,000 interactions):**
- ~700 tokens avg per call (input+output)
- 10,000 × 700 = 7M tokens ≈ $17.50–$70.00 total
- Well within hackathon budget

**Proof extraction use case:**
GPT-4o with structured output is ideal for extracting structured data from a receipt/invoice image:
```json
{
  "type": "json_schema",
  "json_schema": {
    "name": "proof_extraction",
    "strict": true,
    "schema": {
      "type": "object",
      "properties": {
        "item_name": { "type": "string" },
        "price_paid": { "type": "number" },
        "currency": { "type": "string" },
        "purchase_date": { "type": "string" },
        "merchant": { "type": "string" }
      },
      "required": ["item_name", "price_paid", "currency", "purchase_date", "merchant"],
      "additionalProperties": false
    }
  }
}
```

---

## Integration Feasibility Matrix

| Integration | Complexity | Time Estimate | Blocker Risk |
|---|---|---|---|
| PayPal OAuth2 + Create Order | Medium | 1 day | Low — sandbox well documented |
| PayPal Buyer Approval Flow | Medium | 1 day | Low — HATEOAS flow is standard |
| PayPal Capture + Verify | Low | 0.5 day | Low |
| Channel3 Product Search | Low | 0.5 day | Low — SDK available |
| Channel3 Price Tracking (webhook) | Medium | 1 day | Low |
| GPT-4o Structured Output (proof parsing) | Low | 0.5 day | Low |
| GPT-4o Product Matching | Low | 0.5 day | Low |
| End-to-end agent orchestration | High | 3–5 days | Medium — seams between APIs |

**Total estimated implementation: ~8–10 days of focused work** — comfortable within a 6-week hackathon window.

---

## Key Risks and Mitigations

| Risk | Mitigation |
|---|---|
| PayPal sandbox approval UX is cumbersome in demo | Use PayPal JS SDK popup flow instead of full redirect |
| Channel3 doesn't carry a specific product category | Test queries in first week; fall back to broader category search |
| OpenAI structured output schema refusal | Add retry logic; include fallback prompt without strict mode |
| Render free tier spin-down (15 min inactivity) | Use Render Starter ($7/mo) or keep-alive ping for demo day |
| Token expiry (PayPal 9h, OpenAI no expiry) | Implement token refresh with `expires_in` field |
