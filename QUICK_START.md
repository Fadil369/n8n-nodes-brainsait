# Quick Start Guide - BrainSAIT N8N Workflows

Get started with BrainSAIT Healthcare AI Agents in 5 minutes!

## 🚀 For Your Hosted N8N Instance

**Your N8N URL**: https://n8n.srv791040.hstgr.cloud

### Step 1: Import Workflows (2 minutes)

1. **Log in to your N8N instance**
   - Go to: https://n8n.srv791040.hstgr.cloud
   - Log in with your credentials

2. **Import the workflows**
   - Click "+ Add Workflow" button
   - Select "Import from URL" or "Import from File"
   - Import these workflows in order:

   **Start with these 2 workflows (no database required):**
   - `01-masterlinc-orchestrator.json` - Main routing agent
   - `02-ttlinc-translation.json` - Translation service (works immediately!)

   **Optional (for testing):**
   - `03-patient-portal-demo.json` - Demo patient portal
   - `04-system-health-check.json` - System monitoring

### Step 2: Activate Workflows (1 minute)

1. Open each imported workflow
2. Click the **"Active"** toggle in the top right
3. Save the workflow

### Step 3: Test It! (2 minutes)

#### Test Translation Service (No database needed!)

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

**Expected Response:**
```json
{
  "success": true,
  "requestId": "TTLINC-...",
  "translation": {
    "original": "Patient has elevated blood pressure",
    "translated": "المريض لديه ضغط الدم مرتفع",
    "sourceLanguage": "en",
    "targetLanguage": "ar"
  },
  "quality": {
    "score": 85,
    "contentType": "CLINICAL_NOTE"
  },
  "messages": {
    "en": "Translation completed successfully",
    "ar": "تمت الترجمة بنجاح"
  }
}
```

#### Test Patient Portal (Demo Data)

```bash
curl -X POST https://n8n.srv791040.hstgr.cloud/webhook/patient-portal/view-appointments \
  -H "Content-Type: application/json" \
  -d '{
    "patientId": "demo-patient-001",
    "language": "en"
  }'
```

#### Test System Health

The health check workflow runs automatically every 5 minutes!
Check your N8N executions to see the results.

## 📊 What You Get

### Immediate Features (No Database Required):
- ✅ **TTLINC Translation** - Arabic ↔ English medical translation
- ✅ **Patient Portal Demo** - View appointments, lab results (demo data)
- ✅ **System Health Checks** - Automatic monitoring every 5 minutes
- ✅ **MASTERLINC Router** - Central orchestration

### With Database (Optional):
- 🔐 HIPAA-compliant audit logging
- 👥 User management and authentication
- 📋 Real patient records (FHIR R4)
- 💊 Clinical decision support
- 🏥 Insurance claims (NPHIES integration)
- 📧 Lab results notifications

## 🗄️ Optional: Setup Database

If you want full functionality:

### 1. Get PostgreSQL Database

You can use:
- Your existing PostgreSQL server
- Free tier from [Supabase](https://supabase.com) (includes free PostgreSQL)
- [ElephantSQL](https://www.elephantsql.com/) free tier
- [Neon](https://neon.tech/) free tier

### 2. Run Schema Setup

```bash
# Download schema file
wget https://raw.githubusercontent.com/Fadil369/n8n-nodes-brainsait/main/schema.sql

# Connect and run
psql -h YOUR_DB_HOST -U YOUR_DB_USER -d YOUR_DB_NAME -f schema.sql
```

### 3. Add Database Credentials in N8N

1. Go to **Settings** → **Credentials**
2. Click **"+ Add Credential"**
3. Search for "Postgres"
4. Fill in your database details
5. Test connection
6. Save as "BrainSAIT PostgreSQL"

## 🎯 Next Steps

1. **Customize Workflows**
   - Edit the translation service for your needs
   - Modify patient portal actions
   - Add your own agents

2. **Connect to AI Services** (Optional)
   - Add Anthropic Claude API for advanced translations
   - Integrate OpenAI for additional features

3. **Set Up Notifications** (Optional)
   - Configure Email (SMTP)
   - Set up Slack alerts
   - Enable SMS notifications

4. **Production Deployment**
   - Set up proper authentication
   - Configure rate limiting
   - Enable SSL/TLS
   - Set up backups

## 📚 Documentation

- **Full README**: [README.md](README.md)
- **Deployment Guide**: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **Contributing**: [CONTRIBUTING.md](CONTRIBUTING.md)
- **GitHub Repository**: https://github.com/Fadil369/n8n-nodes-brainsait

## 🆘 Troubleshooting

### Workflow not triggering?
- Check if workflow is **Active** (toggle should be ON)
- Verify your webhook URL matches
- Check N8N execution logs

### Translation not working?
- Make sure you're sending valid JSON
- Check supported languages: 'en' and 'ar'
- Verify content is not empty

### Need Help?
- **Email**: fadil@brainsait.com
- **GitHub Issues**: https://github.com/Fadil369/n8n-nodes-brainsait/issues
- **Documentation**: https://brainsait.com

## ⚡ Pro Tips

1. **Test in Browser**
   - Use Postman or Insomnia for API testing
   - Great for debugging workflows

2. **Check Executions**
   - N8N saves all workflow executions
   - Use them to debug issues

3. **Start Simple**
   - Begin with translation service
   - Add features incrementally
   - Test each workflow individually

4. **Monitor Performance**
   - Enable the health check workflow
   - Review execution times
   - Optimize slow workflows

---

**Built with ❤️ by Dr. Mohamed El Fadil**
**BrainSAIT - Healthcare AI for Everyone**

https://brainsait.com
