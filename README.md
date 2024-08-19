# Tokyo Olympics Data Engineering Project

## Project Overview

This project aims to analyze the Tokyo Olympics dataset using Databricks and Apache Spark. The data is stored in Azure Data Lake Storage and is processed using PySpark to derive insights such as top countries with the highest number of gold medals, and gender distribution across various disciplines.

## Architecture

The architecture of the project involves the following components:
- **Data Source**: CSV files from Kaggle.
- **Ingestion**: Azure Data Factory ingests the data into the `raw-data` folder in Azure Data Lake Storage Gen 2.
- **Transformation**: Databricks is used for data transformation.
- **Storage**: Transformed data is saved back into Azure Data Lake Storage under the `transformed-data` folder.
- **Querying**: The transformed data is loaded into Azure Synapse Analytics for querying.

![Architecture Diagram](https://github.com/lukejbyrne/tokyo-olympic-azure-data-engineering-project/blob/main/AzureDataEngineer_TokyoOlympics.png)

## Technologies Used
- **Databricks**: Cloud-based platform for data engineering and machine learning.
- **Apache Spark**: Open-source unified analytics engine for large-scale data processing.
- **Azure Data Lake Storage (ADLS)**: Scalable and secure data lake for high-performance analytics.
- **PySpark**: Python API for Spark, used for performing data processing tasks.
- **Terraform**: Infrastructure as Code (IaC) tool used for provisioning infrastructure.
- **Azure Data Factory**: Data integration service for creating data pipelines.

## Data Sources
Source: [Kaggle Tokyo Olympics Dataset](https://www.kaggle.com/datasets/arjunprasadsarkhel/2021-olympics-in-tokyo)

The data is stored in a container within Azure Data Lake Storage and includes the following datasets:
- **athletes.csv**: Information about the athletes.
- **coaches.csv**: Information about the coaches.
- **entriesgender.csv**: Gender distribution in different sports.
- **medals.csv**: Medal tally by country.
- **teams.csv**: Information about teams participating in different events.

## Configuration

To connect to Azure Data Lake Storage, configure the following settings in your Databricks environment:

```python
configs = {
    "fs.azure.account.auth.type": "OAuth",
    "fs.azure.account.oauth.provider.type": "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
    "fs.azure.account.oauth2.client.id": "<your-client-id>",
    "fs.azure.account.oauth2.client.secret": '<your-client-secret>',
    "fs.azure.account.oauth2.client.endpoint": "https://login.microsoftonline.com/<your-tenant-id>/oauth2/token"
}
```

## Data Mounting

Mount the Azure Data Lake Storage container in Databricks:

```python
dbutils.fs.mount(
    source = "abfss://tokyo-olympic-data@tokyoolympicdata.dfs.core.windows.net",
    mount_point = "/mnt/tokyoolympic",
    extra_configs = configs
)
```

## Data Ingestion

Data is ingested into the `raw-data` folder in Azure Data Lake Storage via Azure Data Factory. The following datasets are available for processing:
- `athletes.csv`
- `coaches.csv`
- `entriesgender.csv`
- `medals.csv`
- `teams.csv`

## Data Exploration and Processing

### 1. Reading the Data

Read the datasets from the raw-data directory:

```python
athletes = spark.read.format("csv").option("header","true").option("inferSchema","true").load("/mnt/tokyoolympic/raw-data/athletes.csv")
coaches = spark.read.format("csv").option("header","true").option("inferSchema","true").load("/mnt/tokyoolympic/raw-data/coaches.csv")
entriesgender = spark.read.format("csv").option("header","true").option("inferSchema","true").load("/mnt/tokyoolympic/raw-data/entriesgender.csv")
medals = spark.read.format("csv").option("header","true").option("inferSchema","true").load("/mnt/tokyoolympic/raw-data/medals.csv")
teams = spark.read.format("csv").option("header","true").option("inferSchema","true").load("/mnt/tokyoolympic/raw-data/teams.csv")
```

### 2. Data Schema

Explore the schema of the datasets:

```python
athletes.printSchema()
coaches.printSchema()
entriesgender.printSchema()
medals.printSchema()
teams.printSchema()
```

### 3. Data Transformation

Perform transformations on the datasets as required:

- **Casting Columns**: Convert `Female`, `Male`, and `Total` columns to IntegerType in `entriesgender` dataset.

```python
from pyspark.sql.functions import col
from pyspark.sql.types import IntegerType

entriesgender = entriesgender.withColumn("Female", col("Female").cast(IntegerType()))\
    .withColumn("Male", col("Male").cast(IntegerType()))\
    .withColumn("Total", col("Total").cast(IntegerType()))
```

- **Calculating Average Entries by Gender**: Compute the average number of male and female participants for each discipline.

```python
average_entries_by_gender = entriesgender.withColumn(
    'Avg_Female', entriesgender['Female'] / entriesgender['Total']
).withColumn(
    'Avg_Male', entriesgender['Male'] / entriesgender['Total']
)
```

- **Top Gold Medal Countries**: List the countries with the highest number of gold medals.

```python
top_gold_medal_countries = medals.orderBy("Gold", ascending=False).select("Team_Country","Gold").show()
```

### 4. Data Storage

After transformation, save the results in the `transformed-data` directory in Azure Data Lake Storage:

```python
athletes.repartition(1).write.mode("overwrite").option("header",'true').csv("/mnt/tokyoolympic/transformed-data/athletes")
coaches.repartition(1).write.mode("overwrite").option("header","true").csv("/mnt/tokyoolympic/transformed-data/coaches")
entriesgender.repartition(1).write.mode("overwrite").option("header","true").csv("/mnt/tokyoolympic/transformed-data/entriesgender")
medals.repartition(1).write.mode("overwrite").option("header","true").csv("/mnt/tokyoolympic/transformed-data/medals")
teams.repartition(1).write.mode("overwrite").option("header","true").csv("/mnt/tokyoolympic/transformed-data/teams")
```

### 5. Loading into Synapse

Load the transformed data into Azure Synapse Analytics for further querying. This step involves creating external tables in Synapse that reference the data stored in Azure Data Lake Storage.

## Results and Insights

- **Top Gold Medal Countries**: The United States leads the gold medal tally, followed closely by China and Japan.
- **Gender Distribution**: Athletics has the highest number of participants with a fairly balanced gender distribution. Artistic Swimming is female-dominated.

## Conclusion

This project demonstrates the use of Databricks, PySpark, and Azure Data Lake Storage for data engineering tasks, including data ingestion, transformation, and analysis. It showcases the capability to process and analyze large datasets effectively in the cloud.
