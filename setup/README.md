# Stock Market Analysis | Setup Guide

## Prerequisites

Before you begin, ensure you have the following installed and set up:

- **Docker**
- **Docker Compose**
- **GCP Account and Project**
- **GCS Service Account** with **Storage Admin** and **BigQuery Admin** roles as well as a service account key *(Note: This is not best practice, but it simplifies the setup)*

  For more information on GCS Service Accounts see these resources:
  - [Create service accounts](https://cloud.google.com/iam/docs/service-accounts-create)
  - [Create and delete service account keys](https://cloud.google.com/iam/docs/keys-create-delete)

  
You will also need the following files:

- [Docker Compose File](/setup/docker-compose.yml)
- [Sync Flow](/setup/sync_flows_from_git.yml) for pulling flows from GitHub

---

## Step 1: Set Up Docker

1. Create a new folder for the project.
2. Place the Docker Compose file in the folder.
3. Run the following command to start the services:
   
    ```bash
    docker-compose up -d
    ```

---

## Step 2: Set Up Kestra

1. Open Kestra in your browser at [http://localhost:8080/](http://localhost:8080/).
2. Create a new flow using the [Sync Flow](/setup/sync_flows_from_git.yml).
3. Execute the flow to pull project flows from GitHub.

### Configure GCP Credentials

1. In Kestra, go to **Namespaces** → `stockmarketanalysis`.
2. Create a new **Key-Value** with the following details:
    - **Key:** `GCP_CREDS`
    - **Type:** `STRING`
    - **Value:** Paste the contents of your GCP service account key JSON file.

---

## Step 3: Configure GCP Infrastructure

1. Go to the **Create_GCP_KVs** flow in the `stockmarketanalysis` namespace.
2. Open the editor and update the following values with your details:
    - `gcp_project_id`
    - `gcp_location`
    - `bucket-name`
3. Save the changes and execute the flow.

### What Happens Next
- This will create four Key-Value pairs for streamlined access to GCS and BigQuery.
- After the successful execution of **Create_GCP_KVs**, the **GCP_Infrastructure** flow will automatically run to create a storage bucket and a BigQuery dataset.
- Once the infrastructure is created, the **Initialization** flow will trigger to:
    - Download historical price data, quarterly balance sheets, and stock symbol information.
    - Upload the data to the GCS bucket.
    - Create external tables in the BigQuery dataset.
    - Sync dbt project files from GitHub and build the dbt project.


---

## Step 4: Backfill Missing Data

- The initial data ends on **March 14, 2025**. To get the latest data, backfill using the **Weekly_Price_Data** flow using **March 21, 2025** or earlier as the start date.
- The **Weekly_Price_Data** flow is scheduled to run every **Saturday at 8 AM UTC**.
- It fetches the latest data from the GitHub repository, which is updated every Saturday at **7 AM UTC**.

You are now all set to analyze stock market data using the provided dashboard!

