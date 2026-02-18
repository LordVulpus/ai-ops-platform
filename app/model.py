import numpy as np

def detect_anomaly(values):
    if len(values) == 0:
        return []

    mean = np.mean(values)
    std = np.std(values)

    threshold = mean + (2 * std)

    anomalies = [x for x in values if x > threshold]

    return anomalies
