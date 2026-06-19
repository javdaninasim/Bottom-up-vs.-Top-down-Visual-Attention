<div align="center">

<h1 align="center">👁️ Bottom-Up vs. Top-Down Visual Attention</h1>
<h3 align="center">Computational Neuroscience Implementation | Visual Saliency & Eye-Tracking Analysis</h3>

[**GitHub**](https://github.com/javdaninasim/Bottom-up-vs.-Top-down-Visual-Attention) &nbsp; ⬩ &nbsp; [**License: MIT**](https://github.com/javdaninasim/Bottom-up-vs.-Top-down-Visual-Attention/blob/main/LICENSE) &nbsp; ⬩ &nbsp; [**University**](https://sharif.edu/)

</div>

---

### 🧠 Project Overview

```
Visual attention is a selective mechanism that prioritizes 
processing of behaviorally relevant information in complex scenes.

Two complementary systems:

┌─────────────────────┐          ┌─────────────────────┐
│   BOTTOM-UP (BU)    │          │    TOP-DOWN (TD)    │
├─────────────────────┤          ├─────────────────────┤
│ Stimulus-driven     │          │ Goal-driven         │
│ Automatic           │          │ Voluntary           │
│ Fast, reflexive     │          │ Slow, deliberate    │
│ Intrinsic features  │          │ Task context        │
│ (color, contrast)   │          │ Prior knowledge     │
│                     │          │                     │
│ Early visual cortex │          │ Prefrontal cortex   │
│ (V1, V2, MT)        │          │ Parietal cortex     │
└─────────────────────┘          └─────────────────────┘
         ↓                                 ↓
         └──────────── Priority Map ──────┘
                          ↓
                  Attention Allocation
                   (Scanpath Prediction)
```

---

### 📚 Scientific Foundation

This project implements classical and contemporary models from computational neuroscience:

**Key References:**
- **Itti, Koch & Niebur (1998)** — Seminal saliency model combining multiple visual features
- **Corbetta & Shulman (2002)** — Neural basis of top-down vs. bottom-up attention
- **Koch & Ullman (1985)** — Shifts in selective visual attention

---

### 📂 Repository Structure

```
Bottom-up-vs.-Top-down-Visual-Attention/
│
├── Bottom-Up/                          # Bottom-up saliency model
│   ├── 1.jpg, 3.jpg, 4.jpg            # Result visualizations
│   ├── Data/                           # Eyetracking data
│   ├── Stimuli/                        # Test stimuli
│   └── heatmaps(fixation)/             # Fixation heatmaps
│
├── Top-Down/                           # Top-down attention model
│   ├── 1.jpg, 2.jpg, 5.jpg            # Result visualizations
│   ├── Data/                           # Eyetracking data
│   ├── Stimuli/                        # Stimuli with task context
│   └── heatmaps/                       # Attention heatmaps
│
├── @Edf2Mat/                           # EDF to MATLAB converter
│   └── Eye tracker data conversion utilities
│
├── edfmex/                             # C MEX interface
│   └── Low-level eye-tracking I/O
│
├── MatFiles/                           # Processed MATLAB data
│   └── .mat files for analysis
│
├── html/                               # Documentation
│   └── Code documentation & guides
│
├── images/                             # Reference images
│   └── Example stimuli & results
│
├── Example.m                           # MATLAB usage example
├── report                              # Technical report
├── LICENSE                             # MIT License
└── README.md                           # This file
```

---

### 🔬 Module Descriptions

#### **1. Bottom-Up Saliency Model** 📍

**Implements the Itti-Koch-Niebur (1998) framework:**

```
Input Image
    ↓
┌───────────────────────────────┐
│  Multi-scale Feature Extraction │
├───────────────────────────────┤
│ • Color channels (RGB → RG/BY) │
│ • Intensity (luminance)         │
│ • Orientation (Gabor filters)   │
│ • (Optional: Motion, depth)     │
└───────────────────────────────┘
    ↓
┌───────────────────────────────┐
│  Center-Surround Operations   │
├───────────────────────────────┤
│ • Gaussian pyramids (6 levels) │
│ • Difference-of-Gaussians      │
│ • For each feature channel     │
└───────────────────────────────┘
    ↓
┌───────────────────────────────┐
│  Conspicuity Maps              │
├───────────────────────────────┤
│ • Normalize each feature stream│
│ • Across-scale combination     │
│ • Color, intensity, orientation│
└───────────────────────────────┘
    ↓
┌───────────────────────────────┐
│  Master Saliency Map           │
├───────────────────────────────┤
│ • Weighted sum of conspicuities│
│ • Continuous activation map    │
│ • Highlights likely fixations  │
└───────────────────────────────┘
    ↓
┌───────────────────────────────┐
│  Winner-Take-All (WTA)         │
├───────────────────────────────┤
│ • Local maxima detection       │
│ • Fixation point selection     │
│ • Inhibition of Return (IoR)   │
│ • Sequential scanpath          │
└───────────────────────────────┘
    ↓
Output: Saliency map + Scanpath
```

**Key Components:**
- **Multi-scale processing:** Captures features at different resolutions
- **Center-surround:** Detects local contrast/novelty
- **Feature normalization:** Prevents feature dominance
- **Inhibition of Return:** Prevents re-fixation at same location

---

#### **2. Top-Down Attention Model** 🎯

**Simulates goal-driven attentional modulation:**

```
Task Specification (e.g., "Find red circles")
    ↓
┌────────────────────────────────┐
│  Feature Template Generation    │
├────────────────────────────────┤
│ • Extract task-relevant features│
│ • Build feature detectors       │
│ • Color template, shape template│
│ • Weighted feature importance   │
└────────────────────────────────┘
    ↓
┌────────────────────────────────┐
│  Multiplicative Modulation      │
├────────────────────────────────┤
│ • Top-down map ⊗ Bottom-up map  │
│ • Enhances task-relevant areas  │
│ • Suppresses distractors        │
└────────────────────────────────┘
    ↓
┌────────────────────────────────┐
│  Contextual Priors              │
├────────────────────────────────┤
│ • Spatial bias (e.g., screen)   │
│ • Semantic context              │
│ • Learned associations          │
└────────────────────────────────┘
    ↓
┌────────────────────────────────┐
│  Priority Map (Combined)        │
├────────────────────────────────┤
│ α · BU_Saliency + β · TD_Bias   │
│ (Weighted combination)          │
└────────────────────────────────┘
    ↓
Output: Task-modulated attention map
```

**Key Components:**
- **Feature templates:** Task representation
- **Multiplicative interaction:** Bottom-up × Top-down
- **Contextual priors:** Scene/semantic knowledge
- **Priority map:** Final attention allocation

---

#### **3. Priority Map** 🎚️

**Unified attention control:**

```
Priority Map = α × Bottom-Up Saliency + β × Top-Down Bias

where:
- α, β ∈ [0, 1] control the balance between systems
- Different tasks may require different weightings
- Neural evidence: Flexible modulation in parietal cortex
```

**Use Cases:**
- **α = 1, β = 0:** Pure stimulus-driven (automatic reactions)
- **α = 0, β = 1:** Pure goal-driven (focused search)
- **α ≈ β:** Mixed mode (visual search in realistic conditions)

---

### 🛠️ Technologies

| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **Core Implementation** | C++ (C++17) | Performance-critical feature extraction |
| **Image Processing** | OpenCV | Image I/O, filters, pyramids |
| **MATLAB Interface** | MATLAB/MEX | EDF eye-tracking data conversion |
| **Build System** | CMake | Cross-platform compilation |
| **Eye Tracking** | EDF (SR Research) | ETG saccade/fixation data |
| **Visualization** | HTML | Interactive result browsing |

**Language Composition:**
- C++ (44.8%) — Core algorithms
- MATLAB (32.8%) — Data analysis & visualization
- C (19.1%) — MEX bindings, low-level I/O
- HTML (3.3%) — Documentation

---

### 📥 Build & Compilation

```bash
# Prerequisites
sudo apt-get install libopencv-dev cmake

# Clone repository
git clone https://github.com/javdaninasim/Bottom-up-vs.-Top-down-Visual-Attention.git
cd Bottom-up-vs.-Top-down-Visual-Attention

# Build
mkdir build && cd build
cmake ..
make -j$(nproc)

# Run
./visual_attention ../images/sample.jpg
```

**Output:**
- Saliency maps (bottom-up, top-down, combined)
- Scanpath visualization
- Fixation heatmaps
- Results saved to `Results/` directory

---

### 📊 MATLAB Usage

#### **EDF Data Conversion:**

```matlab
%% Load eye-tracking data (SR Research EyeLink)
edf = Edf2Mat('eyedata.edf');

%% Inspect data
disp(edf);                                    % Display metadata
plot(edf);                                    % Plot scanpath

%% Access gaze samples
gaze_x = edf.Samples.posX;                   % Horizontal gaze position
gaze_y = edf.Samples.posY;                   % Vertical gaze position
pupil_size = edf.Samples.pa;                 % Pupil area

%% Generate heatmap
heatmap = edf.heatmap();                     % Fixation density map
edf.plotHeatmap();                           % Interactive visualization
```

#### **Integration with Attention Models:**

```matlab
%% Compare predictions vs. human gaze
[bottom_up_map, top_down_map] = attention_model(image);
predicted_priority = combine_maps(bottom_up_map, top_down_map);

%% Calculate correlation with eye-tracking data
human_heatmap = edf.heatmap();
correlation = compare_distributions(predicted_priority, human_heatmap);
fprintf('Model-Human Correlation: %.3f\n', correlation);
```

---

### 🎨 Example Results

**Bottom-Up Module:**
- Detects high-contrast regions
- Responds to texture changes, color boundaries
- Automatic, no task knowledge required
- Often predicts early eye movements (~100-150ms)

**Top-Down Module:**
- Focuses on task-relevant features
- Suppresses visual distractors
- Requires explicit task specification
- Predicts deliberate search patterns (>200ms)

**Combined Priority Map:**
- Balances automatic and goal-driven influences
- More accurate than either system alone
- Captures realistic eye movement patterns
- Validates dual-process attention theory

---

### 📈 Scientific Insights

| Finding | Implication |
| :--- | :--- |
| **BU → TD latency difference** | ~50-100ms gap in fixation onsets |
| **Multiplicative interaction** | Top-down enhances/suppresses BU, not replaces |
| **Feature-dependent weighting** | Different α/β for color vs. motion tasks |
| **Contextual priors** | Scene gist strongly influences attention |
| **Individual differences** | Large variance in TD weighting across subjects |

---

### 📁 Data Organization

```
Bottom-Up/
├── Stimuli/          Visual stimuli (images, videos)
├── Data/             Raw eyetracking samples
└── heatmaps/         Computed fixation density maps

Top-Down/
├── Stimuli/          Task-specified visual stimuli
├── Data/             Search task eyetracking data
└── heatmaps/         Goal-directed fixation patterns

Results/
├── saliency_maps/    Bottom-up attention maps
├── task_maps/        Top-down attention maps
├── priority_maps/    Combined attention maps
└── comparisons/      Model vs. human predictions
```

---

### 🔍 Analysis Workflow

```
1. Load visual stimulus
   ↓
2. Compute bottom-up saliency
   ├─ Feature extraction
   ├─ Center-surround filtering
   └─ Saliency map generation
   ↓
3. Apply top-down modulation
   ├─ Template matching
   ├─ Feature weighting
   └─ Attention map modulation
   ↓
4. Generate priority map
   └─ Weighted combination
   ↓
5. Predict scanpath
   ├─ Winner-Take-All
   ├─ Inhibition of Return
   └─ Fixation sequence
   ↓
6. Compare with human eye-tracking
   ├─ Load real gaze data
   ├─ Compute correlation metrics
   └─ Visualize predictions vs. data
```

---

### 🎓 Learning Outcomes

- ✅ Understand **dual-process visual attention** (automatic vs. deliberate)
- ✅ Implement **saliency-based attention model** from neuroscience
- ✅ Apply **top-down modulation** for task-driven vision
- ✅ Analyze **eye-tracking data** from SR Research
- ✅ Compare **computational predictions** vs. human gaze patterns
- ✅ Develop **computer vision systems** grounded in neuroscience

---

### 📖 File Descriptions

| File | Purpose |
| :--- | :--- |
| `Example.m` | MATLAB tutorial for EDF conversion & heatmap visualization |
| `report` | Technical documentation of models & findings |
| `@Edf2Mat/` | MATLAB class for SR Research EDF file parsing |
| `edfmex/` | C MEX bindings for efficient EDF I/O |
| `MatFiles/` | Pre-processed .mat files for quick analysis |
| `Bottom-Up/` | Bottom-up saliency results & visualizations |
| `Top-Down/` | Top-down attention results & visualizations |
| `Results/` | Final comparison & combined analysis |

---

### 🎯 Applications

1. **Visual Search Tasks** — Predict where people look when searching for targets
2. **Advertising & UX Design** — Optimize layouts based on attention prediction
3. **Video Summarization** — Automatically crop important regions
4. **Driver Attention Monitoring** — Detect distraction in automotive contexts
5. **Prosthetics & BCI** — Eye-gaze interfaces for assistive technology
6. **Neuroscience Research** — Test theories of attention control

---

### ℹ️ Course Information

| Detail | Information |
| :--- | :--- |
| **Institution** | Sharif University of Technology, Dept. of Computer Engineering |
| **Topic** | Computational Neuroscience / Computer Vision |
| **Focus** | Visual attention mechanisms & eye-tracking |
| **Paradigm** | Bridging neuroscience and computational modeling |
<div align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=964B00&height=100&section=footer" width="100%"/>
</div>
