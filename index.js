/**
 * BrainSAIT Healthcare AI Agents for N8N
 * HIPAA/NPHIES Compliant Workflow Automation
 *
 * @author Dr. Mohamed El Fadil <fadil@brainsait.com>
 * @version 1.0.0
 * @license MIT
 */

module.exports = {
  name: 'n8n-nodes-brainsait',
  version: '1.0.0',
  description: 'BrainSAIT Healthcare AI Agents - HIPAA/NPHIES compliant N8N workflow nodes for Saudi Arabian healthcare',

  workflows: {
    masterlinc: require('./workflows/01-masterlinc-orchestrator.json'),
    ttlinc: require('./workflows/02-ttlinc-translation.json'),
    patientPortal: require('./workflows/03-patient-portal-demo.json'),
    systemHealth: require('./workflows/04-system-health-check.json'),
    terryMonitor: require('./workflows/05-terry-system-monitor.json')
  },

  schema: './schema.sql',

  documentation: {
    readme: './README.md',
    deployment: './DEPLOYMENT_GUIDE.md',
    contributing: './CONTRIBUTING.md',
    changelog: './CHANGELOG.md',
    terry: './TERRY_INTEGRATION_GUIDE.md'
  },

  metadata: {
    author: 'Dr. Mohamed El Fadil',
    email: 'fadil@brainsait.com',
    website: 'https://brainsait.com',
    github: 'https://github.com/Fadil369/n8n-nodes-brainsait',
    license: 'MIT'
  }
};
