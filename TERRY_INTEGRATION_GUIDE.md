# Terry Integration Guide - AI System Monitoring for BrainSAIT

![Terry AI Agent](https://img.shields.io/badge/AI-Terry%20Agent-blue)
![Healthcare](https://img.shields.io/badge/Healthcare-HIPAA%20Compliant-green)

## Overview

This guide integrates the concepts from [NetworkChuck's n8n-terry-guide](https://github.com/theNetworkChuck/n8n-terry-guide) with BrainSAIT's healthcare AI workflows, creating an intelligent healthcare system monitoring agent that follows HIPAA compliance standards.

**Terry** is an AI agent built with n8n that can:
- **Monitor** healthcare services 24/7
- **Troubleshoot** issues by analyzing logs and system metrics
- **Alert** administrators when intervention is needed
- **Request approval** before making any system changes
- **Maintain audit logs** for HIPAA compliance

---

## 🎯 Philosophy

> "You're training an employee, not programming a bot."

Terry learns your healthcare infrastructure and processes, adapting to your specific environment while maintaining strict compliance standards.

---

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Terry Workflow (05-terry-system-monitor.json)](#terry-workflow)
- [Healthcare-Specific Monitoring](#healthcare-specific-monitoring)
- [Integration with BrainSAIT Agents](#integration-with-brainsait-agents)
- [Advanced Configuration](#advanced-configuration)
- [Human-in-the-Loop Approval](#human-in-the-loop-approval)
- [Notification Setup](#notification-setup)
- [Security & Compliance](#security--compliance)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

---

## Prerequisites

- n8n instance (v1.0.0+)
- BrainSAIT workflows installed
- OpenAI API key (or compatible LLM like Claude)
- PostgreSQL database (for audit logs)
- Optional: Telegram or Slack for notifications
- Optional: SSH access to monitored systems

---

## Quick Start

### 1. Import Terry Workflow

```bash
# In n8n UI:
# 1. Go to Workflows
# 2. Click "Import from File"
# 3. Select: workflows/05-terry-system-monitor.json
# 4. Click "Import"
```

### 2. Configure AI Agent

1. Open the imported workflow
2. Click on the "AI Agent - Terry" node
3. Configure:
   - **Chat Model**: Select your LLM (GPT-4o-mini, GPT-4, or Claude)
   - **Memory**: Simple Memory (already configured)
   - **System Message**: Pre-configured for healthcare monitoring

### 3. Add Credentials

Add these credentials in n8n:

**OpenAI Credentials:**
- Go to Settings → Credentials
- Add "OpenAI API"
- Enter your API key from https://platform.openai.com

**PostgreSQL (for audit logs):**
- Add "PostgreSQL" credential
- Fill in database details from your `.env` file

### 4. Activate and Test

1. Toggle "Active" switch in top-right
2. Click "Execute Workflow" to test manually
3. Terry will perform initial health check

---

## Terry Workflow

### Workflow Structure

The `05-terry-system-monitor.json` workflow follows this pattern:

```
Schedule Trigger (every 5 minutes)
    ↓
Edit Fields (set prompt & chatId)
    ↓
AI Agent - Terry (analyzes system health)
    ↓
IF Needs Approval
    ├─ True → Request Human Approval (via Telegram)
    └─ False → Continue
         ↓
    Switch - Notification Logic
         ├─ Issues Found → Send Alert
         ├─ All Healthy → No notification
         └─ Default → Log event
              ↓
         Format Notification
              ↓
         Audit Log
```

### Key Components

#### 1. Schedule Trigger
- Runs every 5 minutes (configurable)
- Can be changed to hourly, daily, or custom intervals
- Can be disabled for manual-only mode

#### 2. AI Agent Configuration

**System Prompt Features:**
- Healthcare-specific monitoring focus
- HIPAA compliance checks
- Permission rules (human-in-the-loop)
- Structured JSON output
- Security-first approach

**Terry's Capabilities:**
- Service health checks (webhooks, APIs, databases)
- Resource monitoring (CPU, memory, disk)
- Database connectivity verification
- Audit log integrity checks
- Security compliance scanning

#### 3. Tools Available

**HTTP Health Check Tool:**
- Tests webhook endpoints
- Verifies API responses
- Checks service availability
- Measures response times

**Simple Memory:**
- Maintains conversation context
- Remembers past issues
- Learns from resolutions
- Session-based with unique chatId

---

## Healthcare-Specific Monitoring

### Services Terry Monitors

#### 1. **MASTERLINC Orchestrator**
```bash
# Test endpoint
curl -X POST https://your-n8n.com/webhook/masterlinc/orchestrate \
  -H "Content-Type: application/json" \
  -d '{"agentType": "HEALTHCARELINC", "userRole": "admin", "payload": {}}'
```

Terry checks:
- Endpoint availability
- Response time (< 2 seconds)
- Correct routing logic
- Audit log creation

#### 2. **TTLINC Translation Service**
```bash
# Test endpoint
curl -X POST https://your-n8n.com/webhook/ttlinc/translate \
  -H "Content-Type: application/json" \
  -d '{"content": "Patient has fever", "sourceLanguage": "en", "targetLanguage": "ar"}'
```

Terry checks:
- Translation accuracy
- Medical terminology preservation
- RTL formatting (for Arabic)
- Response format validity

#### 3. **Patient Portal**
```bash
# Test endpoint
curl -X POST https://your-n8n.com/webhook/patient-portal/view-appointments \
  -H "Content-Type: application/json" \
  -d '{"patientId": "demo-001", "language": "en"}'
```

Terry checks:
- Patient authentication
- Data privacy compliance
- Response encryption (if configured)
- Session management

#### 4. **System Health Monitoring**
```bash
# Test endpoint
curl -X GET https://your-n8n.com/webhook/system-health/check
```

Terry checks:
- Database connection
- Disk space availability
- Memory usage
- Active workflow count

#### 5. **PostgreSQL Database**

Terry verifies:
- Connection pool status
- Query performance
- Audit log table size
- Backup status (if configured)
- Replication lag (if applicable)

---

## Integration with BrainSAIT Agents

### Enhanced Monitoring Prompts

#### Basic Health Check
```
"Check if all BrainSAIT healthcare services are operational"
```

#### Specific Service Check
```
"Check the TTLINC translation service and verify it's responding correctly"
```

#### Comprehensive Audit
```
"Perform a full system health check including database, all webhooks, and audit logs"
```

#### Proactive Investigation
```
"Check if there are any warning signs in the system logs that could indicate future issues"
```

### Custom Monitoring Rules

Edit the `Edit Fields` node to add specific checks:

```javascript
{
  "prompt": "Check MASTERLINC orchestrator and verify HIPAA audit logs are being created",
  "chatId": "terry-healthcare-monitor",
  "priority": "high",
  "services": ["MASTERLINC", "audit_logs"]
}
```

---

## Advanced Configuration

### Multi-Stage Monitoring

#### Stage 1: Basic Monitor (Default)
Terry checks if services are up and responding.

#### Stage 2: Smart Investigator
Add SSH tool to investigate system issues:

1. **Create SSH Subworkflow:**
   - Add SSH node
   - Convert to subworkflow
   - Configure command variable
   - Add to Terry's tools

2. **Update System Prompt:**
```
When investigating issues, use the SSH tool to:
- Check container status: docker ps -a
- View recent logs: docker logs <container> --tail 20
- Check disk space: df -h
- Check memory: free -h
- Verify processes: ps aux | grep n8n
```

#### Stage 3: The Fixer (with Human Approval)
Enable Terry to propose and execute fixes:

**Update System Prompt:**
```
If you identify an issue, propose specific commands to fix it.
ALWAYS request approval before executing any commands that modify the system.

Example fixes:
- Restart crashed service: docker restart <container>
- Clear cache: docker system prune -f
- Restart workflow: n8n workflow:activate <workflow-id>
```

#### Stage 4: Predictive Monitoring
Add trend analysis:

```javascript
// In a Function node before Terry
const recentMetrics = [
  { timestamp: Date.now(), cpu: 45, memory: 60, disk: 70 },
  // ... historical data
];

// Terry analyzes trends
"Analyze these metrics and predict if we'll have issues in the next 24 hours"
```

---

## Human-in-the-Loop Approval

### Implementation Steps

#### 1. Add Approval Logic

After the AI Agent node, add:

```javascript
// IF node condition
if ($json.needs_approval === true) {
  // Route to approval flow
} else {
  // Route to notification
}
```

#### 2. Telegram Approval Setup

**Create Telegram Bot:**
1. Open Telegram, search for "BotFather"
2. Send `/newbot`
3. Follow instructions
4. Copy API token

**Get Your Chat ID:**
1. Start chat with your bot
2. Message: [@userinfobot](https://t.me/userinfobot)
3. Copy your Chat ID

**Configure in n8n:**
1. Add Telegram node
2. Operation: "Send and wait for response"
3. Response Type: "Approval"
4. Message template:

```
🚨 TERRY NEEDS APPROVAL 🚨

System: {{ $json.message }}

Recommended Action:
{{ $json.recommended_actions }}

Services Affected:
{{ $json.services_checked.join(', ') }}

Do you approve this action?
```

#### 3. Process Approval Response

Add Edit Fields node after Telegram:
```javascript
{
  "approved": "={{ $json.approved }}",
  "prompt": "Execute the approved action: {{ $('AI Agent - Terry').json.recommended_actions }}",
  "chatId": "terry-healthcare-monitor"
}
```

Connect back to AI Agent to create approval loop.

---

## Notification Setup

### Telegram Notifications

**Simple Alert:**
```javascript
// Telegram node configuration
{
  "chatId": "YOUR_CHAT_ID",
  "text": "⚠️ {{ $json.summary }}"
}
```

**Rich Alert with Actions:**
```javascript
{
  "chatId": "YOUR_CHAT_ID",
  "text": "🏥 BrainSAIT System Alert\n\n{{ $json.summary }}",
  "replyMarkup": {
    "inline_keyboard": [
      [{"text": "View Details", "url": "https://your-n8n.com/workflow/123"}],
      [{"text": "Acknowledge", "callback_data": "ack"}]
    ]
  }
}
```

### Slack Notifications

```javascript
// Slack node configuration
{
  "channel": "#healthcare-alerts",
  "text": ":warning: BrainSAIT Health Alert",
  "attachments": [
    {
      "color": "danger",
      "title": "System Status",
      "text": "{{ $json.message }}",
      "fields": [
        {
          "title": "Services Checked",
          "value": "{{ $json.services_checked.join(', ') }}"
        }
      ]
    }
  ]
}
```

### Email Notifications

```javascript
// Email node configuration
{
  "to": "admin@brainsait.com",
  "subject": "BrainSAIT System Alert - {{ $json.all_services_healthy ? 'Healthy' : 'Issues Detected' }}",
  "html": `
    <h2>System Health Report</h2>
    <p><strong>Status:</strong> {{ $json.all_services_healthy ? '✅ All Healthy' : '⚠️ Issues Found' }}</p>
    <p><strong>Message:</strong> {{ $json.message }}</p>
    <h3>Services Checked:</h3>
    <ul>
      {{ $json.services_checked.map(s => '<li>' + s + '</li>').join('') }}
    </ul>
  `
}
```

---

## Security & Compliance

### HIPAA Compliance

Terry maintains compliance through:

1. **Audit Logging**: All monitoring actions logged
2. **Access Control**: Requires authentication for sensitive operations
3. **Data Privacy**: No PHI in logs or notifications
4. **Encryption**: All communications encrypted (HTTPS/TLS)
5. **Human Approval**: Required for system modifications

### Security Best Practices

#### 1. Secure Credentials
```bash
# Never hardcode credentials
# Use n8n's credential system
# Store in environment variables
```

#### 2. Network Security
```bash
# Use VPN or Twingate for remote access
# Enable firewall rules
# Use SSH key authentication
```

#### 3. Minimal Permissions
```bash
# Grant Terry read-only access by default
# Require explicit approval for writes
# Use service accounts with limited scope
```

#### 4. Audit Trail
```sql
-- All Terry actions logged
INSERT INTO audit_logs (
  event_type,
  event_details,
  user_id,
  timestamp
) VALUES (
  'TERRY_MONITORING',
  '{"action": "health_check", "result": "success"}',
  'terry-agent',
  NOW()
);
```

---

## Troubleshooting

### Common Issues

#### Terry Not Responding

**Problem**: AI Agent returns no output

**Solutions:**
1. Check OpenAI API key validity
2. Verify model is available (gpt-4o-mini)
3. Check rate limits on API
4. Review system prompt for errors
5. Test with simpler prompt

#### Too Many Tool Calls

**Problem**: "Maximum iterations exceeded"

**Solutions:**
1. Increase max iterations in AI Agent settings (default: 10, try 20)
2. Make prompts more specific
3. Reduce number of services checked per run
4. Upgrade to smarter model (GPT-4 instead of mini)

#### Approval Loop Stuck

**Problem**: Approval request not routing correctly

**Solutions:**
1. Verify IF node condition: `needs_approval === true` (Boolean)
2. Check Edit Fields node maps `approved` field
3. Ensure Telegram credentials are valid
4. Test with manual approval first

#### False Positives

**Problem**: Terry reports issues when none exist

**Solutions:**
1. Adjust health check thresholds
2. Update expected response patterns
3. Add retry logic for intermittent failures
4. Whitelist known temporary issues

#### Missing Notifications

**Problem**: Alerts not sent when issues occur

**Solutions:**
1. Check Switch node routing logic
2. Verify Telegram/Slack credentials
3. Test notification node independently
4. Check rate limits on notification service

---

## Best Practices

### 1. Start Simple, Iterate

```
Week 1: Basic health checks (HTTP endpoints)
Week 2: Add database monitoring
Week 3: Enable SSH for system diagnostics
Week 4: Add human-in-the-loop approval
```

### 2. Document Your Infrastructure

Create a knowledge base for Terry:

```markdown
# BrainSAIT Infrastructure

## Services
- MASTERLINC: https://n8n.domain.com/webhook/masterlinc/orchestrate
- TTLINC: https://n8n.domain.com/webhook/ttlinc/translate
- Database: postgres://host:5432/brainsait

## Common Issues
- Issue: TTLINC timeout
  Solution: Restart n8n workflow, check Anthropic API key

- Issue: Database connection lost
  Solution: Check PostgreSQL service, verify credentials
```

### 3. Test in Sandbox First

Before production:
1. Create test workflows
2. Use demo data
3. Test failure scenarios
4. Verify approval flow
5. Check audit logging

### 4. Monitor Terry

Set up meta-monitoring:
- Track Terry's execution success rate
- Monitor API costs (OpenAI/Anthropic)
- Review Terry's decisions weekly
- Collect feedback from team

### 5. Version Control

```bash
# Export workflows regularly
n8n export:workflow --id=<terry-workflow-id> --output=workflows/

# Commit to git
git add workflows/05-terry-system-monitor.json
git commit -m "Update Terry monitoring configuration"
git push
```

### 6. Regular Training

Update Terry's knowledge:
- Add new services as they're deployed
- Document resolution patterns
- Update health check criteria
- Refine approval rules

---

## Example Use Cases

### Use Case 1: Automatic Service Recovery

**Scenario**: TTLINC translation service crashes during high load

**Terry's Response:**
1. Detects service is down (HTTP check fails)
2. Investigates logs: "Out of memory error"
3. Proposes fix: "Restart service and increase memory limit"
4. Requests approval via Telegram
5. After approval: Restarts service
6. Verifies service is healthy
7. Logs incident for review

### Use Case 2: Proactive Disk Space Management

**Scenario**: Database disk usage at 85%

**Terry's Response:**
1. Monitors disk space during routine check
2. Identifies trend: "Disk usage increasing 5% per week"
3. Calculates: "Will reach 95% in 2 weeks"
4. Alerts: "Proactive disk cleanup recommended"
5. Proposes: "Archive old audit logs, run VACUUM on database"
6. Requests approval
7. Executes cleanup after approval

### Use Case 3: Security Compliance Check

**Scenario**: Weekly HIPAA compliance verification

**Terry's Response:**
1. Checks all audit logs are being created
2. Verifies encryption on all endpoints
3. Reviews access control logs
4. Checks for unauthorized access attempts
5. Generates compliance report
6. Sends summary to compliance officer

---

## Advanced Topics

### Multi-Agent Collaboration

Connect Terry with other BrainSAIT agents:

```javascript
// Terry detects translation service issue
// Calls MASTERLINC to route diagnostic request
{
  "agentType": "COMPLIANCELINC",
  "userRole": "admin",
  "payload": {
    "action": "audit_service_health",
    "service": "TTLINC",
    "requestedBy": "terry-monitor"
  }
}
```

### Machine Learning Integration

Add predictive analytics:
- Collect historical metrics
- Train anomaly detection model
- Integrate model predictions with Terry
- Alert before issues occur

### Custom Tool Development

Create specialized tools for healthcare:

```javascript
// HIPAA Compliance Checker Tool
function checkHIPAACompliance() {
  return {
    encryptionEnabled: checkEncryption(),
    auditLogsActive: checkAuditLogs(),
    accessControlsValid: checkAccessControls(),
    dataBackupsRecent: checkBackups()
  };
}
```

---

## Resources

### Official Documentation
- [n8n Documentation](https://docs.n8n.io/)
- [n8n AI Agents](https://docs.n8n.io/integrations/builtin/cluster-nodes/root-nodes/n8n-nodes-langchain.agent/)
- [NetworkChuck Terry Guide](https://github.com/theNetworkChuck/n8n-terry-guide)

### BrainSAIT Documentation
- [README.md](README.md) - Overview and installation
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Deployment instructions
- [API_REFERENCE.md](API_REFERENCE.md) - API endpoints
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues

### Community
- [BrainSAIT GitHub Issues](https://github.com/Fadil369/n8n-nodes-brainsait/issues)
- [n8n Community Forum](https://community.n8n.io/)
- [NetworkChuck Discord](https://discord.gg/networkchuck)

---

## Contributing

Found a bug or have an improvement?

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- **NetworkChuck** for the original Terry concept and guide
- **BrainSAIT Team** for healthcare AI workflow development
- **n8n Community** for the powerful automation platform

---

**Remember**: You're training an employee, not programming a bot. Give Terry context, teach him your processes, and build trust progressively.

Happy automating! 🏥☕️
