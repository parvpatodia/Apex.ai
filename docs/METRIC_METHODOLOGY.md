# Metric Methodology — Method Cards

> Per-metric transparency for investors, academies, and due diligence.  
> Structure follows Mitchell et al. (2018) Model Cards. Ref: [PHASE2_RESEARCH_GROUNDED.md](./PHASE2_RESEARCH_GROUNDED.md)

---

## 1. Release Velocity (m/s)

| Section | Content |
|--------|---------|
| **Definition** | Estimated ball release speed derived from wrist trajectory and dimensionless limb-length scaling. |
| **Formula** | `velocity = clip(power_ratio × 3.5, 4.0, 10.0)` where power_ratio = wrist travel / torso length (dip→release). |
| **Data source** | MediaPipe landmarks: wrist, shoulder, hip (2D normalized). |
| **Assumptions** | Single camera, no ball; wrist proxy for release point. |
| **Typical error** | ±1–2 m/s (wrist proxy vs. true ball velocity). |
| **Limitations** | True velocity requires ball tracking (YOLO). Side-view compresses apparent speed. |
| **Validation status** | Plausibility-checked; no lab validation. |
| **Literature** | NBA guards avg 7–9 m/s (qualitative). |

---

## 2. Shot Arc (°)

| Section | Content |
|--------|---------|
| **Definition** | Angle of the shooting arm (shoulder→wrist) at release, or post-release flight path when detectable. |
| **Formula** | Lever arc: `atan2(Δy, Δx) − 15°` (wrist flick); polynomial fit on post-release frames when ≥3 available. |
| **Data source** | MediaPipe: wrist, shoulder (2D + aspect-ratio correction). |
| **Assumptions** | 45° front-offset recommended; side-view compresses arc. |
| **Typical error** | ±5–8° from 2D projection; ±3° within our frame-window. |
| **Limitations** | Pure side-view underestimates; ball trajectory would improve. |
| **Validation status** | Plausibility-checked. |
| **Literature** | [Frontiers 2026](https://www.frontiersin.org/journals/sports-and-active-living/articles/10.3389/fspor.2026.1732293/full): 45–55° optimal for entry angle. |

---

## 3. Knee Flexion (°)

| Section | Content |
|--------|---------|
| **Definition** | Hip–knee–ankle 3D angle at the dip phase (lowest wrist before drive). |
| **Formula** | `arccos(dot(u,v)/(‖u‖‖v‖))` where u = hip→knee, v = ankle→knee. |
| **Data source** | MediaPipe world landmarks (3D): hip, knee, ankle. |
| **Assumptions** | Single subject; good visibility. |
| **Typical error** | ±5–10° (PMC 9397457); we report ± from frame-window variance. |
| **Limitations** | Occlusion, extreme angles; side-view compresses. |
| **Validation status** | Empirical ± implemented; no lab validation. |
| **Literature** | [PMC 9397457](https://pmc.ncbi.nlm.nih.gov/articles/PMC9397457/): uncertainty propagation in knee angles. Ideal 140–165° (literature). |

---

## 4. Elbow Flexion (°)

| Section | Content |
|--------|---------|
| **Definition** | Shoulder–elbow–wrist 3D angle at release. |
| **Formula** | Same as knee: `arccos(dot(u,v)/(‖u‖‖v‖))`. |
| **Data source** | MediaPipe: shoulder, elbow, wrist (3D). |
| **Assumptions** | Shooting arm visible at release. |
| **Typical error** | ±5–10°; we report ± from frame-window variance. |
| **Limitations** | Arm must be visible; occlusion inflates error. |
| **Validation status** | Empirical ± implemented. |
| **Literature** | Ideal 165–178° for straight shot. |

---

## 5. Kinetic Sync (ms)

| Section | Content |
|--------|---------|
| **Definition** | Time from dip (lowest wrist) to release (highest wrist). |
| **Formula** | `(release_frame − dip_frame) / fps × 1000`; dynamic FPS scaling for slow-motion. |
| **Data source** | Wrist Y trajectory, fps. |
| **Assumptions** | 30 fps or higher; clear dip and release. |
| **Typical error** | ±33 ms at 30 fps (frame granularity). |
| **Limitations** | Frame-rate dependent; no sub-frame resolution. |
| **Validation status** | Plausibility-checked. |
| **Literature** | 120–250 ms typical for one-motion shot. |

---

## 6. Hip Rotation (°)

| Section | Content |
|--------|---------|
| **Definition** | Torso twist: shoulder-line yaw minus hip-line yaw at dip. |
| **Formula** | `atan2(Δz, Δx)` for shoulders and hips in 3D; difference in degrees. |
| **Data source** | MediaPipe: left/right shoulder, left/right hip (3D). |
| **Assumptions** | 45° offset improves depth; pure side-view compresses. |
| **Typical error** | ±5–10°; sensitive to camera angle. |
| **Limitations** | Best from 45° front-offset. |
| **Validation status** | Plausibility-checked. |
| **Literature** | 5–15° typical for one-motion flow. |

---

## 7. Balance Index (/100)

| Section | Content |
|--------|---------|
| **Definition** | Hip–ankle horizontal alignment: deviation of CoM proxy over base. |
| **Formula** | `100 − (|hip_mid_x − ankle_mid_x| / torso_len) × 120`; clamped 40–99. |
| **Data source** | MediaPipe: hips, ankles (2D normalized). |
| **Assumptions** | 2D projection; true CoM requires force plates. |
| **Typical error** | ±10 points. |
| **Limitations** | 2D only; camera angle affects. |
| **Validation status** | Plausibility-checked. |
| **Literature** | 85–99 = stable base. |

---

## 8. Fluidity Score (/100)

| Section | Content |
|--------|---------|
| **Definition** | Smoothness of wrist path from dip to release (low jerk = high score). |
| **Formula** | `100 − jerk × 5000`; jerk = std of second derivative of wrist_y. |
| **Data source** | Wrist Y over dip→release window. |
| **Assumptions** | Savitzky–Golay smoothing applied; single continuous motion. |
| **Typical error** | ±10; sensitive to pose noise. |
| **Limitations** | Jerky motion from pose noise can reduce score. |
| **Validation status** | Plausibility-checked. |
| **Literature** | 75–99 = fluid; lower = jerky. |

---

## References

- Mitchell et al., "Model Cards for Model Reporting," 2018.
- Fonseca et al., "An analytical model to quantify the impact of the propagation of uncertainty in knee joint angle computation," PMC 9397457, 2022.
- Cabarkapa et al., "Biomechanical determinants of proficient 3-point shooters," Frontiers 2026.
- MediaPipe Pose Landmarker: https://ai.google.dev/edge/mediapipe/solutions/vision/pose_landmarker
