```markdown
# Candace Anomaly Detector

## Overview
Candace Anomaly Detector is a smart contract designed to monitor user behavior by analyzing activity metrics over time. It identifies anomalies by comparing new inputs against historical baselines, enabling reliable detection of unusual patterns.

The contract is built with a focus on transparency, configurability, and efficiency, making it suitable for applications that require behavioral monitoring and risk detection.

---

## Features
- Baseline tracking using historical user data
- Deviation-based anomaly detection
- Configurable deviation threshold
- Minimum sample requirement before activation
- Per-user metric storage and tracking
- Administrative controls for system tuning
- On-chain transparency for all stored data

---

## Contract Structure

### Error Codes
| Code | Description |
|------|-------------|
| u100 | Unauthorized access |
| u101 | User not found |
| u102 | Invalid metric input |
| u103 | No anomaly detected |
| u104 | Already flagged |

---

### Configuration Parameters
- **Deviation Threshold**  
  Defines the acceptable percentage deviation from the baseline (default: 30%).

- **Minimum Samples**  
  Minimum number of recorded metrics required before anomaly detection becomes active (default: 3).

---

### Data Storage

#### `user-metrics` Map
Stores user-specific activity data:

| Field | Description |
|------|-------------|
| total-score | Sum of all recorded scores |
| sample-count | Number of recorded samples |
| baseline | Average score (total / count) |
| last-score | Most recent score |
| flagged | Indicates anomaly status |

---

## Core Functions

### Admin Functions

#### `set-deviation-threshold`
Updates the deviation threshold.
- Access: Contract owner only

#### `set-minimum-samples`
Updates the minimum sample requirement.
- Access: Contract owner only

---

### User Function

#### `record-metric`
Records a new activity score for the caller.

**Behavior:**
- Validates input score
- Updates user statistics
- Recalculates baseline
- Initializes new users if no prior record exists

---

## Internal Logic

### Baseline Calculation
The baseline is computed as:
```

baseline = total-score / sample-count

```

### Anomaly Detection
A score is considered anomalous if:
```

absolute(new-score - baseline) > (baseline * deviation-threshold / 100)

```

---

## Security Considerations
- Only the contract owner can modify configuration parameters
- Input validation prevents invalid metric submissions
- Data integrity is maintained through deterministic calculations

---

## Use Cases
- Fraud detection systems
- User behavior monitoring
- Risk analysis platforms
- Activity scoring systems

---

## Future Improvements
- Automated anomaly flagging and resolution workflows
- Event logging for anomaly detection
- Integration with external monitoring systems
- Enhanced analytics and reporting tools

---

## License
This project is open-source and available for use and modification.
```
