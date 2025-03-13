# 🧬 Huntington Disease Prediction

This project applies **machine learning** to predict **Huntington’s Disease progression stages** using clinical, genetic, and functional biomarkers.

## 📂 Dataset
- Sourced from **[Kaggle](https://www.kaggle.com/datasets/rajmohnani12/huntington-disease-dataset/data)**
- Features include **genetic markers, motor symptoms, cognitive decline, and brain volume loss**.
- Target variable: **Disease_Stage** (Pre-Symptomatic, Early, Middle, Late).

## 🛠️ Preprocessing
✔ Dropped non-informative columns  
✔ Handled missing values (mode for categorical, median for numerical)  
✔ One-hot encoded categorical features & standardized numerical features  

## 🤖 Model
- **RandomForestClassifier** trained to predict disease stage.
- **Hyperparameter tuning** with `RandomizedSearchCV`.
- Evaluated using **cross-validation accuracy & feature importance**.

## 🚀 How to Run
1. Install dependencies:  
   ```bash
   pip install -r requirements.txt
   ```
2. Run the Jupyter Notebook:  
   ```bash
   jupyter notebook ML_Huntington_Disease.ipynb
   ```

## 📬 Contact  
Questions? Reach out on **GitHub** or **LinkedIn**!  
