# HubSpot Webhook Authentication

This document explains how webhook authentication works for HubSpot public apps.

## Key Points

1. **Public Apps Use Client Secret**: HubSpot public apps do NOT have a separate webhook secret. They use the app's client secret for webhook signature validation.

2. **Signature Header**: HubSpot sends the signature in the `X-HubSpot-Signature-v3` header.

3. **Validation Process**: The webhook server validates incoming webhooks using the client secret.

## Implementation Details

### Environment Variables

The webhook server uses the following environment variable:
- `HUBSPOT_CLIENT_SECRET`: The app's client secret (used for webhook validation)

### Validation Middleware

Located in `src/middleware/validation.js`:

```javascript
// For public apps, HubSpot uses the app's client secret for signing
const secret = process.env.HUBSPOT_CLIENT_SECRET || process.env.HUBSPOT_WEBHOOK_SECRET;
```

### Signature Calculation

The signature is calculated using:
1. HTTP method
2. Full request URI
3. Request body (JSON stringified)
4. Request timestamp

```javascript
const sourceString = method + uri + body + timestamp;
const hash = crypto.createHmac('sha256', secret)
  .update(sourceString, 'utf8')
  .digest('base64');
```

## Security Considerations

1. **Timestamp Validation**: Webhooks older than 5 minutes are rejected to prevent replay attacks.
2. **Secret Storage**: The client secret is stored in Google Secret Manager.
3. **HTTPS Only**: All webhook endpoints use HTTPS.

## Deployment Configuration

When deploying the webhook server, ensure:
1. The `HUBSPOT_CLIENT_SECRET` environment variable is set
2. The service account has access to the client secret in Google Secret Manager
3. The webhook URL in HubSpot matches your deployed server URL

## References

- [HubSpot Webhook Security Documentation](https://developers.hubspot.com/docs/api/webhooks/validating-requests)
- [HubSpot Public Apps Documentation](https://developers.hubspot.com/docs/api/working-with-oauth)