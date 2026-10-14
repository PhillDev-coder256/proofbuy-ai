# API Contracts

## ProofBuy AI — External API Reference

*Content was rephrased for compliance with licensing restrictions*

Sources: [docs.trychannel3.com](https://docs.trychannel3.com), [developer.paypal.com](https://developer.paypal.com), [developers.openai.com](https://developers.openai.com/api/docs/guides/structured-outputs)

---

## 1. PayPal Orders v2

### Base URLs

| Environment | Base URL |
|---|---|
| Sandbox | `https://api-m.sandbox.paypal.com` |
| Live | `https://api.paypal.com` |

---

### OAuth2 Token

```
POST {base}/v1/oauth2/token
Authorization: Basic base64(CLIENT_ID:CLIENT_SECRET)
Content-Type: application/x-www-form-urlencoded

Body: grant_type=client_credentials
```

**Response:**
```json
{
  "access_token": "A21AAFEpH4PsADblkuuu...",
  "token_type": "Bearer",
  "expires_in": 32400
}
```

- Token is valid for ~9 hours (`expires_in` seconds). Cache and refresh before expiry.
- All subsequent calls use `Authorization: Bearer <access_token>`.

---

### Create Order

```
POST {base}/v2/checkout/orders
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request body:**
```json
{
  "intent": "CAPTURE",
  "purchase_units": [
    {
      "amount": {
        "currency_code": "USD",
        "value": "29.99"
      },
      "description": "Sony WH-1000XM5 Headphones"
    }
  ],
  "application_context": {
    "return_url": "https://example.com/success",
    "cancel_url": "https://example.com/cancel"
  }
}
```

**Response (HTTP 201):**
```json
{
  "id": "5O190127TN364715T",
  "status": "CREATED",
  "links": [
    {
      "href": "https://api-m.sandbox.paypal.com/v2/checkout/orders/5O190127TN364715T",
      "rel": "self",
      "method": "GET"
    },
    {
      "href": "https://www.sandbox.paypal.com/checkoutnow?token=5O190127TN364715T",
      "rel": "approve",
      "method": "GET"
    },
    {
      "href": "https://api-m.sandbox.paypal.com/v2/checkout/orders/5O190127TN364715T/capture",
      "rel": "capture",
      "method": "POST"
    }
  ]
}
```

**Key points:**
- `id` is the order ID used in all subsequent calls.
- `links[rel=approve].href` is the buyer approval URL. With the PayPal JS SDK, this URL is used automatically in the popup flow.
- `intent` values: `CAPTURE` (immediate) or `AUTHORIZE` (hold funds, capture later up to 29 days).

---

### Capture Order

After the buyer approves via the `rel:approve` URL:

```
POST {base}/v2/checkout/orders/{order_id}/capture
Authorization: Bearer <access_token>
Content-Type: application/json

Body: {} (empty or omit)
```

**Response (HTTP 201):**
```json
{
  "id": "5O190127TN364715T",
  "status": "COMPLETED",
  "purchase_units": [
    {
      "payments": {
        "captures": [
          {
            "id": "3C679366HH908993F",
            "status": "COMPLETED",
            "amount": {
              "currency_code": "USD",
              "value": "29.99"
            },
            "final_capture": true,
            "seller_protection": {
              "status": "ELIGIBLE"
            }
          }
        ]
      }
    }
  ]
}
```

---

### Order Status Values

| Status | Meaning |
|---|---|
| `CREATED` | Order created, awaiting buyer approval |
| `SAVED` | Order saved (not started) |
| `APPROVED` | Buyer approved, awaiting merchant capture |
| `VOIDED` | Order cancelled/voided |
| `COMPLETED` | Payment captured successfully |
| `PAYER_ACTION_REQUIRED` | Buyer must take additional action |

---

### Server-Side Payment Verification

To verify a completed payment, call GET on the order:

```
GET {base}/v2/checkout/orders/{order_id}
Authorization: Bearer <access_token>
```

Check:
1. `response.status === "COMPLETED"`
2. `response.purchase_units[0].payments.captures[0].status === "COMPLETED"`
3. Amount matches expected value

Never trust client-provided confirmation alone — always verify server-side.

---

## 2. Channel3 API

Base URL: `https://api.trychannel3.com` (inferred from SDK; confirm in dashboard)
Documentation: [docs.trychannel3.com](https://docs.trychannel3.com)

---

### Authentication

```
x-api-key: <your_api_key>
```
or
```
Authorization: Bearer <your_api_key>
```

- **Anonymous tier** (no key): lower rate limits, no monetization on buy links.
- **Token tier** (with key): higher rate limits, buy links attributed to your account for commission.
- A missing or invalid key falls back to anonymous limits (no 401 error).

---

### Search Products

```
POST /v1/search
x-api-key: <key>
Content-Type: application/json
```

**Request body:**
```json
{
  "query": "Sony WH-1000XM5 headphones",
  "limit": 10,
  "filters": {
    "availability": ["InStock"],
    "conditions": ["new"],
    "price": {
      "min_price": 200,
      "max_price": 450
    }
  }
}
```

Available filter fields:
- `price`: `{ min_price?, max_price? }` — in request currency
- `availability`: `["InStock", "LimitedAvailability", "PreOrder", "BackOrder", "SoldOut", "OutOfStock"]`
- `gender`: `"male"`, `"female"`, `"unisex"`
- `category`: category slug string (e.g. `"running-shoes"`)
- `brand_ids`: array of brand ID strings
- `colors`: `[{ hex: "#ff0000", percentage?: 0.3 }]` (beta)
- `age`: `"newborn"`, `"infant"`, `"toddler"`, `"kids"`, `"adult"`
- `dimensions`: `{ length?, width?, height?, weight? }` each `{ min?, max?, unit }`
- `attributes`: `Record<string, string[]>` for category-specific structured attributes

**Response:**
```json
{
  "products": [
    {
      "id": "prod_abc123",
      "title": "Sony WH-1000XM5 Wireless Headphones",
      "description": "Industry-leading noise canceling...",
      "brands": [
        { "id": "brand_sony", "name": "Sony" }
      ],
      "images": [
        { "url": "https://cdn.channel3.com/images/..." }
      ],
      "category": {
        "slug": "over-ear-headphones",
        "title": "Over-Ear Headphones",
        "has_children": false,
        "path": [
          { "slug": "electronics", "title": "Electronics" },
          { "slug": "audio", "title": "Audio" }
        ]
      },
      "key_features": ["Noise Canceling", "Bluetooth 5.2", "30hr battery"],
      "materials": [],
      "gender": null,
      "age": "adult",
      "offers": [
        {
          "url": "https://channel3.com/buy/track/...",
          "domain": "amazon.com",
          "price": {
            "price": 279.99,
            "currency": "USD",
            "compare_at_price": 349.99
          },
          "availability": "InStock",
          "condition": "new",
          "max_commission_rate": 0.04,
          "dimensions": {
            "length": { "number": 250, "unit": "mm" },
            "width": { "number": 200, "unit": "mm" },
            "height": { "number": 80, "unit": "mm" },
            "weight": { "number": 254000, "unit": "mg" }
          }
        }
      ],
      "variants": {
        "options": [
          {
            "name": "Color",
            "values": [
              { "label": "Black", "exists": true, "available": "InStock", "product_id": "prod_abc123" },
              { "label": "Silver", "exists": true, "available": "InStock", "product_id": "prod_abc124" }
            ]
          }
        ],
        "selected": [
          { "name": "Color", "label": "Black" }
        ]
      },
      "structured_attributes": {
        "connectivity": ["Bluetooth"],
        "driver_size": ["30mm"]
      }
    }
  ],
  "next_page_token": "eyJwYWdlIjogMn0="
}
```

**Pagination:** pass `next_page_token` from response into next request body. Max 500 products total. Each page costs 1 credit.

---

### Lookup Product by ID

```
POST /v1/lookup
x-api-key: <key>
Content-Type: application/json
```

```json
{ "product_id": "prod_abc123" }
```

Returns a single product with the same schema as a search result.

---

### Rate Limits

| Plan | Most endpoints | Search/image-search | Lookup | Daily quota |
|---|---|---|---|---|
| default (free) | 10 req/s | 10 req/s | 5 req/s | 10,000 |
| plus | 25 req/s | 15 req/s | 5 req/s | 250,000 |
| high | 40 req/s | 25 req/s | 10 req/s | 1,000,000 |
| no-limit | 60 req/s | 40 req/s | 15 req/s | none |

On rate limit: HTTP 429 with `Retry-After: 5`. New API keys start on default tier.
Free tier: **1,000 credits/month**.

---

### Locale / Currency

Pass in request body:
```json
{
  "query": "...",
  "country": "US",
  "language": "en",
  "currency": "USD"
}
```

Supported countries: US, CA, GB, IE, AU, DE, AT, FR, BE, IT, ES, NL, SE, FI, PT, CZ, GR, RO, EU
Supported currencies: USD, CAD, AUD, GBP, EUR, SEK, CZK, RON

---

### Price Tracking (Webhook)

```
POST /v0/price-tracking/start
x-api-key: <key>

{ "product_id": "prod_abc123" }
```

Configure webhook URL in Channel3 dashboard. Channel3 sends `POST` to your endpoint with:
```json
{
  "product_id": "prod_abc123",
  "new_price": 259.99,
  "currency": "USD",
  "timestamp": "2026-10-15T14:32:00Z"
}
```

---

## 3. OpenAI GPT-4o Structured Outputs

### Endpoint

```
POST https://api.openai.com/v1/responses
Authorization: Bearer <OPENAI_API_KEY>
Content-Type: application/json
```

(Also supported: `POST /v1/chat/completions` with same `response_format` parameter)

---

### Request Shape (Responses API)

```json
{
  "model": "gpt-4o-2024-08-06",
  "input": [
    {
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "Extract purchase details from this receipt."
        },
        {
          "type": "input_image",
          "image_url": "data:image/jpeg;base64,<base64_image>"
        }
      ]
    }
  ],
  "text": {
    "format": {
      "type": "json_schema",
      "name": "proof_extraction",
      "strict": true,
      "schema": {
        "type": "object",
        "properties": {
          "item_name": { "type": "string" },
          "price_paid": { "type": "number" },
          "currency": { "type": "string", "enum": ["USD", "GBP", "EUR", "CAD", "AUD"] },
          "purchase_date": { "type": "string", "description": "ISO 8601 date" },
          "merchant": { "type": "string" }
        },
        "required": ["item_name", "price_paid", "currency", "purchase_date", "merchant"],
        "additionalProperties": false
      }
    }
  }
}
```

---

### Response

```json
{
  "id": "resp_abc123",
  "object": "response",
  "status": "completed",
  "output": [
    {
      "type": "message",
      "content": [
        {
          "type": "output_text",
          "text": "{\"item_name\": \"Sony WH-1000XM5\", \"price_paid\": 329.99, \"currency\": \"USD\", \"purchase_date\": \"2025-03-14\", \"merchant\": \"Best Buy\"}"
        }
      ]
    }
  ]
}
```

Parse `response.output[0].content[0].text` as JSON.

---

### Handling Refusals

If the model refuses (safety or irrelevant input):
```json
{
  "type": "refusal",
  "refusal": "I'm sorry, I cannot assist with that request."
}
```

Check `content[0].type === "refusal"` before parsing as JSON.

---

### Key Constraints

| Constraint | Value |
|---|---|
| Model support | `gpt-4o-2024-08-06`+, `gpt-4o-mini-2024-07-18`+ |
| Schema object properties | Max 5,000 total |
| Nesting depth | Max 10 levels |
| Enum values | Max 1,000 total across schema |
| Root schema type | Must be `object` (not `anyOf` at root) |
| First-request latency | Higher (schema processing cache miss) |
| Subsequent requests | Normal latency |

---

### Cost Reference (as of October 2026)

| Token type | Price |
|---|---|
| Input (standard) | $2.50 / 1M tokens |
| Output | $10.00 / 1M tokens |
| Cached input reads | $1.25 / 1M tokens |

**Rough per-call cost for proof extraction (500 input + 100 output tokens):**
`(500 × $2.50 + 100 × $10.00) / 1,000,000 ≈ $0.0022`

Source: [litellm.ai/models/gpt-4o](https://models.litellm.ai/models/gpt-4o) (Oct 2026)

---

## 4. APIMatic Context Plugin (PayPal)

Not a runtime API dependency — it is a development-time tool.

**Install:**
```bash
npx context-plugins install paypal
```

Installs into Claude Code, Cursor, VS Code, Codex (whichever is detected on the machine). Grounds AI coding assistance in the PayPal API spec, reducing hallucinated endpoint names and auth flows.

**Hackathon benefit:** Winning teams that used the plugin receive 6 months of APIMatic Business free (covers Context Plugins, SDKs, Documentation portal).

Source: [context.apimatic.io/plugins/paypal](https://context.apimatic.io/plugins/paypal), [paypalaihackathon.devpost.com/details/apimatic](https://paypalaihackathon.devpost.com/details/apimatic)
