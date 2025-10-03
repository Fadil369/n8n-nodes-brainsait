# BrainSAIT N8N Workflows

This directory contains pre-built N8N workflow templates for the BrainSAIT Healthcare AI Agents system.

## 📦 Available Workflows

### 01-masterlinc-orchestrator.json
**MASTERLINC - Master Orchestrator Agent**

**Purpose**: Central routing and coordination hub for all agent requests.

**Features**:
- Role-based access control (RBAC)
- Request validation and sanitization
- Automatic audit logging
- Error handling and retry logic
- Response formatting and standardization

**Webhook Endpoint**: `/webhook/masterlinc/orchestrate`

**Use Cases**:
- Route requests to specialized agents
- Centralized authentication
- Unified audit logging
- Cross-agent coordination

**Dependencies**:
- PostgreSQL (for audit logs)
- None (works standalone)

**Setup Time**: 2 minutes

---

### 02-ttlinc-translation.json
**TTLINC - Translation & Localization Agent**

**Purpose**: Medical translation service with context awareness and medical terminology preservation.

**Features**:
- Arabic ↔ English translation
- Medical terminology preservation
- Context-aware translation
- RTL formatting for Arabic
- Quality scoring
- Translation caching

**Webhook Endpoint**: `/webhook/ttlinc/translate`

**Use Cases**:
- Translate clinical notes
- Translate lab results
- Translate prescriptions
- Translate patient communications
- Bilingual medical documentation

**Dependencies**:
- Anthropic Claude API (optional, for AI translation)
- PostgreSQL (optional, for caching)
- Works with demo data without any setup!

**Setup Time**: 30 seconds (no dependencies required for demo)

**Quick Test**:
```bash
curl -X POST https://your-n8n-instance.com/webhook/ttlinc/translate \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Patient has elevated blood pressure",
    "sourceLanguage": "en",
    "targetLanguage": "ar",
    "contentType": "CLINICAL_NOTE"
  }'
```

---

### 03-patient-portal-demo.json
**Patient Portal Demo Workflow**

**Purpose**: Patient-facing self-service portal for viewing appointments, lab results, and managing prescriptions.

**Features**:
- View appointments
- View lab results
- Request prescription refills
- Update contact information
- Bilingual interface (Arabic/English)
- Demo data included

**Webhook Endpoints**:
- `/webhook/patient-portal/view-appointments`
- `/webhook/patient-portal/view-lab-results`
- `/webhook/patient-portal/request-refill`
- `/webhook/patient-portal/update-profile`

**Use Cases**:
- Patient self-service
- Reduce administrative burden
- Improve patient engagement
- 24/7 access to health information

**Dependencies**:
- PostgreSQL (optional, uses demo data by default)
- SMTP (optional, for notifications)

**Setup Time**: 1 minute

**Quick Test**:
```bash
curl -X POST https://your-n8n-instance.com/webhook/patient-portal/view-appointments \
  -H "Content-Type: application/json" \
  -d '{
    "patientId": "demo-patient-001",
    "language": "en"
  }'
```

---

### 04-system-health-check.json
**System Health Monitoring Workflow**

**Purpose**: Automated monitoring and health checks for the BrainSAIT system.

**Features**:
- Database connection checks
- Workflow status monitoring
- API service health checks
- Performance metrics collection
- Automatic alerts
- Runs every 5 minutes

**Webhook Endpoint**: `/webhook/system-health/check`

**Monitoring Checks**:
- PostgreSQL database connectivity
- N8N workflow status
- External API availability (Anthropic, NPHIES, SMTP)
- Audit log completeness
- System uptime

**Use Cases**:
- Proactive monitoring
- Early problem detection
- System status dashboard
- Compliance monitoring

**Dependencies**:
- PostgreSQL (optional)
- Slack (optional, for alerts)
- Email/SMTP (optional, for alerts)

**Setup Time**: 3 minutes

**Quick Test**:
```bash
curl -X GET https://your-n8n-instance.com/webhook/system-health/check
```

---

## 🚀 Import Instructions

### Method 1: Import via N8N UI (Recommended)

1. Log in to your N8N instance
2. Click "+ Add Workflow" in the top-left
3. Click "Import from File"
4. Select one of the JSON files from this directory
5. Click "Import"
6. Save the workflow

### Method 2: Import via URL

1. In N8N, click "+ Add Workflow"
2. Click "Import from URL"
3. Enter the GitHub raw URL:
   ```
   https://raw.githubusercontent.com/Fadil369/n8n-nodes-brainsait/main/workflows/01-masterlinc-orchestrator.json
   ```
4. Click "Import"

### Method 3: Copy-Paste

1. Open the JSON file in a text editor
2. Copy the entire contents
3. In N8N, click "+ Add Workflow"
4. Click "Import from File" → "Select from Clipboard"
5. Paste the JSON content
6. Click "Import"

---

## ⚙️ Configuration

After importing workflows, you'll need to configure:

### For All Workflows:
1. **Activate the workflow**: Toggle the "Active" switch in the top-right
2. **Update webhook URLs**: If you changed the default webhook paths

### For Workflows with Database (01, 03, 04):
1. **Add PostgreSQL credentials**:
   - Go to Settings → Credentials
   - Add "PostgreSQL" credential
   - Fill in your database details
2. **Update workflow nodes** to use your credentials

### For Translation Workflow (02):
1. **Optional: Add Anthropic API key**:
   - Go to Settings → Credentials
   - Add "Anthropic API" credential
   - Enter your API key from https://console.anthropic.com
2. Works without API key using demo data!

### For System Health Workflow (04):
1. **Optional: Add notification credentials**:
   - Slack webhook (for Slack alerts)
   - SMTP credentials (for email alerts)

---

## 📊 Workflow Dependencies

| Workflow | PostgreSQL | Anthropic API | SMTP | Slack | Works Standalone? |
|----------|------------|---------------|------|-------|-------------------|
| 01-masterlinc | Optional | No | No | No | ✅ Yes |
| 02-ttlinc | Optional | Optional | No | No | ✅ Yes |
| 03-patient-portal | Optional | No | Optional | No | ✅ Yes (demo data) |
| 04-system-health | Optional | No | Optional | Optional | ✅ Yes |

---

## 🧪 Testing Workflows

### Test Order (Recommended):

1. **Start with 02-ttlinc-translation.json**
   - No dependencies required
   - Works immediately
   - Quick to test
   
2. **Then 03-patient-portal-demo.json**
   - Uses demo data
   - No database required
   - Shows patient features
   
3. **Then 04-system-health-check.json**
   - Monitors other workflows
   - Optional notifications
   
4. **Finally 01-masterlinc-orchestrator.json**
   - Central router
   - Coordinates other agents

### Test Commands:

```bash
# Test TTLINC Translation
curl -X POST https://your-n8n.com/webhook/ttlinc/translate \
  -H "Content-Type: application/json" \
  -d '{"content": "Test", "sourceLanguage": "en", "targetLanguage": "ar", "contentType": "CLINICAL_NOTE"}'

# Test Patient Portal
curl -X POST https://your-n8n.com/webhook/patient-portal/view-appointments \
  -H "Content-Type: application/json" \
  -d '{"patientId": "demo-patient-001", "language": "en"}'

# Test System Health
curl -X GET https://your-n8n.com/webhook/system-health/check

# Test MASTERLINC
curl -X POST https://your-n8n.com/webhook/masterlinc/orchestrate \
  -H "Content-Type: application/json" \
  -d '{"agentType": "TTLINC", "userRole": "provider", "payload": {"test": true}}'
```

---

## 🔍 Workflow Details

### Workflow Structure:

Each workflow follows this pattern:

```
Webhook Trigger
    ↓
Input Validation
    ↓
Business Logic
    ↓
Database Operations (if needed)
    ↓
Response Formatting
    ↓
Audit Logging
    ↓
Return Response
```

### Node Types Used:

- **Webhook**: HTTP endpoint trigger
- **Function**: JavaScript/TypeScript logic
- **PostgreSQL**: Database operations
- **HTTP Request**: External API calls
- **Set**: Data transformation
- **IF**: Conditional logic
- **Switch**: Multi-way branching

---

## 🛠️ Customization

### Common Customizations:

1. **Change Webhook URLs**:
   - Open workflow
   - Click Webhook node
   - Update "Path" field

2. **Add Authentication**:
   - Click Webhook node
   - Enable "Authentication"
   - Choose method (Basic, Header, etc.)

3. **Modify Response Format**:
   - Edit the final Function/Set node
   - Update the JSON structure

4. **Add Custom Logic**:
   - Add Function nodes
   - Write JavaScript/TypeScript
   - Access input with `$json`

5. **Connect to Your Database**:
   - Update PostgreSQL nodes
   - Point to your database
   - Update table/column names if needed

---

## 📚 Documentation

For detailed usage examples and API documentation, see:

- **[EXAMPLES.md](../EXAMPLES.md)** - 50+ usage examples
- **[API_REFERENCE.md](../API_REFERENCE.md)** - Complete API docs
- **[DEPLOYMENT_GUIDE.md](../DEPLOYMENT_GUIDE.md)** - Deployment instructions
- **[TROUBLESHOOTING.md](../TROUBLESHOOTING.md)** - Common issues

---

## 🆘 Troubleshooting

### Workflow Not Triggering?
- Check if workflow is Active (toggle should be ON)
- Verify webhook URL is correct
- Check N8N execution logs

### Node Errors?
- Check if credentials are configured
- Verify external services are accessible
- Review node error messages

### Database Errors?
- Ensure PostgreSQL is running
- Check database credentials
- Verify schema is installed (`schema.sql`)

For more help, see [TROUBLESHOOTING.md](../TROUBLESHOOTING.md)

---

## 🔐 Security Notes

### Production Recommendations:

1. **Enable Authentication**:
   - Use Basic Auth or Header Auth
   - Never expose webhooks publicly without auth

2. **Use HTTPS**:
   - Always use TLS/SSL in production
   - Configure SSL certificates

3. **Secure Database**:
   - Use strong passwords
   - Enable SSL connections
   - Restrict network access

4. **Audit Logging**:
   - Enable audit logging for compliance
   - Regularly review logs
   - Archive old logs

---

## 📈 Performance Tips

1. **Caching**: Enable caching for translation service
2. **Database Indexes**: Ensure indexes are created (see `schema.sql`)
3. **Connection Pooling**: Use PgBouncer for PostgreSQL
4. **Batch Processing**: Process multiple items together when possible
5. **Timeout Settings**: Adjust workflow timeouts for long-running operations

---

## 🔄 Versioning

These workflows are version controlled:

- **Current Version**: 1.0.1
- **Compatible N8N Version**: 1.0.0+
- **Last Updated**: January 2025

Check [CHANGELOG.md](../CHANGELOG.md) for version history.

---

## 📞 Support

Having issues with workflows?

1. Check [TROUBLESHOOTING.md](../TROUBLESHOOTING.md)
2. Review N8N execution logs
3. Search [GitHub Issues](https://github.com/Fadil369/n8n-nodes-brainsait/issues)
4. Contact: support@brainsait.com

---

**Built with ❤️ for the healthcare community**

https://brainsait.com
