# NovaPay Digital Bank --- Incident Communication Templates

**Deliverable:** 7 --- Runbook & Incident Playbook\
**Purpose:** Standardize accurate, timely and audience-appropriate
communication during deployments and incidents.

------------------------------------------------------------------------

## 1. Communication Principles

All incident communications must be:

-   Accurate.
-   Concise.
-   Time-stamped.
-   Action-oriented.
-   Appropriate for the audience.
-   Free of unverified speculation.
-   Free of sensitive customer information.
-   Consistent with the incident record.

Use the incident ID in every internal incident update.

------------------------------------------------------------------------

# 2. Deployment Announcement

**Subject:** Production Deployment Starting --- `<service>` ---
`<release>`

``` text
Deployment: <release>
Service: <service>
Environment: Production
Change ID: <change-id>
Git SHA: <git-sha>
Image Digest: <digest>
Strategy: <blue-green/canary>
Start Time: <timestamp>
Expected Duration: <duration>

Approvals:
- Release Manager: <approved>
- SRE Lead: <approved>

Monitoring:
Prometheus/Alertmanager monitoring active.

Rollback:
Automated rollback controls are active according to the rollback specification.

Owner: <name/team>
```

------------------------------------------------------------------------

# 3. Deployment Started

``` text
[DEPLOYMENT STARTED]

Service: <service>
Release: <release>
Change ID: <change-id>
Strategy: <blue-green/canary>
Current traffic: <percentage>
Candidate health: <status>
Database migration: <status>
Monitoring: <status>

Next checkpoint: <timestamp>
```

------------------------------------------------------------------------

# 4. Deployment Successful

``` text
[DEPLOYMENT SUCCESSFUL]

Service: <service>
Release: <release>
Change ID: <change-id>
Completion Time: <timestamp>

Verification:
- Health: PASS
- Readiness: PASS
- Smoke tests: PASS
- Synthetic payment: PASS
- 5xx: <result>
- p99: <result>
- Payment success: <result>
- Database: PASS

Traffic: <final state>
Customer impact: <none/summary>

Evidence archived: <location/reference>
```

------------------------------------------------------------------------

# 5. Deployment Failed / Frozen

``` text
[DEPLOYMENT FROZEN]

Service: <service>
Release: <release>
Change ID: <change-id>
Time: <timestamp>

Reason:
<verified failure condition>

Observed:
<metric/value>

Threshold:
<threshold>

Action:
Production rollout has been frozen. No further promotion will occur until the release is assessed.

Current traffic:
<state>

Incident ID:
<incident-id>
```

------------------------------------------------------------------------

# 6. Rollback Initiated

``` text
[ROLLBACK INITIATED]

Incident: <incident-id>
Service: <service>
Candidate Release: <release>
Stable Release: <stable-release>
Time: <timestamp>

Trigger Category: <A/B/C>
Trigger: <alert/condition>
Observed Value: <value>
Threshold: <threshold>

Action:
Traffic is being returned to the last known-good release.

Verification will include:
- Health/readiness
- Smoke tests
- Synthetic payment
- 5xx
- p99
- Payment success
- Database health
- Customer impact
```

------------------------------------------------------------------------

# 7. Rollback Completed

``` text
[ROLLBACK COMPLETED]

Incident: <incident-id>
Service: <service>
Time: <timestamp>

Stable Release: <release>
Stable Image Digest: <digest>
Traffic: <state>

Verification:
- Health: PASS
- Smoke tests: PASS
- Synthetic payment: PASS
- 5xx: <result>
- p99: <result>
- Payment success: <result>
- Database: <result>

Customer impact:
<summary>

Incident remains:
<open/monitoring/resolved>

Evidence:
<reference>
```

------------------------------------------------------------------------

# 8. SEV-1 Initial Internal Acknowledgement

**Target:** within 5 minutes.

``` text
[SEV-1 INCIDENT ACKNOWLEDGED]

Incident ID: <incident-id>
Time detected: <timestamp>
Time acknowledged: <timestamp>
Service: <service>
Environment: Production

Impact:
<complete outage/data integrity risk>

Current status:
<status>

Incident Commander:
<name>

Technical Lead:
<name>

Immediate action:
<containment/recovery action>

Escalation:
CTO + CISO + VP Engineering notified.

Next update:
<timestamp>
```

------------------------------------------------------------------------

# 9. SEV-2 Initial Internal Acknowledgement

**Target:** within 15 minutes.

``` text
[SEV-2 INCIDENT ACKNOWLEDGED]

Incident ID: <incident-id>
Time: <timestamp>
Service: <service>

Impact:
Major feature degradation affecting approximately <percentage> of users.

Current status:
<status>

Action:
<mitigation>

Incident Commander:
<name>

Escalation:
VP Engineering + SRE Lead notified.

Next update:
<timestamp>
```

------------------------------------------------------------------------

# 10. SEV-3 Initial Internal Acknowledgement

**Target:** within 1 hour.

``` text
[SEV-3 INCIDENT ACKNOWLEDGED]

Incident ID: <incident-id>
Service: <service>
Time: <timestamp>

Impact:
Minor degradation. Current workaround:
<workaround>

Owner:
<name>

Action:
<next action>

Next update:
<timestamp>
```

------------------------------------------------------------------------

# 11. SEV-4 Initial Internal Acknowledgement

``` text
[SEV-4 ISSUE ACKNOWLEDGED]

Issue: <issue-id>
Service: <service>
Time: <timestamp>

Impact:
No customer impact.

Assigned engineer:
<name>

Planned action:
<action>

Target:
Next business day
```

------------------------------------------------------------------------

# 12. SEV-1 External Status Update

Use only after approved review.

``` text
[Service Update]

We are investigating an issue affecting <service>.

Start time: <timestamp>

Current impact:
<verified customer-facing impact>

Our engineering teams are actively working to restore normal service.

Next update:
<timestamp>

We apologize for the disruption.
```

Do not include internal architecture, credentials, security-sensitive
details or unverified root-cause claims.

------------------------------------------------------------------------

# 13. SEV-2 External Status Update

``` text
[Service Degradation]

We are investigating degraded performance affecting <service>.

Start time:
<timestamp>

Impact:
<verified impact>

Mitigation:
<customer-safe summary>

Next update:
<timestamp>
```

------------------------------------------------------------------------

# 14. Regular SEV-1 Update

**Frequency:** every 30 minutes.

``` text
[SEV-1 UPDATE]

Incident: <incident-id>
Time: <timestamp>

Current impact:
<verified impact>

What changed since last update:
<change>

Current action:
<action>

Recovery status:
<status>

Customer impact:
<status>

Next update:
<timestamp>
```

------------------------------------------------------------------------

# 15. Regular SEV-2 Update

**Frequency:** hourly.

``` text
[SEV-2 UPDATE]

Incident: <incident-id>
Time: <timestamp>

Current impact:
<impact>

Actions completed:
<actions>

Current mitigation:
<mitigation>

Recovery status:
<status>

Next update:
<timestamp>
```

------------------------------------------------------------------------

# 16. Business / Management Update

``` text
[EXECUTIVE INCIDENT UPDATE]

Incident: <incident-id>
Severity: <severity>
Start: <timestamp>
Current status: <status>

Business impact:
<verified business impact>

Customer impact:
<verified customer impact>

Service affected:
<service>

Mitigation:
<mitigation>

Rollback:
<yes/no/status>

Estimated recovery:
<time/status>

Next update:
<timestamp>
```

------------------------------------------------------------------------

# 17. Compliance / Regulatory Update

Use only approved regulatory communication channels and verified
information.

``` text
[COMPLIANCE INCIDENT SUMMARY]

Incident ID: <incident-id>
Severity: <severity>
Detected: <timestamp>
Service: <service>

Nature of event:
<verified description>

Customer/business impact:
<verified impact>

Containment:
<action>

Recovery:
<status>

Data-integrity assessment:
<status>

Evidence reference:
<reference>

Follow-up:
<incident/postmortem reference>

Prepared by:
<role/name>

Approved by:
<role/name>
```

------------------------------------------------------------------------

# 18. Incident Resolved

``` text
[INCIDENT RESOLVED]

Incident: <incident-id>
Service: <service>

Resolved at:
<timestamp>

Duration:
<duration>

Impact summary:
<summary>

Recovery:
<recovery action>

Verification:
- Health: PASS
- Smoke tests: PASS
- Synthetic payment: PASS
- Key metrics: stable
- Customer impact assessed: YES

Postmortem:
<required/not required>
Reference:
<link/id>
```

------------------------------------------------------------------------

# 19. Postmortem Announcement

``` text
[POSTMORTEM PUBLISHED]

Incident: <incident-id>
Severity: <severity>
Service: <service>

Root cause:
<concise verified root cause>

Impact:
<summary>

Key corrective actions:
1. <action> — Owner: <owner> — Due: <date>
2. <action> — Owner: <owner> — Due: <date>

Preventive controls:
<summary>

Postmortem reference:
<reference>
```

------------------------------------------------------------------------

# 20. Communication Timing Matrix

  ---------------------------------------------------------------------------------------
  Stage                           SEV-1               SEV-2          SEV-3          SEV-4
  ----------------- ------------------- ------------------- -------------- --------------
  Initial                       \<5 min            \<15 min       \<1 hour  Next business
  acknowledgement                                                                     day

  Regular internal         Every 30 min              Hourly      As needed      As needed
  update                                                                   

  External status                    As                  As    As required    Usually not
                      approved/required   approved/required                      required

  Resolution notice       At resolution       At resolution  At resolution  At resolution

  Postmortem         Required for major         As required    As required    Usually not
                              incidents                                          required
  ---------------------------------------------------------------------------------------

------------------------------------------------------------------------

# 21. Communication Checklist

Before sending:

``` text
[ ] Incident ID included
[ ] Severity correct
[ ] Timestamp included
[ ] Impact verified
[ ] Current action included
[ ] No speculation
[ ] No sensitive customer information
[ ] Next update time included
[ ] Correct audience/channel
[ ] Required approval obtained
```

------------------------------------------------------------------------

# 22. Communication Evidence

Archive:

-   Internal acknowledgement.
-   External status update where applicable.
-   Regular updates.
-   Rollback notification.
-   Resolution notification.
-   Approval records.
-   Final incident summary.

Store references under the project evidence repository without exposing
sensitive information.
