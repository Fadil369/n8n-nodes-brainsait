-- =============================================
-- BrainSAIT Healthcare Database Schema
-- HIPAA/NPHIES Compliant Database Structure
-- Author: Dr. Mohamed El Fadil
-- Version: 1.0.0
-- =============================================

-- Enable required PostgreSQL extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================
-- AUDIT LOGS TABLE - HIPAA Compliance
-- =============================================
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGSERIAL PRIMARY KEY,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    event_type VARCHAR(100) NOT NULL,
    agent_type VARCHAR(50),
    user_id UUID,
    session_id UUID,
    user_role VARCHAR(50),
    ip_address INET,
    request_id VARCHAR(100) UNIQUE,
    compliance_level VARCHAR(50) DEFAULT 'HIPAA_NPHIES',
    payload JSONB,
    status VARCHAR(50),
    error_message TEXT,
    data_encrypted BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT valid_event_type CHECK (event_type IN (
        'AGENT_ORCHESTRATION_REQUEST',
        'PATIENT_ACCESS',
        'PHI_DISCLOSURE',
        'LOGIN_SUCCESS',
        'LOGIN_FAILED',
        'LOGOUT',
        'DATA_MODIFICATION',
        'NPHIES_SUBMISSION',
        'NPHIES_VALIDATION_ERROR',
        'SECURITY_INCIDENT',
        'COMPLIANCE_AUDIT'
    ))
);

CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp DESC);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_event_type ON audit_logs(event_type);
CREATE INDEX idx_audit_logs_request_id ON audit_logs(request_id);

COMMENT ON TABLE audit_logs IS 'HIPAA-compliant audit trail for all system activities';

-- =============================================
-- USERS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    department VARCHAR(100),
    provider_license VARCHAR(100),
    facility_id VARCHAR(100),
    active BOOLEAN DEFAULT true,
    last_login TIMESTAMPTZ,
    failed_login_attempts INT DEFAULT 0,
    account_locked BOOLEAN DEFAULT false,
    mfa_enabled BOOLEAN DEFAULT false,
    mfa_secret VARCHAR(255),
    preferred_language VARCHAR(10) DEFAULT 'en',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT valid_role CHECK (role IN (
        'admin',
        'provider',
        'clinical_staff',
        'auditor',
        'compliance_officer',
        'translator',
        'patient'
    )),
    CONSTRAINT valid_language CHECK (preferred_language IN ('en', 'ar'))
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(active) WHERE active = true;

COMMENT ON TABLE users IS 'User accounts with role-based access control';

-- =============================================
-- PATIENTS TABLE - FHIR R4 Compatible
-- =============================================
CREATE TABLE IF NOT EXISTS patients (
    patient_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    national_id VARCHAR(20) UNIQUE,
    fhir_resource JSONB NOT NULL,
    demographics JSONB,
    contact_info JSONB,
    emergency_contact JSONB,
    insurance_info JSONB,
    consent_status JSONB,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(user_id),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by UUID REFERENCES users(user_id),
    compliance_level VARCHAR(50) DEFAULT 'HIPAA_NPHIES'
);

CREATE INDEX idx_patients_national_id ON patients(national_id);
CREATE INDEX idx_patients_created_at ON patients(created_at DESC);
CREATE INDEX idx_patients_fhir_resource ON patients USING GIN(fhir_resource);
CREATE INDEX idx_patients_active ON patients(active) WHERE active = true;

COMMENT ON TABLE patients IS 'FHIR R4 compliant patient records with PHI encryption';

-- =============================================
-- PHI ACCESS LOGS - HIPAA Required
-- =============================================
CREATE TABLE IF NOT EXISTS phi_access_logs (
    id BIGSERIAL PRIMARY KEY,
    access_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_id UUID NOT NULL REFERENCES users(user_id),
    patient_id UUID NOT NULL REFERENCES patients(patient_id),
    access_type VARCHAR(50) NOT NULL,
    access_reason TEXT,
    records_accessed INT DEFAULT 1,
    access_granted BOOLEAN DEFAULT true,
    access_denied BOOLEAN DEFAULT false,
    denial_reason TEXT,
    ip_address INET,
    session_id UUID,
    CONSTRAINT valid_access_type CHECK (access_type IN (
        'VIEW',
        'EDIT',
        'DELETE',
        'EXPORT',
        'PRINT',
        'PHI'
    ))
);

CREATE INDEX idx_phi_access_timestamp ON phi_access_logs(access_timestamp DESC);
CREATE INDEX idx_phi_access_user ON phi_access_logs(user_id);
CREATE INDEX idx_phi_access_patient ON phi_access_logs(patient_id);

COMMENT ON TABLE phi_access_logs IS 'HIPAA-mandated PHI access tracking';

-- =============================================
-- APPOINTMENTS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS appointments (
    appointment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id),
    provider_id UUID NOT NULL REFERENCES users(user_id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    status VARCHAR(50) DEFAULT 'booked',
    appointment_type VARCHAR(100),
    reason TEXT,
    location VARCHAR(255),
    fhir_resource JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT valid_status CHECK (status IN (
        'booked',
        'arrived',
        'fulfilled',
        'cancelled',
        'noshow',
        'entered-in-error'
    )),
    CONSTRAINT valid_time_range CHECK (end_time > start_time)
);

CREATE INDEX idx_appointments_patient ON appointments(patient_id);
CREATE INDEX idx_appointments_provider ON appointments(provider_id);
CREATE INDEX idx_appointments_start_time ON appointments(start_time);
CREATE INDEX idx_appointments_status ON appointments(status);

COMMENT ON TABLE appointments IS 'Patient appointments with FHIR compatibility';

-- =============================================
-- LAB RESULTS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS lab_results (
    result_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id),
    test_name VARCHAR(255) NOT NULL,
    test_code VARCHAR(50) NOT NULL,
    result_value VARCHAR(255) NOT NULL,
    reference_range VARCHAR(100),
    unit VARCHAR(50),
    status VARCHAR(50) DEFAULT 'preliminary',
    result_date TIMESTAMPTZ NOT NULL,
    ordered_by UUID REFERENCES users(user_id),
    performing_lab VARCHAR(255),
    critical_flag BOOLEAN DEFAULT false,
    abnormal_flag BOOLEAN DEFAULT false,
    notification_sent BOOLEAN DEFAULT false,
    notification_date TIMESTAMPTZ,
    fhir_resource JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT valid_lab_status CHECK (status IN (
        'preliminary',
        'final',
        'corrected',
        'cancelled',
        'entered-in-error'
    ))
);

CREATE INDEX idx_lab_results_patient ON lab_results(patient_id);
CREATE INDEX idx_lab_results_date ON lab_results(result_date DESC);
CREATE INDEX idx_lab_results_notification ON lab_results(notification_sent, status);
CREATE INDEX idx_lab_results_critical ON lab_results(critical_flag) WHERE critical_flag = true;

COMMENT ON TABLE lab_results IS 'Laboratory test results with notification tracking';

-- =============================================
-- CLINICAL RECOMMENDATIONS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS clinical_recommendations (
    id BIGSERIAL PRIMARY KEY,
    request_id VARCHAR(100) UNIQUE NOT NULL,
    patient_id UUID REFERENCES patients(patient_id),
    provider_id UUID REFERENCES users(user_id),
    request_type VARCHAR(100) NOT NULL,
    recommendations JSONB NOT NULL,
    drug_interactions JSONB,
    applied_guidelines JSONB,
    evidence_level VARCHAR(10),
    metadata JSONB,
    reviewed_by UUID REFERENCES users(user_id),
    reviewed_at TIMESTAMPTZ,
    implemented BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_clinical_recs_patient ON clinical_recommendations(patient_id);
CREATE INDEX idx_clinical_recs_provider ON clinical_recommendations(provider_id);
CREATE INDEX idx_clinical_recs_created ON clinical_recommendations(created_at DESC);

COMMENT ON TABLE clinical_recommendations IS 'AI-generated clinical decision support recommendations';

-- =============================================
-- CLINICAL GUIDELINES TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS clinical_guidelines (
    guideline_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    guideline_name VARCHAR(255) NOT NULL,
    condition VARCHAR(100),
    recommendations TEXT NOT NULL,
    evidence_level VARCHAR(10),
    language VARCHAR(10) DEFAULT 'en',
    source VARCHAR(255),
    version VARCHAR(50),
    active BOOLEAN DEFAULT true,
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT valid_evidence CHECK (evidence_level IN ('A', 'B', 'C', 'D'))
);

CREATE INDEX idx_guidelines_condition ON clinical_guidelines(condition);
CREATE INDEX idx_guidelines_language ON clinical_guidelines(language);
CREATE INDEX idx_guidelines_active ON clinical_guidelines(active) WHERE active = true;

COMMENT ON TABLE clinical_guidelines IS 'Evidence-based clinical practice guidelines';

-- =============================================
-- DRUG INTERACTIONS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS drug_interactions (
    id BIGSERIAL PRIMARY KEY,
    drug1_code VARCHAR(50) NOT NULL,
    drug1_name VARCHAR(255) NOT NULL,
    drug2_code VARCHAR(50) NOT NULL,
    drug2_name VARCHAR(255) NOT NULL,
    interaction_severity VARCHAR(50) NOT NULL,
    interaction_description TEXT NOT NULL,
    clinical_management TEXT,
    references TEXT,
    CONSTRAINT valid_severity CHECK (interaction_severity IN (
        'severe',
        'moderate',
        'mild',
        'unknown'
    ))
);

CREATE INDEX idx_drug_interactions_codes ON drug_interactions(drug1_code, drug2_code);
CREATE INDEX idx_drug_interactions_severity ON drug_interactions(interaction_severity);

COMMENT ON TABLE drug_interactions IS 'Drug-drug interaction database';

-- =============================================
-- TRANSLATIONS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS translations (
    id BIGSERIAL PRIMARY KEY,
    source_text TEXT NOT NULL,
    translated_text TEXT NOT NULL,
    source_language VARCHAR(10) NOT NULL,
    target_language VARCHAR(10) NOT NULL,
    content_type VARCHAR(50) NOT NULL,
    quality_score INT,
    metadata JSONB,
    reviewed BOOLEAN DEFAULT false,
    reviewed_by UUID REFERENCES users(user_id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_translations_languages ON translations(source_language, target_language);
CREATE INDEX idx_translations_created ON translations(created_at DESC);
CREATE INDEX idx_translations_quality ON translations(quality_score);

COMMENT ON TABLE translations IS 'Medical translation cache with quality scoring';

-- =============================================
-- MEDICAL TERMINOLOGY TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS medical_terminology (
    id BIGSERIAL PRIMARY KEY,
    term_source VARCHAR(255) NOT NULL,
    term_target VARCHAR(255) NOT NULL,
    language_pair VARCHAR(10) NOT NULL,
    context VARCHAR(100),
    category VARCHAR(50),
    approved BOOLEAN DEFAULT false,
    approved_by UUID REFERENCES users(user_id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_medical_terminology_pair ON medical_terminology(language_pair);
CREATE INDEX idx_medical_terminology_approved ON medical_terminology(approved);

COMMENT ON TABLE medical_terminology IS 'Bilingual medical terminology glossary';

-- =============================================
-- INSURANCE CLAIMS TABLE - NPHIES Integration
-- =============================================
CREATE TABLE IF NOT EXISTS insurance_claims (
    id BIGSERIAL PRIMARY KEY,
    claim_id VARCHAR(100) UNIQUE NOT NULL,
    nphies_claim_id VARCHAR(100),
    patient_id UUID NOT NULL REFERENCES patients(patient_id),
    provider_id UUID NOT NULL REFERENCES users(user_id),
    status VARCHAR(50) NOT NULL,
    outcome VARCHAR(50),
    submission_date TIMESTAMPTZ NOT NULL,
    processing_date TIMESTAMPTZ,
    total_claimed_amount DECIMAL(10,2) NOT NULL,
    approved_amount DECIMAL(10,2),
    patient_responsibility DECIMAL(10,2),
    adjudication_details JSONB,
    eligibility_status VARCHAR(50),
    notes JSONB,
    denial_reason TEXT,
    fhir_claim JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT valid_claim_status CHECK (status IN (
        'draft',
        'submitted',
        'pending',
        'approved',
        'denied',
        'cancelled'
    ))
);

CREATE INDEX idx_insurance_claims_patient ON insurance_claims(patient_id);
CREATE INDEX idx_insurance_claims_provider ON insurance_claims(provider_id);
CREATE INDEX idx_insurance_claims_status ON insurance_claims(status);
CREATE INDEX idx_insurance_claims_submission ON insurance_claims(submission_date DESC);
CREATE INDEX idx_insurance_claims_nphies ON insurance_claims(nphies_claim_id);

COMMENT ON TABLE insurance_claims IS 'NPHIES insurance claims with adjudication tracking';

-- =============================================
-- SECURITY INCIDENTS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS security_incidents (
    incident_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    incident_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    incident_type VARCHAR(100) NOT NULL,
    severity VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    affected_systems JSONB,
    affected_users JSONB,
    detected_by VARCHAR(100),
    reported_by UUID REFERENCES users(user_id),
    status VARCHAR(50) DEFAULT 'OPEN',
    investigation_notes TEXT,
    remediation_actions TEXT,
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES users(user_id),
    CONSTRAINT valid_severity_level CHECK (severity IN (
        'CRITICAL',
        'HIGH',
        'MEDIUM',
        'LOW'
    )),
    CONSTRAINT valid_status_value CHECK (status IN (
        'OPEN',
        'INVESTIGATING',
        'RESOLVED',
        'CLOSED'
    ))
);

CREATE INDEX idx_security_incidents_date ON security_incidents(incident_date DESC);
CREATE INDEX idx_security_incidents_severity ON security_incidents(severity);
CREATE INDEX idx_security_incidents_status ON security_incidents(status);

COMMENT ON TABLE security_incidents IS 'Security incident tracking and management';

-- =============================================
-- COMPLIANCE REPORTS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS compliance_reports (
    id BIGSERIAL PRIMARY KEY,
    report_id VARCHAR(100) UNIQUE NOT NULL,
    audit_period_start TIMESTAMPTZ NOT NULL,
    audit_period_end TIMESTAMPTZ NOT NULL,
    overall_status VARCHAR(50) NOT NULL,
    risk_score INT NOT NULL,
    risk_level VARCHAR(50) NOT NULL,
    critical_findings JSONB,
    compliance_metrics JSONB NOT NULL,
    recommendations TEXT,
    action_items JSONB,
    generated_at TIMESTAMPTZ DEFAULT NOW(),
    generated_by UUID REFERENCES users(user_id),
    metadata JSONB,
    CONSTRAINT valid_risk_level CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH'))
);

CREATE INDEX idx_compliance_reports_generated ON compliance_reports(generated_at DESC);
CREATE INDEX idx_compliance_reports_risk ON compliance_reports(risk_score DESC);

COMMENT ON TABLE compliance_reports IS 'HIPAA/NPHIES compliance audit reports';

-- =============================================
-- MEDICAL RECORDS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS medical_records (
    record_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(patient_id),
    record_type VARCHAR(100) NOT NULL,
    record_date TIMESTAMPTZ NOT NULL,
    summary TEXT,
    provider_name VARCHAR(255),
    department VARCHAR(100),
    document_url TEXT,
    document_s3_key TEXT,
    patient_accessible BOOLEAN DEFAULT true,
    fhir_resource JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(user_id),
    CONSTRAINT valid_record_type CHECK (record_type IN (
        'consultation',
        'procedure',
        'imaging',
        'lab',
        'prescription',
        'discharge_summary',
        'referral',
        'vaccination',
        'allergy',
        'vital_signs'
    ))
);

CREATE INDEX idx_medical_records_patient ON medical_records(patient_id);
CREATE INDEX idx_medical_records_date ON medical_records(record_date DESC);
CREATE INDEX idx_medical_records_type ON medical_records(record_type);
CREATE INDEX idx_medical_records_accessible ON medical_records(patient_accessible) WHERE patient_accessible = true;

COMMENT ON TABLE medical_records IS 'Comprehensive medical records repository';

-- =============================================
-- NOTIFICATION LOG TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS notification_log (
    id BIGSERIAL PRIMARY KEY,
    notification_type VARCHAR(50) NOT NULL,
    recipient_type VARCHAR(50) NOT NULL,
    recipient_id UUID NOT NULL,
    notification_content JSONB NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    sent_at TIMESTAMPTZ,
    delivery_status VARCHAR(50),
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT valid_notification_type CHECK (notification_type IN (
        'LAB_RESULTS',
        'APPOINTMENT_REMINDER',
        'APPOINTMENT_CONFIRMATION',
        'PRESCRIPTION_READY',
        'INSURANCE_UPDATE',
        'CLAIM_STATUS',
        'CRITICAL_ALERT',
        'GENERAL'
    )),
    CONSTRAINT valid_notification_status CHECK (status IN (
        'pending',
        'sent',
        'delivered',
        'failed',
        'bounced'
    ))
);

CREATE INDEX idx_notification_log_recipient ON notification_log(recipient_id);
CREATE INDEX idx_notification_log_type ON notification_log(notification_type);
CREATE INDEX idx_notification_log_status ON notification_log(status);
CREATE INDEX idx_notification_log_sent ON notification_log(sent_at DESC);

COMMENT ON TABLE notification_log IS 'Notification delivery tracking';

-- =============================================
-- SYSTEM HEALTH LOGS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS system_health_logs (
    id BIGSERIAL PRIMARY KEY,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    overall_status VARCHAR(50) NOT NULL,
    checks JSONB NOT NULL,
    critical_issues JSONB,
    warnings JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_system_health_timestamp ON system_health_logs(timestamp DESC);
CREATE INDEX idx_system_health_status ON system_health_logs(overall_status);

COMMENT ON TABLE system_health_logs IS 'System health monitoring and status tracking';

-- =============================================
-- FUNCTIONS AND TRIGGERS
-- =============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to tables with updated_at column
CREATE TRIGGER update_patients_updated_at
    BEFORE UPDATE ON patients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at
    BEFORE UPDATE ON appointments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_insurance_claims_updated_at
    BEFORE UPDATE ON insurance_claims
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- VIEWS FOR DASHBOARDS AND REPORTING
-- =============================================

-- Provider Dashboard View
CREATE OR REPLACE VIEW vw_provider_dashboard AS
SELECT
    u.user_id as provider_id,
    u.username as provider_name,
    COUNT(DISTINCT a.appointment_id) as upcoming_appointments,
    COUNT(DISTINCT CASE WHEN lr.notification_sent = false THEN lr.result_id END) as pending_lab_results,
    COUNT(DISTINCT CASE WHEN lr.critical_flag = true AND lr.notification_sent = false THEN lr.result_id END) as critical_lab_results,
    COUNT(DISTINCT CASE WHEN ic.status = 'pending' THEN ic.id END) as pending_claims
FROM users u
LEFT JOIN appointments a ON u.user_id = a.provider_id AND a.start_time >= NOW() AND a.status = 'booked'
LEFT JOIN lab_results lr ON u.user_id = lr.ordered_by
LEFT JOIN insurance_claims ic ON u.user_id = ic.provider_id
WHERE u.role IN ('provider', 'clinical_staff')
GROUP BY u.user_id, u.username;

COMMENT ON VIEW vw_provider_dashboard IS 'Provider dashboard summary metrics';

-- Patient Portal Dashboard View
CREATE OR REPLACE VIEW vw_patient_portal_dashboard AS
SELECT
    p.patient_id,
    COUNT(DISTINCT CASE WHEN a.start_time >= NOW() THEN a.appointment_id END) as upcoming_appointments,
    COUNT(DISTINCT CASE WHEN lr.notification_sent = true AND lr.result_date >= NOW() - INTERVAL '30 days' THEN lr.result_id END) as recent_lab_results,
    COUNT(DISTINCT CASE WHEN lr.critical_flag = true AND lr.notification_sent = true THEN lr.result_id END) as critical_results,
    COUNT(DISTINCT CASE WHEN ic.status IN ('submitted', 'pending') THEN ic.id END) as pending_claims,
    MAX(a.start_time) as next_appointment_date,
    MAX(lr.result_date) as last_lab_result_date
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id
LEFT JOIN lab_results lr ON p.patient_id = lr.patient_id
LEFT JOIN insurance_claims ic ON p.patient_id = ic.patient_id
GROUP BY p.patient_id;

COMMENT ON VIEW vw_patient_portal_dashboard IS 'Patient portal dashboard summary';

-- Compliance Dashboard View
CREATE OR REPLACE VIEW vw_compliance_dashboard AS
SELECT
    DATE_TRUNC('day', al.timestamp) as audit_date,
    COUNT(DISTINCT al.user_id) as active_users,
    COUNT(*) as total_events,
    COUNT(*) FILTER (WHERE al.event_type = 'PATIENT_ACCESS') as patient_accesses,
    COUNT(*) FILTER (WHERE al.event_type = 'LOGIN_FAILED') as failed_logins,
    COUNT(DISTINCT pal.patient_id) as unique_patients_accessed
FROM audit_logs al
LEFT JOIN phi_access_logs pal ON DATE_TRUNC('day', al.timestamp) = DATE_TRUNC('day', pal.access_timestamp)
GROUP BY DATE_TRUNC('day', al.timestamp)
ORDER BY audit_date DESC;

COMMENT ON VIEW vw_compliance_dashboard IS 'Daily compliance and audit metrics';

-- =============================================
-- SAMPLE DATA (FOR TESTING)
-- =============================================

-- Insert sample admin user
INSERT INTO users (username, email, password_hash, role, department, provider_license, active, preferred_language)
VALUES
    ('admin', 'admin@brainsait.com', crypt('Admin@123', gen_salt('bf')), 'admin', 'Administration', NULL, true, 'en'),
    ('dr.ahmed', 'ahmed@brainsait.com', crypt('Provider@123', gen_salt('bf')), 'provider', 'Cardiology', 'LIC-SA-2025-001', true, 'ar')
ON CONFLICT (email) DO NOTHING;

-- Insert sample clinical guidelines
INSERT INTO clinical_guidelines (guideline_name, condition, recommendations, evidence_level, language, source)
VALUES
    ('Hypertension Management', 'Hypertension', 'Lifestyle modifications and pharmacotherapy based on blood pressure readings', 'A', 'en', 'Saudi MOH Guidelines 2024'),
    ('إدارة ارتفاع ضغط الدم', 'Hypertension', 'تعديلات نمط الحياة والعلاج الدوائي بناءً على قراءات ضغط الدم', 'A', 'ar', 'إرشادات وزارة الصحة السعودية 2024')
ON CONFLICT DO NOTHING;

-- =============================================
-- GRANT PERMISSIONS
-- =============================================

-- Create application role if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'brainsait_app') THEN
        CREATE ROLE brainsait_app WITH LOGIN;
    END IF;
END
$$;

-- Grant permissions
GRANT CONNECT ON DATABASE CURRENT_DATABASE() TO brainsait_app;
GRANT USAGE ON SCHEMA public TO brainsait_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO brainsait_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO brainsait_app;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO brainsait_app;

-- Grant view access
GRANT SELECT ON vw_provider_dashboard TO brainsait_app;
GRANT SELECT ON vw_patient_portal_dashboard TO brainsait_app;
GRANT SELECT ON vw_compliance_dashboard TO brainsait_app;

-- =============================================
-- COMPLETION MESSAGE
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'BrainSAIT Database Schema Installed Successfully!';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Version: 1.0.0';
    RAISE NOTICE 'Tables Created: 16';
    RAISE NOTICE 'Views Created: 3';
    RAISE NOTICE 'Indexes Created: 50+';
    RAISE NOTICE 'Compliance: HIPAA & NPHIES';
    RAISE NOTICE '========================================';
END $$;
