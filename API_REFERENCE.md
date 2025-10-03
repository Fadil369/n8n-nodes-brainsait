# BrainSAIT N8N API Reference

Complete API documentation for all BrainSAIT Healthcare AI Agent workflows.

## Table of Contents

- [Overview](#overview)
- [Authentication](#authentication)
- [Common Patterns](#common-patterns)
- [Endpoints](#endpoints)
  - [MASTERLINC - Orchestrator](#masterlinc---orchestrator)
  - [TTLINC - Translation](#ttlinc---translation)
  - [CLINICALLINC - Clinical Decision Support](#clinicallinc---clinical-decision-support)
  - [HEALTHCARELINC - Healthcare Workflows](#healthcarelinc---healthcare-workflows)
  - [COMPLIANCELINC - Audit & Compliance](#compliancelinc---audit--compliance)
  - [Patient Portal](#patient-portal)
  - [Insurance Claims](#insurance-claims)
  - [System Health](#system-health)
- [Data Models](#data-models)
- [Error Codes](#error-codes)

---

## Overview

BrainSAIT N8N workflows provide RESTful webhook endpoints for healthcare automation. All endpoints return JSON responses and follow HIPAA/NPHIES compliance standards.

**Base URL:** `https://your-n8n-instance.com`

**Supported Versions:** v1.0.0+

---

## Authentication

### Webhook Authentication

N8N webhooks can be secured using built-in authentication:

```bash
# Basic Authentication
curl -X POST https://your-n8n-instance.com/webhook/ttlinc/translate \
  -u "username:password" \
  -H "Content-Type: application/json" \
  -d '{"content": "..."}'

# Header Authentication
curl -X POST https://your-n8n-instance.com/webhook/ttlinc/translate \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"content": "..."}'
```

### Request ID Tracking

Include a unique request ID for tracking:

```bash
curl -X POST https://your-n8n-instance.com/webhook/ttlinc/translate \
  -H "X-Request-ID: UNIQUE-REQUEST-ID" \
  -H "Content-Type: application/json" \
  -d '{"content": "..."}'
```

---

## Common Patterns

### Standard Request Format

```json
{
  "auditContext": {
    "userId": "user-uuid",
    "sessionId": "session-uuid",
    "ipAddress": "192.168.1.100",
    "timestamp": "2025-01-15T10:00:00Z"
  },
  "requestData": {
    // Endpoint-specific data
  }
}
```

### Standard Response Format

```json
{
  "success": true,
  "requestId": "REQ-2025-001",
  "timestamp": "2025-01-15T10:00:00Z",
  "data": {
    // Endpoint-specific response data
  },
  "audit": {
    "complianceLevel": "HIPAA_NPHIES",
    "encryptionUsed": true,
    "loggedAt": "2025-01-15T10:00:00Z"
  }
}
```

### Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "ERR_VALIDATION_FAILED",
    "message": "Required field 'patientId' is missing",
    "details": {
      "field": "patientId",
      "expected": "UUID",
      "received": "null"
    }
  },
  "requestId": "REQ-2025-001",
  "timestamp": "2025-01-15T10:00:00Z"
}
```

---

## Endpoints

### MASTERLINC - Orchestrator

Central routing and orchestration for all agents.

#### Orchestrate Request

Routes requests to appropriate specialized agents.

**Endpoint:** `POST /webhook/masterlinc/orchestrate`

**Request Body:**
```json
{
  "agentType": "HEALTHCARELINC" | "CLINICALLINC" | "TTLINC" | "COMPLIANCELINC",
  "userRole": "provider" | "admin" | "patient" | "staff",
  "payload": {
    // Agent-specific data
  },
  "auditContext": {
    "userId": "user-uuid",
    "sessionId": "session-uuid",
    "ipAddress": "192.168.1.100"
  }
}
```

**Response:**
```json
{
  "success": true,
  "requestId": "MASTERLINC-2025-001",
  "routedTo": "HEALTHCARELINC",
  "response": {
    // Agent-specific response
  },
  "audit": {
    "timestamp": "2025-01-15T10:00:00Z",
    "complianceLevel": "HIPAA_NPHIES"
  }
}
```

---

### TTLINC - Translation

Medical translation service with context awareness.

#### Translate Content

**Endpoint:** `POST /webhook/ttlinc/translate`

**Request Body:**
```json
{
  "content": "string (required)",
  "sourceLanguage": "en" | "ar" (required),
  "targetLanguage": "en" | "ar" (required),
  "contentType": "CLINICAL_NOTE" | "LAB_RESULT" | "PRESCRIPTION" | "DIAGNOSIS" | "DISCHARGE_SUMMARY" (required),
  "preserveMedicalTerms": boolean (optional, default: true),
  "contextData": {
    "patientAge": number (optional),
    "specialty": "string" (optional)
  }
}
```

**Response:**
```json
{
  "success": true,
  "requestId": "TTLINC-2025-001",
  "translation": {
    "original": "Patient has elevated blood pressure",
    "translated": "المريض لديه ضغط الدم مرتفع",
    "sourceLanguage": "en",
    "targetLanguage": "ar"
  },
  "quality": {
    "score": 95,
    "contentType": "CLINICAL_NOTE",
    "preservedTerms": ["blood pressure"]
  },
  "metadata": {
    "translatedAt": "2025-01-15T10:00:00Z",
    "processingTime": "245ms",
    "cached": false
  }
}
```

#### Batch Translation

**Endpoint:** `POST /webhook/ttlinc/translate-batch`

**Request Body:**
```json
{
  "items": [
    {
      "id": "item-1",
      "content": "string",
      "contentType": "CLINICAL_NOTE"
    },
    {
      "id": "item-2",
      "content": "string",
      "contentType": "PRESCRIPTION"
    }
  ],
  "sourceLanguage": "en",
  "targetLanguage": "ar",
  "preserveMedicalTerms": true
}
```

---

### CLINICALLINC - Clinical Decision Support

AI-powered clinical decision support system.

#### Decision Support Request

**Endpoint:** `POST /webhook/clinicallinc/decision-support`

**Request Types:**
- `DIAGNOSIS_SUPPORT`
- `TREATMENT_PROTOCOL`
- `DRUG_INTERACTION_CHECK`
- `CLINICAL_GUIDELINE_LOOKUP`

**Request Body:**
```json
{
  "requestType": "DIAGNOSIS_SUPPORT",
  "providerId": "provider-uuid",
  "clinicalScenario": "string (required)",
  "patientData": {
    "patientId": "patient-uuid",
    "demographics": {
      "age": number,
      "gender": "male" | "female" | "other",
      "weight": number,
      "height": number
    },
    "medicalHistory": {
      "conditions": ["string"],
      "medications": [
        {
          "name": "string",
          "code": "string",
          "dose": "string",
          "frequency": "string"
        }
      ],
      "allergies": ["string"],
      "familyHistory": ["string"]
    },
    "vitalSigns": {
      "bloodPressure": "string",
      "heartRate": number,
      "temperature": number,
      "respiratoryRate": number,
      "oxygenSaturation": number
    },
    "symptoms": ["string"],
    "labResults": [
      {
        "test": "string",
        "value": "string",
        "unit": "string",
        "normalRange": "string"
      }
    ]
  },
  "preferredLanguage": "en" | "ar"
}
```

**Response:**
```json
{
  "success": true,
  "requestId": "CLINICALLINC-2025-001",
  "recommendations": {
    "primaryDiagnosis": {
      "condition": "string",
      "icd10": "string",
      "confidence": "HIGH" | "MEDIUM" | "LOW",
      "reasoning": "string"
    },
    "differentialDiagnoses": [
      {
        "condition": "string",
        "icd10": "string",
        "confidence": "HIGH" | "MEDIUM" | "LOW",
        "note": "string"
      }
    ],
    "immediateActions": ["string"],
    "investigations": [
      {
        "test": "string",
        "urgency": "STAT" | "URGENT" | "ROUTINE",
        "reasoning": "string"
      }
    ],
    "drugInteractions": {
      "warnings": [
        {
          "interaction": "string",
          "severity": "SEVERE" | "MODERATE" | "MILD",
          "note": "string"
        }
      ],
      "contraindications": [
        {
          "drug": "string",
          "reason": "string"
        }
      ]
    },
    "guidelines": [
      {
        "source": "string",
        "title": "string",
        "recommendation": "string",
        "evidenceLevel": "A" | "B" | "C" | "D"
      }
    ]
  },
  "complianceCheck": {
    "hipaaCompliant": boolean,
    "nphiesEligible": boolean,
    "saudiMOHProtocol": "FOLLOWED" | "NOT_APPLICABLE"
  }
}
```

#### Drug Interaction Check

**Endpoint:** `POST /webhook/clinicallinc/drug-interaction`

**Request Body:**
```json
{
  "medications": [
    {
      "name": "string",
      "code": "string",
      "dose": "string"
    }
  ],
  "patientData": {
    "age": number,
    "conditions": ["string"],
    "allergies": ["string"]
  }
}
```

#### Treatment Protocol

**Endpoint:** `POST /webhook/clinicallinc/treatment-protocol`

**Request Body:**
```json
{
  "condition": "string",
  "icd10": "string",
  "patientData": {
    "age": number,
    "gender": "string",
    "comorbidities": ["string"],
    "currentMedications": ["string"]
  },
  "severity": "MILD" | "MODERATE" | "SEVERE",
  "preferredLanguage": "en" | "ar"
}
```

---

### HEALTHCARELINC - Healthcare Workflows

Patient management and healthcare operations.

#### Register Patient

**Endpoint:** `POST /webhook/healthcarelinc/register-patient`

**Request Body:**
```json
{
  "patientData": {
    "name": "string (required)",
    "nationalId": "string (required)",
    "dateOfBirth": "YYYY-MM-DD (required)",
    "gender": "male" | "female" | "other" (required)",
    "phone": "string (required)",
    "email": "string",
    "address": {
      "street": "string",
      "city": "string",
      "postalCode": "string",
      "country": "string"
    },
    "insurance": {
      "payerId": "string",
      "memberId": "string",
      "policyNumber": "string"
    },
    "emergencyContact": {
      "name": "string",
      "relationship": "string",
      "phone": "string"
    },
    "preferredLanguage": "en" | "ar"
  }
}
```

**Response:**
```json
{
  "success": true,
  "patientId": "patient-uuid",
  "mrn": "MRN-2025-001",
  "message": {
    "en": "Patient registered successfully",
    "ar": "تم تسجيل المريض بنجاح"
  },
  "nextSteps": {
    "en": "Patient can now schedule appointments",
    "ar": "يمكن للمريض الآن جدولة المواعيد"
  }
}
```

#### Schedule Appointment

**Endpoint:** `POST /webhook/healthcarelinc/schedule-appointment`

**Request Body:**
```json
{
  "patientId": "patient-uuid (required)",
  "providerId": "provider-uuid (required)",
  "date": "YYYY-MM-DD (required)",
  "time": "HH:MM (required)",
  "type": "consultation" | "follow-up" | "procedure" | "screening",
  "reason": "string",
  "duration": number (minutes),
  "location": "string"
}
```

#### Order Lab Tests

**Endpoint:** `POST /webhook/healthcarelinc/order-labs`

**Request Body:**
```json
{
  "patientId": "patient-uuid",
  "providerId": "provider-uuid",
  "tests": [
    {
      "testCode": "string",
      "testName": "string",
      "priority": "STAT" | "URGENT" | "ROUTINE"
    }
  ],
  "clinicalIndication": "string",
  "specimenType": "string"
}
```

---

### COMPLIANCELINC - Audit & Compliance

Compliance monitoring and audit logging.

#### Log Audit Event

**Endpoint:** `POST /webhook/compliancelinc/audit-log`

**Request Body:**
```json
{
  "eventType": "PATIENT_ACCESS" | "PHI_DISCLOSURE" | "DATA_MODIFICATION" | "NPHIES_SUBMISSION",
  "userId": "user-uuid",
  "sessionId": "session-uuid",
  "ipAddress": "string",
  "userRole": "provider" | "admin" | "patient" | "staff",
  "resourceId": "string",
  "resourceType": "PATIENT" | "APPOINTMENT" | "LAB_RESULT" | "PRESCRIPTION",
  "action": "CREATE" | "READ" | "UPDATE" | "DELETE",
  "metadata": {
    // Event-specific metadata
  }
}
```

#### Compliance Check

**Endpoint:** `POST /webhook/compliancelinc/check`

**Request Body:**
```json
{
  "checkType": "HIPAA" | "NPHIES" | "SAUDI_MOH",
  "scope": "USER" | "FACILITY" | "TRANSACTION",
  "targetId": "string",
  "dateRange": {
    "start": "YYYY-MM-DD",
    "end": "YYYY-MM-DD"
  }
}
```

---

### Patient Portal

Patient-facing endpoints for self-service.

#### View Appointments

**Endpoint:** `POST /webhook/patient-portal/view-appointments`

**Request Body:**
```json
{
  "patientId": "patient-uuid",
  "language": "en" | "ar",
  "dateRange": {
    "start": "YYYY-MM-DD",
    "end": "YYYY-MM-DD"
  },
  "status": "SCHEDULED" | "COMPLETED" | "CANCELLED" | "ALL"
}
```

#### View Lab Results

**Endpoint:** `POST /webhook/patient-portal/view-lab-results`

**Request Body:**
```json
{
  "patientId": "patient-uuid",
  "language": "en" | "ar",
  "resultId": "string (optional)",
  "dateRange": {
    "start": "YYYY-MM-DD",
    "end": "YYYY-MM-DD"
  }
}
```

#### Request Prescription Refill

**Endpoint:** `POST /webhook/patient-portal/request-refill`

**Request Body:**
```json
{
  "patientId": "patient-uuid",
  "prescriptionId": "prescription-uuid",
  "pharmacyId": "pharmacy-uuid",
  "deliveryMethod": "PICKUP" | "DELIVERY",
  "language": "en" | "ar"
}
```

---

### Insurance Claims

NPHIES-compliant insurance claims processing.

#### Submit Claim

**Endpoint:** `POST /webhook/insurance/claims/submit`

See [EXAMPLES.md](EXAMPLES.md#insurance-claims-nphies) for detailed request/response examples.

#### Check Claim Status

**Endpoint:** `POST /webhook/insurance/claims/status`

**Request Body:**
```json
{
  "claimId": "claim-uuid",
  "nphiesReferenceNumber": "string"
}
```

#### Pre-Authorization

**Endpoint:** `POST /webhook/insurance/claims/pre-auth`

**Request Body:**
```json
{
  "patientId": "patient-uuid",
  "procedureCode": "string",
  "procedureName": "string",
  "diagnosisCode": "string",
  "diagnosisDescription": "string",
  "estimatedCost": number,
  "urgency": "STAT" | "URGENT" | "ROUTINE",
  "clinicalJustification": "string"
}
```

---

### System Health

System monitoring and health checks.

#### Health Check

**Endpoint:** `GET /webhook/system-health/check`

**Response:**
```json
{
  "status": "HEALTHY" | "DEGRADED" | "DOWN",
  "timestamp": "2025-01-15T10:00:00Z",
  "checks": {
    "database": {
      "status": "UP" | "DOWN",
      "responseTime": "string",
      "connections": number,
      "maxConnections": number
    },
    "workflows": {
      "active": number,
      "total": number,
      "failedInLast24h": number
    },
    "apiServices": {
      "anthropic": "UP" | "DOWN",
      "nphies": "UP" | "DOWN",
      "smtp": "UP" | "DOWN"
    }
  },
  "uptime": "string",
  "version": "string"
}
```

---

## Data Models

### Patient

```typescript
interface Patient {
  patientId: string;
  mrn: string;
  name: string;
  nationalId: string;
  dateOfBirth: string;
  gender: 'male' | 'female' | 'other';
  phone: string;
  email?: string;
  address: Address;
  insurance?: Insurance;
  emergencyContact?: EmergencyContact;
  preferredLanguage: 'en' | 'ar';
  createdAt: string;
  updatedAt: string;
}
```

### Appointment

```typescript
interface Appointment {
  appointmentId: string;
  patientId: string;
  providerId: string;
  date: string;
  time: string;
  type: 'consultation' | 'follow-up' | 'procedure' | 'screening';
  status: 'SCHEDULED' | 'CONFIRMED' | 'COMPLETED' | 'CANCELLED' | 'NO_SHOW';
  location: string;
  duration: number;
  reason?: string;
  notes?: string;
}
```

### Clinical Recommendation

```typescript
interface ClinicalRecommendation {
  recommendationId: string;
  requestType: string;
  primaryDiagnosis: Diagnosis;
  differentialDiagnoses: Diagnosis[];
  immediateActions: string[];
  investigations: Investigation[];
  drugInteractions: DrugInteraction;
  guidelines: Guideline[];
  confidence: 'HIGH' | 'MEDIUM' | 'LOW';
}
```

### Insurance Claim

```typescript
interface InsuranceClaim {
  claimId: string;
  nphiesReferenceNumber: string;
  patientId: string;
  providerId: string;
  claimType: 'professional' | 'institutional' | 'pharmacy';
  services: Service[];
  diagnoses: Diagnosis[];
  totalAmount: number;
  status: 'SUBMITTED' | 'PROCESSING' | 'APPROVED' | 'REJECTED' | 'PARTIALLY_APPROVED';
  submissionDate: string;
}
```

---

## Error Codes

### General Errors

| Code | Description |
|------|-------------|
| `ERR_VALIDATION_FAILED` | Request validation failed |
| `ERR_MISSING_REQUIRED_FIELD` | Required field is missing |
| `ERR_INVALID_FORMAT` | Invalid data format |
| `ERR_UNAUTHORIZED` | Authentication required |
| `ERR_FORBIDDEN` | Insufficient permissions |
| `ERR_NOT_FOUND` | Resource not found |
| `ERR_RATE_LIMIT_EXCEEDED` | Too many requests |
| `ERR_INTERNAL_SERVER_ERROR` | Internal server error |

### HIPAA/NPHIES Errors

| Code | Description |
|------|-------------|
| `ERR_HIPAA_VIOLATION` | HIPAA compliance violation detected |
| `ERR_NPHIES_INVALID` | NPHIES validation failed |
| `ERR_ELIGIBILITY_CHECK_FAILED` | Insurance eligibility check failed |
| `ERR_PHI_ACCESS_DENIED` | Protected Health Information access denied |
| `ERR_AUDIT_LOG_FAILED` | Failed to create audit log |

### Clinical Errors

| Code | Description |
|------|-------------|
| `ERR_DRUG_INTERACTION_SEVERE` | Severe drug interaction detected |
| `ERR_ALLERGY_CONTRAINDICATION` | Medication contraindicated due to allergy |
| `ERR_CLINICAL_GUIDELINE_VIOLATION` | Clinical guideline violation |
| `ERR_DIAGNOSIS_CONFIDENCE_LOW` | Diagnosis confidence too low |

### Translation Errors

| Code | Description |
|------|-------------|
| `ERR_TRANSLATION_FAILED` | Translation service error |
| `ERR_UNSUPPORTED_LANGUAGE` | Language not supported |
| `ERR_CONTENT_TOO_LONG` | Content exceeds maximum length |
| `ERR_MEDICAL_TERM_NOT_FOUND` | Medical term not in glossary |

---

## Rate Limits

Default rate limits (can be configured):

- **Translation API**: 100 requests/minute
- **Clinical Decision Support**: 50 requests/minute
- **Patient Portal**: 200 requests/minute
- **Insurance Claims**: 30 requests/minute
- **System Health**: Unlimited

---

## Versioning

API versioning follows semantic versioning (SemVer):

- **MAJOR**: Breaking changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible

Current version: `1.0.0`

---

## Support

For API support:
- **Documentation**: https://docs.brainsait.com
- **GitHub Issues**: https://github.com/Fadil369/n8n-nodes-brainsait/issues
- **Email**: support@brainsait.com

---

**Last Updated:** January 2025  
**API Version:** 1.0.0
