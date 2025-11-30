# 📊 OPERATIONS - Monitoring & Logging Strategy

## Overview
Dokumen ini menjelaskan strategi monitoring, logging, dan operasional untuk DRP-PRO Retail System yang dibangun dengan Microsoft Power Apps dan Supabase.

---

## 🔍 Monitoring Strategy

### 1. Application Performance Monitoring (Power Apps)

#### Power Apps Analytics
- **Monitor Locations**: Power Apps Admin Center → Analytics → Usage
- **Metrics yang Dipantau**:
  - Daily/Monthly Active Users (DAU/MAU)
  - Session Duration per user
  - Screen Load Time
  - API Call Response Time
  - Error Rate per screen
  - Device & OS Distribution

#### Performance Alerts
- Screen load > 3 detik
- API timeout > 30 detik
- Error rate > 5% dalam 1 jam
- Concurrent users > 80% kapasitas

### 2. Database Monitoring (Supabase)

#### Supabase Dashboard Metrics
- **Database Performance**:
  - Active connections
  - Query execution time
  - Slow queries (> 1 detik)
  - Database size & growth rate
  - Index usage efficiency

- **API Usage**:
  - Total requests per hour/day
  - Request rate limits
  - Most called endpoints
  - Response time distribution

#### Resource Alerts
- Database connection > 80% limit
- Storage > 75% quota
- API requests mendekati rate limit
- Long-running queries (> 5 detik)

### 3. Power Automate Flow Monitoring

#### Flow Run History
- **Monitor di**: Power Automate → My flows → [Flow name] → Run history
- **Metrics**:
  - Success rate (target: > 95%)
  - Failed runs & error messages
  - Execution duration
  - Triggered count per day

#### Critical Flows untuk Monitoring
- Stock sync automation
- Loyalty point calculation
- Survey response processing
- Daily sales report generation
- Auto-backup scheduler

---

## 📝 Logging Strategy

### 1. Application Logs (Power Apps)

#### Client-Side Logging
```javascript
// Trace levels di Power Apps
- Error: Fatal errors yang menghentikan proses
- Warning: Masalah yang tidak menghentikan tapi perlu perhatian
- Information: Event penting (login, checkout, dll)
- Verbose: Detail debug info
```

#### Log Events yang Dicatat
- **Authentication**: Login, logout, failed attempts
- **Transactions**: POS sales, stock adjustments, returns
- **User Actions**: Screen navigation, button clicks, form submissions
- **Errors**: Runtime errors, API failures, validation errors

#### Implementation
```powerfx
// Contoh logging di Power Apps
Trace(
    "Transaction Complete",
    TraceSeverity.Information,
    {
        TransactionID: varTransactionID,
        Amount: varTotalAmount,
        UserID: User().Email,
        Timestamp: Now()
    }
)
```

### 2. Database Logs (Supabase)

#### Audit Logging via Triggers
```sql
-- Tabel audit log
CREATE TABLE audit_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    table_name TEXT NOT NULL,
    action TEXT NOT NULL, -- INSERT, UPDATE, DELETE
    old_data JSONB,
    new_data JSONB,
    user_id UUID REFERENCES users(id),
    user_email TEXT,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Function untuk audit
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_logs (
        table_name, action, old_data, new_data, 
        user_id, user_email
    )
    VALUES (
        TG_TABLE_NAME,
        TG_OP,
        CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN row_to_json(OLD) END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) END,
        auth.uid(),
        auth.email()
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply ke tabel penting
CREATE TRIGGER products_audit AFTER INSERT OR UPDATE OR DELETE
ON products FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

CREATE TRIGGER transactions_audit AFTER INSERT OR UPDATE OR DELETE
ON transactions FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();
```

#### Log Retention Policy
- **Transaction logs**: 2 tahun
- **Audit logs**: 1 tahun
- **Error logs**: 6 bulan
- **Activity logs**: 3 bulan

### 3. Power Automate Logs

#### Flow Run Data
- Tersimpan otomatis di Power Automate history
- Retention: 28 hari (standar)
- Untuk long-term storage, export ke:
  - SharePoint List
  - Excel di OneDrive
  - External logging service

#### Custom Logging Actions
```
// Di Power Automate flow
Compose Action: Log Entry
{
  "FlowName": "@{workflow().name}",
  "RunID": "@{workflow().run.name}",
  "Status": "Success/Failed",
  "Duration": "@{workflow().run.duration}",
  "ErrorMessage": "@{if(equals(actions('Action_Name').status, 'Failed'), actions('Action_Name').error.message, '')}",
  "Timestamp": "@{utcNow()}"
}

→ Insert Row ke SharePoint/Excel untuk long-term storage
```

---

## 🚨 Error Handling & Alerting

### 1. Error Classification

#### Critical Errors (P1)
- Payment processing failures
- Data corruption
- Authentication system down
- Database connection loss

**Response Time**: Immediate (< 15 menit)

#### High Priority (P2)
- Stock sync failures
- POS transaction errors
- API rate limit exceeded
- Report generation failures

**Response Time**: 1 jam

#### Medium Priority (P3)
- UI rendering issues
- Slow query performance
- Minor data validation errors

**Response Time**: 4 jam

#### Low Priority (P4)
- Cosmetic issues
- Non-critical warnings
- Performance optimization opportunities

**Response Time**: 1 hari

### 2. Alert Channels

#### Email Notifications
- **Recipients**: 
  - Admin: Critical & High priority
  - Developer: All errors
  - Operations: Daily summary

#### Power Automate Alert Flow
```
Trigger: When error occurs in monitored flows
Actions:
1. Check error severity
2. IF Critical → Send Teams message + Email
3. IF High → Send Email
4. Log to SharePoint Error List
5. Create ticket in issue tracker (optional)
```

#### Dashboard Alerts
- Real-time error banner di admin dashboard
- Error count badge per module
- Recent errors widget

---

## 📈 Operational Metrics & KPIs

### 1. System Health KPIs

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| System Uptime | 99.5% | < 99% |
| Average Response Time | < 2s | > 5s |
| Error Rate | < 2% | > 5% |
| Failed Transactions | < 0.5% | > 2% |
| API Success Rate | > 99% | < 95% |

### 2. Business KPIs

| Metric | Description | Frequency |
|--------|-------------|-----------|
| Daily Active Users | Jumlah kasir aktif per hari | Daily |
| Transactions Per Day | Total transaksi sukses | Daily |
| Average Transaction Value | Nilai rata-rata per transaksi | Daily |
| Stock Sync Success Rate | % keberhasilan sync stok | Hourly |
| Loyalty Enrollment Rate | Registrasi member baru | Weekly |

### 3. Performance Metrics

- **Screen Load Time**: Per screen, target < 2 detik
- **API Response Time**: Per endpoint, target < 500ms
- **Database Query Time**: Slow query threshold 1 detik
- **Flow Execution Time**: Per automation flow

---

## 🔧 Maintenance & Operations

### 1. Daily Operations

#### Morning Checklist (9:00 AM)
- [ ] Review overnight error logs
- [ ] Check system health dashboard
- [ ] Verify backup completion
- [ ] Review critical flow runs
- [ ] Check API quota usage

#### End of Day (6:00 PM)
- [ ] Generate daily sales report
- [ ] Review transaction anomalies
- [ ] Check stock sync status
- [ ] Export daily logs
- [ ] Plan tomorrow's maintenance (if any)

### 2. Weekly Maintenance

#### Senin Pagi
- Review system performance metrics
- Analyze slow queries & optimize
- Check database size growth
- Review user feedback & errors

#### Kamis Sore
- Clean up old logs (> retention period)
- Update monitoring thresholds if needed
- Review & tune Power Automate flows
- Database vacuum & analyze (off-peak)

### 3. Monthly Activities

- Full system performance review
- Capacity planning assessment
- Security audit log review
- Update operational documentation
- Stakeholder report generation

---

## 📊 Reporting

### 1. Automated Reports

#### Daily Operations Report
**Schedule**: Every day at 7:00 AM
**Content**:
- Total transactions previous day
- System uptime & errors
- Top performing products
- Active users count
- Stock alerts

**Distribution**: Email to store managers & admins

#### Weekly Performance Report
**Schedule**: Every Monday 9:00 AM
**Content**:
- Week-over-week metrics comparison
- Error rate trends
- System performance trends
- User activity analysis
- Recommendations

**Distribution**: Management team

#### Monthly Executive Dashboard
**Schedule**: 1st day of month
**Content**:
- Business KPIs summary
- System health overview
- Cost analysis (API usage, storage)
- ROI metrics
- Strategic recommendations

**Distribution**: C-level, stakeholders

### 2. On-Demand Reports

- Transaction detail exports
- Audit trail reports
- User activity logs
- Custom date range analytics
- Performance deep-dive analysis

---

## 🛠️ Tools & Implementation

### 1. Monitoring Tools

#### Free/Built-in Options
- **Power Apps Monitor**: Real-time debugging
- **Supabase Dashboard**: Database metrics
- **Power Automate Analytics**: Flow performance
- **Application Insights** (jika Azure-integrated)

#### Recommended External Tools (Optional)
- **Grafana + Prometheus**: Custom metrics dashboard
- **Sentry**: Error tracking & alerting
- **LogRocket**: Session replay & monitoring
- **DataDog** (untuk enterprise)

### 2. Log Storage Solutions

#### Primary (Included)
- Supabase Database Tables
- Power Platform built-in history

#### Long-term Archive
- Azure Blob Storage (low-cost)
- OneDrive/SharePoint (termasuk M365)
- Local backup to network drive

### 3. Dashboard Setup

#### Supabase Monitoring View
```sql
-- Create monitoring dashboard views
CREATE VIEW v_daily_metrics AS
SELECT 
    DATE(created_at) as date,
    COUNT(*) as total_transactions,
    SUM(total_amount) as revenue,
    COUNT(DISTINCT user_id) as active_users
FROM transactions
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;

CREATE VIEW v_error_summary AS
SELECT 
    DATE(timestamp) as date,
    COUNT(*) as error_count,
    JSONB_OBJECT_AGG(error_type, count) as errors_by_type
FROM error_logs
WHERE timestamp >= NOW() - INTERVAL '7 days'
GROUP BY DATE(timestamp);
```

#### Power Apps Dashboard Screen
- Real-time transaction count
- Today's revenue chart
- Error rate gauge
- Active users list
- System status indicators
- Quick access to logs

---

## 🔐 Security Monitoring

### 1. Security Events to Log

- Failed login attempts (> 3 in 5 minutes)
- Privilege escalation attempts
- Unusual data access patterns
- After-hours administrative actions
- Bulk data exports
- Configuration changes

### 2. Compliance & Audit

#### Data Access Logs
- Who accessed what data
- When & from which device
- What actions were performed
- Any data exports/downloads

#### Compliance Reports
- GDPR data access requests
- Data retention compliance
- Security incident reports
- Access control audit

---

## 📞 Incident Response

### 1. Incident Response Flow

```
1. DETECT: Alert triggered
   ↓
2. TRIAGE: Classify severity (P1-P4)
   ↓
3. NOTIFY: Alert appropriate team
   ↓
4. INVESTIGATE: Check logs & metrics
   ↓
5. RESOLVE: Apply fix
   ↓
6. VERIFY: Confirm resolution
   ↓
7. DOCUMENT: Post-mortem report
   ↓
8. PREVENT: Update monitoring/alerts
```

### 2. Emergency Contacts

```markdown
| Role | Contact | Availability |
|------|---------|--------------|
| System Admin | [Email/Phone] | 24/7 |
| Lead Developer | [Email/Phone] | Business hours |
| Database Admin | [Email/Phone] | On-call |
| Business Owner | [Email/Phone] | Critical only |
```

### 3. Rollback Procedures

- **Database**: Restore from last hourly backup
- **Power Apps**: Revert to previous published version
- **Power Automate**: Disable problematic flow, rollback changes
- **Configuration**: Restore from version control

---

## ✅ Best Practices

1. **Log Structured Data**: Gunakan JSON format untuk mudah di-parse
2. **Consistent Timestamps**: Selalu gunakan UTC timezone
3. **Include Context**: User ID, Session ID, Transaction ID di setiap log
4. **Sensitive Data**: NEVER log passwords, credit cards, personal ID numbers
5. **Performance Impact**: Logging tidak boleh menambah > 10% overhead
6. **Regular Reviews**: Review & tune monitoring quarterly
7. **Test Alerts**: Test alert channels monthly
8. **Documentation**: Update runbooks saat ada changes

---

## 📚 References & Resources

- [Power Apps Monitor Documentation](https://learn.microsoft.com/power-apps/maker/monitor-overview)
- [Supabase Monitoring Guide](https://supabase.com/docs/guides/platform/metrics)
- [Power Automate Error Handling](https://learn.microsoft.com/power-automate/error-handling)
- [PostgreSQL Logging Best Practices](https://www.postgresql.org/docs/current/runtime-config-logging.html)

---

## 📌 Appendix

### A. Sample Power Automate Alert Flow

```yaml
Flow Name: Critical Error Alert
Trigger: When error logged in error_logs table (Supabase)

Actions:
1. Get Error Details
   - Query error_logs table
   - Extract: error_type, severity, user_id, timestamp

2. Condition: Check Severity
   IF severity = 'Critical' OR 'High'
   
3. Send Email (Critical/High)
   To: admin@company.com
   Subject: [ALERT-@{severity}] System Error Detected
   Body: 
     Error Type: @{error_type}
     User: @{user_email}
     Time: @{timestamp}
     Details: @{error_message}
     
4. Send Teams Message (Critical only)
   IF severity = 'Critical'
   Channel: Operations Team
   Message: 🚨 CRITICAL ERROR - Immediate action required
   
5. Create Task in Planner (Optional)
   Title: Resolve @{error_type}
   Assign to: On-call engineer
   Due date: +2 hours
   
6. Log Alert Sent
   Update error_logs: alert_sent = true, alert_time = now()
```

### B. Database Health Check Query

```sql
-- Run daily untuk health check
WITH db_stats AS (
  SELECT 
    pg_database_size(current_database()) / 1024 / 1024 AS db_size_mb,
    (SELECT count(*) FROM pg_stat_activity) AS active_connections,
    (SELECT count(*) FROM pg_stat_activity WHERE state = 'active') AS active_queries
),
table_stats AS (
  SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size,
    n_live_tup AS row_count
  FROM pg_stat_user_tables
  ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
  LIMIT 10
),
slow_queries AS (
  SELECT 
    query,
    calls,
    total_time / calls AS avg_time_ms,
    rows / calls AS avg_rows
  FROM pg_stat_statements
  WHERE calls > 100
  ORDER BY total_time DESC
  LIMIT 5
)
SELECT * FROM db_stats;
```

### C. Power Apps Performance Monitoring Code

```powerfx
// Tambahkan di OnVisible property setiap screen
Set(varScreenLoadStart, Now());

// Tambahkan di akhir OnVisible setelah data loaded
Trace(
    "Screen Performance",
    TraceSeverity.Information,
    {
        ScreenName: Screen1.Name,
        LoadTime: DateDiff(varScreenLoadStart, Now(), Milliseconds),
        UserID: User().Email,
        RecordCount: CountRows(colDataSource),
        Timestamp: Now()
    }
);

// Alert jika load time > 3 detik
If(
    DateDiff(varScreenLoadStart, Now(), Seconds) > 3,
    Notify("Screen loading slowly. Please check connection.", NotificationType.Warning)
);
```

### D. Daily Operations Dashboard SQL Views

```sql
-- View untuk realtime dashboard
CREATE OR REPLACE VIEW v_operations_dashboard AS
SELECT 
    -- Today's stats
    (SELECT COUNT(*) FROM transactions WHERE DATE(created_at) = CURRENT_DATE) as today_transactions,
    (SELECT SUM(total_amount) FROM transactions WHERE DATE(created_at) = CURRENT_DATE) as today_revenue,
    (SELECT COUNT(DISTINCT user_id) FROM user_sessions WHERE DATE(login_at) = CURRENT_DATE) as active_users_today,
    
    -- Error stats (last 24h)
    (SELECT COUNT(*) FROM error_logs WHERE timestamp >= NOW() - INTERVAL '24 hours') as errors_24h,
    (SELECT COUNT(*) FROM error_logs WHERE severity = 'Critical' AND timestamp >= NOW() - INTERVAL '24 hours') as critical_errors_24h,
    
    -- System health
    (SELECT COUNT(*) FROM pg_stat_activity) as db_connections,
    (SELECT pg_database_size(current_database()) / 1024 / 1024) as db_size_mb,
    
    -- Stock alerts
    (SELECT COUNT(*) FROM products WHERE stock_quantity < minimum_stock) as low_stock_items,
    
    -- Pending tasks
    (SELECT COUNT(*) FROM loyalty_transactions WHERE status = 'pending') as pending_loyalty_calc,
    (SELECT COUNT(*) FROM survey_responses WHERE processed = false) as unprocessed_surveys
;

-- Query untuk anomaly detection
CREATE OR REPLACE VIEW v_transaction_anomalies AS
SELECT 
    t.id,
    t.created_at,
    t.total_amount,
    t.user_id,
    u.full_name,
    t.outlet_id,
    CASE 
        WHEN t.total_amount > (SELECT AVG(total_amount) * 3 FROM transactions) THEN 'High Value'
        WHEN t.total_amount < 1000 THEN 'Very Low Value'
        WHEN t.created_at::time < '06:00:00' OR t.created_at::time > '23:00:00' THEN 'Off Hours'
        ELSE 'Normal'
    END as anomaly_type
FROM transactions t
JOIN users u ON t.user_id = u.id
WHERE DATE(t.created_at) = CURRENT_DATE
  AND (
    t.total_amount > (SELECT AVG(total_amount) * 3 FROM transactions)
    OR t.total_amount < 1000
    OR t.created_at::time < '06:00:00' 
    OR t.created_at::time > '23:00:00'
  )
ORDER BY t.created_at DESC;
```

---

**Document Version**: 1.0  
**Last Updated**: 2025-11-30  
**Maintained By**: Technical Team DRP-PRO  
**Next Review**: 2026-02-28

---

## 📝 Change Log

| Version | Date | Author | Changes |
|---------|------|--------|----------|
| 1.0 | 2025-11-30 | DevOps Team | Initial operations documentation |

---

> **Note**: Dokumen ini adalah living document dan akan diupdate seiring dengan perkembangan sistem. Feedback dan improvement suggestions sangat diterima melalui GitHub Issues atau email ke team@drp-pro.com

---

Untuk pertanyaan lebih lanjut atau implementasi support, silakan hubungi:
- **Technical Support**: support@drp-pro.com
- **Emergency Hotline**: [Phone Number]
- **GitHub Issues**: https://github.com/rendyafx-arch/drp-pro-retail-system/issues
