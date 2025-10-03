# BrainSAIT N8N Troubleshooting Guide

Common issues and solutions for BrainSAIT Healthcare AI Agents.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Workflow Issues](#workflow-issues)
- [Database Issues](#database-issues)
- [API & Integration Issues](#api--integration-issues)
- [Performance Issues](#performance-issues)
- [Security & Compliance Issues](#security--compliance-issues)
- [Translation Issues](#translation-issues)
- [NPHIES Integration Issues](#nphies-integration-issues)
- [Debugging Tips](#debugging-tips)

---

## Installation Issues

### Issue: Workflows not importing

**Symptoms:**
- JSON import fails
- Workflow appears corrupted
- Missing nodes error

**Solutions:**

1. **Verify JSON Format**
   ```bash
   # Check if JSON is valid
   jq empty workflows/01-masterlinc-orchestrator.json
   ```

2. **Check N8N Version**
   ```bash
   n8n --version
   # Minimum required: 1.0.0
   ```

3. **Import Manually**
   - Open N8N interface
   - Click "+ Add Workflow"
   - Select "Import from File"
   - Choose the workflow JSON file
   - Click "Import"

4. **Check File Permissions**
   ```bash
   ls -la workflows/*.json
   # All files should be readable
   ```

---

### Issue: Missing dependencies

**Symptoms:**
- npm install fails
- Module not found errors

**Solutions:**

1. **Update npm**
   ```bash
   npm install -g npm@latest
   ```

2. **Clear Cache**
   ```bash
   npm cache clean --force
   rm -rf node_modules package-lock.json
   npm install
   ```

3. **Check Node Version**
   ```bash
   node --version
   # Should be 18.0.0 or higher
   ```

---

## Workflow Issues

### Issue: Webhook not triggering

**Symptoms:**
- POST requests return 404
- Workflow doesn't execute
- No execution history

**Solutions:**

1. **Check Workflow is Active**
   - Open the workflow
   - Toggle "Active" switch to ON
   - Save the workflow

2. **Verify Webhook URL**
   ```bash
   # Correct format:
   https://your-n8n-instance.com/webhook/workflow-name
   
   # Test with curl:
   curl -I https://your-n8n-instance.com/webhook/ttlinc/translate
   # Should return 200 or 405 (if GET is not allowed)
   ```

3. **Check N8N Logs**
   ```bash
   # Docker logs
   docker logs n8n-container-name
   
   # System logs
   journalctl -u n8n -n 100
   ```

4. **Test with Simple Request**
   ```bash
   curl -X POST https://your-n8n-instance.com/webhook/test \
     -H "Content-Type: application/json" \
     -d '{"test": true}'
   ```

---

### Issue: Workflow execution fails

**Symptoms:**
- Workflow starts but doesn't complete
- Error in execution log
- Red nodes in workflow

**Solutions:**

1. **Check Execution Log**
   - Go to "Executions" tab
   - Click on failed execution
   - Review error messages

2. **Common Errors & Fixes**

   **Error: "Missing credentials"**
   ```
   Solution: 
   1. Go to Settings → Credentials
   2. Add required credentials (PostgreSQL, Anthropic, etc.)
   3. Update workflow nodes to use these credentials
   ```

   **Error: "Database connection failed"**
   ```
   Solution:
   1. Verify database is running
   2. Check connection string
   3. Test connection:
      psql -h HOST -U USER -d DATABASE -c "SELECT 1;"
   ```

   **Error: "Timeout"**
   ```
   Solution:
   1. Increase workflow timeout
   2. Check if external service is responding
   3. Review node execution times
   ```

3. **Test Individual Nodes**
   - Click "Test workflow"
   - Execute nodes one at a time
   - Identify which node fails

---

### Issue: Data not flowing between nodes

**Symptoms:**
- Nodes execute but data is empty
- Undefined variable errors
- Expression errors

**Solutions:**

1. **Check Node Connections**
   - Verify nodes are properly connected
   - Check connection lines are solid, not dashed

2. **Verify Data Structure**
   ```javascript
   // In Code node, log the input data
   console.log('Input data:', $input.all());
   console.log('Item 0:', $input.first());
   return $input.all();
   ```

3. **Check Expressions**
   ```javascript
   // Valid expressions in N8N:
   {{ $json.fieldName }}
   {{ $node["Node Name"].json.fieldName }}
   {{ $items[0].json.data }}
   ```

4. **Enable Debug Mode**
   - Click on node
   - Enable "Always Output Data"
   - Check output in execution

---

## Database Issues

### Issue: Database connection fails

**Symptoms:**
- "Connection refused" error
- "Authentication failed" error
- Timeout errors

**Solutions:**

1. **Verify Database is Running**
   ```bash
   # PostgreSQL status
   systemctl status postgresql
   
   # Docker container
   docker ps | grep postgres
   ```

2. **Test Connection**
   ```bash
   psql -h localhost -U brainsait_app -d brainsait -c "SELECT version();"
   ```

3. **Check Credentials**
   ```bash
   # In N8N:
   # Settings → Credentials → PostgreSQL
   # Verify:
   # - Host
   # - Port (default: 5432)
   # - Database name
   # - Username
   # - Password
   ```

4. **Check Firewall**
   ```bash
   # Allow PostgreSQL port
   sudo ufw allow 5432/tcp
   
   # Check if port is open
   telnet postgres-host 5432
   ```

5. **Check pg_hba.conf**
   ```bash
   # Add this line to allow connections:
   host    all             all             0.0.0.0/0               md5
   
   # Restart PostgreSQL
   sudo systemctl restart postgresql
   ```

---

### Issue: Schema not installed

**Symptoms:**
- "Table does not exist" errors
- "Relation not found" errors

**Solutions:**

1. **Run Schema File**
   ```bash
   psql -h HOST -U USER -d DATABASE -f schema.sql
   ```

2. **Verify Tables Created**
   ```bash
   psql -h HOST -U USER -d DATABASE -c "\dt"
   # Should list 16 tables
   ```

3. **Check for Errors**
   ```bash
   # Run with verbose output
   psql -h HOST -U USER -d DATABASE -f schema.sql -v ON_ERROR_STOP=1
   ```

---

## API & Integration Issues

### Issue: Anthropic API not responding

**Symptoms:**
- Translation fails
- Clinical support timeout
- API key error

**Solutions:**

1. **Verify API Key**
   ```bash
   curl https://api.anthropic.com/v1/messages \
     -H "x-api-key: YOUR_API_KEY" \
     -H "anthropic-version: 2023-06-01" \
     -H "content-type: application/json" \
     -d '{"model": "claude-3-sonnet-20240229", "messages": [{"role": "user", "content": "test"}], "max_tokens": 10}'
   ```

2. **Check API Limits**
   - Review Anthropic dashboard
   - Check rate limits
   - Verify billing status

3. **Update Credentials in N8N**
   - Settings → Credentials → Anthropic API
   - Update API key
   - Test connection

---

### Issue: NPHIES integration fails

**Symptoms:**
- Claims not submitting
- Eligibility check fails
- Authentication errors

**Solutions:**

1. **Verify NPHIES Credentials**
   - Check provider license
   - Verify facility ID
   - Confirm API key is active

2. **Test NPHIES Endpoint**
   ```bash
   curl -X POST https://nphies.sa.gov/api/v2/eligibility/check \
     -H "Authorization: Bearer YOUR_KEY" \
     -H "Content-Type: application/json" \
     -d '{"memberId": "TEST-001"}'
   ```

3. **Check NPHIES Status**
   - Visit NPHIES portal
   - Check system status
   - Review maintenance schedules

4. **Review Claim Format**
   - Ensure FHIR R4 compliance
   - Validate required fields
   - Check coding systems

---

## Performance Issues

### Issue: Slow workflow execution

**Symptoms:**
- Workflows take too long
- Timeout errors
- High CPU/memory usage

**Solutions:**

1. **Identify Bottlenecks**
   - Review execution times per node
   - Check database query performance
   - Monitor API response times

2. **Optimize Database Queries**
   ```sql
   -- Add indexes if missing
   CREATE INDEX IF NOT EXISTS idx_patients_mrn ON patients(mrn);
   CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(date);
   
   -- Analyze query performance
   EXPLAIN ANALYZE SELECT * FROM patients WHERE mrn = 'MRN-001';
   ```

3. **Implement Caching**
   ```javascript
   // In N8N Code node
   const cache = {};
   const cacheKey = $json.requestId;
   
   if (cache[cacheKey]) {
     return cache[cacheKey];
   }
   
   // Fetch data...
   cache[cacheKey] = result;
   return result;
   ```

4. **Use Batch Processing**
   - Process multiple items together
   - Use batch translation endpoints
   - Aggregate database operations

5. **Increase Resources**
   ```yaml
   # docker-compose.yml
   services:
     n8n:
       environment:
         - N8N_PAYLOAD_SIZE_MAX=16
         - EXECUTIONS_TIMEOUT=600
       deploy:
         resources:
           limits:
             memory: 4G
   ```

---

### Issue: High database load

**Symptoms:**
- Slow queries
- Connection pool exhausted
- Database CPU high

**Solutions:**

1. **Monitor Database Performance**
   ```sql
   -- Active connections
   SELECT count(*) FROM pg_stat_activity;
   
   -- Slow queries
   SELECT pid, now() - query_start as duration, query 
   FROM pg_stat_activity 
   WHERE state = 'active' 
   ORDER BY duration DESC;
   ```

2. **Optimize Connections**
   ```bash
   # PostgreSQL config
   max_connections = 200
   shared_buffers = 256MB
   effective_cache_size = 1GB
   ```

3. **Add Missing Indexes**
   ```sql
   -- Check for missing indexes
   SELECT schemaname, tablename, attname, n_distinct, correlation
   FROM pg_stats
   WHERE schemaname = 'public'
   AND n_distinct > 100;
   ```

---

## Security & Compliance Issues

### Issue: HIPAA audit logging not working

**Symptoms:**
- Audit logs empty
- Events not recorded
- Compliance reports incomplete

**Solutions:**

1. **Verify Audit Table Exists**
   ```sql
   SELECT COUNT(*) FROM audit_logs;
   ```

2. **Check Logging Configuration**
   ```javascript
   // In workflow, ensure audit context is passed:
   {
     "auditContext": {
       "userId": "user-id",
       "sessionId": "session-id",
       "ipAddress": "192.168.1.100",
       "action": "PATIENT_ACCESS"
     }
   }
   ```

3. **Test Audit Logging**
   ```sql
   -- Insert test log
   INSERT INTO audit_logs (event_type, user_id, payload)
   VALUES ('TEST_EVENT', 'test-user', '{"test": true}');
   
   -- Verify
   SELECT * FROM audit_logs WHERE event_type = 'TEST_EVENT';
   ```

---

### Issue: PHI data not encrypted

**Symptoms:**
- Data visible in plain text
- Security scan warnings

**Solutions:**

1. **Enable Database Encryption**
   ```sql
   -- Check encryption status
   SELECT datname, datencoding FROM pg_database;
   ```

2. **Use pgcrypto**
   ```sql
   CREATE EXTENSION IF NOT EXISTS pgcrypto;
   
   -- Encrypt sensitive data
   UPDATE patients 
   SET ssn = pgp_sym_encrypt(ssn, 'encryption-key');
   ```

3. **Configure SSL/TLS**
   ```bash
   # PostgreSQL SSL
   ssl = on
   ssl_cert_file = '/path/to/server.crt'
   ssl_key_file = '/path/to/server.key'
   ```

---

## Translation Issues

### Issue: Translation quality poor

**Symptoms:**
- Incorrect translations
- Medical terms mistranslated
- Context lost

**Solutions:**

1. **Use Correct Content Type**
   ```json
   {
     "contentType": "CLINICAL_NOTE",  // Not "GENERAL"
     "preserveMedicalTerms": true
   }
   ```

2. **Add Medical Terminology**
   ```sql
   -- Add to medical_terminology table
   INSERT INTO medical_terminology 
   (term_source, term_target, language_pair, category, approved)
   VALUES 
   ('Myocardial Infarction', 'احتشاء عضلة القلب', 'en-ar', 'CARDIOLOGY', true);
   ```

3. **Provide Context**
   ```json
   {
     "content": "Patient has MI",
     "contextData": {
       "specialty": "Cardiology",
       "patientAge": 65
     }
   }
   ```

---

### Issue: RTL formatting broken

**Symptoms:**
- Arabic text displays left-to-right
- Mixed content alignment issues

**Solutions:**

1. **Set Proper HTML Direction**
   ```html
   <div dir="rtl" lang="ar">
     {{ arabicContent }}
   </div>
   ```

2. **Use Unicode Control Characters**
   ```javascript
   const RLM = '\u200F'; // Right-to-left mark
   const LRM = '\u200E'; // Left-to-right mark
   
   const formatted = RLM + arabicText + RLM;
   ```

---

## NPHIES Integration Issues

### Issue: Claims rejected

**Symptoms:**
- NPHIES returns rejection
- Validation errors
- Invalid format errors

**Solutions:**

1. **Validate Claim Format**
   ```bash
   # Use NPHIES validator
   curl -X POST https://nphies.sa.gov/api/v2/claims/validate \
     -H "Authorization: Bearer YOUR_KEY" \
     -d @claim.json
   ```

2. **Check Required Fields**
   - Provider license
   - Patient eligibility
   - Service codes (CPT/ICD-10)
   - Diagnosis codes
   - Date of service

3. **Review Rejection Reason**
   ```json
   {
     "rejectionCode": "ERR_005",
     "reason": "Invalid diagnosis code",
     "field": "diagnoses[0].code"
   }
   ```

4. **Common Issues**
   - **Invalid codes**: Use Saudi MOH code sets
   - **Eligibility**: Check insurance is active
   - **Authorization**: Verify pre-auth if required
   - **Documentation**: Include required attachments

---

## Debugging Tips

### Enable Verbose Logging

```javascript
// In N8N Code node
console.log('DEBUG: Input data:', JSON.stringify($input.all(), null, 2));
console.log('DEBUG: Processing item:', $json);
console.log('DEBUG: Current state:', variables);
```

### Use N8N Debug Mode

1. Open workflow
2. Click "Execute Workflow" (not "Execute" on individual nodes)
3. Check "Debug" checkbox
4. Review detailed execution log

### Test API Calls Externally

```bash
# Save request to file
cat > request.json << EOF
{
  "content": "test",
  "sourceLanguage": "en",
  "targetLanguage": "ar"
}
EOF

# Test with curl
curl -v -X POST https://your-n8n-instance.com/webhook/ttlinc/translate \
  -H "Content-Type: application/json" \
  -d @request.json \
  | jq .
```

### Monitor System Resources

```bash
# CPU and memory
top -p $(pgrep -f n8n)

# Database connections
watch -n 1 'psql -h localhost -U user -d db -c "SELECT count(*) FROM pg_stat_activity;"'

# Disk space
df -h

# Network connections
netstat -an | grep :5678  # N8N default port
```

### Check N8N Logs

```bash
# Docker
docker logs -f n8n-container --tail 100

# PM2
pm2 logs n8n

# System service
journalctl -u n8n -f
```

---

## Getting Help

If you're still experiencing issues:

1. **Check Documentation**
   - [README.md](README.md)
   - [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
   - [API_REFERENCE.md](API_REFERENCE.md)
   - [EXAMPLES.md](EXAMPLES.md)

2. **Search Existing Issues**
   - [GitHub Issues](https://github.com/Fadil369/n8n-nodes-brainsait/issues)

3. **Create New Issue**
   - Include N8N version
   - Include workflow configuration
   - Include error messages
   - Include steps to reproduce

4. **Contact Support**
   - Email: support@brainsait.com
   - Include system information:
   ```bash
   n8n --version
   node --version
   npm --version
   psql --version
   ```

---

## Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `ECONNREFUSED` | Service not running | Check service status |
| `ETIMEDOUT` | Network timeout | Increase timeout, check network |
| `ENOTFOUND` | DNS resolution failed | Check hostname/DNS |
| `ERR_INVALID_JSON` | Malformed JSON | Validate JSON format |
| `ER_ACCESS_DENIED` | Wrong credentials | Verify username/password |
| `ER_NO_SUCH_TABLE` | Table missing | Run schema.sql |
| `ER_DUP_ENTRY` | Duplicate record | Check unique constraints |
| `HIPAA_VIOLATION` | Compliance issue | Review audit logs |
| `NPHIES_INVALID` | NPHIES validation failed | Check claim format |

---

**Last Updated:** January 2025  
**Version:** 1.0.0
