# Azure Data Engineering Pipeline

# Summary
Purpose: To learn the basics of Data Engineering

Data: https://www.kaggle.com/datasets/arjunprasadsarkhel/2021-olympics-in-tokyo

Design: 
- CSV from Kaggle
- Ingest via Data Factory to raw-data folder in Data Lake Gen 2
- Transform using Databricks 
- Output to transformed-data in same Data Lake
- Load into Synapse to run queries against new tables

I also created this infrastructure in Terraform for improved infrastructure management, given more time it would be sensible to add an AzureDevOps pipeline for the IaC, however this is not within the scope of the project.

Archtitecture:
![alt text](https://github.com/lukejbyrne/tokyo-olympic-azure-data-engineering-project/blob/main/AzureDataEngineer_TokyoOlympics.png)