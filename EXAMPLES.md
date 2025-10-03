# BrainSAIT N8N Workflows - Usage Examples

This document provides comprehensive examples for using the BrainSAIT Healthcare AI Agents in your N8N workflows.

## Table of Contents

- [Translation Service (TTLINC)](#translation-service-ttlinc)
- [Clinical Decision Support (CLINICALLINC)](#clinical-decision-support-clinicallinc)
- [Patient Portal](#patient-portal)
- [Insurance Claims (NPHIES)](#insurance-claims-nphies)
- [Health Monitoring](#health-monitoring)
- [Advanced Use Cases](#advanced-use-cases)

---

## Translation Service (TTLINC)

### Basic Translation

Translate medical content between English and Arabic with context awareness.

**Endpoint:** `POST /webhook/ttlinc/translate`

#### Example 1: Clinical Note Translation

```bash
curl -X POST https://your-n8n-instance.com/webhook/ttlinc/translate \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Patient presents with acute myocardial infarction. Administered aspirin 325mg and started on heparin infusion.",
    "sourceLanguage": "en",
    "targetLanguage": "ar",
    "contentType": "CLINICAL_NOTE",
    "preserveMedicalTerms": true
  }'
```

**Response:**
```json
{
  "success": true,
  "requestId": "TTLINC-2025-001",
  "translation": {
    "original": "Patient presents with acute myocardial infarction...",
    "translated": "يعاني المريض من احتشاء عضلة القلب الحاد. تم إعطاء الأسبرين 325 ملغ وبدء تسريب الهيبارين.",
    "sourceLanguage": "en",
    "targetLanguage": "ar"
  },
  "quality": {
    "score": 95,
    "contentType": "CLINICAL_NOTE",
    "preservedTerms": ["myocardial infarction", "aspirin", "heparin"]
  },
  "audit": {
    "translatedAt": "2025-01-15T10:30:00Z",
    "complianceLevel": "HIPAA_NPHIES"
  }
}
```

#### Example 2: Lab Results Translation

```bash
curl -X POST https://your-n8n-instance.com/webhook/ttlinc/translate \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Hemoglobin: 12.5 g/dL (Normal: 13-17), White Blood Cell Count: 8,500/μL (Normal)",
    "sourceLanguage": "en",
    "targetLanguage": "ar",
    "contentType": "LAB_RESULT",
    "preserveMedicalTerms": true
  }'
```

#### Example 3: Prescription Translation

```bash
curl -X POST https://your-n8n-instance.com/webhook/ttlinc/translate \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Metformin 500mg twice daily with meals. Monitor blood glucose levels weekly.",
    "sourceLanguage": "en",
    "targetLanguage": "ar",
    "contentType": "PRESCRIPTION"
  }'
```

---

## Clinical Decision Support (CLINICALLINC)

### AI-Powered Diagnosis Support

**Endpoint:** `POST /webhook/clinicallinc/decision-support`

#### Example 1: Diagnosis Support

```bash
curl -X POST https://your-n8n-instance.com/webhook/clinicallinc/decision-support \
  -H "Content-Type: application/json" \
  -d '{
    "requestType": "DIAGNOSIS_SUPPORT",
    "providerId": "provider-uuid-123",
    "clinicalScenario": "65-year-old male with sudden onset chest pain, diaphoresis, and shortness of breath",
    "patientData": {
      "patientId": "patient-uuid-456",
      "demographics": {
        "age": 65,
        "gender": "male",
        "weight": 85,
        "height": 175
      },
      "medicalHistory": {
        "conditions": [
          "Type 2 Diabetes Mellitus",
          "Hypertension",
          "Hyperlipidemia"
        ],
        "medications": [
          { "name": "Metformin", "code": "6809", "dose": "1000mg", "frequency": "BID" },
          { "name": "Lisinopril", "code": "104375", "dose": "20mg", "frequency": "QD" },
          { "name": "Atorvastatin", "code": "83367", "dose": "40mg", "frequency": "QHS" }
        ],
        "allergies": ["Penicillin"],
        "familyHistory": ["Father - MI at age 60", "Mother - Stroke at age 70"]
      },
      "vitalSigns": {
        "bloodPressure": "160/95",
        "heartRate": 105,
        "temperature": 37.2,
        "respiratoryRate": 22,
        "oxygenSaturation": 94
      },
      "symptoms": [
        "Chest pain (8/10)",
        "Diaphoresis",
        "Shortness of breath",
        "Nausea"
      ]
    },
    "preferredLanguage": "en"
  }'
```

**Response:**
```json
{
  "success": true,
  "requestId": "CLINICALLINC-2025-001",
  "recommendations": {
    "primaryDiagnosis": {
      "condition": "Acute Coronary Syndrome (ACS)",
      "icd10": "I21.9",
      "confidence": "HIGH",
      "reasoning": "Patient presents with classic symptoms of ACS including chest pain, diaphoresis, and SOB. Multiple cardiac risk factors present (diabetes, hypertension, hyperlipidemia, age, family history)."
    },
    "differentialDiagnoses": [
      {
        "condition": "Unstable Angina",
        "icd10": "I20.0",
        "confidence": "MEDIUM"
      },
      {
        "condition": "Aortic Dissection",
        "icd10": "I71.0",
        "confidence": "LOW",
        "note": "Consider if pain is tearing/ripping quality"
      }
    ],
    "immediateActions": [
      "Call cardiology consult STAT",
      "Administer aspirin 325mg if not contraindicated",
      "Obtain 12-lead ECG immediately",
      "Start oxygen therapy (target SpO2 >94%)",
      "Establish IV access",
      "Order cardiac enzymes (Troponin, CK-MB)",
      "Consider nitroglycerin 0.4mg sublingual if BP allows"
    ],
    "investigations": [
      {
        "test": "12-Lead ECG",
        "urgency": "STAT",
        "reasoning": "Essential for diagnosing STEMI vs NSTEMI"
      },
      {
        "test": "Cardiac Troponins",
        "urgency": "STAT",
        "reasoning": "Biomarker for myocardial injury"
      },
      {
        "test": "Complete Blood Count",
        "urgency": "URGENT"
      },
      {
        "test": "Basic Metabolic Panel",
        "urgency": "URGENT"
      },
      {
        "test": "Chest X-ray",
        "urgency": "URGENT",
        "reasoning": "Rule out other causes"
      }
    ],
    "drugInteractions": {
      "warnings": [
        {
          "interaction": "Aspirin + Lisinopril",
          "severity": "MODERATE",
          "note": "May reduce antihypertensive effect, monitor BP"
        }
      ],
      "contraindications": [
        {
          "drug": "Penicillin-based antibiotics",
          "reason": "Known allergy"
        }
      ]
    },
    "guidelines": [
      {
        "source": "Saudi MOH Guidelines 2024",
        "title": "Acute Coronary Syndrome Management",
        "recommendation": "Immediate cardiology consultation and consideration for PCI within 90 minutes for STEMI"
      },
      {
        "source": "ACC/AHA Guidelines",
        "evidenceLevel": "A",
        "recommendation": "Dual antiplatelet therapy (Aspirin + P2Y12 inhibitor)"
      }
    ]
  },
  "complianceCheck": {
    "hipaaCompliant": true,
    "nphiesEligible": true,
    "saudiMOHProtocol": "FOLLOWED"
  },
  "audit": {
    "providerId": "provider-uuid-123",
    "timestamp": "2025-01-15T10:45:00Z",
    "sessionId": "session-789"
  }
}
```

#### Example 2: Drug Interaction Check

```bash
curl -X POST https://your-n8n-instance.com/webhook/clinicallinc/drug-interaction \
  -H "Content-Type: application/json" \
  -d '{
    "requestType": "DRUG_INTERACTION_CHECK",
    "providerId": "provider-uuid-123",
    "medications": [
      { "name": "Warfarin", "code": "11289" },
      { "name": "Aspirin", "code": "1191" },
      { "name": "Ibuprofen", "code": "5640" }
    ],
    "patientData": {
      "age": 70,
      "conditions": ["Atrial Fibrillation", "Chronic Pain"]
    }
  }'
```

#### Example 3: Treatment Protocol Recommendation

```bash
curl -X POST https://your-n8n-instance.com/webhook/clinicallinc/treatment-protocol \
  -H "Content-Type: application/json" \
  -d '{
    "requestType": "TREATMENT_PROTOCOL",
    "condition": "Type 2 Diabetes Mellitus",
    "patientData": {
      "age": 55,
      "hba1c": 8.5,
      "eGFR": 75,
      "currentMedications": ["Metformin 1000mg BID"]
    },
    "preferredLanguage": "ar"
  }'
```

---

## Patient Portal

### Patient Dashboard Access

**Endpoint:** `POST /webhook/patient-portal/*`

#### Example 1: View Appointments

```bash
curl -X POST https://your-n8n-instance.com/webhook/patient-portal/view-appointments \
  -H "Content-Type: application/json" \
  -d '{
    "patientId": "patient-uuid-456",
    "language": "en",
    "dateRange": {
      "start": "2025-01-15",
      "end": "2025-02-15"
    }
  }'
```

**Response:**
```json
{
  "success": true,
  "appointments": [
    {
      "appointmentId": "appt-001",
      "date": "2025-01-20",
      "time": "10:00",
      "provider": {
        "name": "Dr. Ahmed Al-Sayed",
        "specialty": "Cardiology",
        "department": "Cardiology"
      },
      "location": "Building A, Floor 3, Room 301",
      "type": "Follow-up",
      "status": "CONFIRMED",
      "instructions": {
        "en": "Please bring your medication list and recent lab results",
        "ar": "يرجى إحضار قائمة الأدوية ونتائج المختبر الأخيرة"
      }
    }
  ]
}
```

#### Example 2: View Lab Results

```bash
curl -X POST https://your-n8n-instance.com/webhook/patient-portal/view-lab-results \
  -H "Content-Type: application/json" \
  -d '{
    "patientId": "patient-uuid-456",
    "language": "ar",
    "resultId": "lab-result-789"
  }'
```

#### Example 3: Request Prescription Refill

```bash
curl -X POST https://your-n8n-instance.com/webhook/patient-portal/request-refill \
  -H "Content-Type: application/json" \
  -d '{
    "patientId": "patient-uuid-456",
    "prescriptionId": "rx-12345",
    "medication": {
      "name": "Metformin",
      "dose": "1000mg",
      "frequency": "BID"
    },
    "pharmacyId": "pharmacy-001",
    "language": "en"
  }'
```

---

## Insurance Claims (NPHIES)

### NPHIES Claims Submission

**Endpoint:** `POST /webhook/insurance/claims/*`

#### Example 1: Submit Insurance Claim

```bash
curl -X POST https://your-n8n-instance.com/webhook/insurance/claims/submit \
  -H "Content-Type: application/json" \
  -d '{
    "providerId": "provider-uuid-123",
    "patientId": "patient-uuid-456",
    "serviceDate": "2025-01-15",
    "claimData": {
      "claimType": "professional",
      "priority": "normal",
      "payee": {
        "type": "provider",
        "providerId": "provider-uuid-123"
      },
      "insurance": {
        "payerId": "insurance-001",
        "memberId": "INS-2025-12345",
        "policyNumber": "POL-67890"
      },
      "diagnoses": [
        {
          "code": "E11.9",
          "system": "ICD-10",
          "description": "Type 2 diabetes mellitus without complications",
          "type": "principal"
        },
        {
          "code": "I10",
          "system": "ICD-10",
          "description": "Essential (primary) hypertension",
          "type": "secondary"
        }
      ],
      "services": [
        {
          "serviceCode": "99213",
          "serviceType": "consultation",
          "serviceName": "Office Visit - Established Patient",
          "quantity": 1,
          "unitPrice": 350.00,
          "totalPrice": 350.00,
          "dateOfService": "2025-01-15"
        },
        {
          "serviceCode": "80053",
          "serviceType": "laboratory",
          "serviceName": "Comprehensive Metabolic Panel",
          "quantity": 1,
          "unitPrice": 150.00,
          "totalPrice": 150.00,
          "dateOfService": "2025-01-15"
        }
      ],
      "totalAmount": 500.00,
      "currency": "SAR"
    },
    "submissionMetadata": {
      "nphiesVersion": "2.0",
      "facilityLicense": "FAC-2025-001",
      "submittedBy": "provider-uuid-123"
    }
  }'
```

**Response:**
```json
{
  "success": true,
  "claimId": "CLAIM-2025-001",
  "nphiesReferenceNumber": "NPHIES-REF-123456",
  "status": "SUBMITTED",
  "submissionTimestamp": "2025-01-15T11:00:00Z",
  "eligibilityStatus": {
    "eligible": true,
    "coverageDetails": {
      "network": "PRIMARY",
      "copayAmount": 50.00,
      "coveredAmount": 450.00
    }
  },
  "estimatedProcessingTime": "48-72 hours",
  "nextSteps": {
    "en": "Claim submitted to NPHIES. You will receive notification once processed.",
    "ar": "تم تقديم المطالبة إلى نفيس. ستتلقى إشعارًا بمجرد المعالجة."
  },
  "audit": {
    "submittedBy": "provider-uuid-123",
    "ipAddress": "192.168.1.100",
    "complianceLevel": "NPHIES_COMPLIANT"
  }
}
```

#### Example 2: Check Claim Status

```bash
curl -X POST https://your-n8n-instance.com/webhook/insurance/claims/status \
  -H "Content-Type: application/json" \
  -d '{
    "claimId": "CLAIM-2025-001",
    "nphiesReferenceNumber": "NPHIES-REF-123456"
  }'
```

#### Example 3: Pre-Authorization Request

```bash
curl -X POST https://your-n8n-instance.com/webhook/insurance/claims/pre-auth \
  -H "Content-Type: application/json" \
  -d '{
    "patientId": "patient-uuid-456",
    "procedureCode": "45378",
    "procedureName": "Colonoscopy",
    "diagnosisCode": "K51.9",
    "diagnosisDescription": "Ulcerative colitis",
    "estimatedCost": 3500.00,
    "urgency": "ROUTINE",
    "clinicalJustification": "Patient has history of UC with recent symptoms requiring evaluation"
  }'
```

---

## Health Monitoring

### System Health Check

**Endpoint:** `GET /webhook/system-health/check`

#### Example 1: Basic Health Check

```bash
curl -X GET https://your-n8n-instance.com/webhook/system-health/check
```

**Response:**
```json
{
  "status": "HEALTHY",
  "timestamp": "2025-01-15T12:00:00Z",
  "checks": {
    "database": {
      "status": "UP",
      "responseTime": "15ms",
      "connections": 5,
      "maxConnections": 100
    },
    "workflows": {
      "active": 4,
      "total": 4,
      "failedInLast24h": 0
    },
    "apiServices": {
      "anthropic": "UP",
      "nphies": "UP",
      "smtp": "UP"
    },
    "auditLogs": {
      "last24h": 156,
      "avgProcessingTime": "45ms"
    }
  },
  "uptime": "99.98%",
  "version": "1.0.0"
}
```

---

## Advanced Use Cases

### Multi-Step Workflow Example

#### Complete Patient Journey: From Registration to Insurance Claim

```javascript
// Step 1: Register Patient
const registrationResponse = await fetch('https://your-n8n-instance.com/webhook/healthcarelinc/register-patient', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    patientData: {
      name: "Ahmad Al-Mansour",
      nationalId: "1234567890",
      dateOfBirth: "1970-05-15",
      gender: "male",
      phone: "+966501234567",
      email: "ahmad@example.com",
      address: {
        street: "King Fahd Road",
        city: "Riyadh",
        postalCode: "12345",
        country: "SA"
      },
      insurance: {
        payerId: "insurance-001",
        memberId: "INS-2025-12345",
        policyNumber: "POL-67890"
      },
      preferredLanguage: "ar"
    }
  })
});

// Step 2: Schedule Appointment
const appointmentResponse = await fetch('https://your-n8n-instance.com/webhook/healthcarelinc/schedule-appointment', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    patientId: registrationResponse.patientId,
    providerId: "provider-uuid-123",
    date: "2025-01-20",
    time: "10:00",
    type: "consultation",
    reason: "Annual checkup and diabetes follow-up"
  })
});

// Step 3: Clinical Decision Support During Visit
const clinicalResponse = await fetch('https://your-n8n-instance.com/webhook/clinicallinc/decision-support', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    requestType: "TREATMENT_PROTOCOL",
    patientId: registrationResponse.patientId,
    condition: "Type 2 Diabetes Mellitus",
    patientData: {
      hba1c: 7.8,
      currentMedications: ["Metformin 1000mg BID"]
    }
  })
});

// Step 4: Submit Insurance Claim
const claimResponse = await fetch('https://your-n8n-instance.com/webhook/insurance/claims/submit', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    patientId: registrationResponse.patientId,
    providerId: "provider-uuid-123",
    serviceDate: "2025-01-20",
    claimData: {
      // ... claim details
    }
  })
});

// Step 5: Translate Clinical Notes to Arabic for Patient
const translationResponse = await fetch('https://your-n8n-instance.com/webhook/ttlinc/translate', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    content: "Continue current diabetes management. Schedule follow-up in 3 months.",
    sourceLanguage: "en",
    targetLanguage: "ar",
    contentType: "CLINICAL_NOTE"
  })
});
```

---

## Best Practices

### 1. Error Handling

Always wrap API calls in try-catch blocks:

```javascript
try {
  const response = await fetch(url, options);
  const data = await response.json();
  
  if (!data.success) {
    console.error('API Error:', data.error);
    // Handle error appropriately
  }
  
  return data;
} catch (error) {
  console.error('Network Error:', error);
  // Implement retry logic or fallback
}
```

### 2. Authentication

Secure your webhooks with authentication headers:

```javascript
const response = await fetch(url, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer YOUR_API_KEY',
    'X-Request-ID': generateRequestId()
  },
  body: JSON.stringify(data)
});
```

### 3. Rate Limiting

Implement rate limiting for production environments:

```javascript
const rateLimiter = {
  requests: 0,
  maxRequests: 100,
  windowMs: 60000, // 1 minute
  
  async checkLimit() {
    if (this.requests >= this.maxRequests) {
      throw new Error('Rate limit exceeded');
    }
    this.requests++;
    
    setTimeout(() => {
      this.requests = Math.max(0, this.requests - 1);
    }, this.windowMs);
  }
};
```

### 4. Audit Logging

Always include audit context in sensitive operations:

```javascript
const auditContext = {
  userId: currentUser.id,
  sessionId: session.id,
  ipAddress: request.ip,
  timestamp: new Date().toISOString(),
  action: 'PATIENT_DATA_ACCESS'
};

const response = await fetch(url, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    ...requestData,
    auditContext
  })
});
```

---

## Testing

### Test with cURL

```bash
# Save this as test-suite.sh
#!/bin/bash

BASE_URL="https://your-n8n-instance.com"

echo "Testing Translation Service..."
curl -X POST $BASE_URL/webhook/ttlinc/translate \
  -H "Content-Type: application/json" \
  -d '{"content": "Test", "sourceLanguage": "en", "targetLanguage": "ar", "contentType": "CLINICAL_NOTE"}'

echo "\nTesting System Health..."
curl -X GET $BASE_URL/webhook/system-health/check

echo "\nAll tests completed!"
```

### Test with Postman

Import this collection:

```json
{
  "info": {
    "name": "BrainSAIT N8N API Tests",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Translation Test",
      "request": {
        "method": "POST",
        "header": [{"key": "Content-Type", "value": "application/json"}],
        "body": {
          "mode": "raw",
          "raw": "{\"content\": \"Test\", \"sourceLanguage\": \"en\", \"targetLanguage\": \"ar\", \"contentType\": \"CLINICAL_NOTE\"}"
        },
        "url": "{{base_url}}/webhook/ttlinc/translate"
      }
    }
  ]
}
```

---

## Support

For issues or questions:
- **GitHub Issues**: https://github.com/Fadil369/n8n-nodes-brainsait/issues
- **Email**: fadil@brainsait.com
- **Documentation**: https://docs.brainsait.com

---

**Last Updated:** January 2025  
**Version:** 1.0.0
