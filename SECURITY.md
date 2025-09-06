# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 10.5.x  | :white_check_mark: |
| < 10.0  | :x:                |

## Security Standards

This project follows industry-standard security practices for web applications:

- **Authentication**: Strong password policies, email verification, MFA for administrators
- **Authorization**: Role-based access control (RBAC) with principle of least privilege
- **Data Protection**: Encryption at rest and in transit, secure session management
- **Input Validation**: All user inputs sanitized and validated
- **Dependency Management**: Regular security audits and updates

## Reporting a Vulnerability

**DO NOT** report security vulnerabilities through public GitHub issues.

Instead, please report security vulnerabilities via:

1. **Email**: Send details to security@[yourdomain.com]
2. **Response Time**: We will acknowledge receipt within 48 hours
3. **Timeline**: Security issues will be addressed within 30 days
4. **Disclosure**: Coordinated disclosure after fixes are deployed

## Security Features

### Current Protections

- CSRF protection on all forms
- XSS protection via Content Security Policy
- SQL injection prevention through parameterized queries
- Rate limiting on authentication endpoints
- Secure session management
- Input sanitization middleware

### Planned Enhancements

- Web Application Firewall (WAF) integration
- Advanced threat detection
- Security headers optimization
- Penetration testing automation

## Security Scanning

This repository includes automated security scanning:

- **Static Analysis**: PHPStan, Psalm for code quality
- **Dependency Audit**: Composer security advisories
- **Secret Detection**: Gitleaks prevents credential commits
- **Code Quality**: CodeQL for vulnerability detection

## Security Requirements

### Production Deployment

- [ ] All secrets managed via environment variables
- [ ] TLS 1.3 enforced for all connections
- [ ] Database connections encrypted
- [ ] Admin interfaces behind VPN/allowlist
- [ ] Regular security audits scheduled
- [ ] Incident response plan documented

### Development Environment

- [ ] No production credentials in development
- [ ] Local HTTPS development setup
- [ ] Pre-commit hooks for security scanning
- [ ] Regular dependency updates

## Security Contacts

- **Security Team**: security@[yourdomain.com]
- **Emergency Contact**: [emergency-phone]
- **PGP Key**: [security-pgp-key-id]

## Compliance Notes

This application is designed for **demo/token gameplay only** by default. 

**For real-money gambling operations**, additional compliance requirements apply:
- Jurisdictional gambling licenses
- KYC/AML procedures
- Age verification systems
- Certified RNG systems
- PCI DSS compliance (if handling card data)
- Audit trail requirements
- Dispute resolution processes

These compliance features are **NOT** included in this open-source version.