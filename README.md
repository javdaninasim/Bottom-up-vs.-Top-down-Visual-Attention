# Bottom-Up vs. Top-Down Visual Attention

> A C++ implementation and comparison of **stimulus-driven** (bottom-up) and **goal-driven** (top-down) models of visual attention, grounded in computational neuroscience.  
> **Author:** Nasim Javdani · [GitHub](https://github.com/javdaninasim) · [LinkedIn](https://linkedin.com/in/nasim-javdani-810a9932a)  
> **License:** MIT

---

## Overview

Visual attention in biological systems operates through two complementary mechanisms:

- **Bottom-up attention** is automatically driven by visually salient features in the scene — such as color contrast, orientation, motion, and intensity — without any prior task knowledge.
- **Top-down attention** is voluntarily guided by cognitive goals, task context, and prior knowledge, directing gaze toward task-relevant regions.

This project implements, simulates, and compares both mechanisms, drawing on seminal neuroscience models and applying them to real visual stimuli.

---

## Repository Structure

```
Bottom-up-vs.-Top-down-Visual-Attention/
├── src/
│   ├── bottom_up/        # Saliency map computation (feature conspicuity maps, WTA)
│   ├── top_down/         # Goal-driven modulation and feature templates
│   ├── priority_map/     # Integration of both signals
│   └── visualization/    # Heatmap and scanpath rendering
├── include/              # Header files
├── data/                 # Sample input images
├── results/              # Output attention maps and scanpaths
├── CMakeLists.txt
└── main.cpp
```

---

## Contents

### Bottom-Up Module
Implements saliency computation inspired by the **Itti-Koch-Niebur (1998)** model:
- Multi-scale feature extraction: color (R-G, B-Y), intensity, orientation
- Center-surround difference maps
- Conspicuity maps normalized and combined into a master **saliency map**
- **Winner-Take-All (WTA)** selection with Inhibition of Return (IoR) for sequential fixation simulation

### Top-Down Module
Simulates goal-driven attention via:
- Feature templates derived from task specification (e.g., "find red circles")
- Multiplicative modulation of the bottom-up saliency map
- Contextual priors (e.g., spatial bias toward screen center)

### Priority Map
- Linear combination of bottom-up saliency and top-down bias
- Controls attention allocation in the unified competitive map

### Visualization
- Attention heatmaps overlaid on input images
- Simulated scanpaths (sequence of fixation points)

---

## Background

The distinction between bottom-up and top-down attention is one of the central questions in systems neuroscience. Bottom-up signals originate in early visual areas (V1, V2) and are shaped by feature contrast. Top-down signals descend from prefrontal and parietal cortex (e.g., FEF, LIP) to modulate sensory processing. This project bridges the biological understanding with a working computational model.

---

## Technologies

| Tool | Purpose |
|---|---|
| C++ (C++17) | Core implementation |
| OpenCV | Image processing and visualization |
| CMake | Build system |

---

## Build & Run

```bash
mkdir build && cd build
cmake ..
make
./visual_attention ../data/sample_image.jpg
```

Output attention maps are saved to `results/`.

---

## References

- Itti, L., Koch, C., & Niebur, E. (1998). *A model of saliency-based visual attention for rapid scene analysis.* IEEE TPAMI.
- Corbetta, M. & Shulman, G.L. (2002). *Control of goal-directed and stimulus-driven attention in the brain.* Nature Reviews Neuroscience.
- Koch, C. & Ullman, S. (1985). *Shifts in selective visual attention.* Human Neurobiology.

---

## Course Info

- **Topic:** Computational Neuroscience / Computer Vision
- **Institution:** Sharif University of Technology, Department of Computer Engineering
