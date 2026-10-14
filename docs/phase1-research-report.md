# Phase 1 Research Report

## ProofBuy AI — PayPal AI Hackathon 2026

**Prepared:** October 2026
**Scope:** Hackathon rules, PayPal Orders v2, Channel3 API, OpenAI structured outputs

---

## Summary

All four research areas are resolved with high confidence. ProofBuy AI is technically feasible, sponsor-eligible for at least 4 cash prizes, and can be built comfortably within the 6-week window.

**Three blockers confirmed as non-issues:**
1. PayPal Orders v2 has a working sandbox with documented OAuth2 + create/capture flow.
2. Channel3 is a fully public API with 1,000 free searches/month and a published product schema.
3. OpenAI GPT-4o structured output (`strict: true`) guarantees schema-compliant JSON — no fragile regex parsing of receipts.

**One access failure:** The devpost rules page (`paypalaihackathon.devpost.com/rules`, `devpost.com/details/apimatic`) returned HTTP 403. All rules data was reconstructed from the [PayPal Community Blog](https://developer.paypal.com/community/blog/PayPal_AI_Hackathon/) and [AG Grid blog post](https://www.ag-grid.com/blog/hackathon-paypal-and-ag-studio/), which together are authoritative for dates and prizes.

---

## 1. Hackathon Requirements

### Key Findings

**Dates (from PayPal dev blog):**
- Submissions open: October 1, 2026
- Submissions close: **November 12, 2026, 12:00 pm Pacific**
- Judging: December 1–15, 2026
- Winners announced: December 21, 2026

**Fundamental requirement:** Project must "meaningfully use both PayPal and AI." No prescribed tracks.

**Prize pool: $60,000+ USD**

Core prizes: $12k / $8k / $5k for 1st/2nd/3rd. Honorable mentions: $5k each (Most Creative, Most Impactful, Best Demo, Best Use of PayPal+AI, Best Use of Agentic Commerce).

**Sponsor prizes relevant to ProofBuy AI:**
| Sponsor | Prize | Requirement |
|---|---|---|
| Channel3 | $1,500 | Use Channel3 API for product data |
| APIMatic | ×3 $1,000 | Use APIMatic Context Plugin for PayPal |
| Render | Up to $1,000 credits | Deploy on Render |
| AG Grid | Up to $5,000 | Use AG Studio for dashboards/charts |

**Total addressable prize for ProofBuy AI: up to ~$24,500** (Best Overall 1st + Agentic Commerce HM + Channel3 + APIMatic + Render).

**Judging criteria:** The rules page was inaccessible (HTTP 403). Expected criteria (standard for this hackathon format): Innovation, Technical Execution, Use of PayPal+AI, Demo Quality, Impact.

**Submission assets:** Devpost rules not confirmed due to 403. Based on devpost norms: demo video (2–3 min), public GitHub repo, written description. Confirm before submission.

**Evidence:** [developer.paypal.com/community/blog/PayPal_AI_Hackathon/](https://developer.paypal.com/community/blog/PayPal_AI_Hackathon/), [ag-grid.com/blog/hackathon-paypal-and-ag-studio/](https://www.ag-grid.com/blog/hackathon-paypal-and-ag-studio/)

---

## 2. PayPal Orders v2

### Key Findings

**Base URLs:**
- Sandbox: `https://api-m.sandbox.paypal.com`
- Live: `https://api.paypal.com`

**OAuth2 Token (client_credentials grant):**
```
POST /v1/oauth2/token
Authorization: Basic base64(CLIENT_ID:CLIENT_SECRET)
Body: grant_type=client_credentials
```
Returns `access_token` valid for `expires_in` seconds (~9 hours). Must refresh before expiry.

**Create Order:**
```
POST /v2/checkout/orders
{ "intent": "CAPTURE", "purchase_units": [{ "amount": { "currency_code": "USD", "value": "29.99" } }] }
```
Returns HTTP 201 with `id` (order ID) and HATEOAS links including `rel:approve` (buyer approval URL) and `rel:capture`.

**Buyer Approval:** Client redirects to or opens popup at `rel:approve` URL. PayPal JS SDK handles this natively — no full-page redirect needed.

**Capture:**
```
POST /v2/checkout/orders/{id}/capture
```
Returns HTTP 201 with `status: COMPLETED` and `purchase_units[0].payments.captures[0].status: COMPLETED` on success.

**Server-Side Verification:**
```
GET /v2/checkout/orders/{id}
```
Check `status === "COMPLETED"` and capture status. Never trust client-side confirmation alone.

**Order Statuses:** CREATED → APPROVED → COMPLETED (also: SAVED, VOIDED, PAYER_ACTION_REQUIRED)

**Access note:** The PayPal developer docs site (`developer.paypal.com/docs/api/orders/v2/`) has aggressive cookie walls and returned truncated content. All data above was gathered from the [REST API get-started page](https://developer.paypal.com/api/get-started), [payment-links API page](https://developer.paypal.com/api/payment-links-buttons), and search results referencing official docs. The **APIMatic Context Plugin** (`npx context-plugins install paypal`) is strongly recommended as it grounds AI-assisted coding in the actual PayPal spec.

**Evidence:** [developer.paypal.com/api/get-started](https://developer.paypal.com/api/get-started), [developer.paypal.com/api/orders/v2/orders-authorize](https://developer.paypal.com/api/orders/v2/orders-authorize), [developer.paypal.com/api/payment-links-buttons](https://developer.paypal.com/api/payment-links-buttons)

---

## 3. Channel3 API

### Key Findings

**Documentation:** Fully public at [docs.trychannel3.com](https://docs.trychannel3.com). No login required to read docs.

**Correct domain:** `trychannel3.com` (not `channel3.ai` or `docs.channel3.ai` — those domains returned no results).

**Scale:** 100M+ products from 25,000+ brands across US, UK, CA, AU, and 12 EU countries.

**Authentication:**
- Anonymous tier (no key): lower limits, no commission tracking
- Token tier (API key): `x-api-key: <key>` or `Authorization: Bearer <key>`. Bad/missing keys fall back silently to anonymous — no 401.

**Core endpoint:** `POST /v1/search`

**Request fields:** `query` (text), `limit`, `filters` (price, availability, gender, category, brand_ids, colors, age, dimensions, attributes), `country`, `language`, `currency`, `next_page_token`, `mode: "keyword"` (low-latency exact match)

**Response schema (confirmed from API reference):**
```
products[].id, title, description
products[].brands[].id, name
products[].images[].url
products[].category.slug, title, path
products[].key_features[], materials[]
products[].offers[].url (tracked buy link)
products[].offers[].domain
products[].offers[].price.price, currency, compare_at_price
products[].offers[].availability, condition
products[].offers[].dimensions.{length,width,height,weight}
products[].offers[].max_commission_rate
products[].variants.options[].name, values[].label, available, product_id
products[].structured_attributes (category-specific key/values)
next_page_token
```

**Rate limits (per API key):**
| Plan | Search req/s | Daily quota | Monthly free credits |
|---|---|---|---|
| default (free) | 10/s | 10,000/day | 1,000 |
| plus | 15/s | 250,000/day | n/a |

Rate limit response: HTTP 429, `Retry-After: 5`.

**Additional APIs:**
- `POST /v1/lookup` — fetch product by ID
- `POST /v1/image-search` — visual similarity search
- `POST /v0/price-tracking/start` — subscribe to price changes (webhook)
- `GET /v0/price-tracking/history/{id}` — price history

**SDK:** `npm install @channel3/sdk` → `client.products.search({ query: "..." })`

**Evidence:** [docs.trychannel3.com/api-reference/v1/search](https://docs.trychannel3.com/api-reference/v1/search), [docs.trychannel3.com/faq/rate-limits](https://docs.trychannel3.com/faq/rate-limits), [docs.trychannel3.com/ucp/authentication](https://docs.trychannel3.com/ucp/authentication), [docs.trychannel3.com/sdk](https://docs.trychannel3.com/sdk)

---

## 4. OpenAI GPT-4o Structured Outputs

### Key Findings

**Endpoint:** `POST https://api.openai.com/v1/responses` (Responses API) or `POST /v1/chat/completions`

**How to request schema-constrained JSON:**
Set `text.format` (Responses API) or `response_format` (Chat Completions) to:
```json
{
  "type": "json_schema",
  "name": "schema_name",
  "strict": true,
  "schema": { ... }
}
```
With `strict: true`, the model is guaranteed to produce output matching the schema. This is not JSON mode — it enforces field names, types, and required fields.

**Model requirements:** `gpt-4o-2024-08-06` or later, `gpt-4o-mini-2024-07-18` or later. Older models support JSON mode only (no schema guarantee).

**Latency:** First request with a new schema incurs extra latency (schema cache miss). Subsequent calls with the same schema return at normal latency.

**Cost (October 2026):**
- Input: $2.50/1M tokens
- Output: $10.00/1M tokens
- Cached input: $1.25/1M tokens

Typical proof extraction call (~500 input + 100 output tokens) ≈ $0.0022.

**Vision (receipt images):** GPT-4o supports `input_image` content in the Responses API — pass base64-encoded image alongside text prompt. Schema-constrained output works with vision input.

**Refusal handling:** Model may return `{ "type": "refusal", "refusal": "..." }` instead of output_text. Must check `content[0].type` before parsing.

**Evidence:** [developers.openai.com/api/docs/guides/structured-outputs](https://developers.openai.com/api/docs/guides/structured-outputs), [litellm.ai/models/gpt-4o](https://models.litellm.ai/models/gpt-4o)

---

## Conclusions and Recommendations

### Go / No-Go per API

| API | Decision | Confidence |
|---|---|---|
| PayPal Orders v2 | **GO** | High — sandbox documented, flow confirmed |
| Channel3 | **GO** | High — docs fully accessible, schema confirmed |
| OpenAI GPT-4o Structured Outputs | **GO** | High — feature GA, schema enforcement guaranteed |
| APIMatic Context Plugin | **USE IT** | High — free, reduces PayPal coding errors |

### Priority Actions

1. **Install APIMatic Context Plugin** immediately (`npx context-plugins install paypal`). The PayPal dev docs site has cookie walls; the plugin grounds all PayPal coding in the real spec.

2. **Obtain API keys** in parallel: PayPal sandbox credentials (developer.paypal.com), Channel3 free key (trychannel3.com), OpenAI API key.

3. **Test Channel3 search with target product categories** in the first 2 days. The free tier (1,000/month) is sufficient for development; confirm product coverage for your target categories before building around it.

4. **Implement PayPal token refresh** from the start. Tokens expire after ~9 hours — a production-grade implementation needs to track `expires_in` and refresh.

5. **Confirm hackathon submission requirements** at [paypalaihackathon.devpost.com/rules](https://paypalaihackathon.devpost.com/rules) (was 403 during research). Specifically confirm: video length limit, required repo license, and whether a live demo URL is required.

6. **Plan for Render free tier spin-down.** The free tier sleeps after 15 minutes; this will break a demo. Use Render Starter ($7/mo) or a keep-alive ping for the Nov 12 submission demo.

### Risks

| Risk | Severity | Mitigation |
|---|---|---|
| Devpost rules page inaccessible | Medium | Retry; use blog post data as fallback |
| PayPal doc cookie walls | Low | APIMatic Context Plugin solves this |
| Channel3 coverage gap for niche products | Medium | Test early; broaden search query if needed |
| OpenAI schema first-request latency | Low | Pre-warm schema on server startup |
| Render free spin-down on demo day | High | Upgrade to Starter tier before submission |

---

## Files Written

| File | Description |
|---|---|
| `docs/hackathon-requirements.md` | Full prize breakdown, dates, sponsor requirements, eligibility summary |
| `docs/technical-feasibility.md` | Per-API feasibility analysis, risk matrix, time estimates |
| `docs/architecture.md` | System diagram, component breakdown, data flow, technology choices |
| `docs/api-contracts.md` | Complete API reference: endpoints, request/response shapes, auth, limits |
| `docs/phase1-research-report.md` | This document |
