# n8n-nodes-brainsait

![BrainSAIT Logo](https://brainsait.com/logo.png)

**HIPAA/NPHIES Compliant Healthcare AI Agents for N8N**

A comprehensive N8N community node package providing AI-powered healthcare workflow automation with full HIPAA and NPHIES compliance, designed specifically for Saudi Arabian healthcare providers.

## 🏥 Features

### 5 Specialized AI Agents

1. **MASTERLINC** - Master Orchestrator
   - Central routing and coordination
   - Role-based access control
   - HIPAA audit logging
   - Multi-agent workflow orchestration

2. **HEALTHCARELINC** - Healthcare Workflows
   - Patient registration
   - Appointment scheduling
   - Lab/radiology orders
   - FHIR R4 compliant
   - NPHIES integration

3. **CLINICALLINC** - Clinical Decision Support
   - AI-powered diagnosis support
   - Drug interaction checking
   - Evidence-based treatment recommendations
   - Clinical guideline compliance
   - Saudi MOH protocols

4. **TTLINC** - Translation & Localization
   - Medical translation (Arabic ↔ English)
   - RTL formatting support
   - Medical terminology preservation
   - FHIR resource translation

5. **COMPLIANCELINC** - Audit & Compliance
   - Automated compliance monitoring
   - HIPAA violation detection
   - NPHIES submission tracking
   - Risk scoring and reporting
   - Anomaly detection

### Additional Workflows

- Patient Portal Integration
- Insurance Claims Processing
- Lab Results Notifications
- System Health Monitoring
- **Terry** - AI System Monitor (inspired by [NetworkChuck's n8n-terry-guide](https://github.com/theNetworkChuck/n8n-terry-guide))

## 📋 Prerequisites

- Node.js >= 18.0.0
- N8N >= 1.0.0
- PostgreSQL >= 13
- Redis >= 6.0
- Docker & Docker Compose (optional)

## 🚀 Installation

### Option 1: NPM Installation

```bash
# Install globally
npm install -g n8n-nodes-brainsait

# Or install in your N8N project
npm install n8n-nodes-brainsait
```

### Option 2: Manual Installation

```bash
# Clone the repository
git clone https://github.com/Fadil369/n8n-nodes-brainsait.git
cd n8n-nodes-brainsait

# Install dependencies
npm install

# Build the package
npm run build

# Install locally
npm run install:local
```

### Option 3: Docker Deployment

```bash
# Clone and configure
git clone https://github.com/Fadil369/n8n-nodes-brainsait.git
cd n8n-nodes-brainsait

# Copy and configure environment
cp .env.example .env
# Edit .env with your settings

# Deploy
docker-compose up -d
```

## ⚙️ Configuration

### Environment Variables

Create a `.env` file with the following:

```bash
# Database
POSTGRES_HOST=your-db-host
POSTGRES_PORT=5432
POSTGRES_DB=brainsait
POSTGRES_USER=your-user
POSTGRES_PASSWORD=your-password

# AI Services
ANTHROPIC_API_KEY=your-api-key
OPENAI_API_KEY=your-api-key

# NPHIES Integration
NPHIES_API_URL=https://nphies.sa.gov/api/v2
NPHIES_PROVIDER_LICENSE=your-license
NPHIES_FACILITY_ID=your-facility-id
NPHIES_API_KEY=your-nphies-key

# Notifications
SLACK_API_KEY=your-slack-key
SMTP_HOST=smtp.gmail.com
SMTP_USER=notifications@yourdomain.com
SMTP_PASSWORD=your-smtp-password
```

### Database Setup

```bash
# Initialize the database schema
psql -h localhost -U your-user -d brainsait -f schema.sql

# Or using the deployment script
./deploy-n8n.sh
```

## 📚 Usage Examples

### Example 1: Submit Insurance Claim

```bash
POST https://your-n8n-instance.com/webhook/insurance/claims/submit-claim
```

```json
{
  "providerId": "uuid-provider-123",
  "patientId": "uuid-patient-456",
  "serviceDate": "2025-01-15",
  "claimData": {
    "services": [
      {
        "serviceCode": "99213",
        "serviceName": "Office Visit",
        "serviceType": "consultation",
        "quantity": 1,
        "unitPrice": 350.00
      }
    ],
    "diagnoses": [
      {
        "code": "E11.9",
        "description": "Type 2 diabetes mellitus without complications"
      }
    ],
    "priority": "normal"
  }
}
```

### Example 2: Request Clinical Decision Support

```bash
POST https://your-n8n-instance.com/webhook/clinicallinc/decision-support
```

```json
{
  "clinicalScenario": "45-year-old male with chest pain, history of hypertension",
  "requestType": "DIAGNOSIS_SUPPORT",
  "providerId": "uuid-provider-123",
  "patientData": {
    "patientId": "uuid-patient-456",
    "demographics": {
      "age": 45,
      "gender": "male"
    },
    "medicalHistory": {
      "conditions": ["Hypertension"],
      "medications": [
        {
          "name": "Lisinopril",
          "code": "104375"
        }
      ],
      "allergies": []
    },
    "vitalSigns": {
      "bloodPressure": "150/95",
      "heartRate": 88,
      "temperature": 37.2
    },
    "preferredLanguage": "en"
  }
}
```

### Example 3: Translate Medical Content

```bash
POST https://your-n8n-instance.com/webhook/ttlinc/translate
```

```json
{
  "content": "The patient presents with acute onset chest pain radiating to the left arm.",
  "sourceLanguage": "en",
  "targetLanguage": "ar",
  "contentType": "CLINICAL_NOTE",
  "preserveMedicalTerms": true
}
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│              MASTERLINC Orchestrator            │
│          (Master Routing & Coordination)        │
└────────┬────────────────────────────────┬───────┘
         │                                │
    ┌────▼────────┐                 ┌─────▼──────┐
    │ HEALTHCARE  │                 │  CLINICAL  │
    │    LINC     │                 │    LINC    │
    │  (FHIR/     │                 │  (AI CDS)  │
    │   NPHIES)   │                 │            │
    └─────────────┘                 └────────────┘
         │                                │
    ┌────▼────────┐                 ┌─────▼──────┐
    │      TT     │                 │ COMPLIANCE │
    │    LINC     │                 │    LINC    │
    │ (i18n/l10n) │                 │  (Audit)   │
    └─────────────┘                 └────────────┘
         │                                │
    └────┴────────────────────────────────┴───────┘
                        │
              ┌─────────▼──────────┐
              │   PostgreSQL DB    │
              │   (HIPAA Audit)    │
              └────────────────────┘
```

## 🔒 Security & Compliance

### HIPAA Compliance
- End-to-end encryption
- Comprehensive audit logging
- PHI access tracking
- Automatic de-identification

### NPHIES Compliance
- Real-time eligibility verification
- Claims submission & tracking
- Saudi MOH protocol adherence

### Data Security
- AES-256-GCM encryption
- TLS 1.3 for all connections
- Role-based access control (RBAC)
- SOC 2 Type II compatible

## 🧪 Testing

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Lint code
npm run lint

# Format code
npm run format
```

## 📖 Documentation

Comprehensive documentation is available in the repository:

- **[Quick Start Guide](QUICK_START.md)** - Get started in 5 minutes
- **[Deployment Guide](DEPLOYMENT_GUIDE.md)** - Complete deployment instructions
- **[API Reference](API_REFERENCE.md)** - Complete API documentation
- **[Examples](EXAMPLES.md)** - Comprehensive usage examples
- **[Architecture](ARCHITECTURE.md)** - System architecture and design
- **[Terry Integration Guide](TERRY_INTEGRATION_GUIDE.md)** - AI-powered system monitoring
- **[Troubleshooting](TROUBLESHOOTING.md)** - Common issues and solutions
- **[Contributing](CONTRIBUTING.md)** - Contribution guidelines
- **[Changelog](CHANGELOG.md)** - Version history

Online documentation: https://docs.brainsait.com

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Fork and clone the repo
git clone https://github.com/YOUR_USERNAME/n8n-nodes-brainsait.git

# Install dependencies
npm install

# Create a feature branch
git checkout -b feature/my-new-feature

# Make your changes and commit
git commit -am 'Add some feature'

# Push to your fork
git push origin feature/my-new-feature

# Open a Pull Request
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This software is provided for healthcare workflow automation. While designed with HIPAA and NPHIES compliance in mind, ultimate responsibility for regulatory compliance rests with the implementing organization. Always consult with legal and compliance experts before deploying in production healthcare environments.

## 👥 Author

**Dr. Mohamed El Fadil**
- Email: fadil@brainsait.com
- GitHub: [@Fadil369](https://github.com/Fadil369)
- Website: [brainsait.com](https://brainsait.com)

See also the list of [contributors](https://github.com/Fadil369/n8n-nodes-brainsait/contributors) who participated in this project.

## 🙏 Acknowledgments

- N8N Community
- Saudi Ministry of Health
- NPHIES Team
- FHIR® Community
- Anthropic Claude AI
- Healthcare IT Standards

## 📞 Support

- **Documentation**: https://docs.brainsait.com
- **Issues**: [GitHub Issues](https://github.com/Fadil369/n8n-nodes-brainsait/issues)
- **Email**: support@brainsait.com
- **Website**: https://brainsait.com

## 📊 Roadmap

- [x] v1.0.0 - Initial release with 5 core agents
- [ ] v1.1.0 - Enhanced NPHIES features
- [ ] v1.2.0 - Telemedicine integration
- [ ] v1.3.0 - Advanced analytics dashboard
- [ ] v2.0.0 - Multi-facility support
- [ ] v2.1.0 - Mobile app integration

---

**Made with ❤️ by Dr. Mohamed El Fadil for the healthcare community**
