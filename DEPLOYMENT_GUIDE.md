# BrainSAIT N8N Deployment Guide for Hosted Instance

**N8N Instance**: https://n8n.srv791040.hstgr.cloud

This guide will help you deploy the BrainSAIT Healthcare AI Agents to your existing N8N hosted instance.

## 🚀 Quick Start

### Step 1: Import Workflows

1. Navigate to your N8N instance: https://n8n.srv791040.hstgr.cloud/home/workflows
2. Click on **Import from File** or **Import from URL**
3. Import the following workflow files in order:

   - `workflows/01-masterlinc-orchestrator.json`
   - `workflows/02-healthcarelinc-workflow.json`
   - `workflows/03-clinicallinc-workflow.json`
   - `workflows/04-ttlinc-workflow.json`
   - `workflows/05-compliancelinc-workflow.json`
   - `workflows/06-patient-portal-workflow.json`
   - `workflows/07-insurance-claims-workflow.json`
   - `workflows/08-lab-results-notification.json`
   - `workflows/09-system-monitoring.json`

### Step 2: Configure Database

You'll need a PostgreSQL database. Use your existing database or set up a new one:

```bash
# Connect to your database
psql -h YOUR_DB_HOST -U YOUR_DB_USER -d YOUR_DB_NAME

# Run the schema file
\i schema.sql
```

### Step 3: Set Up Credentials in N8N

In your N8N instance, go to **Settings** → **Credentials** and add:

#### PostgreSQL Credentials
- **Name**: BrainSAIT PostgreSQL
- **Host**: Your PostgreSQL host
- **Database**: Your database name
- **User**: Your database user
- **Password**: Your database password
- **SSL**: Enabled (recommended)

#### Anthropic API (for Claude AI)
- **Name**: Anthropic Claude API
- **API Key**: Your Anthropic API key (get from https://console.anthropic.com)

#### SMTP (for Email Notifications)
- **Name**: BrainSAIT SMTP
- **Host**: smtp.gmail.com (or your SMTP server)
- **Port**: 587
- **User**: Your email
- **Password**: Your email password or app password

#### Slack (Optional - for Alerts)
- **Name**: BrainSAIT Slack
- **Access Token**: Your Slack bot token

#### NPHIES API (for Saudi Healthcare Integration)
- **Name**: NPHIES API Auth
- **Authentication Method**: Header Auth
- **Header Name**: Authorization
- **Value**: Bearer YOUR_NPHIES_API_KEY

### Step 4: Update Workflow Credentials

For each imported workflow:

1. Open the workflow
2. Click on each node that requires credentials
3. Select the credentials you created in Step 3
4. Save the workflow

### Step 5: Configure Environment Variables

In each workflow's **Code** nodes, update the environment references:

```javascript
// Replace these with your actual values:
const POSTGRES_HOST = 'your-db-host';
const NPHIES_API_URL = 'https://nphies.sa.gov/api/v2';
const ANTHROPIC_API_KEY = 'your-api-key';
// etc.
```

Or better yet, use N8N's **Environment Variables** feature:
1. Go to **Settings** → **Variables**
2. Add the following variables from `.env.example`

### Step 6: Activate Workflows

1. Open each workflow
2. Click the **Active** toggle in the top right
3. Test each webhook endpoint

### Step 7: Test Your Setup

#### Test MASTERLINC Orchestrator:
```bash
curl -X POST https://n8n.srv791040.hstgr.cloud/webhook/masterlinc/orchestrate \
  -H "Content-Type: application/json" \
  -d '{
    "agentType": "HEALTHCARELINC",
    "userRole": "provider",
    "payload": {
      "test": true
    },
    "auditContext": {
      "userId": "test-user-123",
      "sessionId": "test-session-456",
      "ipAddress": "127.0.0.1"
    }
  }'
```

#### Test Translation Service:
```bash
curl -X POST https://n8n.srv791040.hstgr.cloud/webhook/ttlinc/translate \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Patient has elevated blood pressure",
    "sourceLanguage": "en",
    "targetLanguage": "ar",
    "contentType": "CLINICAL_NOTE"
  }'
```

## 📋 Webhook URLs

After importing, your webhook URLs will be:

- **MASTERLINC**: `https://n8n.srv791040.hstgr.cloud/webhook/masterlinc/orchestrate`
- **HEALTHCARELINC**: `https://n8n.srv791040.hstgr.cloud/webhook/healthcarelinc/execute`
- **CLINICALLINC**: `https://n8n.srv791040.hstgr.cloud/webhook/clinicallinc/decision-support`
- **TTLINC**: `https://n8n.srv791040.hstgr.cloud/webhook/ttlinc/translate`
- **COMPLIANCELINC**: `https://n8n.srv791040.hstgr.cloud/webhook/compliancelinc/audit`
- **Patient Portal**: `https://n8n.srv791040.hstgr.cloud/webhook/patient-portal/:action`
- **Insurance Claims**: `https://n8n.srv791040.hstgr.cloud/webhook/insurance/claims/:action`

## 🔒 Security Recommendations

1. **Enable Authentication** on your N8N instance
2. **Use HTTPS** (already configured)
3. **Restrict webhook access** using N8N's authentication features
4. **Enable rate limiting** in your hosting provider
5. **Use strong credentials** for all services
6. **Enable database SSL** connections
7. **Regular backups** of your workflows and database

## 🗄️ Database Setup

### Required Tables

The `schema.sql` file will create all necessary tables. Key tables include:

- `audit_logs` - HIPAA compliance audit trail
- `patients` - Patient records (FHIR compatible)
- `appointments` - Appointment management
- `insurance_claims` - NPHIES claims tracking
- `lab_results` - Laboratory results
- `clinical_recommendations` - AI clinical decision support
- `translations` - Translation cache
- `compliance_reports` - Compliance monitoring

### Database Maintenance

```bash
# Backup
pg_dump -h YOUR_DB_HOST -U YOUR_DB_USER YOUR_DB_NAME > brainsait_backup_$(date +%Y%m%d).sql

# Restore
psql -h YOUR_DB_HOST -U YOUR_DB_USER YOUR_DB_NAME < brainsait_backup_20250115.sql
```

## 🧪 Testing Checklist

- [ ] Database connection successful
- [ ] All credentials configured
- [ ] MASTERLINC workflow active and responding
- [ ] HEALTHCARELINC workflow active
- [ ] CLINICALLINC workflow active with AI responses
- [ ] TTLINC translation working (Arabic ↔ English)
- [ ] COMPLIANCELINC audit logging functional
- [ ] Patient portal endpoints responding
- [ ] Insurance claims workflow processing
- [ ] Lab results notifications sending
- [ ] System monitoring alerts working
- [ ] Email notifications configured
- [ ] Slack alerts configured (if using)

## 📊 Monitoring

### Check Workflow Executions

1. Go to **Executions** in N8N
2. Monitor for errors
3. Review execution times
4. Check for failed workflows

### Database Monitoring

```sql
-- Check audit log entries
SELECT COUNT(*), event_type
FROM audit_logs
WHERE timestamp > NOW() - INTERVAL '24 hours'
GROUP BY event_type;

-- Check system health
SELECT COUNT(*) as total_patients FROM patients;
SELECT COUNT(*) as total_appointments FROM appointments WHERE start_time > NOW();
SELECT COUNT(*) as pending_claims FROM insurance_claims WHERE status = 'pending';
```

## 🆘 Troubleshooting

### Workflow Not Triggering
- Check if workflow is **Active**
- Verify webhook URL is correct
- Check N8N execution logs
- Verify authentication settings

### Database Connection Errors
- Verify credentials are correct
- Check database is accessible from N8N server
- Ensure SSL settings match
- Check firewall rules

### AI Responses Not Working
- Verify Anthropic API key is valid
- Check API quota/limits
- Review error messages in executions
- Test API key independently

### Translation Issues
- Verify source/target languages are supported
- Check for special characters in content
- Review translation quality settings

## 📚 Additional Resources

- **N8N Documentation**: https://docs.n8n.io
- **NPHIES Integration**: https://nphies.sa/documentation
- **FHIR R4 Specification**: https://hl7.org/fhir/R4/
- **BrainSAIT Support**: support@brainsait.com
- **GitHub Repository**: https://github.com/Fadil369/n8n-nodes-brainsait

## 🔄 Updates and Maintenance

To update workflows:
1. Export current workflow as backup
2. Import new workflow version
3. Migrate data if needed
4. Test thoroughly before activating

## 👨‍⚕️ Author

**Dr. Mohamed El Fadil**
- Email: fadil@brainsait.com
- Website: https://brainsait.com
- GitHub: @Fadil369

---

**Need Help?** Contact support@brainsait.com or create an issue on GitHub.
