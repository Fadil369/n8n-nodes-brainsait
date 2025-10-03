# BrainSAIT N8N Architecture

Comprehensive architecture documentation for the BrainSAIT Healthcare AI Agents system.

## Table of Contents

- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Agent Architecture](#agent-architecture)
- [Data Flow](#data-flow)
- [Database Schema](#database-schema)
- [Security Architecture](#security-architecture)
- [Integration Architecture](#integration-architecture)
- [Deployment Architecture](#deployment-architecture)
- [Scalability & Performance](#scalability--performance)

---

## Overview

BrainSAIT is a comprehensive healthcare automation platform built on N8N, providing HIPAA/NPHIES-compliant workflow automation for Saudi Arabian healthcare providers.

### Core Principles

1. **Modularity**: Each agent is self-contained and independent
2. **Compliance**: HIPAA and NPHIES compliance built-in
3. **Bilingual**: Full Arabic and English support
4. **Scalability**: Designed for high-volume healthcare operations
5. **Security**: End-to-end encryption and audit logging

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     External Systems                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ NPHIES   │  │ EHR/EMR  │  │ Lab Sys  │  │ Pharmacy │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
└───────┼─────────────┼─────────────┼─────────────┼──────────┘
        │             │             │             │
        └─────────────┼─────────────┼─────────────┘
                      │             │
              ┌───────▼─────────────▼───────┐
              │      N8N Platform            │
              │  ┌────────────────────────┐  │
              │  │  MASTERLINC Orchestrator│  │
              │  │  (Central Router)       │  │
              │  └───────┬─────────────┬───┘  │
              │          │             │       │
              │  ┌───────▼──────┐ ┌───▼─────┐│
              │  │ HEALTHCARELINC│ │CLINICAL││
              │  │  (Workflows)  │ │ LINC   ││
              │  └───────┬───────┘ └───┬────┘│
              │          │              │     │
              │  ┌───────▼──────┐ ┌────▼────┐│
              │  │   TTLINC     │ │COMPLIAN││
              │  │(Translation) │ │CE LINC ││
              │  └───────┬──────┘ └───┬─────┘│
              │          │             │      │
              └──────────┼─────────────┼──────┘
                         │             │
              ┌──────────▼─────────────▼──────┐
              │     PostgreSQL Database        │
              │  ┌──────────────────────────┐  │
              │  │ - Patients               │  │
              │  │ - Appointments           │  │
              │  │ - Clinical Data          │  │
              │  │ - Audit Logs (HIPAA)     │  │
              │  │ - Insurance Claims       │  │
              │  │ - Translations           │  │
              │  └──────────────────────────┘  │
              └─────────────────────────────────┘
                         │
              ┌──────────▼─────────────┐
              │   AI Services          │
              │  ┌──────────────────┐  │
              │  │ Anthropic Claude │  │
              │  │ (Clinical AI)    │  │
              │  └──────────────────┘  │
              └────────────────────────┘
```

### Component Overview

| Component | Purpose | Technology |
|-----------|---------|------------|
| N8N Platform | Workflow orchestration | N8N |
| MASTERLINC | Central routing & coordination | N8N Workflow |
| HEALTHCARELINC | Patient management, appointments | N8N Workflow |
| CLINICALLINC | Clinical decision support | N8N + Claude AI |
| TTLINC | Medical translation | N8N + Claude AI |
| COMPLIANCELINC | Audit logging, compliance | N8N Workflow |
| PostgreSQL | Persistent data storage | PostgreSQL 13+ |
| Redis | Caching & session management | Redis 6+ (optional) |

---

## Agent Architecture

### MASTERLINC - Master Orchestrator

**Purpose**: Central routing hub for all agent requests

**Workflow Design**:
```
┌─────────────────────────────────────────────┐
│          Webhook Trigger                    │
│      /webhook/masterlinc/orchestrate        │
└─────────────────┬───────────────────────────┘
                  │
         ┌────────▼─────────┐
         │  Validate Request │
         │  - Check auth     │
         │  - Validate schema│
         └────────┬──────────┘
                  │
         ┌────────▼─────────┐
         │  Route to Agent   │
         │  - HEALTHCARELINC │
         │  - CLINICALLINC   │
         │  - TTLINC         │
         │  - COMPLIANCELINC │
         └────────┬──────────┘
                  │
         ┌────────▼─────────┐
         │  Audit Logging    │
         │  - Log request    │
         │  - HIPAA tracking │
         └────────┬──────────┘
                  │
         ┌────────▼─────────┐
         │  Return Response  │
         └───────────────────┘
```

**Key Features**:
- Role-based access control (RBAC)
- Request validation & sanitization
- Automatic audit logging
- Error handling & retry logic
- Response formatting

---

### HEALTHCARELINC - Healthcare Workflows

**Purpose**: Patient management and healthcare operations

**Capabilities**:
- Patient registration
- Appointment scheduling
- Lab/radiology orders
- Prescription management
- Insurance eligibility checks

**Workflow Pattern**:
```
Request → Validation → Database Query → FHIR Formatting → Response
                ↓
         Audit Logging
```

**Integration Points**:
- NPHIES API (insurance)
- External EHR systems
- Laboratory systems
- Pharmacy systems

---

### CLINICALLINC - Clinical Decision Support

**Purpose**: AI-powered clinical guidance

**Capabilities**:
- Diagnosis support
- Treatment recommendations
- Drug interaction checking
- Clinical guideline adherence
- Evidence-based protocols

**AI Integration**:
```
Clinical Query
      ↓
  Format Prompt
      ↓
  Claude API Call
      ↓
  Parse Response
      ↓
  Validate Recommendations
      ↓
  Return Structured Data
```

**Safety Features**:
- Confidence scoring
- Multiple differential diagnoses
- Drug contraindication checks
- Allergy warnings
- Clinical guideline references

---

### TTLINC - Translation Service

**Purpose**: Medical translation with context awareness

**Architecture**:
```
┌──────────────────────────────────────────┐
│         Translation Request              │
└──────────────┬───────────────────────────┘
               │
      ┌────────▼─────────┐
      │  Check Cache     │
      │  (translations   │
      │   table)         │
      └────────┬─────────┘
               │
          ┌────▼────┐
          │  Found? │
          └────┬────┘
               │
        ┌──────┴──────┐
        │             │
     Yes│             │No
        │             │
   ┌────▼────┐   ┌───▼─────────────┐
   │ Return  │   │ Medical Term    │
   │ Cached  │   │ Lookup          │
   └─────────┘   └───┬─────────────┘
                     │
              ┌──────▼──────────┐
              │ Claude API Call │
              │ (with context)  │
              └──────┬──────────┘
                     │
              ┌──────▼──────────┐
              │ Quality Check   │
              │ - Medical terms │
              │ - RTL format    │
              └──────┬──────────┘
                     │
              ┌──────▼──────────┐
              │ Cache Result    │
              └──────┬──────────┘
                     │
              ┌──────▼──────────┐
              │ Return Response │
              └─────────────────┘
```

**Quality Assurance**:
- Medical terminology preservation
- Context-aware translation
- RTL formatting for Arabic
- Quality scoring
- Review workflow

---

### COMPLIANCELINC - Audit & Compliance

**Purpose**: HIPAA/NPHIES compliance monitoring

**Audit Events**:
- Patient data access
- PHI disclosure
- Data modifications
- NPHIES submissions
- Authentication events
- Security incidents

**Audit Log Structure**:
```sql
audit_logs (
  id BIGSERIAL PRIMARY KEY,
  timestamp TIMESTAMPTZ,
  event_type VARCHAR(100),
  user_id UUID,
  session_id UUID,
  ip_address INET,
  request_id VARCHAR(100),
  payload JSONB,
  status VARCHAR(50),
  compliance_level VARCHAR(50)
)
```

---

## Data Flow

### Patient Registration Flow

```
1. Patient Data → MASTERLINC
                     ↓
2. Route to HEALTHCARELINC
                     ↓
3. Validate Patient Data
   - National ID check
   - Duplicate check
                     ↓
4. Check Insurance Eligibility (NPHIES)
                     ↓
5. Create Patient Record (PostgreSQL)
   - patients table
   - Generate MRN
                     ↓
6. Create Audit Log
   - event: PATIENT_REGISTRATION
   - HIPAA compliant
                     ↓
7. Return Patient ID + MRN
```

### Clinical Decision Support Flow

```
1. Clinical Query → MASTERLINC
                       ↓
2. Route to CLINICALLINC
                       ↓
3. Load Patient Context
   - Medical history
   - Current medications
   - Allergies
   - Lab results
                       ↓
4. Check Drug Interactions (Local DB)
                       ↓
5. Format Prompt for Claude AI
   - Include guidelines
   - Add patient context
   - Specify output format
                       ↓
6. Claude API Call
   - Diagnosis support
   - Treatment recommendations
                       ↓
7. Parse & Validate Response
   - Check confidence levels
   - Verify drug safety
   - Reference guidelines
                       ↓
8. Store Recommendation (PostgreSQL)
   - clinical_recommendations table
                       ↓
9. Create Audit Log
                       ↓
10. Return Recommendations
```

### Translation Flow

```
1. Translation Request → MASTERLINC
                            ↓
2. Route to TTLINC
                            ↓
3. Check Cache (translations table)
   - Source + target language
   - Content hash
                            ↓
4. If cached → Return
   If not cached ↓
                            ↓
5. Load Medical Terminology
   - medical_terminology table
   - For term preservation
                            ↓
6. Format Prompt for Claude
   - Content type context
   - Medical specialty
   - Terminology to preserve
                            ↓
7. Claude API Call
                            ↓
8. Quality Check
   - Medical term preservation
   - RTL formatting (if Arabic)
   - Context accuracy
                            ↓
9. Cache Result
   - translations table
                            ↓
10. Return Translation
```

---

## Database Schema

### Core Tables

#### patients
```sql
- patient_id (UUID, PK)
- mrn (VARCHAR, UNIQUE)
- national_id (VARCHAR, UNIQUE)
- name (VARCHAR)
- date_of_birth (DATE)
- gender (VARCHAR)
- contact_info (JSONB)
- insurance_info (JSONB)
- medical_history (JSONB)
- created_at (TIMESTAMPTZ)
```

#### appointments
```sql
- appointment_id (UUID, PK)
- patient_id (UUID, FK)
- provider_id (UUID, FK)
- date (DATE)
- time (TIME)
- type (VARCHAR)
- status (VARCHAR)
- location (VARCHAR)
```

#### clinical_recommendations
```sql
- recommendation_id (UUID, PK)
- patient_id (UUID, FK)
- provider_id (UUID, FK)
- request_type (VARCHAR)
- clinical_scenario (TEXT)
- recommendations (JSONB)
- confidence_level (VARCHAR)
- created_at (TIMESTAMPTZ)
```

#### translations
```sql
- id (BIGSERIAL, PK)
- source_text (TEXT)
- translated_text (TEXT)
- source_language (VARCHAR)
- target_language (VARCHAR)
- content_type (VARCHAR)
- quality_score (INT)
- metadata (JSONB)
```

#### audit_logs
```sql
- id (BIGSERIAL, PK)
- timestamp (TIMESTAMPTZ)
- event_type (VARCHAR)
- user_id (UUID)
- session_id (UUID)
- ip_address (INET)
- payload (JSONB)
- compliance_level (VARCHAR)
```

### Indexes

Key indexes for performance:

```sql
-- Patient lookup
CREATE INDEX idx_patients_mrn ON patients(mrn);
CREATE INDEX idx_patients_national_id ON patients(national_id);

-- Appointment queries
CREATE INDEX idx_appointments_date ON appointments(date);
CREATE INDEX idx_appointments_patient ON appointments(patient_id);
CREATE INDEX idx_appointments_provider ON appointments(provider_id);

-- Audit logs
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp DESC);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_event ON audit_logs(event_type);

-- Translation cache
CREATE INDEX idx_translations_languages ON translations(source_language, target_language);
CREATE INDEX idx_translations_created ON translations(created_at DESC);
```

---

## Security Architecture

### Authentication & Authorization

```
┌──────────────────────────────────────────┐
│         User Authentication              │
│  ┌────────────────────────────────────┐  │
│  │ N8N Built-in Auth                  │  │
│  │ - Basic Auth                       │  │
│  │ - Header Auth                      │  │
│  │ - OAuth 2.0                        │  │
│  └────────────────────────────────────┘  │
└──────────────────┬───────────────────────┘
                   │
        ┌──────────▼──────────┐
        │  Role-Based Access  │
        │  Control (RBAC)     │
        │  - admin            │
        │  - provider         │
        │  - patient          │
        │  - staff            │
        └──────────┬──────────┘
                   │
        ┌──────────▼──────────┐
        │  Permission Check   │
        │  - Resource access  │
        │  - Operation type   │
        └──────────┬──────────┘
                   │
        ┌──────────▼──────────┐
        │  Audit Logging      │
        │  - All access       │
        │  - All operations   │
        └─────────────────────┘
```

### Data Encryption

**At Rest**:
- PostgreSQL encryption (pgcrypto)
- Sensitive fields encrypted
- Backup encryption

**In Transit**:
- TLS 1.3 for all connections
- HTTPS for webhooks
- Encrypted database connections

**Encryption Implementation**:
```sql
-- Encrypt sensitive data
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Encrypt SSN
UPDATE patients 
SET ssn = pgp_sym_encrypt(ssn, 'encryption-key');

-- Decrypt for authorized access
SELECT pgp_sym_decrypt(ssn::bytea, 'encryption-key') 
FROM patients;
```

### HIPAA Compliance

**Requirements Met**:
1. ✅ Access Control (§164.312(a)(1))
2. ✅ Audit Controls (§164.312(b))
3. ✅ Integrity Controls (§164.312(c)(1))
4. ✅ Transmission Security (§164.312(e)(1))
5. ✅ Authentication (§164.312(d))

**Audit Trail**:
- All PHI access logged
- User identification
- Date/time stamps
- Access type
- Resources accessed

---

## Integration Architecture

### NPHIES Integration

```
┌────────────────────────────────────────────┐
│         BrainSAIT System                   │
│                                            │
│  ┌──────────────────────────────────────┐ │
│  │  Insurance Claims Processing         │ │
│  └──────────────┬───────────────────────┘ │
│                 │                          │
└─────────────────┼──────────────────────────┘
                  │
                  │ HTTPS/TLS 1.3
                  │
┌─────────────────▼──────────────────────────┐
│         NPHIES API Gateway                 │
│                                            │
│  ┌──────────────────────────────────────┐ │
│  │  Endpoints:                          │ │
│  │  - /eligibility/check                │ │
│  │  - /claims/submit                    │ │
│  │  - /claims/status                    │ │
│  │  - /preauthorization/request         │ │
│  └──────────────────────────────────────┘ │
└────────────────────────────────────────────┘
```

**Integration Points**:
1. Eligibility Verification
2. Claims Submission
3. Pre-Authorization
4. Claims Status Tracking

### External EHR Integration

**FHIR R4 Compatibility**:
- Patient resources
- Appointment resources
- Observation resources
- Medication resources
- Condition resources

**Integration Pattern**:
```
BrainSAIT → FHIR Mapper → External EHR
    ↓
 Audit Log
```

---

## Deployment Architecture

### Docker Deployment

```yaml
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=${N8N_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_PASSWORD}
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:13
    environment:
      - POSTGRES_DB=brainsait
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./schema.sql:/docker-entrypoint-initdb.d/schema.sql

  redis:
    image: redis:6-alpine
    volumes:
      - redis_data:/data

volumes:
  n8n_data:
  postgres_data:
  redis_data:
```

### High Availability Setup

```
┌──────────────────────────────────────────┐
│         Load Balancer (HAProxy/Nginx)    │
└──────────┬───────────────┬───────────────┘
           │               │
    ┌──────▼──────┐ ┌──────▼──────┐
    │  N8N Node 1 │ │  N8N Node 2 │
    └──────┬──────┘ └──────┬──────┘
           │               │
    ┌──────▼───────────────▼──────┐
    │   PostgreSQL Primary         │
    └──────┬───────────────────────┘
           │
    ┌──────▼───────────────────────┐
    │   PostgreSQL Replica         │
    └──────────────────────────────┘
```

---

## Scalability & Performance

### Horizontal Scaling

**N8N Instances**:
- Multiple N8N instances behind load balancer
- Shared PostgreSQL database
- Redis for session management

**Database Scaling**:
- Read replicas for queries
- Connection pooling (PgBouncer)
- Query optimization with indexes

### Caching Strategy

**Translation Cache**:
- Store in `translations` table
- Cache key: hash(source_text + languages)
- TTL: 30 days

**Session Cache**:
- Redis for session data
- TTL: 24 hours

**Database Query Cache**:
- Frequently accessed data
- Patient demographics
- Medical terminology

### Performance Optimization

**Database**:
- Partitioning for audit_logs (by month)
- Vacuum and analyze regularly
- Index optimization

**N8N Workflows**:
- Batch processing where possible
- Async operations for long-running tasks
- Timeout configuration

**API Calls**:
- Rate limiting
- Request throttling
- Circuit breakers

---

## Monitoring & Observability

### Metrics to Monitor

1. **System Health**
   - N8N uptime
   - Database connections
   - API response times

2. **Workflow Metrics**
   - Execution count
   - Success/failure rates
   - Average execution time

3. **Compliance Metrics**
   - Audit log completeness
   - HIPAA compliance score
   - NPHIES submission success rate

### Logging Strategy

```
Application Logs → Centralized Log System (ELK Stack)
                          ↓
                   Analysis & Alerts
```

### Health Check Endpoints

```
GET /webhook/system-health/check

Response:
{
  "status": "HEALTHY",
  "checks": {
    "database": "UP",
    "workflows": "ACTIVE",
    "apiServices": "UP"
  }
}
```

---

## Future Enhancements

### Phase 2
- [ ] Telemedicine integration
- [ ] Real-time analytics dashboard
- [ ] Mobile app integration
- [ ] Advanced AI models

### Phase 3
- [ ] Multi-facility support
- [ ] IoT device integration
- [ ] Predictive analytics
- [ ] Population health management

---

**Last Updated:** January 2025  
**Architecture Version:** 1.0.0
